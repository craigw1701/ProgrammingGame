import java.util.List;

enum GameStateState
{
  INIT,
  STARTING,
  RUNNING,
  STOPPING,
  STOPPED
};
  
class GameState
{
  GameState(String aName)
  {
    myName = aName;
    SetState(GameStateState.INIT);
    myDrawWhileTransitioning = true;
    myFadeColor = color(0, 0, 0, 255);
    myFadePercent = 1;
    myFadeInTime = 1;
    myFadeOutTime = 1;
    myTimeActive = 0;
    myIsActive = true;
  }
  
  boolean Init() 
  { 
    if(myTimeActive > 0)
      return true;
      
    LogLn("Init: " + myName);     
    myLevelConfig = new LevelConfig(myName);    
    ConfigData initData = myLevelConfig.GetChild("Init");    
    myTextToDisplay = new LocText(initData.GetData("Text"));
    
    if(initData.HasData("Background"))
    {
      String background = initData.GetData("Background");
      if(background != "")
        myBackground =  new Texture("Backgrounds/" + background, true);
    }
    if(initData.HasChild("Characters"))
    {
      ConfigData characters = initData.GetChild("Characters");
      
      for(String theKey : characters.GetChildKeys())
      {
        Pawn actor = CreatePawn(theKey, characters.GetChild(theKey));
        actor.Init(characters.GetChild(theKey));
        myActors.put(theKey, actor);
      }
    }
    
    if(initData.HasData("Music"))
    {
      ourSoundManager.PlayMusic(initData.GetData("Music"));
    }
    
    if(initData.HasData("HideCursor"))
    {
      myShowCursor = !initData.GetData("HideCursor").equals("true");
    }
    
    if(myLevelConfig.HasChild("Triggers"))
    myTriggers = myLevelConfig.GetChild("Triggers");
    
    
    return OnInit(); 
  }
  
  boolean OnInit() 
  {    
    LogLn("OnInit: " + myName + ": " + myTimeActive + ":" + myTimeInState);
    return myTimeInState > 0; 
  }
  
  boolean OnStart(float aDeltaTime)
  { 
    //LogLn("Start: " + myName + ", active: " + myTimeActive + ", inState: " + myTimeInState );
    myFadePercent = 1-(myTimeInState / myFadeInTime);
    //println("Start: " + myName + " - " + myFadePercent);
    return myTimeInState > myFadeInTime; 
  }
    
  boolean OnEnd(float aDeltaTime) 
  { 
    myFadePercent = (myTimeInState / myFadeOutTime);
    //println("End: " + myName + " - " + myFadePercent);
    return myTimeInState > myFadeOutTime; 
  }
  
  boolean OnUpdate(float aDeltaTime) 
  {
    for(Pawn actor : myActors.values())
    {
      actor.Update(aDeltaTime);
    }
       
    if(myState == GameStateState.RUNNING)
    {
      myHoveredActor = null;
      for(Pawn actor : myActors.values())
      {
        if(actor.myIsSelectable && actor.IsMouseOver())
        {
          myHoveredActor = actor;
          break;
        }
      }
    }
    return !myIsActive; 
  }
  
  boolean ProcessInput(char aKey) { return false; }

  void SetNextState(GameStateState aState)
  {
    myNextState = aState;
  }
  
  void SetState(GameStateState aState)
  {
    LogLn("State: " + aState + ":" + myName + ":" + myTimeActive);
    
    if(aState == GameStateState.STOPPED)
    {
      for(String name : myControlNames)
      {
        cp5.remove(name); //<>//
      }
      myControlNames.clear();
    }
   
    myTimeInState = 0;
    myState = aState;
    myNextState = aState;
  }
  
  void Draw()
  {
    if(myBackground != null)
      myBackground.DrawBackground();  
      
    for(Pawn actor : myActors.values())
    {
      pushStyle();
      actor.Draw(actor == myHoveredActor);
      popStyle();
    }
    
    textAlign(CENTER, CENTER);
    cp5.draw();
      
    OnDraw();
    DebugDraw();
  }  
    
  void DebugDraw()
  {    
    if(ourMouseInfo)
    {
      pushStyle();
      for(Pawn actor : myActors.values())
      {
        actor.DebugDraw(actor == myHoveredActor);
      }
      
      textAlign(LEFT, BOTTOM);
      text("Hovered Actor: " + ((myHoveredActor == null) ? "null" : myHoveredActor.myName), 0, height);
      
      popStyle();
    }
  }
  
  boolean Update(float aDeltaTime)
  {    
    if(myState != myNextState)
      SetState(myNextState);
      
    if(myState == GameStateState.STOPPED)
    {
      return true;
    }
    
    if(myState == GameStateState.STARTING)
    {
      if(OnStart(aDeltaTime))
        SetNextState(GameStateState.RUNNING);
    }
     //<>//
    if(myState == GameStateState.INIT)
    {
      if(Init())
        SetNextState(GameStateState.STARTING);
    }
    
    
    if(myState == GameStateState.RUNNING)
    {
      if(OnUpdate(aDeltaTime))
        SetNextState(GameStateState.STOPPING);
    }
    
    if(myState == GameStateState.STOPPING)
    {
       if(OnEnd(aDeltaTime))
         SetNextState(GameStateState.STOPPED);
    }
    
    myTimeInState += aDeltaTime;
    myTimeActive += aDeltaTime;
    
    return false;
  }
  
