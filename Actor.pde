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
    
    if(myConfig.HasData("PlacebleLocation"))
    {
      myPlaceableLocation = myConfig.GetData("PlacebleLocation");      
      myIsSelectable = true;
      myTint = color(221, 182, 92, 255);
    }
    
    if(myConfig.HasData("PlaceLocation"))
    {
      myAmIAPlaceableLocation = true;
    }
  }
  
  void OnSetFromConfig(ConfigData aConfig) 
  {    
    if(aConfig.HasData("OnClick"))
    {
      myOnClickTrigger = aConfig.GetData("OnClick");
      myIsSelectable = true;
    }
    if(aConfig.HasData("StartRotation"))
    {
      float degrees = Float.parseFloat(aConfig.GetData("StartRotation"));
      myRotation = radians(degrees);
      //println("Degrees: " + degrees + ", Radians: " + myRotation);
    }
    
    boolean changeScale = false;
    if(aConfig.HasData("Idle"))
    {
      myCurrentAnimation = myCurrentIdle = new Animation(aConfig.GetData("Idle"));
      changeScale = true;
    }
    else if(aConfig.HasData("Image"))
    {
      myCurrentTexture = new Texture(aConfig.GetData("Image"), false);
      changeScale = true;
    }
    
    if(aConfig.HasData("GlowImage"))
    {
      myGlowTexture = new Texture(aConfig.GetData("GlowImage"), false);
    }
    
    if(aConfig.HasData("ScaleTimes"))
    {
      myScale = Float.parseFloat(aConfig.GetData("ScaleTimes"));
    }
    
    if(aConfig.HasData("Scale"))
    {
      mySize = GetVector2FromLine(aConfig.GetData("Scale"));
    }
    else if(changeScale)
    {
      PImage texture = null;
      if(myCurrentTexture != null)
        texture = myCurrentTexture.GetTexture();
      else if(myCurrentAnimation != null)
        texture = myCurrentAnimation.GetCurrentImage();
      
      if(texture != null)
        mySize = GetRelativeSize(new PVector(texture.width * myScale, texture.height * myScale));
      else
        mySize = new PVector(400,400);
    }
  }
  
  boolean OnTrigger(ConfigData aConfig)
  {
    LogLn("Trigger: " + myName);
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
    if(aConfig.HasData("SetOneShotOffset"))
    {
      myCurrentAnimation.myOffset = GetVector2FromLine(aConfig.GetData("SetOneShotOffset"));
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
    
    if(aConfig.HasChild("MovePath"))
    {
      ConfigData path = aConfig.GetChild("MovePath");
      int index = 0;
      myMovePath = new ArrayList<PVector>();
      while(true)
      {
        if(!path.HasData(str(index)))
          break;
          
        myMovePath.add(GetVector2FromLine(path.GetData(str(index))));
        index++;
      }
      if(index % 4 != 0)
      {
        Error("Path must be in mutliples of 4 for the Bezier curves to work, we have " + index + " points");
        return false;
      }
      myTravelPercent = 0;
      myPathSubSection = 0;
      myRotation = 0;
      handled = true;
    }
    
    
    return handled;
  }
  
  String GetPlaceName()
  {
    if(myConfig.HasData("PlaceableName"))
    {
      return myConfig.GetData("PlaceableName");
    }    
    return myName;
  }
  
  boolean PlaceOn(Actor anActorToPlaceOn)
  {
    if(!myPlaceableLocation.equalsIgnoreCase(anActorToPlaceOn.GetPlaceName()))
      return false;
      
    if(!myConfig.HasData("KeepPlacedLocation"))
    {
      myIsPlaced = true;
      myIsSelectable = false;
      myIsDisabled = true;
      SetVisible(false);
      myPlaceableLocation = null;
    }
    anActorToPlaceOn.myAmIAPlaceableLocation = false;
    anActorToPlaceOn.myIsSelectable = false;
    anActorToPlaceOn.myIsDisabled = true;
    if(!myConfig.HasData("KeepPlacedLocation"))
      anActorToPlaceOn.SetVisible(false);
    
    String actorName = null;    
    if(myConfig.HasData("ReplaceActor"))
    {
      actorName = myConfig.GetData("ReplaceActor");
    }
    else if(anActorToPlaceOn.myConfig.HasData("ReplaceActor"))
    {
      actorName = anActorToPlaceOn.myConfig.GetData("ReplaceActor");
    }
    
    if(actorName != null)
    {
      Pawn actor = gsManager.myCurrentState.myActors.get(actorName);
      actor.SetVisible(true);
      boolean replacedAll = true;
      for(Pawn pawn : gsManager.myCurrentState.myActors.values())
      {
        if(pawn instanceof Actor)
        {
          Actor a = (Actor)pawn;
          if(a.myAmIAPlaceableLocation == true)
            replacedAll = false;
        }
      }
      if(replacedAll)
      {
        FireTrigger("TRIGGER_REPLACED_ALL");
      }
    }
  
    anActorToPlaceOn.myIsSelectable = false;
    return true;
  }
  
  void OnUpdate(float aDeltaTime)
  {      
    //myPosition.x += myMoveDelta.x * aDeltaTime;
    //myPosition.y += myMoveDelta.y * aDeltaTime;
    
    if(myMovePath != null)
    {
      myTravelPercent += (0.5 * aDeltaTime);
      if(myTravelPercent > 1.0)
      {
        myTravelPercent = 0;
        myPathSubSection++;
        if(myMovePath.size() / 4 <= myPathSubSection)
        {
          myTravelPercent = 1;
          myPathSubSection--;
          //myRotation = 0;
        }
      }
      
      if(myMovePath != null)
      {
        PVector p1 = myMovePath.get(myPathSubSection * 4 + 0);
        PVector p2 = myMovePath.get(myPathSubSection * 4 + 1);
        PVector p3 = myMovePath.get(myPathSubSection * 4 + 2);
        PVector p4 = myMovePath.get(myPathSubSection * 4 + 3);
        myPosition.x = bezierPoint(p1.x, p2.x, p3.x, p4.x, myTravelPercent);
        myPosition.y = bezierPoint(p1.y, p2.y, p3.y, p4.y, myTravelPercent);        
      }
    }
      
    if(myCurrentAnimation != null)
    {
      myCurrentAnimation.Update(aDeltaTime);
      if(!myCurrentAnimation.myIsRunning)
      {
        myCurrentAnimation = myCurrentIdle;
      }
    }
  }
  
  boolean IsSelectable()
  {    
    if(myOnClickTrigger != null)
    {
      if(myOnClickTrigger.equalsIgnoreCase("TRIGGER_TRY_PLACE"))
      {
        if(gsManager.myCurrentState.myPlaceableActor == null)
          return false;
      }
    }
    
    return super.IsSelectable();
  }
  
  boolean OnClicked()
  {    
    if(!myIsPlaced && myPlaceableLocation != null)
    {
      if(gsManager.myCurrentState.myPlaceableActor == this)
        gsManager.myCurrentState.myPlaceableActor = null;
      else
        gsManager.myCurrentState.myPlaceableActor = this;
    }
    
    if(myOnClickTrigger != null)
    {
      if(myOnClickTrigger.equalsIgnoreCase("TRIGGER_TRY_PLACE"))
      {
        if(gsManager.myCurrentState.myPlaceableActor != null)
        {
          if(gsManager.myCurrentState.myPlaceableActor.PlaceOn(this))
          {
            gsManager.myCurrentState.myPlaceableActor = null;
          }
        } 
      }
      else
      {
        FireTrigger(myOnClickTrigger);
      }
    }
    
    return true;
  } 
    
  void DrawInternal(PImage anImage, int anOutlineThickness)
  {
    if(myIsFullScreen)
          image(anImage, width/2, height/2, width + anOutlineThickness, height + anOutlineThickness);
        else
        {
          PVector offset = myCurrentAnimation != null ? myCurrentAnimation.myOffset : new PVector(0,0);
          PVector position = new PVector(myPosition.x + offset.x, myPosition.y + offset.y);
          image(anImage, position.x, position.y, mySize.x + anOutlineThickness, mySize.y + anOutlineThickness);
        }
  }
   
  boolean OnProcessInput(char aKey)
  { 
    if(gsManager.myCurrentState.mySelectedActor != this)
      return false;
    
    if(myMovePath == null)
      return false;
      
    if(aKey == '+')
     {
       myPathIndex = (myPathIndex + 1) % myMovePath.size();
       if(myPathIndex != 0 && myPathIndex % 4 == 0)
         myPathIndex = (myPathIndex + 2) % myMovePath.size();
       println("index: " + myPathIndex);
     }
     else if(aKey == CODED)
     {
       PVector point = myMovePath.get(myPathIndex);
       if(keyCode == LEFT)
         point.x--;
       if(keyCode == RIGHT)
         point.x++;
       if(keyCode == UP)
         point.y--;
       if(keyCode == DOWN)
         point.y++;
         
       if(myPathIndex % 4 == 3 && myPathIndex < myMovePath.size()-1)
       {
         PVector point2 = myMovePath.get(myPathIndex+1);
         point2.x = point.x;
         point2.y = point.y;
       }
       if(myPathIndex % 4 == 2 && myPathIndex < myMovePath.size()-2)
       {
         PVector midPoint = myMovePath.get(myPathIndex+1);
         PVector point2 = myMovePath.get(myPathIndex+3);
         
         point2.x = midPoint.x + (midPoint.x - point.x);
         point2.y = midPoint.y + (midPoint.y - point.y);         
       }
         
       //println("Index: " + myPathIndex + " - (" + point.x + ", " + point.y + ")");
     }
     else if(aKey == 'm' || aKey == 'M')
     {
       for(int i = 0; i < myMovePath.size(); i++)
       {
         PVector p = GetScreenToPercent(myMovePath.get(i));
         println(i + " = (" + p.x + ", " + p.y + ")");
       }
     }
      
    return false;
  }    
  
  void OnDraw(boolean isSelected)
  {           
    PImage currentTexture = myCurrentTexture != null ? myCurrentTexture.GetTexture() : myCurrentAnimation.GetCurrentImage();
    if(myLastImage != null && myLastImage != currentTexture)
        mySize = GetRelativeSize(new PVector(currentTexture.width * myScale, currentTexture.height * myScale));
       
    myLastImage = currentTexture;
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
    
    boolean selected = (isSelected  && IsSelectable()) || gsManager.myCurrentState.myPlaceableActor == this;
    if(selected)
    {
      if(myGlowTexture == null)
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
    }
    
    pushMatrix();
    
    if(myMovePath != null)
    {
        PVector p1 = myMovePath.get(myPathSubSection * 4 + 0);
        PVector p2 = myMovePath.get(myPathSubSection * 4 + 1);
        PVector p3 = myMovePath.get(myPathSubSection * 4 + 2);
        PVector p4 = myMovePath.get(myPathSubSection * 4 + 3);
        float tx = bezierTangent(p1.x, p2.x, p3.x, p4.x, myTravelPercent);
        float ty = bezierTangent(p1.y, p2.y, p3.y, p4.y, myTravelPercent);
        float a = atan2(ty, tx);
        float newRotation = (a + PI/2);
        myRotation = newRotation;//lerp(myRotation, newRotation, 0.1);
    }
    
    PVector offset = myCurrentAnimation != null ? myCurrentAnimation.myOffset : new PVector(0,0);
    PVector position = new PVector(myPosition.x + offset.x, myPosition.y + offset.y); 
    
    translate(position.x, position.y);
    rotate(myRotation);
    translate(-position.x, -position.y);
    DrawInternal(currentTexture, 0);
    
    if(myGlowTexture != null)
      if(selected)
        DrawInternal(myGlowTexture.GetTexture(), 10);
    
    popMatrix();      
    noTint();
  }
  
  void OnDebugDraw(boolean aIsSelected)
  {          
      if(aIsSelected)
      {
        if(myCurrentAnimation != null)
          myCurrentAnimation.DrawDebug();
      }
      
      if(myMovePath != null)
      {
        stroke(255, 0, 0, 128);
        noFill();
        for(int i = 0; i < myMovePath.size() / 4; i++)
        {
          PVector p1 = myMovePath.get(i * 4 + 0);
          PVector p2 = myMovePath.get(i * 4 + 1);
          PVector p3 = myMovePath.get(i * 4 + 2);
          PVector p4 = myMovePath.get(i * 4 + 3);
          bezier(p1.x, p1.y, p2.x, p2.y, p3.x, p3.y, p4.x, p4.y);
        }
        
        fill(0, 255, 0, 128);
        ellipse(myMovePath.get(myPathIndex).x, myMovePath.get(myPathIndex).y, 10, 10);
      }
  }
  
  Animation myCurrentAnimation;
  Animation myCurrentIdle;
  Texture myCurrentTexture = null;
  PImage myLastImage = null;
  TextInput myTextInput = null;
  Texture myGlowTexture = null;
  
  String myOnClickTrigger = null;
  color myTint;
  boolean myIsFullScreen;
  boolean myHasOutline = false;
  
  PVector myMoveDelta = new PVector(0,0);
  
  ArrayList<PVector> myMovePath = null;
  
  float myTravelPercent = 0;
  int myPathSubSection = 0;
  float myRotation = 0;
  float myScale = 1;
  
  String myPlaceableLocation = null;
  boolean myIsPlaced = false;
  boolean myAmIAPlaceableLocation = false;
  
  // DEBUG
  int myPathIndex = 0;
};