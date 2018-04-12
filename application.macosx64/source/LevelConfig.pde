import java.util.Map;
import java.util.Set;

class ConfigData
{
  boolean SetData(BufferedReader aReader)
  {
    if(aReader == null)
    {
      Error("SetData Failed, aReader is null");
      return false;
    }
    
    int childDepth = 0;
    String line = null;
    int lineNumber = 0;
    while(true)
    {
      try
      {
        line = aReader.readLine();
        lineNumber++;
      }
      catch(IOException e)
      {
        e.printStackTrace();
        exit();
      }
      
      if(line == null)
      {
        LogLn("End Of File");
        break;
      }
      
      line = line.trim();
      
      if(IsLineAComment(line))
        continue;
      
      if(IsLineStartOfTable(line))
      {
        childDepth++;
        String id = GetKeyFromLine(line);
        ConfigData data = new ConfigData();
        if(!data.SetData(aReader))
          return false;
          
        if(myChildren.containsKey(id))
        {
          Error("Already contains a entry called: " + id);
          return false;
        }
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
     if(myData.containsKey(theKey))
      {
        Error("Already contains a entry called: " + theKey);
        return false;
      }
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
      
    Error("ERROR, FAILED TO GET CHILD: " + anID); //<>// //<>//
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
      
    Error("ERROR, FAILED TO GET DATA: " + anID);
    return "";
  }
  
  void PrintIndention(int anIndention, String aString)
  {
    for(int i = 0; i < anIndention; i++)
      aString = "  " + aString;
    LogLn(aString);
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
    String filePath = dataPath("Levels/" + aLevelConfig + "/level.config");
    BufferedReader reader = createReader(filePath);
    if(reader == null)
    {
      Error("FAILED TO OPEN CONFIG: " + filePath);
      return;
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
    LogLn("-----------");
    LogLn("Config: " + myConfigName);
    LogLn("");
    myRoot.DebugPrint(0);
    LogLn("-----------");
    LogLn("");
  }
  
  ConfigData myRoot;
  String myConfigName;
};