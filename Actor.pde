class Actor
{
  Actor(String aName)
  {
    myName = aName;
  }
  
  void Init(ConfigData aConfig)
  {
    if(aConfig.HasData("StartPosition"))
      myPosition = GetVector2FromLine(aConfig.GetData("StartPosition"));
    else
      myPosition = new PVector(0,0);
    
    if(aConfig.HasData("Scale"))
      mySize = GetVector2FromLine(aConfig.GetData("Scale"));
    else
      mySize = new PVector(400, 400);
      
    if(aConfig.HasData("Tint"))
      myTint = GetColorFromLine(aConfig.GetData("Tint"));
    else
      myTint = color(0,0,0);
      
    if(aConfig.HasData("DrawFullscreen"))
      myIsFullScreen = aConfig.GetData("DrawFullscreen").equals("true");
    else
      myIsFullScreen = false;
    
      
    myCurrentAnimation = new Animation(aConfig.GetData("Idle"));
  }
  
  void Trigger(ConfigData aConfig)
  {
    if(aConfig.HasData("Say"))
    {
       println(aConfig.GetData("Say"));
    }
  }
  
  void Update(float aDeltaTime)
  {
    myCurrentAnimation.Update(aDeltaTime);
  }
    
  void Draw()
  {
    if(IsMouseOver())
      tint(myTint);
      
    PVector size = mySize;
    if(myIsFullScreen)
    {
      myCurrentAnimation.Draw(new PVector(width/2, height/2), new PVector(width, height));
    }
    else
    {
      myCurrentAnimation.Draw(myPosition, size);
    }
    noTint();
  }
  
  void DebugDraw()
  {    
      stroke(255, 0,0);  
      noFill();
      rect(myPosition.x, myPosition.y, mySize.x, mySize.y);
  }
  
  boolean IsMouseOver()
  {       //<>//
    if((myPosition.x + mySize.x/2) < mouseX) //<>//
      return false;
      
    if((myPosition.x - mySize.x/2) > mouseX)
      return false;
      
    if((myPosition.y + mySize.y/2) < mouseY)
      return false;
      
    if((myPosition.y - mySize.y/2) > mouseY)
      return false;
      
    return true;
  }
  
  String myName;
  Animation myCurrentAnimation;
  PVector myPosition;
  PVector mySize;
  color myTint;
  boolean myIsFullScreen;
};