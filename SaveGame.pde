import java.util.*;

class SaveGame
{
  void SetFlag(String aFlagName)
  {
    myFlags.add(aFlagName);
  }
  
  void ClearFlag(String aFlagName)
  {
    myFlags.remove(aFlagName);  
  }
  
  boolean HasFlagSet(String aFlagName)
  {
    return myFlags.contains(aFlagName);
  }
  
  HashSet<String> myFlags = new HashSet<String>();
};