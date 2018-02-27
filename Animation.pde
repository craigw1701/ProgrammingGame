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
    myTotalRunningTime += aDeltaTime;
    if(myTotalRunningTime > 0.125)
    {
      myCurrentFrame = (myCurrentFrame+1) % myAnimationData.myLength;
      myTotalRunningTime -= 0.125;
    }    
  }
  
  void Draw(PVector aPosition, PVector aSize)
  {
    image(myAnimationData.GetFrame(myCurrentFrame), myPos.x + aPosition.x, myPos.y + aPosition.y, aSize.x, aSize.y);
    text(myCurrentFrame, width/2,height/2);
  }
  
  AnimationData myAnimationData;
  int myCurrentFrame;
  PVector myPos;
  float myTotalRunningTime;
};

class AnimationData
{
  boolean LoadAnimation(String anAnimation)
  {
    String filePath = dataPath("Animations/" + anAnimation + ".anim");
    File f = new File(filePath);
    if(!f.exists())
    {
      println("Failed to find animation with name: " + anAnimation);
      exit();
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
        println("End Of File");
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
            println("Reading in an animation frame out of order");
            exit();
            return false;
          }
          for(; counter < currentFrame+1; counter++)
          { 
            String animFilePath = dataPath("Animations/" + GetValueFromLine(line));
            File animFile = new File(animFilePath);
            if(!animFile.exists())
            {
              println("Failed to find animation file: " + animFilePath);
              exit();
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
        println("Failed to load animation: " + anAnimation);
        exit();
        return null;
      }
      myAnimations.put(anAnimation, animData);
    }
    return myAnimations.get(anAnimation);
  }
  
  HashMap<String, AnimationData> myAnimations = new HashMap<String, AnimationData>();
};