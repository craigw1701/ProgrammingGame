import processing.sound.*;

Pawn CreatePawn(String aName, ConfigData aConfig)
{
  if(aConfig.HasData("PawnType"))
  {
    String pawnType= aConfig.GetData("PawnType");
    if(pawnType.equals("TextInput"))
      return new TextInput(aName);
    else if(pawnType.equals("Code"))
      return new Code(aName);
  }
  
  return new Actor(aName);
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

boolean GetBoolFromLine(String aLine)
{
  return GetValueFromLine(aLine).equals("true");
}

boolean IsTrue(String aString)
{
  return aString.equals("true");
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

PVector GetPercentToScreen(PVector aPos)
{
  return new PVector(aPos.x * width, aPos.y * height);
}

PVector GetScreenToPercent(PVector aPos)
{
  return new PVector(aPos.x / width, aPos.y / height);
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
  ourSoundManager.PlayErrorSound();
  exit();
}
