class GameStateManager
{
  GameStateManager()
  {
    myCurrentStates = new ArrayList<GameState>();
    myQueue = new ArrayList<GameState>();
  }
  
  boolean AddState(GameState aState)
  {
    //println("Add State: " + aState.myName);
    myCurrentState = aState;
    myCurrentStates.add(aState);
    DebugPrint("Add State: " + aState.myName);
    return true;
  }
  
  void ClearStates()
  {
    LogLn("Clearning States");
    myCurrentStates.clear();
  }
  
  void RemoveState(GameState aState)
  {
    DebugPrint("Remove State: " + aState.myName);
 
    if(myQueue.size() != 0)
    {
      ClearStates();
      AddState(myQueue.get(0));
      myQueue.remove(0);
    }
    else
    {
      myCurrentStates.remove(aState);
      if(myCurrentStates.size() > 0)
        myCurrentState = myCurrentStates.get(myCurrentStates.size()-1);
      else
        myCurrentState = null;
    }
    
/*    println("Remove State: " + aState.myName);
    myCurrentStates.remove(aState);
    if(myCurrentStates.size() > 0)
    {
      myCurrentState = myCurrentStates.get(myCurrentStates.size()-1);
    }
    else
    {
      if(myQueue.size() == 0)
      {
        myCurrentState = null;
        return;
      }
      
      AddState(myQueue.get(0));
      myQueue.remove(0);
    }
    DebugPrint();
    */
  }
  
  boolean Update(float aDeltaTime)
  {
    if(myCurrentState == null)
      return false;
    
    if(myCurrentState.Update(aDeltaTime))
      RemoveState(myCurrentState);
    
    background(0,0,0,255);      
    for(int i = 0; i < myCurrentStates.size(); i++)
    {
      fill(255);
      myCurrentStates.get(i).Draw();
    }
    return true;
  }
  
  boolean ProcessInput(char aKey)
  {
    for(int i = myCurrentStates.size() - 1; i >= 0; i--)
      if(myCurrentStates.get(i).ProcessInput(aKey))
        return true;
        
    return false;
  }
  
  boolean MouseClick()
  {
    for(int i = myCurrentStates.size() - 1; i >= 0; i--)
      if(myCurrentStates.get(i).OnClicked())
        return true;
        
    return false;
  }
  
  void AddToQueue(GameState aState)
  {
    myQueue.add(aState);
  }
  
  void ClearQueue()
  {
    myQueue.clear();
  }
  
  void DebugPrint(String aMessage)
  {
    LogLn("--------");
    LogLn(aMessage);
    LogLn("Current states:");
    for(int i = 0; i < myCurrentStates.size(); i++)
    {
      LogLn(" - " + myCurrentStates.get(i).myName);
    }
    LogLn();
    
    LogLn("Queue states:");
    for(int i = 0; i < myQueue.size(); i++)
    {
      LogLn(" - " + myQueue.get(i).myName);
    }
    LogLn("--------");
    LogLn();
  }
  
  GameState myCurrentState;
  ArrayList<GameState> myCurrentStates;
  ArrayList<GameState> myQueue;
};