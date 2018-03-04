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
    LogLn("Init: " + myName);     
    myLevelConfig = new LevelConfig(myName);    
    ConfigData initData = myLevelConfig.GetChild("Init");    
    myTextToDisplay = new LocText(initData.GetData("Text"));
    
    if(initData.HasData("Background"))
    {
      String background = initData.GetData("Background");
      if(background != "")
        myBackground =  new Texture(background, true);
    }
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
    
    return OnInit(); 
  }
  
  boolean OnInit() 
  {    
    LogLn("OnInit: " + myName + ": " + myTimeActive + ":" + myTimeInState);
    return myTimeInState > 0; 
  }
  
  boolean OnStart(float aDeltaTime)
  { 
    LogLn("Start: " + myName + ", active: " + myTimeActive + ", inState: " + myTimeInState );
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
    for(Actor actor : myActors.values())
    {
      actor.Update(aDeltaTime);
    }
       
    if(myState == GameStateState.RUNNING)
    {
      myHoveredActor = null;
      for(Actor actor : myActors.values())
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
    myTimeInState = 0;
    myState = aState;
    myNextState = aState;
  }

  void Draw()
  {
    if(myBackground != null)
      myBackground.DrawBackground();  
      
    for(Actor actor : myActors.values())
    {
      pushStyle();
      actor.Draw(actor == myHoveredActor);
      popStyle();
    }
      
    OnDraw();
    DebugDraw();
  }  
    
  void DebugDraw()
  {    
    if(ourMouseInfo)
    {
      pushStyle();
      for(Actor actor : myActors.values())
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
  }
  
  boolean Trigger(String aTrigger)
  {    
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
          hasHandled = true;
        }
        if(trigger.HasData("PushLevel"))
        {
          PushLevel(trigger.GetData("PushLevel"));
          hasHandled = true;
        }
        if(trigger.HasData("SetLanguage"))
        {
          locManager.SetLanguage(trigger.GetData("SetLanguage"));
        }
      }
    }
    
    if(hasHandled)
      return true;
      
    return OnTrigger(aTrigger);
  }
  
  boolean OnTrigger(String aTrigger)
  {
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
  
  void SetNextLevel(String aLevelName)
  {
    gsManager.AddToQueue(new Level(aLevelName, myName));
    myIsActive = false;
  }
  
  void PushLevel(String aLevelName)
  {
    gsManager.AddState(new Level(aLevelName, null));
  }
  
  float GetFadePercent() { return myFadePercent; }
  
  // Member Variables
  GameStateState myState;
  GameStateState myNextState; 
  LevelConfig myLevelConfig;  
  ConfigData myTriggers;
  Texture myBackground = null;
  Actor myHoveredActor = null;
  HashMap<String, Actor> myActors = new HashMap<String, Actor>();
  LocText myTextToDisplay;
  
  String myName;
  float myFadeInTime;
  float myFadeOutTime;
  color myFadeColor;

  boolean myIsActive;
  float myFadePercent;
  float myTimeInState;
  float myTimeActive;
  boolean myDrawWhileTransitioning;
};