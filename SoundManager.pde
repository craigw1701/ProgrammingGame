class SoundManager
{
  void PlayMusic(String aFileName)
  {
    println("PlayMusic: " + aFileName);
    if(!mySounds.containsKey(aFileName))
    {
      String filePath = dataPath("Audio/" + aFileName);
      File f = new File(filePath);
      if(!f.exists())
      {
        Error("Failed to find file: " + filePath);
        return;
      }
      
      SoundFile sound = new SoundFile(ourThis, filePath);
      mySounds.put(aFileName, sound);
      PlayMusic(sound);
      return;
    }
    
    PlayMusic(mySounds.get(aFileName));
  }
  
  void PlayMusic(SoundFile aSound)
  {
    if(myCurrentMusic == aSound)
      return;
      
    if(myCurrentMusic != null)
    {
      myCurrentMusic.stop();
      println("stop this");
    }
    
    aSound.play();
    //aSound.loop();
    myCurrentMusic = aSound;
  }
  
  void SetMusicVolume(float aVolume)
  {
    if(myCurrentMusic != null)
    {
      println("SetMusicVolume: " + aVolume);
      myCurrentMusic.amp(aVolume);
    }
  }
  
  SoundFile myCurrentMusic = null;
  HashMap<String, SoundFile> mySounds = new HashMap<String, SoundFile>();
};