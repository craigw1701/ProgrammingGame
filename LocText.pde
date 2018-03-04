class LocManager
{
  LocManager() { myDefaultLanguage = "en-GB"; }
  
  void LoadLanguage(String aLanguage)
  {
    HashMap<String, String> text = new HashMap<String, String>();
    LogLn("Loading: " + aLanguage);
    BufferedReader reader = createReader(dataPath(aLanguage + "/Text/main.txt"));
    String line = null;
    while(true)
    {
      try
      {
        line = reader.readLine();
      }
      catch(IOException e)
      {
        e.printStackTrace();
        exit();
      }
      
      if(line == null)
      {
        LogLn("End of file");
        break;
      }
        
      int index = line.indexOf(":");
      if(index == -1)
      {
        Warning("couldn't find ':'");
      }
      else
      {
        String theKey = line.substring(0, index);
        String theValue = line.substring(index+1);
        LogLn("key: " + theKey + ", value: " + theValue);
        text.put(theKey, theValue);
      }
    }
    myLocText.put(aLanguage, text);
    myCurrentLanguage = aLanguage;
  }
  
  
  String GetText(LocText aLocText)
  {
    HashMap<String, String> text = myLocText.get(myCurrentLanguage);
    if(text.containsKey(aLocText.myTextID))
      return text.get(aLocText.myTextID);
      
    //println("Failed to find text for id '" + aLocText.myTextID + "' trying fallback language:
    
    return aLocText.myTextID;
  }
  
  PImage GetTexture(String aTextureName)
  {
    if(myTextures.containsKey(aTextureName))
      return myTextures.get(aTextureName);
    
    String filePath = dataPath(GetImagePath() + aTextureName);
    LogLn("Try Loading Texture: " + filePath);
    File f = new File(filePath);
    if(!f.exists())
    {
      filePath = dataPath("Images/" + aTextureName);
      f = new File(filePath);
      if(!f.exists())
      {
        Error("FAILED TO GET IMAGE: " + aTextureName);
        return null;
      }
    }
    
    LogLn("Loading Texture: " + filePath);
    
    PImage image = loadImage(filePath);      
    if(image == null)
    {
      Error("FAILED TO GET IMAGE: " + aTextureName);
      return null;
    }
    
    //image.resize(width, height);
    myTextures.put(aTextureName, image);
    //LogLn("Failed to find text for id '" + aLocText.myTextID + "' trying fallback language:
    return image;
  }
  
  String GetImagePath()
  {
    return myCurrentLanguage + "/Images/";
  }
  
  void SwitchLanguage()
  {
    if(myCurrentLanguage == "en-GB")
      myCurrentLanguage = "sv-SE";
    else
      myCurrentLanguage = "en-GB";
      
    ReloadImages();    
  }
  
  void SetLanguage(String aLanguage)
  {
    myCurrentLanguage = aLanguage;
    ReloadImages();  
  }
  
  void ReloadImages()
  {
    myTextures.clear();
    for(Texture texture : myTextureList)
    {
      texture.ReloadImage();
    }
  }
  
  String myDefaultLanguage;  
  String myCurrentLanguage;
  HashMap<String, HashMap<String, String>> myLocText = new HashMap<String, HashMap<String, String>>(); 
  HashMap<String, PImage> myTextures = new HashMap<String, PImage>();
  ArrayList<Texture> myTextureList = new ArrayList<Texture>();
};

class LocText
{
  LocText(String aTextID) { myTextID = aTextID; }
  String GetText()
  {
    return locManager.GetText(this);
  }
  
  void DrawText(int aX, int aY)
  {
      text(GetText(), aX, aY);     
  }
  
  String myTextID;
};

class Texture
{
  Texture(String aTextureName, Boolean aIsFullScreen) 
  { 
    myTextureID = aTextureName; 
    myIsFullScreen = aIsFullScreen;
    if(aIsFullScreen)
      GetTexture().resize(width, height);
    locManager.myTextureList.add(this);
  }
  
  void ReloadImage()
  {
    if(myIsFullScreen)
      GetTexture().resize(width, height);
  }
  
  void SetSize(PVector aSize)
  {
      GetTexture().resize((int)aSize.x, (int)aSize.y);
  }
  
  PImage GetTexture() 
  {
    return locManager.GetTexture(myTextureID);
  }   
  
  void Draw(PVector aPos, PVector aSize)
  {
    image(GetTexture(), aPos.x, aPos.y, aSize.x, aSize.y);
  }
  
  void DrawBackground()
  {
    background(GetTexture());
  }
  
  void DrawFullScreen()
  {
    image(GetTexture(), width/2, height/2, width, height);
  }
  
  String myTextureID;
  boolean myIsFullScreen;
}