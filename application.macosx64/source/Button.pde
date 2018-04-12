class Button extends Actor
{
  Button(String aName)
  {
    super(aName);
  }
  
  void Init(ConfigData aConfig)
  {
    super.Init(aConfig);
    
  }
  
  boolean myIsSelected = false;
  boolean myIsHovered = false;
};