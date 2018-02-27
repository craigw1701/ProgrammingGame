class LocManager
{
  LocManager() { myDefaultLanguage = "en-GB"; }
  
  void LoadLanguage(String aLanguage)
  {
    HashMap<String, String> text = new HashMap<String, String>();
    println("Loading: " + aLanguage);
    BufferedReader reader = createReader("/Data/" + aLanguage + "/Text/main.txt");
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
        println("break?");
        break;
      }
        
      int index = line.indexOf(":");
      if(index == -1)
      {
        println("couldn't find ':'");
      }
      else
      {
        String theKey = line.substring(0, index);
        String theValue = line.substring(index+1);
        println("key: " + theKey + ", value: " + theValue);
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
    println("Try Loading Texture: " + filePath);
    File f = new File(filePath);
    if(!f.exists())
    {
      filePath = dataPath("Images/" + aTextureName);
      f = new File(filePath);
      if(!f.exists())
      {
        println("FAILED TO GET IMAGE: " + aTextureName);
        exit();
      }
    }
    
    println("Loading Texture: " + filePath);
    
    PImage image = loadImage(filePath);      
    if(image == null)
    {
      println("FAILED TO GET IMAGE: " + aTextureName);
      exit();
      return null;
    }
    
    image.resize(width, height);
    myTextures.put(aTextureName, image);
    //println("Failed to find text for id '" + aLocText.myTextID + "' trying fallback language:
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
      
    myTextures.clear();
  }
  
  String myDefaultLanguage;  
  String myCurrentLanguage;
  HashMap<String, HashMap<String, String>> myLocText = new HashMap<String, HashMap<String, String>>(); 
  HashMap<String, PImage> myTextures = new HashMap<String, PImage>();
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
  Texture(String aTextureName) { myTextureID = aTextureName; }
  PImage GetTexture() 
  {
    return locManager.GetTexture(myTextureID);
  }   
  
  void Draw(int aX, int aY, int aWidth, int aHeight)
  {
    background(GetTexture());
    //image(GetTexture(), aX, aY, aWidth, aHeight);
  }
  
  void DrawBackground()
  {
    Draw(width/2, height/2, width, height);
  }
  
  void DrawFullScreen()
  {
    image(GetTexture(), width/2, height/2, width, height);
  }
  
  String myTextureID;
}