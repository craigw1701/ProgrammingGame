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
}

String GetKeyFromLine(String aLine)
{
  int index = aLine.indexOf("=");
  if(index == -1)
  {
    Error("FAILED TO GET IDENTIFIER FOR LINE: " + aLine);
    return "";
  }
 
  String val = aLine.substring(0, index);
  return val.trim();
}

String GetValueFromLine(String aLine)
{
  int index = aLine.indexOf("=");
  if(index == -1)
  {
    Error("FAILED TO GET VALUE FROM LINE: " + aLine);
    return "";
  }
  
  String val = aLine.substring(index+1);
  val = val.trim();
  
  if(val.length() == 0)
    return val;
    
  if(val.charAt(0) == '"')
    val = val.substring(1);
  
  if(val.charAt(val.length()-1) == '"')
    val = val.substring(0, val.length()-1);
    
  return val;
}

boolean IsLineAComment(String aLine)
{
  return aLine.indexOf("//") == 0;
}

boolean IsLineStartOfTable(String aLine)
{
  String text = aLine;
  int index = aLine.indexOf("=");
  if(index != -1)
  {
    text = text.substring(index+1).trim();
  }
  return text.indexOf("{") == 0;
}

boolean IsLineEndOfTable(String aLine)
{
  String text = aLine.trim();
  int index = text.indexOf("}");
  if(index == -1)
    return false;
    
  return index == text.length() - 1;
}

PVector GetVector2FromLine(String aLine)
{
  String theValue = aLine;
  int index = theValue.indexOf("(");
  if(index != -1)
  {
    int index2 = theValue.indexOf(",", index+1);
    if(index2 != -1)
    {
      String xString = theValue.substring(index+1, index2).trim();
      float xPercent = Float.parseFloat(xString);
      int xVal = int(xPercent * width);
      
      index = theValue.indexOf(")", index2);
      if(index != -1)
      {
        String yString = theValue.substring(index2+1, index).trim();
        float yPercent = Float.parseFloat(yString);
        int yVal = int(yPercent * height);
        return new PVector(xVal, yVal);
      }
    }
  }
 
  Error("FAILED TO GET VECTOR FROM LINE: " + aLine);
  return new PVector(0,0);
}

color GetColorFromLine(String aLine)
{
  String theValue = aLine;
  int index = theValue.indexOf("(");
  if(index == -1)
  {
    Warning("Failed to get Color from Line: " + aLine);
    return color(255, 255, 255);
  }
  
  int index2 = theValue.indexOf(",", index+1);
  if(index2 == -1)
  {
    Warning("Failed to get Color from Line: " + aLine);
    return color(255, 255, 255);
  }
  
  String redString = theValue.substring(index+1, index2).trim();
  int red = Integer.parseInt(redString);
  
  index = theValue.indexOf(",", index2+1);
  if(index == -1)
  {
    Warning("Failed to get Color from Line: " + aLine);
    return color(255, 255, 255);
  }
  
  String greenString = theValue.substring(index2+1, index).trim();
  int green = Integer.parseInt(greenString);
  
  index2 = theValue.indexOf(")", index+1);
  if(index2 == -1)
  {
    Warning("Failed to get Color from Line: " + aLine);
    return color(255, 255, 255);
  }
  
  String blueString = theValue.substring(index+1, index2).trim();
  int blue = Integer.parseInt(blueString);
  
  return color(red, green, blue);  
}

PVector GetRelativeSize(PVector aSourceSize)
{
  return new PVector(aSourceSize.x / ourSourceResolution.x * width, aSourceSize.y / ourSourceResolution.y * height);
}

PVector GetRelativeSize(PImage aSourceImage)
{
  return new PVector(aSourceImage.width / ourSourceResolution.x * width, aSourceImage.height / ourSourceResolution.y * height);
}

String LogPrefix()
{
  return "[" + ourFrameRate.myTotalFrames + "] ";
}

void LogLn(String aString)
{
  if(ourIsLogging)
    println(LogPrefix() + aString);
}

void LogLn()
{
  if(ourIsLogging)
    println();
}

void Log(String aString)
{
  if(ourIsLogging)
    print(aString);
}

void Warning(String aWarningMessage)
{
  println(LogPrefix() + "[WARN] " + aWarningMessage);
}

void Error(String anErrorMessage)
{
  println(LogPrefix() + "[ERROR] " + anErrorMessage);
  exit();
}