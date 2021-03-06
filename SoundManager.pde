boolean ourNeedsToFadeMusic = false;
  
class SoundManager
{
  void PlayMusic(String aFileName)
  {
    if(aFileName.equals(myCurrentMusicName))
      return;
      
    println("PlayMusic: " + aFileName + ":" + myCurrentMusicName);
    if(!mySounds.containsKey(aFileName))
    {
      String filePath = dataPath("Audio/" + aFileName);
      File f = new File(filePath);
      if(!f.exists())
      {
        Error("Failed to find file: " + filePath);
        return;
      }
      
      println(aFileName);
      SoundFile sound = new SoundFile(ourThis, filePath);
      mySounds.put(aFileName, sound);
    }
    
    if(PlayMusic(mySounds.get(aFileName)))
      myCurrentMusicName = aFileName;
  }
  
  void Update(float aDeltaTime)
  {
    if(myDuckTime > ourFrameRate.myLastTime)
    {
      SetMusicVolume(0.1);
    }
    else// if(myDuckTime > 0)
    {
      SetMusicVolume(lerp(myCurrentVolume, 1, 0.05));
    }   
    if(myIsMuted)
    {
      SetMusicVolume(0);
    }
    
    if(myCurrentMusic != null)
    {
      int timePlaying = millis() - myMusicStartTime;
      float timePlayingF = float(timePlaying) / 1000;
      if(myCurrentMusic.duration() < timePlayingF + 1)  // Hack to loop sounds without it crashing... :'(
      {
        myCurrentMusic.jump(1);
        myMusicStartTime = millis();
      }
    }
  }
  
  boolean PlayMusic(SoundFile aSound)
  {
    if(myCurrentMusic == aSound)
      return false;
    
    myIsMuted = false;
    if(myCurrentMusic != null)
    {
      myCurrentMusic.stop();
    }
    
    myMusicStartTime = millis();
    aSound.play();
    //aSound.loop();
    myCurrentMusic = aSound;
    return true;
  }
  
  void StopMusic()
  {
    if(myCurrentMusic != null)
    {
      println("stopMusic");
      SetMusicVolume(0.001);
      myCurrentMusic.stop();
      myCurrentMusic = null;
    }
    //myIsMuted = true;
  }
  
  void SetMusicVolume(float aVolume)
  {
    if(myCurrentMusic != null)
    {
      //LogLn("SetMusicVolume: " + aVolume + ": MaxVolume" + myMaxVolume);
      myCurrentVolume = aVolume;
      myCurrentMusic.amp(aVolume * myMaxVolume);
    }
  }
  
  void PlayErrorSound()
  {
    if(myErrorSound == null)
      myErrorSound = new SoundFile(ourThis, "Audio/ErrorSound.wav");
    
    myDuckTime = ourFrameRate.myLastTime + 2000;
    myErrorSound.play();
  }
  
  void PlaySuccessSound()
  {
    if(mySuccessSound == null)
      mySuccessSound = new SoundFile(ourThis, "Audio/SuccessSound.wav");
      
    myDuckTime = ourFrameRate.myLastTime + 2000;
    mySuccessSound.play();
  }
  
  void ToggleMute()
  {
    myIsMuted = !myIsMuted;
  }
  
  String myCurrentMusicName = null;
  SoundFile myCurrentMusic = null;
  HashMap<String, SoundFile> mySounds = new HashMap<String, SoundFile>();
  SoundFile myErrorSound = null;
  SoundFile mySuccessSound = null;
  float myDuckTime = 0;
  float myMaxVolume = 1;
  float myCurrentVolume = 1;
  float myTargetVolume = 1;
  boolean myIsMuted = false;
  
  int myMusicStartTime;
};