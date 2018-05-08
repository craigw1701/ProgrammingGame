import java.util.*;

boolean CheckFlags(ConfigData aConfig)
{    
  if(aConfig.HasChild("CheckAllFlags"))
  {
    ConfigData checkFlags = aConfig.GetChild("CheckAllFlags");
    for(String theFlag : checkFlags.myData.keySet())
    {
      if(ourSaveGame.HasFlagSet(theFlag) != IsTrue(checkFlags.GetData(theFlag)))
        return false;
    }   
    return true;
  } 
  else if(aConfig.HasChild("CheckAnyFlags"))
  {
    ConfigData checkFlags = aConfig.GetChild("CheckAnyFlags");
    for(String theFlag : checkFlags.myData.keySet())
    {
      if(ourSaveGame.HasFlagSet(theFlag) == IsTrue(checkFlags.GetData(theFlag)))
        return true;
    }
    return false;
  }
  return true;
}

class SaveGame
{
  void SetFlag(String aFlagName)
  {
    LogLn("SetFlag: " + aFlagName);
    myFlags.add(aFlagName);
  }
  
  void ClearFlag(String aFlagName)
  {
    LogLn("ClearFlag: " + aFlagName);
    myFlags.remove(aFlagName);  
  }
  
  void UpdateFlags(ConfigData aConfig)
  {
    for(String flag : aConfig.myData.keySet())
    {
      if(IsTrue(aConfig.GetData(flag)))
        SetFlag(flag);          
      else
        ClearFlag(flag);
    }
  }
  
  boolean HasFlagSet(String aFlagName)
  {
    return myFlags.contains(aFlagName);
  }
  
  void NewGame()
  {
    myFlags.clear();
  }
  
  void PrintFlags()
  {
    LogLn("Flags: ");
    for(Object flag : myFlags.toArray())
    {
      LogLn(" - " + flag);
    }
    LogLn();
  }
  
  // Variables
  HashSet<String> myFlags = new HashSet<String>();
};
