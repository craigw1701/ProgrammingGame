class Cursor
{
  Cursor()
  {
    myDefault = locManager.GetTexture("mousecursornormal.png");
    myNextRoom = locManager.GetTexture("mousecursornextroom.png");
    myClick = locManager.GetTexture("mousecursorclick.png");
  }
  
  void Update(float aDeltaTime)
  {
    if(gsManager.myCurrentState.myState != GameStateState.RUNNING || gsManager.myCurrentState.myShowCursor == false)
    {
      noCursor();
      myCurrentImage = null;
    }
    else
    {
      if(gsManager.myCurrentState.myHoveredActor != null)
      {
        myCurrentImage = myClick;
        cursor(myCurrentImage);
      }
      else
      {
        myCurrentImage = myDefault;
        cursor(myCurrentImage);
      }      
    }
  }
  
  PImage myCurrentImage = null;
  PImage myDefault = null;
  PImage myNextRoom = null;
  PImage myClick = null;
};