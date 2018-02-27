int ourLevelNumber = 0;

class Level extends GameState
{
  Level(String aLevelName)
  {    
    super(aLevelName); 
    ourLevelNumber++;
    myLevelNumber = ourLevelNumber;
    myBackground = null;
    Init();
  }
  
  boolean Init()
  {
    myLevelConfig = new LevelConfig(myName);
    ConfigData initData = myLevelConfig.GetChild("Init");
    String background = initData.GetData("Background");
    if(background != "")
      myBackground =  new Texture(background);
    myTextToDisplay = new LocText(initData.GetData("Text"));
    
    if(initData.HasChild("Characters"))
    {
      ConfigData characters = initData.GetChild("Characters");
      
      for(String theKey : characters.GetChildKeys())
      {
        Actor actor = new Actor(theKey);
        actor.Init(characters.GetChild(theKey));
        myActors.put(theKey, actor);
      }
    }
    
    if(myLevelConfig.HasChild("Triggers"))
      myTriggers = myLevelConfig.GetChild("Triggers");
    
    if(myLevelConfig.HasChild("Timeline"))
      myTimeline = myLevelConfig.GetChild("Timeline");
      
     if(myLevelConfig.HasChild("Code"))
        myCode = myLevelConfig.GetChild("Code");
        
     if(myLevelConfig.HasChild("Instructions"))
       myInstructions = myLevelConfig.GetChild("Instructions");
     
     myHoveredActor = null;
     
    return true;
  }  
  
  boolean OnUpdate(float aDeltaTime)   
  {
    float lastFrameTime = myTimeActive - aDeltaTime;
    if(myTimeline != null)
    {
      for(String s : myTimeline.myData.keySet())
      {
        float time = Float.parseFloat(s);
        if(time > lastFrameTime && time < myTimeActive)
        {
          Trigger(myTimeline.myData.get(s));
        }
      }
    }
    
    for(Actor actor : myActors.values())
    {
      actor.Update(aDeltaTime);
    }
       
    myHoveredActor = null;
    for(Actor actor : myActors.values())
    {
      if(actor.IsMouseOver())
      {
        myHoveredActor = actor;
        break;
      }
    }
    
    return super.OnUpdate(aDeltaTime);
  }
  
  void Trigger(String aTrigger)
  {
    ConfigData trigger = myTriggers.GetChild(aTrigger);
    
    for(String actorName : trigger.GetChildKeys())
    {
      Actor actor = myActors.get(actorName);
      actor.Trigger(trigger.GetChild(actorName));
    }
  }
  
  void OnDraw()
  {
    if(myBackground != null)
      myBackground.DrawBackground();
    
  
    for(Actor actor : myActors.values())
    {
      actor.Draw();
    }
    
    if(false && myCode != null)
    {
      fill(0,0,0); 
      textAlign(LEFT, TOP);
      String code = myCode.GetData("Text");
      code = code.replace("<br>", "\n");
      println(code);
      PVector pos = GetVector2FromLine(myCode.GetData("Position"));
      text(code, pos.x, pos.y);
    }
    
    /*tint(0, 153, 204);
    Texture t = new Texture("mothsinlivingroom.png");
    t.DrawFullScreen();
    noTint();*/
    
    if(myInstructions != null)
    {
      Texture instructions = new Texture(myInstructions.GetData("0"));
      instructions.DrawFullScreen();      
    }
    
    textAlign(CENTER, TOP);
    //ellipse(width / 2 + sin(myTimeActive) * 300, height / 2 + cos(myTimeActive) * 200, 20,20);
    myTextToDisplay.DrawText(width/2, 0);
    
    DebugDraw();
  }
  
  void DebugDraw()
  {    
    if(ourMouseInfo)
    {      
      if(myHoveredActor != null && keyCode == CONTROL && mousePressed && (mouseButton == LEFT))
      {
        myHoveredActor.myPosition.x = mouseX;
        myHoveredActor.myPosition.y = mouseY;
        println(myHoveredActor.myName + ": newPos(" + float(mouseX)/float(width) + ", " + float(mouseY)/float(height) + ")");
      }
      
      for(Actor actor : myActors.values())
      {
        actor.DebugDraw();
      }
    }
  }
  
  boolean ProcessInput(char aKey)
  {
    println("key: " + aKey);
     if(aKey == ESC)
     {
       gsManager.AddState(new PauseMenu());
       return true;
     }
     else if(aKey == 'f' || aKey == 'F')
     {
       String nextLevel = myLevelConfig.GetChild("Init").GetData("NextLevel"); //<>//
       gsManager.AddToQueue(new Level(nextLevel));
       myIsActive = false;
       return true;
     }
     return false;
  }
  
  int myLevelNumber;
  LocText myTextToDisplay;
  Texture myBackground;
  LevelConfig myLevelConfig;
  ConfigData myTimeline;
  ConfigData myTriggers;
  ConfigData myCode;
  ConfigData myInstructions;
  Actor myHoveredActor;
  HashMap<String, Actor> myActors = new HashMap<String, Actor>();
};