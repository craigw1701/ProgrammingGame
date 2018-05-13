class FrontEnd extends GameState
{
  FrontEnd()
  { 
    super("FrontEnd"); 
    myIsActive = true; 
  }
  
  void OnDraw()
  {
    fill(255,0,0);
    //text("Front End Menu\nPress 'n'", width/2, height/2);
    
    textAlign(CENTER, TOP);
    //ellipse(width / 2 + sin(myTimeActive) * 300, height / 2 + cos(myTimeActive) * 200, 20,20);
    //myTextToDisplay.DrawText(width/2, 0);
    
    super.OnDraw();
  }
  
  void StartNewGame()
  {
    ourSaveGame.NewGame();
    SetNextLevel("Level_001", null);
  }
  
  boolean OnTrigger(String aTrigger)
  {
    if(aTrigger.equals("TRIGGER_NEW_GAME"))
    {
      StartNewGame();
      return true;
    }
    
    return false;
  }
  
  boolean ProcessInput(char aKey)
  {
    if(aKey == 'n' || aKey == 'N')
    {
      StartNewGame();
      return true;
    }
    return false;
  }
};