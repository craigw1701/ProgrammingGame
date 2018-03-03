int ourLevelNumber = 0;

class Level extends GameState
{
  Level(String aLevelName, String aPreviousLevel)
  {    
    super(aLevelName); 
    ourLevelNumber++;
    myLevelNumber = ourLevelNumber;
    myPreviousLevel = aPreviousLevel;
    Init();
  }
  
  boolean Init()
  {
    ConfigData initData = myLevelConfig.GetChild("Init");
    
    if(myLevelConfig.HasChild("Timeline"))
      myTimeline = myLevelConfig.GetChild("Timeline");
      
     if(myLevelConfig.HasChild("Code"))
        myCode = myLevelConfig.GetChild("Code");
        
     if(myLevelConfig.HasChild("Instructions"))
       myInstructions = myLevelConfig.GetChild("Instructions");
         
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
    
    return super.OnUpdate(aDeltaTime);
  }
  
  boolean OnTrigger(String aTrigger)
  {
    LogLn("Trigger: " + aTrigger);
    boolean hasHandled = false;
    
    if(hasHandled == false)
    {
      if(aTrigger.equals("TRIGGER_LEVEL_BACK"))
      {
        if(myPreviousLevel != null)
        { 
          SetNextLevel(myPreviousLevel);  
        }
        myIsActive = false;
        return true;
      }
    }
    
    return hasHandled;
  }
  
  void OnDraw()
  {      
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
      Texture instructions = new Texture(myInstructions.GetData("0"), true);
      instructions.DrawFullScreen();      
    }
    
    if(myState != GameStateState.RUNNING)
    {
      super.OnDraw();
    }
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
    return super.OnClicked();
  }
  
  int myLevelNumber;
  String myPreviousLevel;
  ConfigData myTimeline;
  ConfigData myCode;
  ConfigData myInstructions;
};