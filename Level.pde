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
      myBackground =  new Texture(background, true);
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
  
  boolean OnTrigger(String aTrigger)
  {
    LogLn("Trigger: " + aTrigger);
    boolean hasHandled = false;
    
    if(myTriggers != null)
    {
      if(myTriggers.HasChild(aTrigger))
      {
        ConfigData trigger = myTriggers.GetChild(aTrigger);
        if(trigger.HasChild("Characters"))
        {
          ConfigData characters = trigger.GetChild("Characters");
          for(String actorName : characters.GetChildKeys())
          {
            Actor actor = myActors.get(actorName);
            hasHandled |= actor.Trigger(trigger.GetChild(actorName));
          }
        }
        if(trigger.HasData("SetLevel"))
        {
          SetNextLevel(trigger.GetData("SetLevel"));      
        }
        if(trigger.HasData("PushLevel"))
        {
          PushLevel(trigger.GetData("PushLevel"));
        }
      }
    }
    
    if(hasHandled == false)
    {
      if(aTrigger.equals("TRIGGER_LEVEL_BACK"))
      {
        myIsActive = false;
        return true;
      }
    }
    
    return hasHandled;
  }
  
  void OnDraw()
  {
    if(myBackground != null)
      myBackground.DrawBackground();    
  
    for(Actor actor : myActors.values())
    {
      actor.Draw(actor == myHoveredActor);
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
      Texture instructions = new Texture(myInstructions.GetData("0"), false);
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
      for(Actor actor : myActors.values())
      {
        actor.DebugDraw(actor == myHoveredActor);
      }
    }
  }
  
  void SetNextLevel(String aLevelName)
  {
    gsManager.AddToQueue(new Level(aLevelName));
    myIsActive = false;
  }
  
  void PushLevel(String aLevelName)
  {
    gsManager.AddState(new Level(aLevelName));
  }
  
  boolean ProcessInput(char aKey)
  {
    //println("key: " + aKey);
     if(aKey == ESC)
     {
       gsManager.AddState(new PauseMenu());
       return true;
     }
     else if(aKey == 'f' || aKey == 'F')
     {
       SetNextLevel(myLevelConfig.GetChild("Init").GetData("NextLevel"));
       return true;
     }
    
    if(ourMouseInfo)
    {      
      if(myHoveredActor != null)
      {
        if(aKey == CODED && keyCode == CONTROL && mousePressed && (mouseButton == LEFT))
        {
          myHoveredActor.myPosition.x = mouseX;
          myHoveredActor.myPosition.y = mouseY;
          LogLn(myHoveredActor.myName + ": newPos(" + float(mouseX)/float(width) + ", " + float(mouseY)/float(height) + ")");
        }
        else
        {
          PVector sizeChange = new PVector(0,0);
          if(aKey == '+')
            sizeChange.x = 1;
          else if(aKey == '-')
            sizeChange.x = -1;
          else if(aKey == '1')
            sizeChange.y = 1;
          else if(aKey == '2')
            sizeChange.y = -1;
            
          if(sizeChange.magSq() != 0)
          {
             myHoveredActor.mySize.x += sizeChange.x;
             myHoveredActor.mySize.y += sizeChange.y;
              LogLn(myHoveredActor.myName + ": newScale(" + myHoveredActor.mySize.x/float(width) + ", " + myHoveredActor.mySize.y/float(height) + ")");
          }
        }
      }
    }
     return false;
  }
  
  boolean OnClicked()
  {
    if(myHoveredActor != null)
    {
      return myHoveredActor.OnClick();
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