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
      cursor(WAIT);
      myCurrentImage = null;
    }
    else
    {
      if(gsManager.myCurrentState.myHoveredActor != null)
      {
        myCurrentImage = myClick;
        //cursor(myCurrentImage);
        cursor(HAND);
      }
      else
      {
        myCurrentImage = myDefault;
        //cursor(myCurrentImage);
        cursor(ARROW);
      }      
    }
  }
  
  PImage myCurrentImage = null;
  PImage myDefault = null;
  PImage myNextRoom = null;
  PImage myClick = null;
};
