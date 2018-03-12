import java.util.*;

class SaveGame
{
  void SetFlag(String aFlagName)
  {
    myFlags.add(aFlagName);
  }
  
  boolean HasFlagSet(String aFlagName)
  {
    return myFlags.contains(aFlagName);
  }
  
  HashSet<String> myFlags = new HashSet<String>();
};