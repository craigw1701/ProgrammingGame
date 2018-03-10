PVector ourBoundingBoxBuffer = new PVector(width * 0.1, height * 0.1);

class Actor
{
  Actor(String aName)
  {
    myName = aName;
    myConfig = null;
    myCurrentAnimation = null;
    myCurrentIdle = null;
    myCurrentTexture = null;
  }
  
  void Init(ConfigData aConfig)
  {
    myConfig = aConfig;
    if(aConfig.HasData("StartPosition"))
      myPosition = GetVector2FromLine(aConfig.GetData("StartPosition"));
    else
      myPosition = new PVector(0,0);
      
    if(aConfig.HasData("OnClick"))
      myIsSelectable = true;
    
    if(aConfig.HasData("Idle"))
      myCurrentAnimation = myCurrentIdle = new Animation(aConfig.GetData("Idle"));
    else
      myCurrentTexture = new Texture(aConfig.GetData("Image"), false);
      
    if(aConfig.HasData("Scale"))
    {
      mySize = GetVector2FromLine(aConfig.GetData("Scale"));
    }
    else
    {
      PImage texture = null;
      if(myCurrentTexture != null)
        texture = myCurrentTexture.GetTexture();
      else if(myCurrentAnimation != null)
        texture = myCurrentAnimation.GetCurrentImage();
      
      if(texture != null)
        mySize = GetRelativeSize(new PVector(texture.width, texture.height));
      else
        mySize = new PVector(400,400);
    }
      
    if(aConfig.HasData("Tint"))
      myTint = GetColorFromLine(aConfig.GetData("Tint"));
    else
      myTint = color(255, 255, 255, 255);
      
    if(aConfig.HasData("DrawFullscreen"))
      myIsFullScreen = aConfig.GetData("DrawFullscreen").equals("true");
    else
      myIsFullScreen = false;
      
    if(aConfig.HasData("HasOutline"))
      myHasOutline = aConfig.GetData("HasOutline").equals("true");
      
    if(aConfig.HasData("IsDisabled"))
      myIsDisabled = aConfig.GetData("IsDisabled").equals("true");
      
    if(aConfig.HasData("IsHidden"))
      myIsVisible = !aConfig.GetData("IsHidden").equals("true");
  }
  
  boolean Trigger(ConfigData aConfig)
  {
    println("Trigger: " + myName); //<>//
    boolean handled = false;
    if(aConfig.HasData("Say"))
    {
       println(aConfig.GetData("Say"));
       handled = true;
    }
    if(aConfig.HasData("PlayOneShot"))
    {
      myCurrentAnimation = new Animation(aConfig.GetData("PlayOneShot")); 
      myCurrentAnimation.myIsLooping = false;
      handled = true;
    }
    if(aConfig.HasData("PlayIdle"))
    {
      myCurrentIdle = new Animation(aConfig.GetData("PlayIdle"));
      handled = true;
    }
    if(aConfig.HasData("SetVisible"))
    {
      myIsVisible = aConfig.GetData("SetVisible").equals(true);
      handled = true;
    }
    if(aConfig.HasData("MoveDelta"))
    {
      myMoveDelta = GetVector2FromLine(aConfig.GetData("MoveDelta"));
      handled = true;
    }
    
    return handled;
  }
  
  void Update(float aDeltaTime)
  {
    if(!myIsVisible)
      return;
      
    myPosition.x += myMoveDelta.x * aDeltaTime;
    myPosition.y += myMoveDelta.y * aDeltaTime;
      
    if(myCurrentAnimation != null)
    {
      myCurrentAnimation.Update(aDeltaTime);
      if(!myCurrentAnimation.myIsRunning)
      {
        myCurrentAnimation = myCurrentIdle;
      }
    }
  }
  
  boolean OnClick()
  {
    if(!myIsVisible)
      return false;
      
    if(myIsSelectable)
    {
      FireTrigger(myConfig.GetData("OnClick"));
      return true;
    }
    return false;
  } 
    
  void DrawInternal(PImage anImage, int anOutlineThickness)
  {
    if(myIsFullScreen)
          image(anImage, width/2, height/2, width + anOutlineThickness, height + anOutlineThickness);
        else
          image(anImage, myPosition.x, myPosition.y, mySize.x + anOutlineThickness, mySize.y + anOutlineThickness);
  }
  
  void Draw(boolean isSelected)
  {      
    if(!myIsVisible)
      return;
      
    PImage currentTexture = myCurrentTexture != null ? myCurrentTexture.GetTexture() : myCurrentAnimation.GetCurrentImage();
    
    if(myIsDisabled)
    {
      PImage texture = currentTexture.copy();
      texture.loadPixels();
      for(int i = 0; i < texture.width * texture.height; i++)
      {
        if(alpha(texture.pixels[i]) > 0)
        {
          texture.pixels[i] = color(128,128,128,255);
        }
        texture.updatePixels();
      }
      texture.filter(POSTERIZE, 127);
      DrawInternal(texture, 0);
      return;
    }
    
    if(isSelected && myIsSelectable)
    {
      if(myTint == color(255, 255, 255, 255))
      {
        PImage texture = currentTexture.copy();
        texture.filter(THRESHOLD, 0.0);
        DrawInternal(texture, 10);
        if(myHasOutline == false)
          return;
      }
      else
      {
        tint(myTint);
      }
    }
    
    DrawInternal(currentTexture, 0);
    noTint();
  }
  
  void DebugDraw(boolean aIsSelected)
  {    
    if(!myIsVisible)
      return;
      
      stroke(255, 0,0);  
      noFill();
      PVector boundingBox = GetBoundingBoxSize();
      rect(myPosition.x, myPosition.y, boundingBox.x, boundingBox.y);
      
      if(aIsSelected)
      {
        if(myCurrentAnimation != null)
          myCurrentAnimation.DrawDebug();
      }
      noStroke();
  }
  
  PVector GetBoundingBoxSize()
  {
    return new PVector(mySize.x + ourBoundingBoxBuffer.x, mySize.y + ourBoundingBoxBuffer.y);
  }
  
  boolean IsMouseOver()
  {      
    if(!myIsVisible)
      return false;
      
    PVector boundingBox = GetBoundingBoxSize();
    if((myPosition.x + boundingBox.x/2) < mouseX)
      return false;
      
    if((myPosition.x - boundingBox.x/2) > mouseX)
      return false;
      
    if((myPosition.y + boundingBox.y/2) < mouseY)
      return false;
      
    if((myPosition.y - boundingBox.y/2) > mouseY)
      return false;
      
    return true;
  }
  
  void SetVisible(boolean aIsVisible)
  {
    myIsVisible = aIsVisible;
  }
  
  String myName;
  Animation myCurrentAnimation;
  Animation myCurrentIdle;
  Texture myCurrentTexture;
  ConfigData myConfig;
  PVector myPosition;
  PVector mySize;
  color myTint;
  boolean myIsFullScreen;
  boolean myIsSelectable = false;
  boolean myHasOutline = false;
  boolean myIsDisabled = false;
  boolean myIsVisible = true;
  
  PVector myMoveDelta = new PVector(0,0);
};