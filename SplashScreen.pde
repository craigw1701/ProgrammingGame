class SplashScreen extends GameState
{
  SplashScreen() { super("SplashScreen"); }
  boolean OnInit()
  {
    background(0);
    myUpdateTime = 2;
    return super.OnInit();
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
    //text("Splash Screen", width/2, height/2);
    
    super.OnDraw();
  }
};