class FrameRate
{
  FrameRate() { myLastTime = millis(); }
  
  void Update()
  {    
    myTotalFrames++;
    myDeltaTime = float(millis() - myLastTime) / 1000;
    myLastTime = millis();
    
    if(myAverageTimes.size() > 100)
      myAverageTimes.remove(0);
      
    myAverageTimes.append(myDeltaTime);
    
    if(myIsPaused)
      myDeltaTime = 0;
  }
  
  void Display()
  {
    float totalTime = 0;
    for(float time : myAverageTimes)
      totalTime += time;
    
    textAlign(LEFT, TOP);
    text(totalTime / myAverageTimes.size(), 0, 0);
    textAlign(RIGHT, TOP);
    text(1 / myDeltaTime, width, 0);
    textAlign(RIGHT, BOTTOM);
    text(1/(totalTime / myAverageTimes.size()), width, height);
    textAlign(CENTER, CENTER);
  }
  
  int myLastTime = 0;
  float myDeltaTime = 0;
  FloatList myAverageTimes = new FloatList();
  int myTotalFrames = 0;
  boolean myIsPaused = false;
}
