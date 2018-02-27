import java.util.Map;
import java.util.Set;

class ConfigData
{
  boolean SetData(BufferedReader aReader)
  {
    if(aReader == null)
    {
      println("SetData Failed, aReader is null");
      exit();
      return false;
    }
    
    int childDepth = 0;
    String line = null;
    while(true)
    {
      try
      {
        line = aReader.readLine();
      }
      catch(IOException e)
      {
        e.printStackTrace();
        exit();
      }
      
      if(line == null)
      {
        println("End Of File");
        break;
      }
      
      line = line.trim();
      
      if(IsLineStartOfTable(line))
      {
        childDepth++;
        String id = GetKeyFromLine(line);
        ConfigData data = new ConfigData();
        if(!data.SetData(aReader))
          return false;
          
        myChildren.put(id, data);
        childDepth--;
        continue;
      }
      
      if(IsLineEndOfTable(line))
      {
        if(childDepth <= 0)
          return true;
          
        continue;
      }
      
      String theKey = GetKeyFromLine(line);
      String theValue = GetValueFromLine(line);
      myData.put(theKey, theValue);
    }
    return true;
  }

  boolean HasChild(String anID)
  {
    return myChildren.containsKey(anID);
  }

  ConfigData GetChild(String anID)
  {
    if(myChildren.containsKey(anID))
      return myChildren.get(anID);
      
    println("ERROR, FAILED TO GET CHILD: " + anID);
    exit();
    return new ConfigData();
  }
  
  boolean HasData(String anID)
  {
    return myData.containsKey(anID);
  }
  
  String GetData(String anID)
  {
    if(myData.containsKey(anID))
      return myData.get(anID);
      
    println("ERROR, FAILED TO GET DATA: " + anID);
    return "";
  }
  
  void PrintIndention(int anIndention, String aString)
  {
    for(int i = 0; i < anIndention; i++)
      print("  ");
    println(aString);
  }
  
  void DebugPrint(int anIndention)
  {
    for(Map.Entry entry : myData.entrySet())
    {
      PrintIndention(anIndention, entry.getKey() + " = " + entry.getValue());
    }
    
    for(Map.Entry entry : myChildren.entrySet())
    {
      PrintIndention(anIndention, entry.getKey() + " = ");
      PrintIndention(anIndention, "{");
      ConfigData d = (ConfigData)entry.getValue();
      d.DebugPrint(anIndention + 1);
      PrintIndention(anIndention, "}");
    }
  }
  
  Set<String> GetChildKeys()
  {
    return myChildren.keySet();
  }
  
  HashMap<String, String> myData = new HashMap<String, String>();
  HashMap<String, ConfigData> myChildren = new HashMap<String, ConfigData>();
};

class LevelConfig
{
  LevelConfig(String aLevelConfig)
  {
    myConfigName = aLevelConfig;
    String filePath = "/Data/Levels/" + aLevelConfig + "/level.config";
    BufferedReader reader = createReader(filePath);
    if(reader == null)
    {
      println("FAILED TO OPEN CONFIG: " + filePath);
      exit();
    }
    
    myRoot = new ConfigData();
    myRoot.SetData(reader);
    DebugPrint();
  }
  
  boolean HasChild(String anID)
  {
    return myRoot.HasChild(anID);
  }
  
  ConfigData GetChild(String anID)
  {
    return myRoot.GetChild(anID);
  }
  
  void DebugPrint()
  {
    println("-----------");
    println("Config: " + myConfigName);
    println();
    myRoot.DebugPrint(0);
    println("-----------");
    println();
  }
  
  ConfigData myRoot;
  String myConfigName;
};