  void OnDraw()
  {
    Fade(GetFadePercent(), myFadeColor);
    ourSoundManager.SetMusicVolume(1 - GetFadePercent());
  }
  
  void AddDelayedTrigger(ConfigData aConfig)
  {
    Error("AddDelayedTrigger1");
  }
  
  void AddDelayedTrigger(float aDelay, ConfigData aConfig)
  {
    Error("AddDelayedTrigger2");
  }
  
  boolean Trigger(ConfigData aConfig)
  {
    boolean hasHandled = false;
    if(aConfig.HasData("Delay"))
    {
      AddDelayedTrigger(aConfig);
      hasHandled = true;
    }
    
    if(aConfig.HasChild("Timeline"))
    {
      ConfigData timeline = aConfig.GetChild("Timeline");
      for(String theKey : timeline.GetChildKeys())
      {
        float delay = Float.parseFloat(theKey);
        AddDelayedTrigger(delay, timeline.GetChild(theKey));
      }
    }
     
    if(aConfig.HasChild("Characters"))
    {
      ConfigData characters = aConfig.GetChild("Characters");
      for(String actorName : characters.GetChildKeys())
      {
        Pawn actor = myActors.get(actorName);
        hasHandled |= actor.Trigger(characters.GetChild(actorName));
      }
    }
    if(aConfig.HasData("SetLevel"))
    {
      SetNextLevel(aConfig.GetData("SetLevel"), myName);   
      hasHandled = true;
    }
    if(aConfig.HasData("PushLevel"))
    {
      PushLevel(aConfig.GetData("PushLevel"));
      hasHandled = true;
    }
    if(aConfig.HasData("SetLanguage"))
    {
      locManager.SetLanguage(aConfig.GetData("SetLanguage"));
      hasHandled = true;
    }
    if(aConfig.HasData("Name"))
    {
      Trigger(aConfig.GetData("Name"));
      hasHandled = true;
    }
    
    return OnTrigger(aConfig) || hasHandled;
  }
  
  boolean Trigger(String aTrigger)
  {    
    if(myTriggers != null)
    {
      if(myTriggers.HasChild(aTrigger))
      {
        if(Trigger(myTriggers.GetChild(aTrigger)))
          return true;        
      }
    }    
      
    if(OnTrigger(aTrigger))
      return true;
      
    for(Pawn actor : myActors.values())
    {
      if(actor.OnTrigger(aTrigger))
        return true;
    }
    return false;
  }
  
  boolean OnTrigger(String aTrigger) { return false; }
  boolean OnTrigger(ConfigData aConfig) { return false; }
  
  boolean OnClicked()
  {    
    if(myHoveredActor != null)
    {
      return myHoveredActor.Clicked();
    }
    return false;
  }
  
  void SetNextLevel(String aLevelName, String aPreviousLevel)
  {
    gsManager.AddToQueue(new Level(aLevelName, aPreviousLevel));
    myIsActive = false;
  }
  
  void PushLevel(String aLevelName)
  {
    gsManager.AddState(new Level(aLevelName, null));
  }
  
  float GetFadePercent() { return myFadePercent; }

  Textfield AddTextField(String aName)
  {
    Textfield textField = cp5.addTextfield(aName, 100,100, 64, 32).setAutoClear(false).setColorBackground(InputBackgroundColor).setColorForeground(InputForgroundColor).setColorActive(InputActiveColor);
    textField.align(CENTER, CENTER, CENTER, CENTER);
    Label c = textField.getCaptionLabel();
    c.hide();
    myControlNames.add(aName);
    return textField;
  }
  
  Textlabel AddTextLabel(String aName)
  {
    Textlabel textLabel = cp5.addTextlabel(aName, "", 32, 32).setColor(color(255,255,255,255)).setFont(font);
    myControlNames.add(aName);
    return textLabel;
  }
  
  // Member Variables
  GameStateState myState;
  GameStateState myNextState; 
  LevelConfig myLevelConfig;  
  ConfigData myTriggers;
  Texture myBackground = null;
  Pawn myHoveredActor = null;
  HashMap<String, Pawn> myActors = new HashMap<String, Pawn>();  
  ArrayList<String> myControlNames = new ArrayList<String>();
  LocText myTextToDisplay;
  
  String myName;
  float myFadeInTime;
  float myFadeOutTime;
  color myFadeColor;

  boolean myShowCursor = true;
  boolean myIsActive;
  float myFadePercent;
  float myTimeInState;
  float myTimeActive;
  boolean myDrawWhileTransitioning;
};