class Code extends Pawn
{
  Code(String aName)
  {
    super(aName);
    myIsSelectable = true;
  }
  
  String GetTextFieldName(int anIndex)
  {
    return gsManager.myCurrentState.myName + "_TextField_" + anIndex;
  }
  
  // Helpers
  void CreateTextLabel(ConfigData aConfig)
  {
    Textlabel textLabel = gsManager.myCurrentState.AddTextLabel(gsManager.myCurrentState.myName + "_TextLabel_" + myCodeParts);
    textLabel.setLineHeight(32);
    Label label = textLabel.get();
    textLabel.align(0,16,0,16);
    label.setLineHeight(32);
    label.setHeight(32); 
    textLabel.setText(aConfig.GetData("Text"));    
    textLabel.setPosition(myCurrentPosition.x, myCurrentPosition.y + 3);  // TODO:CW Magic number?   
    myCurrentPosition.x += textWidth(label.getText());
    myCurrentLineHeight = max(myCurrentLineHeight, 32);
    myTextLabels.add(textLabel);
  }
  
  void CreateTextField(ConfigData aConfig)
  {
    Textfield textField = gsManager.myCurrentState.AddTextField(GetTextFieldName(myCodeParts));
    textField.setPosition(myCurrentPosition.x, myCurrentPosition.y);
    if(aConfig.GetData("Type").equals("Integer"))
      textField.setInputFilter(ControlP5.INTEGER);
    textField.align(ControlP5.CENTER, ControlP5.CENTER, ControlP5.CENTER, ControlP5.CENTER);
    textField.getCaptionLabel().alignX(CENTER);
    textField.getValueLabel().alignX(CENTER);
    
    myCurrentPosition.x += textField.getWidth();
    myTextFieldMap.put(textField.getName(), textField);
    myTextFields.add(textField);    
  }
  
  // Overridden Functions
  void OnInit() 
  {
    myCurrentPosition = myPosition.copy();
    ConfigData code = myConfig.GetChild("Code");
    while(true)
    {
      if(!code.HasChild(str(myCodeParts)))
        break;
        
      ConfigData part = code.GetChild(str(myCodeParts));
      
      if(part.HasChild("TextLabel"))
        CreateTextLabel(part.GetChild("TextLabel"));
      else if(part.HasChild("TextField"))
        CreateTextField(part.GetChild("TextField"));
      
      myCodeParts++;
    }
    
    OnVisibilityChanged();
  }  
  
  void OnVisibilityChanged()
  {
    for(Textfield textField : myTextFields)
      textField.setVisible(myIsVisible);
    for(Textlabel textLabel : myTextLabels)
      textLabel.setVisible(myIsVisible);
  }
  
  boolean IsMouseOver()
  {
    for(Textfield textField : myTextFields)
      if(textField.isMouseOver())
        return true;
    return false;
  }
  
  // Override this one since it's special
  void DebugDraw(boolean aIsSelected)
  { 
    pushStyle();
    {
      stroke(255, 0,0);  
      noFill();
      rectMode(CORNER);
      for(Textfield textField : myTextFields)
        rect(textField.getPosition()[0], textField.getPosition()[1], textField.getWidth(), textField.getHeight());
        
      line(myPosition.x, myPosition.y, myCurrentPosition.x, myCurrentPosition.y);
      line(myPosition.x, myPosition.y + 32, myCurrentPosition.x, myCurrentPosition.y + 32);
    }
    popStyle();
  }
  
  boolean OnTrigger(ConfigData aConfig) { return false; }
  boolean OnTrigger(String aTrigger)
  {
    if(aTrigger.equals("OnSubmit"))
    {
      boolean isSuccessful = true;
      ConfigData submitData = myConfig.GetChild("OnSubmit");
      for(String data : submitData.myData.keySet())
      {
        String fieldName = GetTextFieldName(Integer.parseInt(data));
        Textfield textField = myTextFieldMap.get(fieldName);
        boolean success = textField.getText().equals(submitData.myData.get(data));
        if(success)
        {
          textField.setColorBackground(SuccessColor);
        }
        else
        {
          textField.setColorBackground(ErrorColor);
        }        
        
        textField.setFocus(false);
        isSuccessful &= success;
      }
      myCurrentFocus = null;
      
      if(isSuccessful)
      {
        println("YAY");
        FireTrigger(myConfig.GetData("OnSuccess"));
        ourSoundManager.PlaySuccessSound();
      }
      else
      {
        println("booo!");
        ourSoundManager.PlayErrorSound();
      }
      
      return true; 
    }
    return false; 
  }
    
  void OnUpdate(float aDeltaTime) 
  {    
    for(Textfield textField : myTextFields)
    {
      String text = textField.getText();
      
      if(textField.isFocus())
      {
        if(myCurrentFocus != textField)
        {
          SetFocus(textField);
         // textField.setText("0");
       //   continue;
        }
      }
      
      if(text.length() == 0)
        textField.setText("0");
        
      if(text.length() > 2)
      {
        textField.setText(text.substring(text.length() - 1));
      }
      
      int val = Integer.parseInt(textField.getText());
      textField.setText(str(val));
    }
  }
  
  void SetFocus(Textfield aTextField)
  {
    myCurrentFocus = aTextField;
    aTextField.setFocus(true);
    for(Textfield textField : myTextFields)
      textField.setColorBackground(InputBackgroundColor);
  }
  
  boolean OnProcessInput(char aKey)
  {
    if(myIsVisible == false)
      return false;
      
    if(aKey == TAB)
    {
      int currentIndex = 0;
      for(Textfield textField : myTextFields)
      {
        if(textField.isFocus())
        {
          textField.setFocus(false); 
          break;
        }
        currentIndex++;
      }     
        
      int direction = cp5.isShiftDown() ? myTextFields.size()-1 : 1;
      int newIndex = ((currentIndex + direction) % myTextFields.size());
      SetFocus(myTextFields.get(newIndex));
      
      return true;
    }
    
    if(aKey >= 0 && aKey <= 9)
    //if(myCurrentFocus != null)
      return true;     
    
    return false;
  }
  
  void OnDraw(boolean isSelected) {}
  boolean OnClicked() { return false; }
  void OnDebugDraw(boolean aIsSelected) {}
  
  
  // Variables
  PVector myCurrentPosition;
  int myCurrentLineHeight = 0;
  int myCodeParts = 0;
  int myMaxValue = 12;
  Textfield myCurrentFocus = null;
  HashMap<String, Textfield> myTextFieldMap = new HashMap<String, Textfield>(); 
  ArrayList<Textfield> myTextFields = new ArrayList<Textfield>();
  ArrayList<Textlabel> myTextLabels = new ArrayList<Textlabel>();
};