class SplashScreen extends GameState
{
  SplashScreen() { super("SplashScreen"); }
  boolean Init()
  {
    background(0);
    myUpdateTime = 2;
    return true;
  }
  /*
  boolean OnStart(float aDeltaTime) { return true; }
  boolean OnEnd(float aDeltaTime) { return true; }
  */
  boolean OnUpdate(float aDeltaTime) 
  {
    myUpdateTime -= aDeltaTime;
    
    return myUpdateTime <= 0; 
  }
  
  float myUpdateTime;
  void OnDraw()
  {
    background(0,0,0,255);
    text("Splash Screen", width/2, height/2);
    
    super.OnDraw();
  }
};