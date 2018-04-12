class PauseMenu extends GameState
{
  PauseMenu() 
  { 
    super("PauseMenu");
    myFadeInTime = 0.25;
    myFadeOutTime = 0.25;
    myFadeColor = color(0,0,0,128);
    myDrawWhileTransitioning = false;
    myIsQuitting = false;
  }
  
  boolean ProcessInput(char aKey)
  {
    LogLn("Process Input: " + aKey + "/" + ESC);
     if(aKey == ESC)
     {
       myIsActive = false;
       return true;
     }
     else if(aKey == 'q' || aKey == 'Q')
     {
       gsManager.AddToQueue(new FrontEnd());
       myIsActive = false;
       myFadeColor = color(0,0,0,255);
       myIsQuitting = true;
       return true;
     }
     return false;
  }
  
  boolean OnTrigger(String aTrigger)
  {
    if(aTrigger.equals("TRIGGER_UNPAUSE"))
    {
       myIsActive = false;
      return true;
    }
    
    return false;
  }
  
  float GetFadePercent()
  {
    if(myIsQuitting)
      return myFadePercent;
      
    return 1-myFadePercent;
  }
      
  void Draw()
  {      
    OnDraw();
    if(myState == GameStateState.RUNNING)
    {
      fill(248, 236, 194, 255);
      PVector size = GetPercentToScreen(new PVector(0.4, 0.375));
      rect(width/2, height/2, size.x, size.y);
      //fill(0);
      //text("Pause", width/2, height/2);      
      for(Pawn actor : myActors.values())
      {
        actor.Draw(actor == myHoveredActor);
      }
    }
    
    DebugDraw();
  }
  
  boolean myIsQuitting;
};