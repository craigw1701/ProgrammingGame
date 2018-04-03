import java.util.List;
import processing.video.*;

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
    
    myLevelConfig = new LevelConfig(myName);  
    
    ConfigData initData = myLevelConfig.GetChild("Init");
    if(initData.HasData("Music"))
    {
      myBackgroundMusic = initData.GetData("Music");
    }
    if(initData.HasData("NoMusic"))
    {
      ourSoundManager.StopMusic();
      myHasNoMusic = true;
    }
    
    ourSaveGame.PrintFlags();
  }
  
  void UpdateFlags(ConfigData aConfig)
  {
    if(aConfig.HasChild("UpdateFlags"))
    {
      ConfigData ifFlags = aConfig.GetChild("UpdateFlags");
      for(String theKey : ifFlags.GetChildKeys())
      {
        ConfigData action = ifFlags.GetChild(theKey); 
        if(CheckFlags(action))
        {
          ourSaveGame.UpdateFlags(action.GetChild("Flags"));          
        }
      }
    }
  }
  
  void AddToLevel(Pawn aPawn)
  {
      myActors.put(aPawn.myName, aPawn);
      myActorsInDrawOrder.add(aPawn);
      Collections.sort(myActorsInDrawOrder);
//      for(Pawn p : myActorsInDrawOrder)
//      {
//        println(p.myName + " - " + p.myDrawLayer);
//      }
//      println("__");
  }
  
  boolean Init() 
  { 
    if(myTimeActive > 0) //<>//
      return true;
      
    LogLn("Init: " + myName);       
    ConfigData initData = myLevelConfig.GetChild("Init"); 
    UpdateFlags(initData);    
    
    myTextToDisplay = new LocText(initData.GetData("Text"));
    
    if(initData.HasData("Background"))
    { //<>//
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
        actor.Init(characters.GetChild(theKey)); //<>//
        AddToLevel(actor);
      }
    }
    
    if(myBackgroundMusic != null)
      ourSoundManager.PlayMusic(myBackgroundMusic);
    
    if(initData.HasData("HideCursor"))
    {
      myShowCursor = !initData.GetData("HideCursor").equals("true");
    }
    
    if(myLevelConfig.HasChild("Triggers"))
      myTriggers = myLevelConfig.GetChild("Triggers");    
        
    boolean hasInit = OnInit();    
    SetFromConfig(initData);
    
    if(initData.HasChild("IfFlagSet"))
    {
      ConfigData ifFlagSet = initData.GetChild("IfFlagSet");
      for(String theKey : ifFlagSet.GetChildKeys())
      {
        if(ourSaveGame.HasFlagSet(theKey))
        {
          SetFromConfig(ifFlagSet.GetChild(theKey));
        }
      }
    }
    
    if(initData.HasChild("IfFlagNotSet"))
    {
      ConfigData ifFlagNotSet = initData.GetChild("IfFlagNotSet");
      for(String theKey : ifFlagNotSet.GetChildKeys())
      {
        if(!ourSaveGame.HasFlagSet(theKey))
        {
          SetFromConfig(ifFlagNotSet.GetChild(theKey));
        }
      }
    }
    
    Collections.sort(myActorsInDrawOrder);
    
    if(initData.HasData("Movie"))
    {
      String filePath = dataPath("Animations/" + initData.GetData("Movie"));
      myMovie = new Movie(ourThis, filePath);
      myMovie.play();
    }
    
    return hasInit;
  }
  
  void SetFromConfig(ConfigData aConfig)
  {
    OnSetFromConfig(aConfig);
  }
  
  void OnSetFromConfig(ConfigData aConfig) {}
  
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
    return myTimeInState > myFadeInTime;  //<>//
  }
    
  boolean OnEnd(float aDeltaTime) 
  { 
    myFadePercent = (myTimeInState / myFadeOutTime);
    //println("End: " + myName + " - " + myFadePercent);
    return myTimeInState > myFadeOutTime; 
  }
  
  boolean OnUpdate(float aDeltaTime) 
  {
    if(myMovie != null)
    {
      float timeLeft = myMovie.duration() - myMovie.time();
      if(timeLeft <= 0)
      {
        SetNextLevel(myLevelConfig.GetChild("Init").GetData("NextLevel"), null);
        return true;
      }
    }
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
      ConfigData init = myLevelConfig.GetChild("Init");
      if(init.HasData("OnExit"))
      {
        FireTrigger(init.GetData("OnExit"));
      }
      Reset();
    }
    //<>//
    myTimeInState = 0;
    myState = aState;
    myNextState = aState;
  }
  
  void Reset()
  {
    for(String name : myControlNames)
      {
        cp5.remove(name);
      }
      myControlNames.clear();
  }
  
  void Draw()
  {
    if(myMovie != null)
    {
      image(myMovie, width/2, height/2, width, height);
      return;
    }
    
    if(myBackground != null)
      myBackground.DrawBackground();  
      
    for(Pawn actor : myActorsInDrawOrder)
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
      text("Selected Actor: " + ((mySelectedActor == null) ? "null" : mySelectedActor.myName), 0, height);
      
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
    if(ourNeedsToFadeMusic)
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
    if(aConfig.HasData("PlayMusic"))
    {
      ourSoundManager.PlayMusic(aConfig.GetData("PlayMusic"));
    }
    if(aConfig.HasData("SetFlag"))
    {
      ourSaveGame.SetFlag(aConfig.GetData("SetFlag"));
    }
    if(aConfig.HasChild("Flags"))
    {
      ourSaveGame.UpdateFlags(aConfig.GetChild("Flags"));
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
   
    if(aTrigger.equals("OnReset"))
      Reset();
    
    if(OnTrigger(aTrigger))
      return true;
      
    for(Pawn actor : myActors.values())
    {
      if(actor.OnTrigger(aTrigger))
        return true;
    }
    
    if(aTrigger.equals("OnSubmit"))
    {
      boolean isCorrect = true;
      Code code = null;
      for(Pawn pawn : myActorsInDrawOrder)
      {
        if(pawn.myIsVisible)
        {
          if(pawn.getClass() == Code.class)
          {
            code = (Code)pawn;
            isCorrect &= code.myIsCorrect;
          }
        }
      }
      if(code != null)
      {
        code.OnSubmit(isCorrect);
      }
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
    for(Pawn actor : myActors.values())
    {
      if(actor.IsMouseOver())
      {
        mySelectedActor = actor;
        break;
      }
    }
    return false;
  }
  
  void ReloadLevel()
  {
       SetNextLevel(myName, null);
  }
  
  void SetNextLevel(String aLevelName, String aPreviousLevel)
  {
    Level newLevel = new Level(aLevelName, aPreviousLevel);
    gsManager.AddToQueue(newLevel); 
    ourNeedsToFadeMusic = false;
    if(newLevel.myBackgroundMusic != null)
      if(!ourSoundManager.myCurrentMusicName.equals(newLevel.myBackgroundMusic))
        ourNeedsToFadeMusic = true;
        
    if(newLevel.myHasNoMusic == true)
    {
      ourNeedsToFadeMusic = true;
      //ourSoundManager.StopMusic();
    }
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
  Pawn mySelectedActor = null;
  HashMap<String, Pawn> myActors = new HashMap<String, Pawn>();
  ArrayList<Pawn> myActorsInDrawOrder = new ArrayList<Pawn>();
  ArrayList<String> myControlNames = new ArrayList<String>();
  LocText myTextToDisplay;
  
  boolean myHasNoMusic = false;
  Movie myMovie = null;
  
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
  String myBackgroundMusic = null;
};