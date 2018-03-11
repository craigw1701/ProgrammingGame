PVector ourBoundingBoxBuffer = new PVector(width * 0.1, height * 0.1);

class Pawn
{
  Pawn(String aName)
  {
    myName = aName;
  }
  
  void Init(ConfigData aConfig)
  {
    myConfig = aConfig;
         
    if(myConfig.HasData("StartPosition"))
      myPosition = GetVector2FromLine(aConfig.GetData("StartPosition"));
    else
      myPosition = new PVector(0,0);
      
    if(myConfig.HasData("IsDisabled"))
      myIsDisabled = myConfig.GetData("IsDisabled").equals("true");
      
    if(myConfig.HasData("IsHidden"))
      myIsVisible = !myConfig.GetData("IsHidden").equals("true");
      
    OnInit(); 
  }
  
  boolean Trigger(ConfigData aConfig)
  {
    boolean handled = false;
    if(aConfig.HasData("SetVisible"))
    {
      SetVisible(aConfig.GetData("SetVisible").equals("true"));
      handled = true;
    }
    
    return OnTrigger(aConfig) | handled; 
  }
  
  void Update(float aDeltaTime)
  {
    if(!myIsVisible)
      return;
      
    OnUpdate(aDeltaTime);
  }
  
  void Draw(boolean isSelected)
  {      
    if(!myIsVisible)
      return;
      
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
  
  ConfigData myConfig = null;
};