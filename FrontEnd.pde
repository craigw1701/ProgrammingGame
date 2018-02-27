class FrontEnd extends GameState
{
  FrontEnd() { super("Splash Screen"); myIsActive = true; }
  boolean OnUpdate(float aDeltaTime) { return !myIsActive; }
  
  void OnDraw()
  {
    fill(255,0,0);
    text("Front End Menu\nPress 'n'", width/2, height/2);
    super.OnDraw();
  }
  
  boolean ProcessInput(char aKey)
  {
    if(aKey == 'n' || aKey == 'N')
    {
      gsManager.AddToQueue(new Level("Level_001"));
      myIsActive = false;
      return true;
    }
    return false;
  }
};