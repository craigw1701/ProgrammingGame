class Animation
{
  Animation(String anAnimation)
  {
    myAnimationData = ourAnimManager.GetAnimationData(anAnimation);
    myCurrentFrame = 0;
    myTotalRunningTime = 0;
    myPos = new PVector(0,0);
  }
  
  void Update(float aDeltaTime)
  {
    if(myIsRunning == false)
      return;
      
    myTotalRunningTime += aDeltaTime;
    if(myTotalRunningTime > myAnimationData.myFrameRate)
    {
      if(myCurrentFrame + 1 > myAnimationData.myLength - 1)
      {
        if(myIsLooping)
        {
          myCurrentFrame = 0;
        }
        else
        {
          myIsRunning = false;
        }
      }
      else
      {
        myCurrentFrame++;
      }
      myTotalRunningTime -= myAnimationData.myFrameRate;
    }    
  }
  
  void Draw(PVector aPosition, PVector aSize)
  {
    image(myAnimationData.GetFrame(myCurrentFrame), myPos.x + aPosition.x, myPos.y + aPosition.y, aSize.x, aSize.y);
  }
  
  void DrawDebug()
  {
    pushStyle();
      textAlign(CENTER, BOTTOM);
      text("Animation Frame: " + myCurrentFrame, width/2,height);
    popStyle();
  }
  
  PImage GetCurrentImage()
  {
    return myAnimationData.GetFrame(myCurrentFrame);
  }
  
  AnimationData myAnimationData;
  int myCurrentFrame;
  PVector myPos;
  float myTotalRunningTime;
  boolean myIsLooping = true;
  boolean myIsRunning = true;
};

class AnimationData
{
  boolean LoadAnimation(String anAnimation)
  {
    String filePath = dataPath("Animations/" + anAnimation + ".anim");
    File f = new File(filePath);
    if(!f.exists())
    {
      Error("Failed to find animation with name: " + anAnimation);
      return false;
    }
    
    BufferedReader reader = createReader(filePath);
    String line = null;
    boolean isReadingFrames = false;
    int counter = 0;
    int currentFrame = 0;
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
        LogLn("End Of File");
        break;
      }
      
      if(IsLineEndOfTable(line))
        continue; 
        
      String theKey = GetKeyFromLine(line);
      String theValue = GetValueFromLine(line);
      if(theKey.equals("Length"))
      {
        myLength = Integer.parseInt(theValue);
      }
      else if(theKey.equals("FrameRate"))
      {
        myFrameRate = 1 / Float.parseFloat(theValue);
      }
      else if(theKey.equals("Frames"))
      {
        isReadingFrames = true;
      }
      else if(isReadingFrames)
      {
        if(theKey.equals("}"))
          isReadingFrames = false;
        else
        {
          String frameString = theKey.substring(1, theKey.length()-1);
          currentFrame = Integer.parseInt(frameString);
          if(currentFrame < counter)
          {
            Error("Reading in an animation frame out of order");
            return false;
          }
          for(; counter < currentFrame+1; counter++)
          { 
            String animFilePath = dataPath("Animations/" + GetValueFromLine(line));
            File animFile = new File(animFilePath);
            if(!animFile.exists())
            {
              Error("Failed to find animation file: " + animFilePath);
              return false;
            }
            PImage frameImage = loadImage(animFilePath);
            //frameImage.resize(400,400);
            myImages.add(frameImage);
          }
        }
      }
    }
    
    return true;
  }
  
  PImage GetFrame(int aFrame) { return myImages.get(aFrame); }
  
  ArrayList<PImage> myImages = new ArrayList<PImage>();
  int myLength;
  float myFrameRate = 0.125;
};

class AnimationManager
{
  AnimationData GetAnimationData(String anAnimation)
  {
    if(!myAnimations.containsKey(anAnimation))
    {
      AnimationData animData = new AnimationData();
      if(!animData.LoadAnimation(anAnimation))
      {
        Error("Failed to load animation: " + anAnimation);
        return null;
      }
      myAnimations.put(anAnimation, animData);
    }
    return myAnimations.get(anAnimation);
  }
  
  HashMap<String, AnimationData> myAnimations = new HashMap<String, AnimationData>();
};