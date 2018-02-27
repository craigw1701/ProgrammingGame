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
    println("Init: " + myName); return true; 
  }
  
  boolean OnStart(float aDeltaTime)
  { 
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
  //println("Update: " + myName);  
    return !myIsActive; 
  }
  boolean ProcessInput(char aKey) { return false; }

  void SetState(GameStateState aState)
  {
    myTimeInState = 0;
    myState = aState;
  }

  void Draw()
  {
      OnDraw();
  }
  
  boolean Update(float aDeltaTime)
  {
    myTimeInState += aDeltaTime;
    myTimeActive += aDeltaTime;
    if(myState == GameStateState.INIT)
    {
      if(Init())
        SetState(myState = GameStateState.STARTING);
    }
    
    if(myState == GameStateState.STARTING)
    {
      if(OnStart(aDeltaTime))
        SetState(GameStateState.RUNNING);
    }
    
    if(myState == GameStateState.RUNNING)
    {
      if(OnUpdate(aDeltaTime))
        SetState(GameStateState.STOPPING);
    }
    
    if(myState == GameStateState.STOPPING)
    {
       if(OnEnd(aDeltaTime))
         SetState(GameStateState.STOPPED);
    }
    
    if(myState == GameStateState.STOPPED)
    {
      return true;
    }
    return false;
  }
  
  void OnDraw()
  {
    Fade(GetFadePercent(), myFadeColor);
  }
  
  float GetFadePercent() { return myFadePercent; }
  
  // Member Variables
  GameStateState myState;
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