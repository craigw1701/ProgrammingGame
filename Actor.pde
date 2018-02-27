class Actor
{
  Actor(String aName)
  {
    myName = aName;
    myConfig = null;
    myCurrentAnimation = null;
    myCurrentTexture = null;
  }
  
  void Init(ConfigData aConfig)
  {
    myConfig = aConfig;
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
      myTint = color(255, 255, 255, 255);
      
    if(aConfig.HasData("DrawFullscreen"))
      myIsFullScreen = aConfig.GetData("DrawFullscreen").equals("true");
    else
      myIsFullScreen = false;
    
    if(aConfig.HasData("Idle"))
      myCurrentAnimation = new Animation(aConfig.GetData("Idle"));
    else
      myCurrentTexture = new Texture(aConfig.GetData("Image"));
  }
  
  boolean Trigger(ConfigData aConfig)
  {
    if(aConfig.HasData("Say"))
    {
       println(aConfig.GetData("Say"));
       return true;
    }
    return false;
  }
  
  void Update(float aDeltaTime)
  {
    if(myCurrentAnimation != null)
      myCurrentAnimation.Update(aDeltaTime);
  }
  
  boolean OnClick()
  {
    if(myConfig.HasData("OnClick"))
    {
      FireTrigger(myConfig.GetData("OnClick"));
      return true;
    }
    return false;
  }
    
  void Draw(boolean isSelected)
  {
    if(isSelected)
      tint(myTint);
      
    PVector size = mySize;
    if(myIsFullScreen)
    {
      if(myCurrentAnimation != null)
        myCurrentAnimation.Draw(new PVector(width/2, height/2), new PVector(width, height));
      else
        myCurrentTexture.DrawFullScreen();
    }
    else
    {
      if(myCurrentAnimation != null)
        myCurrentAnimation.Draw(myPosition, size);
      else
        myCurrentTexture.Draw(myPosition, size);
    }
    noTint();
  }
  
  void DebugDraw(boolean aIsSelected)
  {    
      stroke(255, 0,0);  
      noFill();
      rect(myPosition.x, myPosition.y, mySize.x, mySize.y);
      
      if(aIsSelected)
      {
        if(myCurrentAnimation != null)
          myCurrentAnimation.DrawDebug();
      }
  }
  
  boolean IsMouseOver()
  {      
    if((myPosition.x + mySize.x/2) < mouseX)
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
  Texture myCurrentTexture;
  ConfigData myConfig;
  PVector myPosition;
  PVector mySize;
  color myTint;
  boolean myIsFullScreen;
};