PVector ourBoundingBoxBuffer = new PVector(width * 0.1, height * 0.1);

class Pawn implements Comparable<Pawn> 
{
  Pawn(String aName)
  {
    myName = aName;
  }
  
  public int compareTo(Pawn aPawn)
  {
    return constrain(myDrawLayer - aPawn.myDrawLayer, -1, 1); 
  }
    
  void Init(ConfigData aConfig)
  {
    myConfig = aConfig;
      
    SetFromConfig(myConfig);
      
    OnInit(); 
    
    if(myConfig.HasChild("IfFlags"))
    {
      ConfigData ifFlags = myConfig.GetChild("IfFlags");
      for(String theKey : ifFlags.GetChildKeys())
      {
        ConfigData action = ifFlags.GetChild(theKey); 
        if(CheckFlags(action))
        {
          SetFromConfig(action);          
        }
      }
    }
    
    if(myConfig.HasChild("IfFlagSet"))
    {
      ConfigData ifFlagSet = myConfig.GetChild("IfFlagSet");
      for(String theKey : ifFlagSet.GetChildKeys())
      {
        if(ourSaveGame.HasFlagSet(theKey))
        {
          SetFromConfig(ifFlagSet.GetChild(theKey));
        }
      }
    }
    if(myConfig.HasChild("IfFlagNotSet"))
    {
      ConfigData ifFlagNotSet = myConfig.GetChild("IfFlagNotSet");
      for(String theKey : ifFlagNotSet.GetChildKeys())
      {
        if(!ourSaveGame.HasFlagSet(theKey))
        {
          SetFromConfig(ifFlagNotSet.GetChild(theKey));
        }
      }
    }
  }
  
  void SetFromConfig(ConfigData aConfig)
  {
    if(aConfig.HasData("IsHidden"))
      myIsVisible = !aConfig.GetData("IsHidden").equals("true");      
         
    if(aConfig.HasData("StartPosition"))
      myPosition = GetVector2FromLine(aConfig.GetData("StartPosition"));
      
    if(myConfig.HasData("IsDisabled"))
      myIsDisabled = myConfig.GetData("IsDisabled").equals("true");
      
    if(aConfig.HasData("DrawLayer"))
      myDrawLayer = Integer.parseInt(aConfig.GetData("DrawLayer"));
      
    OnSetFromConfig(aConfig);
  }
  
  boolean Trigger(ConfigData aConfig)
  {
    boolean handled = false;
    if(aConfig.HasData("SetVisible"))
    {
      SetVisible(aConfig.GetData("SetVisible").equals("true"));
      handled = true;
    }
    if(aConfig.HasData("StartFadeIn"))
    {
      StartFadeIn(Float.parseFloat(aConfig.GetData("StartFadeIn")));
      handled = true;
    }
    if(aConfig.HasData("StartFadeOut"))
    {
      StartFadeOut(Float.parseFloat(aConfig.GetData("StartFadeOut")));
      handled = true;
    }
    
    if(aConfig.HasData("SetPosition"))
    {
      myPosition = GetVector2FromLine(aConfig.GetData("SetPosition"));
    }
    
    return OnTrigger(aConfig) | handled; 
  }
  
  void Update(float aDeltaTime)
  {
    if(myIsFadingIn || myIsFadingOut)
    {
      if(!myIsVisible)
      { //<>// //<>//
        SetVisible(true);
      }
      
      float length = myFadeEndTime - myFadeStartTime;
      float timeSinceStart = ourFrameRate.myLastTime - myFadeStartTime;
      myFadePercent = timeSinceStart / length;
      if(myIsFadingOut)
        myFadePercent = 1 - myFadePercent;
      
      if(myFadeEndTime <= ourFrameRate.myLastTime)
      {
        if(myIsFadingIn)
          myFadePercent = 1;
        
        if(myIsFadingOut)  
        {
          myFadePercent = 0;
          SetVisible(false);
        }
        myIsFadingIn = false;
        myIsFadingOut = false;
        
      }
    }
    
    if(!myIsVisible)
      return;
      
    OnUpdate(aDeltaTime);
  }
  
  void StartFadeIn(float aTime)
  {
      myFadeStartTime = ourFrameRate.myLastTime;
      myFadeEndTime = myFadeStartTime + (1000 * aTime);
      myIsFadingIn = true;
  }
  
  void StartFadeOut(float aTime)
  {
      myFadeStartTime = ourFrameRate.myLastTime;
      myFadeEndTime = myFadeStartTime + (1000 * aTime);
      myIsFadingOut = true;
  }
  
  void Draw(boolean isSelected)
  {      
    if(!myIsVisible)
      return;
      
    tint(255, 255 * myFadePercent);
    OnDraw(isSelected);
  }
  
  boolean Clicked()
  {
    if(!myIsVisible)
      return false;
      
    if(!myIsSelectable)
      return false;
      
    return OnClicked();
  }
    
  PVector GetBoundingBoxSize()
  {
    return new PVector(mySize.x + ourBoundingBoxBuffer.x, mySize.y + ourBoundingBoxBuffer.y);
  }
  
  void DebugDraw(boolean aIsSelected)
  {    
    if(!myIsVisible)
      return;
    // TODO:CW - STYLE  
    pushStyle();
    stroke(255, 0,0);  
    noFill();
    rectMode(CENTER);
    
    OnDebugDraw(aIsSelected);
    
    PVector boundingBox = GetBoundingBoxSize();
    rect(myPosition.x, myPosition.y, boundingBox.x, boundingBox.y);
    
    noStroke();
    popStyle();
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
  
  boolean ProcessInput(char aKey)
  {
    if(!myIsVisible)
      return false;
      
    return OnProcessInput(aKey);
  }
  
  void SetVisible(boolean aIsVisible)
  {
    if(myIsVisible == aIsVisible)
      return;
      
    if(!aIsVisible)
      myIsFadingIn = false;
    else
      myIsFadingOut = false;
    
    LogLn("SetVisible (" + myName + ") - " + aIsVisible);
    myIsVisible = aIsVisible;
    if(myIsVisible && myConfig.HasData("OnShow"))
      FireTrigger(myConfig.GetData("OnShow"));
    else if(!myIsVisible && myConfig.HasData("OnHide"))
      FireTrigger(myConfig.GetData("OnHide"));
    OnVisibilityChanged();
  }
  
  // Virtual Functions
  void OnInit() {}
  void OnSetFromConfig(ConfigData aConfig) {}
  boolean OnTrigger(ConfigData aConfig) { return false; }
  boolean OnTrigger(String aTrigger) { return false; }
  void OnUpdate(float aDeltaTime) {}
  void OnDraw(boolean isSelected) {}
  boolean OnClicked() { return false; }
  void OnDebugDraw(boolean aIsSelected) {}
  boolean OnProcessInput(char aKey) { return false; }
  void OnVisibilityChanged() {}
  
  // Variable
  String myName = "INVALID";
  PVector myPosition = new PVector(width/2, height/2);
  PVector mySize = new PVector(100, 100);  
  boolean myIsSelectable = false;
  boolean myIsDisabled = false;
  boolean myIsVisible = true;
  boolean myIsFadingIn = false;
  boolean myIsFadingOut = false;
  float myFadeStartTime = -1;
  float myFadeEndTime = -1;
  float myFadePercent = 1;
  int myDrawLayer = 0;
  
  ConfigData myConfig = null;
};