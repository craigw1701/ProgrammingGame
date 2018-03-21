int ourLevelNumber = 0;

ArrayList<String> ourLevelStack = new ArrayList<String>();

class Level extends GameState
{
  Level(String aLevelName, String aPreviousLevel)
  {    
    super(aLevelName);
    ourLevelNumber++;
    myLevelNumber = ourLevelNumber;
    myPreviousLevel = aPreviousLevel;
    if(myPreviousLevel != null)
      ourLevelStack.add(myPreviousLevel);
  }
  
  String GetInstructionName(int anIndex)
  {
    return myName + "_Instruction_" + anIndex;
  }
  
  boolean OnInit()
  {
    ConfigData initData = myLevelConfig.GetChild("Init");
    
    if(myLevelConfig.HasChild("Timeline"))
      myTimeline = myLevelConfig.GetChild("Timeline");
    else
      myTimeline = new ConfigData(); 
      
     if(myLevelConfig.HasChild("Code"))
        myCode = myLevelConfig.GetChild("Code");
        
     if(myLevelConfig.HasChild("Instructions"))
     {
       myInstructions = myLevelConfig.GetChild("Instructions");
         
       while(true)
       {
         if(!myInstructions.HasChild(str(myNumberOfInstructions)))
           break;
         
         Actor instruction = new Actor(GetInstructionName(myNumberOfInstructions));
         instruction.myDrawLayer = 4;
         instruction.Init(myInstructions.GetChild(str(myNumberOfInstructions)));
         AddToLevel(instruction);
         myNumberOfInstructions++;
       }
       if(myNumberOfInstructions > 0)
         ChangeInstructions(0);
    }
    LogLn("myNumberOfInstructions: " + myNumberOfInstructions + " " + myName);
    boolean result = super.OnInit();
   
    return result;
  }  
  
  void OnSetFromConfig(ConfigData aConfig) 
  {
    if(aConfig.HasData("OnStart"))
    {
      FireTrigger(aConfig.GetData("OnStart"));
    }
  }
  
  boolean OnUpdate(float aDeltaTime)   
  {
    float lastFrameTime = myTimeActive - aDeltaTime;
    if(myTimeline != null)
    {
      HashMap<String, ConfigData> temp = new HashMap<String, ConfigData>();
      //Iterator<Map.Entry<String, ConfigData> > iter = myTimeline.myChildren.keySet().iterator();
      temp.putAll(myTimeline.myChildren);
      for(String s : temp.keySet())
      {
        float time = Float.parseFloat(s);
        if(/*time > lastFrameTime &&*/time < myTimeActive)
        {
          ConfigData data = myTimeline.myChildren.get(s);
          if(data.HasData("TriggerName"))
          {
            Trigger(data.GetData("TriggerName"));
          }
          else
          {
            Trigger(data);
          }
          myTimeline.myChildren.remove(s);
          
         myTimeline.DebugPrint(0);
        }
      }
    }    
    
    return super.OnUpdate(aDeltaTime);
  }
  
  void ChangeInstructions(int anInstruction)
  {
    if(myCurrentInstruction == anInstruction)
      return;
      
      if(myCurrentInstruction >= 0)
        myActors.get(GetInstructionName(myCurrentInstruction)).SetVisible(false);
        
      myCurrentInstruction = anInstruction;
      myActors.get(GetInstructionName(myCurrentInstruction)).StartFadeIn(2);
      
      if(myActors.containsKey("PreviousButton")) 
        myActors.get("PreviousButton").myIsDisabled = myCurrentInstruction == 0;
      if(myActors.containsKey("NextButton"))
        myActors.get("NextButton").myIsDisabled = myCurrentInstruction >= myNumberOfInstructions - 1;
  }
  
  void AddDelayedTrigger(ConfigData aConfig)
  {
    float delay = Float.parseFloat(aConfig.GetData("Delay"));
    float triggerTime = myTimeActive + delay;
    myTimeline.myChildren.put(str(triggerTime), aConfig.GetChild("Trigger"));
  }
  
  void AddDelayedTrigger(float aDelay, ConfigData aConfig)
  {
    float triggerTime = myTimeActive + aDelay;
    myTimeline.myChildren.put(str(triggerTime), aConfig);
  }
  
  boolean OnTrigger(ConfigData aConfig)
  {
    if(aConfig.HasData("HideInstructions"))
    {      
      if(myCurrentInstruction >= 0)
        myActors.get(GetInstructionName(myCurrentInstruction)).myIsVisible = false;
        
      if(myActors.containsKey("PreviousButton")) 
        myActors.get("PreviousButton").SetVisible(false);
      
      if(myActors.containsKey("NextButton"))
        myActors.get("NextButton").SetVisible(false);
    }
    return false;
  }
  
  boolean OnTrigger(String aTrigger)
  {
    LogLn("Trigger: " + aTrigger);
    if(aTrigger.equals("TRIGGER_LEVEL_BACK"))
    {
      String previousLevel = ourLevelStack.get(ourLevelStack.size()-1);
      SetNextLevel(previousLevel, null);  
      ourLevelStack.remove(previousLevel);
      myIsActive = false;
      return true;
    }
    else if(aTrigger.equals("TRIGGER_NEXT_INSTRUCTION"))
    {
      if(myCurrentInstruction < myNumberOfInstructions - 1)
      {
        ChangeInstructions(myCurrentInstruction + 1);        
      }
      return true;
    }
    else if(aTrigger.equals("TRIGGER_PREVIOUS_INSTRUCTION"))
    {
      if(myCurrentInstruction > 0)
      {
        ChangeInstructions(myCurrentInstruction - 1);
      }
      return true;
    }
    else if(aTrigger.equals("TRIGGER_RELOAD_LEVEL"))
    {
      ReloadLevel();
      return true;
    }
    
    return false;
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
       SetNextLevel(myLevelConfig.GetChild("Init").GetData("NextLevel"), null);
       return true;
     }    
     else if(aKey == 'r' || aKey == 'R')
     {
       ReloadLevel();
       return true;
     }      
     
     for(Pawn actor : myActors.values())
     {
       if(actor.ProcessInput(aKey))
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
    
  int myCurrentInstruction = -1;
  int myNumberOfInstructions = 0;
  int myLevelNumber;
  String myPreviousLevel;
  ConfigData myTimeline;
  ConfigData myCode;
  ConfigData myInstructions;  
};