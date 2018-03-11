class Actor extends Pawn
{
  Actor(String aName)
  {
    super(aName);
    myCurrentAnimation = null;
    myCurrentIdle = null;
    myCurrentTexture = null;
  }
  
  void OnInit()
  {    
    if(myConfig.HasData("OnClick"))
      myIsSelectable = true;
    
    if(myConfig.HasData("Idle"))
      myCurrentAnimation = myCurrentIdle = new Animation(myConfig.GetData("Idle"));
    else if(myConfig.HasData("Image"))
      myCurrentTexture = new Texture(myConfig.GetData("Image"), false);
      
    if(myConfig.HasData("Scale"))
    {
      mySize = GetVector2FromLine(myConfig.GetData("Scale"));
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
      
    if(myConfig.HasData("Tint"))
      myTint = GetColorFromLine(myConfig.GetData("Tint"));
    else
      myTint = color(255, 255, 255, 255);
      
    if(myConfig.HasData("DrawFullscreen"))
      myIsFullScreen = myConfig.GetData("DrawFullscreen").equals("true");
    else
      myIsFullScreen = false;
      
    if(myConfig.HasData("HasOutline"))
      myHasOutline = myConfig.GetData("HasOutline").equals("true");
  }
  
  boolean OnTrigger(ConfigData aConfig)
  {
    println("Trigger: " + myName);
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
    if(aConfig.HasData("MoveDelta"))
    {
      myMoveDelta = GetVector2FromLine(aConfig.GetData("MoveDelta"));
      handled = true;
    }
    
    return handled;
  }
  
  void OnUpdate(float aDeltaTime)
  {      
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
  
  boolean OnClicked()
  {
    FireTrigger(myConfig.GetData("OnClick"));
    return true;
  } 
    
  void DrawInternal(PImage anImage, int anOutlineThickness)
  {
    if(myIsFullScreen)
          image(anImage, width/2, height/2, width + anOutlineThickness, height + anOutlineThickness);
        else
          image(anImage, myPosition.x, myPosition.y, mySize.x + anOutlineThickness, mySize.y + anOutlineThickness);
  }
  
  void OnDraw(boolean isSelected)
  {           
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
  
  void OnDebugDraw(boolean aIsSelected)
  {          
      if(aIsSelected)
      {
        if(myCurrentAnimation != null)
          myCurrentAnimation.DrawDebug();
      }
  }
  
  Animation myCurrentAnimation;
  Animation myCurrentIdle;
  Texture myCurrentTexture = null;
  TextInput myTextInput = null;
  
  color myTint;
  boolean myIsFullScreen;
  boolean myHasOutline = false;
  
  PVector myMoveDelta = new PVector(0,0);
};