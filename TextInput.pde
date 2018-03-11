enum TextInputTypes
{
  FLOAT,
  INTEGER,
  VECTOR2I,
  VECTOR2F
};

class TextInput extends Pawn
{
  //TextInput(String aType, ConfigData aConfig)
  TextInput(String aName)
  {
    super(aName);
    myIsSelectable = true;
    //myParent = aParent;
  }
  
  void OnInit()
  {
    String type = myConfig.GetData("Type");
    if(type.equals("Vector2i"))
    {
      myType = TextInputTypes.VECTOR2I;
    }
    
    if(myConfig.HasData("Text"))
      myText = new LocText(myConfig.GetData("Text"));
      
    if(myConfig.HasData("StartValue"))
      myCurrentValue = myConfig.GetData("StartValue");
  }
  
  void OnDraw(boolean aIsSelected)
  { 
    textAlign(LEFT, TOP);
    String resolvedText = myText.GetText();
    resolvedText = resolvedText.replaceAll("%s", myCurrentValue);    
    noStroke();
    if(myIsEditing)
      fill(255, 0, 0, 255);
    else
      fill(255, 255, 255, 255);
    mySize = new PVector(textWidth(resolvedText), 32); //<>//
    text(resolvedText, myPosition.x, myPosition.y);
  }
  
  void OnDebugDraw(boolean aIsSelected)
  {
    rectMode(CORNER);
  }
  
  boolean OnProcessInput(char aKey)
  {
    if(!myIsEditing)
      return false;
    
    if(aKey >= '0' && aKey <= '9')
    {
      myCurrentValue = str(aKey);
      return true;
    }   
    
    return false;
  }
  
  boolean IsMouseOver()
  {
    if((myPosition.x + mySize.x) < mouseX)
      return false;
      
    if((myPosition.x) > mouseX)
      return false;
      
    if((myPosition.y + mySize.y) < mouseY)
      return false;
      
    if((myPosition.y) > mouseY)
      return false;     
      
    return true;
  }
  
  boolean OnClicked()
  {
    if(myIsEditing == false)
    {
      myCarrotPosition = myCurrentValue.length();
    }
    myIsEditing = true;
    return true;
  }
  
  TextInputTypes myType;
  
  boolean myHasMaxValue = false;
  boolean myHasMinValue = false;
  boolean myHasStartValue = false;
  LocText myText;
  
  int myCarrotPosition = 0;
  boolean myIsEditing = false;
  String myCurrentValue;
}