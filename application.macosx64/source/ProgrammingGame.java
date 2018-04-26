import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import controlP5.*; 
import java.util.List; 
import processing.video.*; 
import java.util.Map; 
import java.util.Set; 
import java.util.*; 
import processing.sound.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class ProgrammingGame extends PApplet {



GameStateManager gsManager = new GameStateManager();
LocManager locManager = new LocManager();
AnimationManager ourAnimManager = new AnimationManager();
SoundManager ourSoundManager = new SoundManager();
SaveGame ourSaveGame = new SaveGame();
FrameRate ourFrameRate;
Cursor ourCursor;
ControlP5 cp5;
PApplet ourThis;

PFont font;
PVector ourSourceResolution = new PVector(2560, 1600);
boolean showFPS = false;
boolean ourMouseInfo = false;
boolean ourIsLogging = false;

boolean ourIsCtrlDown = false;


public void FireTrigger(String aTrigger)
{
  if(aTrigger.equals("TRIGGER_QUIT_GAME"))
  {
    exit();
    return;
  }
  gsManager.myCurrentState.Trigger(aTrigger);
}

public void setup()  
{
  ourThis = this;
  ourFrameRate = new FrameRate();
  
  //size(1280,800, FX2D);
  //size(1280,800);
  font = loadFont("WhiteRabbit-32.vlw");
  textFont(font);
  noStroke();
  colorMode(RGB, 256);
  frameRate(120);
  rectMode(CENTER);
  imageMode(CENTER);
  frameRate(30);

  textSize(32);
  textAlign(CENTER, CENTER);  
  cp5 = new ControlP5(this, font);
  cp5.setAutoDraw(false);
  
  gsManager.AddState(new SplashScreen());
  gsManager.AddToQueue(new FrontEnd());
  locManager.LoadLanguage("en-GB");
  locManager.LoadLanguage("sv-SE");
  
  ourCursor = new Cursor();
  //text("word", width/2, height/2);
}
 //<>//
public void Fade(float aFadePercent, int aFadeColor)
{
  pushStyle();
  //color fillColor = g.fillColor;
  fill(red(aFadeColor), green(aFadeColor), blue(aFadeColor), alpha(aFadeColor) * aFadePercent);
  //println("Fade: " + aFadePercent);
  rect(width/2, height/2, width, height);
  //fill(fillColor);
  popStyle();
}

public void keyPressed()
{
  if(gsManager.ProcessInput(key))
    key = 0;
    
  if(key == 'l' || key == 'L')
    locManager.SwitchLanguage();
    
  if(key == 'z' || key == 'Z')
    showFPS = !showFPS;
    
  if(key == 'x' || key == 'X')
  {
    ourMouseInfo = !ourMouseInfo;
    ControlP5.DEBUG = ourMouseInfo; 
  }
  if(key == 'm' || key == 'M')
    ourSoundManager.ToggleMute();
    
  if(key == 'q' || key == 'Q')
    ourIsLogging = !ourIsLogging;
    
  if(key == 'p' || key == 'P')
    ourFrameRate.myIsPaused = !ourFrameRate.myIsPaused;
    
  if(key == 'n' || key == 'N')
    ourSaveGame.NewGame();
    
  key = 0;
  keyCode = 0;
}

public void mouseClicked()
{
  if(gsManager.MouseClick())
  {
  }
}

// Called every time a new frame is available to read
public void movieEvent(Movie m) {
  m.read();
}

public void controlEvent(ControlEvent theEvent) 
{
  if (theEvent.isAssignableFrom(Textfield.class)) 
  {
    /*println("controlEvent: accessing a string from controller '"
      +theEvent.getName()+"': "
      +theEvent.getStringValue()
      );*/
    FireTrigger("OnSubmit");
  } 
}

public void Update()
{
  ourFrameRate.Update();
  
  gsManager.Update(ourFrameRate.myDeltaTime);
  ourCursor.Update(ourFrameRate.myDeltaTime);
  ourSoundManager.Update(ourFrameRate.myDeltaTime);
  
  if(showFPS)
    ourFrameRate.Display();
  
  if(ourMouseInfo)
  {
    textAlign(LEFT, TOP);
    text("Mouse Pos: (" + mouseX + ", " + mouseY + ")\nMouse Percent: (" + PApplet.parseFloat(mouseX)/PApplet.parseFloat(width) + ", " + PApplet.parseFloat(mouseY)/PApplet.parseFloat(height) + ")", 0, 0);
    
  }
}










public void draw()
{
  Update();
}
class Actor extends Pawn
{
  Actor(String aName)
  {
    super(aName);
    myCurrentAnimation = null;
    myCurrentIdle = null;
    myCurrentTexture = null;
  }
  
  public void OnInit()
  {                  
    if(myConfig.HasData("Tint"))
      myTint = GetColorFromLine(myConfig.GetData("Tint"));
    else
      myTint = color(255, 255, 255, 255);
      
    if(myConfig.HasData("DrawFullscreen"))
      myIsFullScreen = myConfig.GetData("DrawFullscreen").equals("true");
    else
      myIsFullScreen = false;
      
    if(myConfig.HasData("HasOutline"))
      myHasOutline = myConfig.GetData("HasOutline").equals("true");
    
    if(myConfig.HasData("PlacebleLocation"))
    {
      myPlaceableLocation = myConfig.GetData("PlacebleLocation");      
      myIsSelectable = true;
      myTint = color(221, 182, 92, 255);
    }
    
    if(myConfig.HasData("PlaceLocation"))
    {
      myAmIAPlaceableLocation = true;
    }
  }
  
  public void OnSetFromConfig(ConfigData aConfig) 
  {    
    if(aConfig.HasData("OnClick"))
    {
      myOnClickTrigger = aConfig.GetData("OnClick");
      myIsSelectable = true;
    }
    if(aConfig.HasData("StartRotation"))
    {
      float degrees = Float.parseFloat(aConfig.GetData("StartRotation"));
      myRotation = radians(degrees);
      //println("Degrees: " + degrees + ", Radians: " + myRotation);
    }
    
    boolean changeScale = false;
    if(aConfig.HasData("Idle"))
    {
      myCurrentAnimation = myCurrentIdle = new Animation(aConfig.GetData("Idle"));
      changeScale = true;
    }
    else if(aConfig.HasData("Image"))
    {
      myCurrentTexture = new Texture(aConfig.GetData("Image"), false);
      changeScale = true;
    }
    
    if(aConfig.HasData("GlowImage"))
    {
      myGlowTexture = new Texture(aConfig.GetData("GlowImage"), false);
    }
    
    if(aConfig.HasData("ScaleTimes"))
    {
      myScale = Float.parseFloat(aConfig.GetData("ScaleTimes"));
    }
    
    if(aConfig.HasData("Scale"))
    {
      mySize = GetVector2FromLine(aConfig.GetData("Scale"));
    }
    else if(changeScale)
    {
      PImage texture = null;
      if(myCurrentTexture != null)
        texture = myCurrentTexture.GetTexture();
      else if(myCurrentAnimation != null)
        texture = myCurrentAnimation.GetCurrentImage();
      
      if(texture != null)
        mySize = GetRelativeSize(new PVector(texture.width * myScale, texture.height * myScale));
      else
        mySize = new PVector(400,400);
    }
  }
  
  public boolean OnTrigger(ConfigData aConfig)
  {
    LogLn("Trigger: " + myName);
    boolean handled = false;
    if(aConfig.HasData("Say"))
    {
       println(aConfig.GetData("Say"));
       handled = true;
    }
    if(aConfig.HasData("PlayOneShot"))
    {
      myCurrentAnimation = new Animation(aConfig.GetData("PlayOneShot")); 
      myCurrentAnimation.myIsLooping = false;
      handled = true;
    }
    if(aConfig.HasData("SetOneShotOffset"))
    {
      myCurrentAnimation.myOffset = GetVector2FromLine(aConfig.GetData("SetOneShotOffset"));
      handled = true;
    }
    
    if(aConfig.HasData("PlayIdle"))
    {
      myCurrentIdle = new Animation(aConfig.GetData("PlayIdle"));
      handled = true;
    }
    if(aConfig.HasData("MoveDelta"))
    {
      myMoveDelta = GetVector2FromLine(aConfig.GetData("MoveDelta"));
      handled = true;
    }
    
    if(aConfig.HasChild("MovePath"))
    {
      ConfigData path = aConfig.GetChild("MovePath");
      int index = 0;
      myMovePath = new ArrayList<PVector>();
      while(true)
      {
        if(!path.HasData(str(index)))
          break;
          
        myMovePath.add(GetVector2FromLine(path.GetData(str(index))));
        index++;
      }
      if(index % 4 != 0)
      {
        Error("Path must be in mutliples of 4 for the Bezier curves to work, we have " + index + " points");
        return false;
      }
      myTravelPercent = 0;
      myPathSubSection = 0;
      myRotation = 0;
      handled = true;
    }
    
    
    return handled;
  }
  
  public String GetPlaceName()
  {
    if(myConfig.HasData("PlaceableName"))
    {
      return myConfig.GetData("PlaceableName");
    }    
    return myName;
  }
  
  public boolean PlaceOn(Actor anActorToPlaceOn)
  {
    if(!myPlaceableLocation.equalsIgnoreCase(anActorToPlaceOn.GetPlaceName()))
      return false;
      
    if(!myConfig.HasData("KeepPlacedLocation"))
    {
      myIsPlaced = true;
      myIsSelectable = false;
      myIsDisabled = true;
      SetVisible(false);
      myPlaceableLocation = null;
    }
    anActorToPlaceOn.myAmIAPlaceableLocation = false;
    anActorToPlaceOn.myIsSelectable = false;
    anActorToPlaceOn.myIsDisabled = true;
    if(!myConfig.HasData("KeepPlacedLocation"))
      anActorToPlaceOn.SetVisible(false);
    
    String actorName = null;    
    if(myConfig.HasData("ReplaceActor"))
    {
      actorName = myConfig.GetData("ReplaceActor");
    }
    else if(anActorToPlaceOn.myConfig.HasData("ReplaceActor"))
    {
      actorName = anActorToPlaceOn.myConfig.GetData("ReplaceActor");
    }
    
    if(actorName != null)
    {
      Pawn actor = gsManager.myCurrentState.myActors.get(actorName);
      actor.SetVisible(true);
      boolean replacedAll = true;
      for(Pawn pawn : gsManager.myCurrentState.myActors.values())
      {
        if(pawn instanceof Actor)
        {
          Actor a = (Actor)pawn;
          if(a.myAmIAPlaceableLocation == true)
            replacedAll = false;
        }
      }
      if(replacedAll)
      {
        FireTrigger("TRIGGER_REPLACED_ALL");
      }
    }
  
    anActorToPlaceOn.myIsSelectable = false;
    return true;
  }
  
  public void OnUpdate(float aDeltaTime)
  {      
    //myPosition.x += myMoveDelta.x * aDeltaTime;
    //myPosition.y += myMoveDelta.y * aDeltaTime;
    
    if(myMovePath != null)
    {
      myTravelPercent += (0.5f * aDeltaTime);
      if(myTravelPercent > 1.0f)
      {
        myTravelPercent = 0;
        myPathSubSection++;
        if(myMovePath.size() / 4 <= myPathSubSection)
        {
          myTravelPercent = 1;
          myPathSubSection--;
          //myRotation = 0;
        }
      }
      
      if(myMovePath != null)
      {
        PVector p1 = myMovePath.get(myPathSubSection * 4 + 0);
        PVector p2 = myMovePath.get(myPathSubSection * 4 + 1);
        PVector p3 = myMovePath.get(myPathSubSection * 4 + 2);
        PVector p4 = myMovePath.get(myPathSubSection * 4 + 3);
        myPosition.x = bezierPoint(p1.x, p2.x, p3.x, p4.x, myTravelPercent);
        myPosition.y = bezierPoint(p1.y, p2.y, p3.y, p4.y, myTravelPercent);        
      }
    }
      
    if(myCurrentAnimation != null)
    {
      myCurrentAnimation.Update(aDeltaTime);
      if(!myCurrentAnimation.myIsRunning)
      {
        myCurrentAnimation = myCurrentIdle;
      }
    }
  }
  
  public boolean IsSelectable()
  {    
    if(myOnClickTrigger != null)
    {
      if(myOnClickTrigger.equalsIgnoreCase("TRIGGER_TRY_PLACE"))
      {
        if(gsManager.myCurrentState.myPlaceableActor == null)
          return false;
      }
    }
    
    return super.IsSelectable();
  }
  
  public boolean OnClicked()
  {    
    if(!myIsPlaced && myPlaceableLocation != null)
    {
      if(gsManager.myCurrentState.myPlaceableActor == this)
        gsManager.myCurrentState.myPlaceableActor = null;
      else
        gsManager.myCurrentState.myPlaceableActor = this;
    }
    
    if(myOnClickTrigger != null)
    {
      if(myOnClickTrigger.equalsIgnoreCase("TRIGGER_TRY_PLACE"))
      {
        if(gsManager.myCurrentState.myPlaceableActor != null)
        {
          if(gsManager.myCurrentState.myPlaceableActor.PlaceOn(this))
          {
            gsManager.myCurrentState.myPlaceableActor = null;
          }
        } 
      }
      else
      {
        FireTrigger(myOnClickTrigger);
      }
    }
    
    return true;
  } 
    
  public void DrawInternal(PImage anImage, int anOutlineThickness)
  {
    if(myIsFullScreen)
          image(anImage, width/2, height/2, width + anOutlineThickness, height + anOutlineThickness);
        else
        {
          PVector offset = myCurrentAnimation != null ? myCurrentAnimation.myOffset : new PVector(0,0);
          PVector position = new PVector(myPosition.x + offset.x, myPosition.y + offset.y);
          image(anImage, position.x, position.y, mySize.x + anOutlineThickness, mySize.y + anOutlineThickness);
        }
  }
   
  public boolean OnProcessInput(char aKey)
  { 
    if(gsManager.myCurrentState.mySelectedActor != this)
      return false;
    
    if(myMovePath == null)
      return false;
      
    if(aKey == '+')
     {
       myPathIndex = (myPathIndex + 1) % myMovePath.size();
       if(myPathIndex != 0 && myPathIndex % 4 == 0)
         myPathIndex = (myPathIndex + 2) % myMovePath.size();
       println("index: " + myPathIndex);
     }
     else if(aKey == CODED)
     {
       PVector point = myMovePath.get(myPathIndex);
       if(keyCode == LEFT)
         point.x--;
       if(keyCode == RIGHT)
         point.x++;
       if(keyCode == UP)
         point.y--;
       if(keyCode == DOWN)
         point.y++;
         
       if(myPathIndex % 4 == 3 && myPathIndex < myMovePath.size()-1)
       {
         PVector point2 = myMovePath.get(myPathIndex+1);
         point2.x = point.x;
         point2.y = point.y;
       }
       if(myPathIndex % 4 == 2 && myPathIndex < myMovePath.size()-2)
       {
         PVector midPoint = myMovePath.get(myPathIndex+1);
         PVector point2 = myMovePath.get(myPathIndex+3);
         
         point2.x = midPoint.x + (midPoint.x - point.x);
         point2.y = midPoint.y + (midPoint.y - point.y);         
       }
         
       //println("Index: " + myPathIndex + " - (" + point.x + ", " + point.y + ")");
     }
     else if(aKey == 'm' || aKey == 'M')
     {
       for(int i = 0; i < myMovePath.size(); i++)
       {
         PVector p = GetScreenToPercent(myMovePath.get(i));
         println(i + " = (" + p.x + ", " + p.y + ")");
       }
     }
      
    return false;
  }    
  
  public void OnDraw(boolean isSelected)
  {           
    PImage currentTexture = myCurrentTexture != null ? myCurrentTexture.GetTexture() : myCurrentAnimation.GetCurrentImage();
    if(myLastImage != null && myLastImage != currentTexture)
        mySize = GetRelativeSize(new PVector(currentTexture.width * myScale, currentTexture.height * myScale));
       
    myLastImage = currentTexture;
    if(myIsDisabled)
    {
      PImage texture = currentTexture.copy();
      texture.loadPixels();
      for(int i = 0; i < texture.width * texture.height; i++)
      {
        if(alpha(texture.pixels[i]) > 0)
        {
          texture.pixels[i] = color(128,128,128,255);
        }
        texture.updatePixels();
      }
      texture.filter(POSTERIZE, 127);
      DrawInternal(texture, 0);
      return;
    }
    
    boolean selected = (isSelected  && IsSelectable()) || gsManager.myCurrentState.myPlaceableActor == this;
    if(selected)
    {
      if(myGlowTexture == null)
      {
        if(myTint == color(255, 255, 255, 255))
        {
          PImage texture = currentTexture.copy();
          texture.filter(THRESHOLD, 0.0f);
          DrawInternal(texture, 10);
          if(myHasOutline == false)
            return;
        }
        else
        {
          tint(myTint);
        }
      }
    }
    
    pushMatrix();
    
    if(myMovePath != null)
    {
        PVector p1 = myMovePath.get(myPathSubSection * 4 + 0);
        PVector p2 = myMovePath.get(myPathSubSection * 4 + 1);
        PVector p3 = myMovePath.get(myPathSubSection * 4 + 2);
        PVector p4 = myMovePath.get(myPathSubSection * 4 + 3);
        float tx = bezierTangent(p1.x, p2.x, p3.x, p4.x, myTravelPercent);
        float ty = bezierTangent(p1.y, p2.y, p3.y, p4.y, myTravelPercent);
        float a = atan2(ty, tx);
        float newRotation = (a + PI/2);
        myRotation = newRotation;//lerp(myRotation, newRotation, 0.1);
    }
    
    PVector offset = myCurrentAnimation != null ? myCurrentAnimation.myOffset : new PVector(0,0);
    PVector position = new PVector(myPosition.x + offset.x, myPosition.y + offset.y); 
    
    translate(position.x, position.y);
    rotate(myRotation);
    translate(-position.x, -position.y);
    DrawInternal(currentTexture, 0);
    
    if(myGlowTexture != null)
      if(selected)
        DrawInternal(myGlowTexture.GetTexture(), 10);
    
    popMatrix();      
    noTint();
  }
  
  public void OnDebugDraw(boolean aIsSelected)
  {          
      if(aIsSelected)
      {
        if(myCurrentAnimation != null)
          myCurrentAnimation.DrawDebug();
      }
      
      if(myMovePath != null)
      {
        stroke(255, 0, 0, 128);
        noFill();
        for(int i = 0; i < myMovePath.size() / 4; i++)
        {
          PVector p1 = myMovePath.get(i * 4 + 0);
          PVector p2 = myMovePath.get(i * 4 + 1);
          PVector p3 = myMovePath.get(i * 4 + 2);
          PVector p4 = myMovePath.get(i * 4 + 3);
          bezier(p1.x, p1.y, p2.x, p2.y, p3.x, p3.y, p4.x, p4.y);
        }
        
        fill(0, 255, 0, 128);
        ellipse(myMovePath.get(myPathIndex).x, myMovePath.get(myPathIndex).y, 10, 10);
      }
  }
  
  Animation myCurrentAnimation;
  Animation myCurrentIdle;
  Texture myCurrentTexture = null;
  PImage myLastImage = null;
  TextInput myTextInput = null;
  Texture myGlowTexture = null;
  
  String myOnClickTrigger = null;
  int myTint;
  boolean myIsFullScreen;
  boolean myHasOutline = false;
  
  PVector myMoveDelta = new PVector(0,0);
  
  ArrayList<PVector> myMovePath = null;
  
  float myTravelPercent = 0;
  int myPathSubSection = 0;
  float myRotation = 0;
  float myScale = 1;
  
  String myPlaceableLocation = null;
  boolean myIsPlaced = false;
  boolean myAmIAPlaceableLocation = false;
  
  // DEBUG
  int myPathIndex = 0;
};
class Animation
{
  Animation(String anAnimation)
  {
    myAnimationData = ourAnimManager.GetAnimationData(anAnimation);
    myCurrentFrame = 0;
    myTotalRunningTime = 0;
    myPos = new PVector(0, 0);
  }

  public void Update(float aDeltaTime)
  {
    if (myIsRunning == false)
      return;

    myTotalRunningTime += aDeltaTime;
    if (myTotalRunningTime > myAnimationData.myFrameRate)
    {
      if (myCurrentFrame + 1 > myAnimationData.myLength - 1)
      {
        if (myIsLooping)
        {
          myCurrentFrame = 0;
        } else
        {
          myIsRunning = false;
        }
      } else
      {
        myCurrentFrame++;
      }
      myTotalRunningTime -= myAnimationData.myFrameRate;
    }
  }

  public void Draw(PVector aPosition, PVector aSize)
  {
    image(myAnimationData.GetFrame(myCurrentFrame), myPos.x + aPosition.x, myPos.y + aPosition.y, aSize.x, aSize.y);
  }

  public void DrawDebug()
  {
    pushStyle();
    textAlign(CENTER, BOTTOM);
    text("Animation Frame: " + myCurrentFrame, width/2, height);
    popStyle();
  }

  public PImage GetCurrentImage()
  {
    return myAnimationData.GetFrame(myCurrentFrame);
  }
  
  AnimationData myAnimationData;
  int myCurrentFrame;
  PVector myPos;
  float myTotalRunningTime;
  boolean myIsLooping = true;
  boolean myIsRunning = true;
  PVector myOffset = new PVector(0,0);
};

class AnimationData
{
  public boolean LoadAnimation(String anAnimation)
  {
    String filePath = dataPath("Animations/" + anAnimation + ".anim");
    File f = new File(filePath);
    if (!f.exists())
    {
      Error("Failed to find animation with name: " + anAnimation);
      return false;
    }

    BufferedReader reader = createReader(filePath);
    String line = null;
    boolean isReadingFrames = false;
    int counter = 0;
    int currentFrame = 0;
    while (true)
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

      if (line == null)
      {
        LogLn("End Of File");
        break;
      }

      if (IsLineEndOfTable(line))
        continue; 

      String theKey = GetKeyFromLine(line);
      String theValue = GetValueFromLine(line);
      if (theKey.equals("Length"))
      {
        myLength = Integer.parseInt(theValue);
      } else if (theKey.equals("FrameRate"))
      {
        myFrameRate = 1 / Float.parseFloat(theValue);
      } else if (theKey.equals("Frames"))
      {
        isReadingFrames = true;
      } else if (isReadingFrames)
      {
        if (theKey.equals("}"))
          isReadingFrames = false;
        else
        {
          String frameString = theKey.substring(1, theKey.length()-1);
          currentFrame = Integer.parseInt(frameString);
          if (currentFrame < counter)
          {
            Error("Reading in an animation frame out of order");
            return false;
          }
          for (; counter < currentFrame+1; counter++)
          { 
            String animFilePath = dataPath("Animations/" + GetValueFromLine(line));
            File animFile = new File(animFilePath);
            if (!animFile.exists())
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

  public PImage GetFrame(int aFrame) { 
    return myImages.get(aFrame);
  }

  ArrayList<PImage> myImages = new ArrayList<PImage>();
  int myLength;
  float myFrameRate = 0.125f;
};

class AnimationManager
{
  public AnimationData GetAnimationData(String anAnimation)
  {
    if (!myAnimations.containsKey(anAnimation))
    {
      AnimationData animData = new AnimationData();
      if (!animData.LoadAnimation(anAnimation))
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
class Button extends Actor
{
  Button(String aName)
  {
    super(aName);
  }
  
  public void Init(ConfigData aConfig)
  {
    super.Init(aConfig);
    
  }
  
  boolean myIsSelected = false;
  boolean myIsHovered = false;
};
class Code extends Pawn
{
  Code(String aName)
  {
    super(aName);
    myIsSelectable = true;
  }
  
  public String GetTextFieldName(int anIndex)
  {
    return gsManager.myCurrentState.myName + "_" + myName + "_TextField_" + anIndex;
  }
  
  // Helpers
  public void CreateTextLabel(ConfigData aConfig)
  {
    Textlabel textLabel = gsManager.myCurrentState.AddTextLabel(gsManager.myCurrentState.myName + "_" + myName +  "_TextLabel_" + myCodeParts);
    textLabel.setLineHeight(32);
    Label label = textLabel.get();
    textLabel.align(0,16,0,16);
    label.setLineHeight(32);
    label.setHeight(32); 
    textLabel.setText(aConfig.GetData("Text"));    
    textLabel.setPosition(myCurrentPosition.x, myCurrentPosition.y + 3);  // TODO:CW Magic number?   
    myCurrentPosition.x += textWidth(label.getText());
    myCurrentLineHeight = max(myCurrentLineHeight, 32);
    myTextLabels.add(textLabel);
  }
  
  public void CreateTextField(ConfigData aConfig)
  {
    Textfield textField = gsManager.myCurrentState.AddTextField(GetTextFieldName(myCodeParts));
    textField.setPosition(myCurrentPosition.x, myCurrentPosition.y);
    textField.setText(aConfig.GetData("DefaultValue"));
    if(aConfig.GetData("Type").equals("Integer"))
      textField.setInputFilter(ControlP5.INTEGER);
    textField.align(ControlP5.CENTER, ControlP5.CENTER, ControlP5.CENTER, ControlP5.CENTER);
    textField.getCaptionLabel().alignX(CENTER);
    textField.getValueLabel().alignX(CENTER);
    
    myCurrentPosition.x += textField.getWidth();
    myTextFieldMap.put(textField.getName(), textField);
    myTextFields.add(textField);    
  }
  
  // Overridden Functions
  public void OnInit() 
  {
    ConfigData code = myConfig.GetChild("Code");
    SetupCodeParts(code);
    
    OnVisibilityChanged();
  }  
  
  public void SetupCodeParts(ConfigData aConfig)
  {
    myCurrentPosition = myPosition.copy();
    myCodeParts = 0;
    myTextFields.clear();
    myTextFieldMap.clear();
    myTextLabels.clear();
    
    while(true)
    {
      if(!aConfig.HasChild(str(myCodeParts)))
        break;
        
      ConfigData part = aConfig.GetChild(str(myCodeParts));
      
      if(part.HasChild("TextLabel"))
        CreateTextLabel(part.GetChild("TextLabel"));
      else if(part.HasChild("TextField"))
        CreateTextField(part.GetChild("TextField"));
      
      myCodeParts++;
    }
  }
  
  public void OnVisibilityChanged()
  {
    for(Textfield textField : myTextFields)
      textField.setVisible(myIsVisible);
    for(Textlabel textLabel : myTextLabels)
      textLabel.setVisible(myIsVisible);
  }
  
  public boolean IsMouseOver()
  {
    for(Textfield textField : myTextFields)
      if(textField.isMouseOver())
        return true;
    return false;
  }
  
  // Override this one since it's special
  public void DebugDraw(boolean aIsSelected)
  { 
    pushStyle();
    {
      stroke(255, 0,0);  
      noFill();
      rectMode(CORNER);
      for(Textfield textField : myTextFields)
        rect(textField.getPosition()[0], textField.getPosition()[1], textField.getWidth(), textField.getHeight());
        
      line(myPosition.x, myPosition.y, myCurrentPosition.x, myCurrentPosition.y);
      line(myPosition.x, myPosition.y + 32, myCurrentPosition.x, myCurrentPosition.y + 32);
    }
    popStyle();
  }
  
  public boolean OnTrigger(ConfigData aConfig) { return false; }
  public boolean OnTrigger(String aTrigger)
  {
    if(myIsVisible == false)
      return false;
      
    boolean handled = false;
    if(aTrigger.equals("OnReset"))
    {
      ConfigData code = myConfig.GetChild("Code");
      SetupCodeParts(code);
      //handled = true;
      myIsCorrect = false;
    }
      
    if(aTrigger.equals("OnSubmit"))
    {
      boolean isSuccessful = true;
      ConfigData submitData = myConfig.GetChild("OnSubmit");
      for(String data : submitData.myData.keySet())
      {
        String fieldName = GetTextFieldName(Integer.parseInt(data));
        Textfield textField = myTextFieldMap.get(fieldName);
        boolean success = textField.getText().equals(submitData.myData.get(data));
        if(success)
        {
          textField.setColorBackground(SuccessColor);
        }
        else
        {
          textField.setColorBackground(ErrorColor);
        }        
        
        textField.setFocus(false);
        isSuccessful &= success;
      }
      myCurrentFocus = null;
      myIsCorrect = isSuccessful;
      
      //handled = true;
    }
    return handled; 
  }
  
  public void Cheat()
  {
    ConfigData submitData = myConfig.GetChild("OnSubmit");
    for(String data : submitData.myData.keySet())
    {
      String fieldName = GetTextFieldName(Integer.parseInt(data));
      Textfield textField = myTextFieldMap.get(fieldName);
      textField.setText(submitData.myData.get(data));
    }
  }
  
  public void OnSubmit(boolean aIsCorrect)
  {
    if(aIsCorrect)
    {
      println("YAY");
      FireTrigger(myConfig.GetData("OnSuccess"));
      ourSoundManager.PlaySuccessSound();
    }
    else
    {
      println("booo!");
      ourSoundManager.PlayErrorSound();
    }
  }
    
  public void OnUpdate(float aDeltaTime) 
  {    
    for(Textfield textField : myTextFields)
    {
      String text = textField.getText();
      
      if(textField.isFocus())
      {
        if(myCurrentFocus != textField)
        {
          SetFocus(textField);
         // textField.setText("0");
       //   continue;
        }
      }
      
      if(text.length() == 0)
        textField.setText("0");
        
      if(text.length() > 2)
      {
        textField.setText(text.substring(text.length() - 1));
      }
      
      int val = Integer.parseInt(textField.getText());
      textField.setText(str(val));
    }
  }
  
  public void SetFocus(Textfield aTextField)
  {
    myCurrentFocus = aTextField;
    aTextField.setFocus(true);
    for(Textfield textField : myTextFields)
      textField.setColorBackground(InputBackgroundColor);
  }
  
  public boolean OnProcessInput(char aKey)
  {
    if(myIsVisible == false)
      return false;
      
    if(aKey == TAB)
    {
      int currentIndex = 0;
      for(Textfield textField : myTextFields)
      {
        if(textField.isFocus())
        {
          textField.setFocus(false); 
          break;
        }
        currentIndex++;
      }     
        
      int direction = cp5.isShiftDown() ? myTextFields.size()-1 : 1;
      int newIndex = ((currentIndex + direction) % myTextFields.size());
      SetFocus(myTextFields.get(newIndex));
      
      return true;
    }
    else if(aKey == 'c' || aKey == 'C')
    {
      Cheat();
      return false;
    }    
    
    if(aKey >= 0 && aKey <= 9)
    //if(myCurrentFocus != null)
      return true;     
    
    return false;
  }
  
  public void OnDraw(boolean isSelected) {}
  public boolean OnClicked() { return false; }
  public void OnDebugDraw(boolean aIsSelected) {}
  
  
  // Variables
  PVector myCurrentPosition;
  int myCurrentLineHeight = 0;
  int myCodeParts = 0;
  int myMaxValue = 12;
  boolean myIsCorrect = false;
  Textfield myCurrentFocus = null;
  HashMap<String, Textfield> myTextFieldMap = new HashMap<String, Textfield>(); 
  ArrayList<Textfield> myTextFields = new ArrayList<Textfield>();
  ArrayList<Textlabel> myTextLabels = new ArrayList<Textlabel>();
};
int InputBackgroundColor = color(128, 128, 128, 128);
int InputForgroundColor = color(128, 128, 128, 255);
int InputActiveColor = color(255);
int ErrorColor = color(200, 40, 40, 50);
int SuccessColor = color(40, 200, 40, 50);
class Cursor
{
  Cursor()
  {
    myDefault = locManager.GetTexture("mousecursornormal.png");
    myNextRoom = locManager.GetTexture("mousecursornextroom.png");
    myClick = locManager.GetTexture("mousecursorclick.png");
  }
  
  public void Update(float aDeltaTime)
  {
    if(gsManager.myCurrentState.myState != GameStateState.RUNNING || gsManager.myCurrentState.myShowCursor == false)
    {
      cursor(WAIT);
      myCurrentImage = null;
    }
    else
    {
      if(gsManager.myCurrentState.myHoveredActor != null)
      {
        myCurrentImage = myClick;
        //cursor(myCurrentImage);
        cursor(HAND);
      }
      else
      {
        myCurrentImage = myDefault;
        //cursor(myCurrentImage);
        cursor(ARROW);
      }      
    }
  }
  
  PImage myCurrentImage = null;
  PImage myDefault = null;
  PImage myNextRoom = null;
  PImage myClick = null;
};
class FrameRate
{
  FrameRate() { myLastTime = millis(); }
  
  public void Update()
  {    
    myTotalFrames++;
    myDeltaTime = PApplet.parseFloat(millis() - myLastTime) / 1000;
    myLastTime = millis();
    
    if(myAverageTimes.size() > 100)
      myAverageTimes.remove(0);
      
    myAverageTimes.append(myDeltaTime);
    
    if(myIsPaused)
      myDeltaTime = 0;
  }
  
  public void Display()
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
class FrontEnd extends GameState
{
  FrontEnd()
  { 
    super("FrontEnd"); 
    myIsActive = true; 
  }
  
  public void OnDraw()
  {
    fill(255,0,0);
    //text("Front End Menu\nPress 'n'", width/2, height/2);
    
    textAlign(CENTER, TOP);
    //ellipse(width / 2 + sin(myTimeActive) * 300, height / 2 + cos(myTimeActive) * 200, 20,20);
    //myTextToDisplay.DrawText(width/2, 0);
    
    super.OnDraw();
  }
  
  public void StartNewGame()
  {
    ourSaveGame.NewGame();
    SetNextLevel("IntroMovie", null);
  }
  
  public boolean OnTrigger(String aTrigger)
  {
    if(aTrigger.equals("TRIGGER_NEW_GAME"))
    {
      StartNewGame();
      return true;
    }
    
    return false;
  }
  
  public boolean ProcessInput(char aKey)
  {
    if(aKey == 'n' || aKey == 'N')
    {
      StartNewGame();
      return true;
    }
    return false;
  }
};



enum GameStateState
{
  INIT,
  STARTING,
  RUNNING,
  STOPPING,
  STOPPED
};
  
class GameState
{
  GameState(String aName)
  {
    myName = aName;
    SetState(GameStateState.INIT);
    myDrawWhileTransitioning = true;
    myFadeColor = color(0, 0, 0, 255);
    myFadePercent = 1;
    myFadeInTime = 1;
    myFadeOutTime = 1;
    myTimeActive = 0;
    myIsActive = true;
    
    myLevelConfig = new LevelConfig(myName);  
    
    ConfigData initData = myLevelConfig.GetChild("Init");
    if(initData.HasData("Music"))
    {
      myBackgroundMusic = initData.GetData("Music");
    }
    if(initData.HasData("NoMusic"))
    {
      ourSoundManager.StopMusic();
      myHasNoMusic = true;
    }
    
    ourSaveGame.PrintFlags();
  }
  
  public void UpdateFlags(ConfigData aConfig)
  {
    if(aConfig.HasChild("UpdateFlags"))
    {
      ConfigData ifFlags = aConfig.GetChild("UpdateFlags");
      for(String theKey : ifFlags.GetChildKeys())
      {
        ConfigData action = ifFlags.GetChild(theKey); 
        if(CheckFlags(action))
        {
          ourSaveGame.UpdateFlags(action.GetChild("Flags"));          
        }
      }
    }
  }
  
  public void AddToLevel(Pawn aPawn)
  {
      myActors.put(aPawn.myName, aPawn);
      myActorsInDrawOrder.add(aPawn);
      Collections.sort(myActorsInDrawOrder);
//      for(Pawn p : myActorsInDrawOrder)
//      {
//        println(p.myName + " - " + p.myDrawLayer);
//      }
//      println("__");
  }
  
  public boolean Init() 
  { 
    if(myTimeActive > 0)
      return true;
      
    LogLn("Init: " + myName);       
    ConfigData initData = myLevelConfig.GetChild("Init"); 
    UpdateFlags(initData);    
    
    myTextToDisplay = new LocText(initData.GetData("Text"));
    
    if(initData.HasData("Background"))
    {
      String background = initData.GetData("Background");
      if(background != "")
        myBackground =  new Texture("Backgrounds/" + background, true);
    }
    if(initData.HasChild("Characters"))
    {
      ConfigData characters = initData.GetChild("Characters");
      
      for(String theKey : characters.GetChildKeys())
      {
        Pawn actor = CreatePawn(theKey, characters.GetChild(theKey));
        actor.Init(characters.GetChild(theKey));
        AddToLevel(actor);
      }
    }
    
    if(myBackgroundMusic != null)
      ourSoundManager.PlayMusic(myBackgroundMusic);
    
    if(initData.HasData("HideCursor"))
    {
      myShowCursor = !initData.GetData("HideCursor").equals("true");
    }
    
    if(myLevelConfig.HasChild("Triggers"))
      myTriggers = myLevelConfig.GetChild("Triggers");    
        
    boolean hasInit = OnInit();    
    SetFromConfig(initData);
    
    if(initData.HasChild("IfFlagSet"))
    {
      ConfigData ifFlagSet = initData.GetChild("IfFlagSet");
      for(String theKey : ifFlagSet.GetChildKeys())
      {
        if(ourSaveGame.HasFlagSet(theKey))
        {
          SetFromConfig(ifFlagSet.GetChild(theKey));
        }
      }
    }
    
    if(initData.HasChild("IfFlagNotSet"))
    {
      ConfigData ifFlagNotSet = initData.GetChild("IfFlagNotSet");
      for(String theKey : ifFlagNotSet.GetChildKeys())
      {
        if(!ourSaveGame.HasFlagSet(theKey))
        {
          SetFromConfig(ifFlagNotSet.GetChild(theKey));
        }
      }
    }
    
    Collections.sort(myActorsInDrawOrder);
    
    if(initData.HasData("Movie"))
    {
      String filePath = dataPath("Animations/" + initData.GetData("Movie"));
      myMovie = new Movie(ourThis, filePath);
      myMovie.play();
    }
    
    return hasInit;
  }
  
  public void SetFromConfig(ConfigData aConfig)
  {
    OnSetFromConfig(aConfig);
  }
  
  public void OnSetFromConfig(ConfigData aConfig) {}
  
  public boolean OnInit() 
  {    
    LogLn("OnInit: " + myName + ": " + myTimeActive + ":" + myTimeInState);
    return myTimeInState > 0; 
  }
  
  public boolean OnStart(float aDeltaTime)
  { 
    //LogLn("Start: " + myName + ", active: " + myTimeActive + ", inState: " + myTimeInState );
    myFadePercent = 1-(myTimeInState / myFadeInTime);
    //println("Start: " + myName + " - " + myFadePercent);
    return myTimeInState > myFadeInTime; 
  }
    
  public boolean OnEnd(float aDeltaTime) 
  { 
    myFadePercent = (myTimeInState / myFadeOutTime);
    //println("End: " + myName + " - " + myFadePercent);
    return myTimeInState > myFadeOutTime; 
  }
  
  public boolean OnUpdate(float aDeltaTime) 
  {
    if(myMovie != null)
    {
      float timeLeft = myMovie.duration() - myMovie.time();
      if(timeLeft <= 0)
      {
        SetNextLevel(myLevelConfig.GetChild("Init").GetData("NextLevel"), null);
        return true;
      }
    }
    for(Pawn actor : myActors.values())
    {
      actor.Update(aDeltaTime);
    }
       
    if(myState == GameStateState.RUNNING)
    {
      myHoveredActor = null;
      for(Pawn actor : myActors.values())
      {
        if(actor.myIsSelectable && actor.IsMouseOver())
        {
          myHoveredActor = actor;
          break;
        }
      }
    }
    return !myIsActive; 
  }
  
  public boolean ProcessInput(char aKey) { return false; }

  public void SetNextState(GameStateState aState)
  {
    myNextState = aState;
  }
  
  public void SetState(GameStateState aState)
  {
    LogLn("State: " + aState + ":" + myName + ":" + myTimeActive);
    
    if(aState == GameStateState.STOPPED)
    {
      ConfigData init = myLevelConfig.GetChild("Init");
      if(init.HasData("OnExit"))
      {
        FireTrigger(init.GetData("OnExit"));
      }
      Reset();
    }
    //<>//
    myTimeInState = 0;
    myState = aState;
    myNextState = aState;
  }
  
  public void Reset()
  {
    for(String name : myControlNames)
      {
        cp5.remove(name);
      }
      myControlNames.clear();
  }
  
  public void Draw()
  {
    if(myMovie != null)
    {
      image(myMovie, width/2, height/2, width, height);
      return;
    }
    
    if(myBackground != null)
      myBackground.DrawBackground();  
      
    for(Pawn actor : myActorsInDrawOrder)
    {
      pushStyle();
      actor.Draw(actor == myHoveredActor);
      popStyle();
    }
    
    textAlign(CENTER, CENTER);
    cp5.draw();
      
    OnDraw();
    DebugDraw();
  }  
    
  public void DebugDraw()
  {    
    if(ourMouseInfo)
    {
      pushStyle();
      for(Pawn actor : myActors.values())
      {
        actor.DebugDraw(actor == myHoveredActor);
      }
      
      textAlign(LEFT, BOTTOM);
      text("Selected Actor: " + ((mySelectedActor == null) ? "null" : mySelectedActor.myName) +
          "\nHovered Actor: " + ((myHoveredActor == null) ? "null" : myHoveredActor.myName) + 
          "\nPlaceable Actor: " + ((myPlaceableActor == null) ? "null" : myPlaceableActor.myName), 0, height);
      
      popStyle();
    }
  }
  
  public boolean Update(float aDeltaTime)
  {    
    if(myState != myNextState)
      SetState(myNextState);
      
    if(myState == GameStateState.STOPPED)
    {
      return true;
    }
    
    if(myState == GameStateState.STARTING)
    {
      if(OnStart(aDeltaTime))
        SetNextState(GameStateState.RUNNING);
    }
     //<>//
    if(myState == GameStateState.INIT)
    {
      if(Init())
        SetNextState(GameStateState.STARTING);
    }
    
    
    if(myState == GameStateState.RUNNING)
    {
      if(OnUpdate(aDeltaTime))
        SetNextState(GameStateState.STOPPING);
    }
    
    if(myState == GameStateState.STOPPING)
    {
       if(OnEnd(aDeltaTime))
         SetNextState(GameStateState.STOPPED);
    }
    
    myTimeInState += aDeltaTime;
    myTimeActive += aDeltaTime;
    
    return false;
  }
  
  public void OnDraw()
  {
    Fade(GetFadePercent(), myFadeColor);
    if(ourNeedsToFadeMusic)
      ourSoundManager.SetMusicVolume(1 - GetFadePercent());
  }
  
  public void AddDelayedTrigger(ConfigData aConfig)
  {
    Error("AddDelayedTrigger1");
  }
  
  public void AddDelayedTrigger(float aDelay, ConfigData aConfig)
  {
    Error("AddDelayedTrigger2");
  }
  
  public boolean Trigger(ConfigData aConfig)
  {
    boolean hasHandled = false;
    if(aConfig.HasData("Delay"))
    {
      AddDelayedTrigger(aConfig);
      hasHandled = true;
    }
    
    if(aConfig.HasChild("Timeline"))
    {
      ConfigData timeline = aConfig.GetChild("Timeline");
      for(String theKey : timeline.GetChildKeys())
      {
        float delay = Float.parseFloat(theKey);
        AddDelayedTrigger(delay, timeline.GetChild(theKey));
      }
    }
     
    if(aConfig.HasChild("Characters"))
    {
      ConfigData characters = aConfig.GetChild("Characters");
      for(String actorName : characters.GetChildKeys())
      {
        Pawn actor = myActors.get(actorName);
        hasHandled |= actor.Trigger(characters.GetChild(actorName));
      }
    }
    if(aConfig.HasData("SetLevel"))
    {
      SetNextLevel(aConfig.GetData("SetLevel"), myName);   
      hasHandled = true;
    }
    if(aConfig.HasData("PushLevel"))
    {
      PushLevel(aConfig.GetData("PushLevel"));
      hasHandled = true;
    }
    if(aConfig.HasData("SetLanguage"))
    {
      locManager.SetLanguage(aConfig.GetData("SetLanguage"));
      hasHandled = true;
    }
    if(aConfig.HasData("Name"))
    {
      Trigger(aConfig.GetData("Name"));
      hasHandled = true;
    }
    if(aConfig.HasData("PlayMusic"))
    {
      ourSoundManager.PlayMusic(aConfig.GetData("PlayMusic"));
    }
    if(aConfig.HasData("SetFlag"))
    {
      ourSaveGame.SetFlag(aConfig.GetData("SetFlag"));
    }
    if(aConfig.HasChild("Flags"))
    {
      ourSaveGame.UpdateFlags(aConfig.GetChild("Flags"));
    }
    
    return OnTrigger(aConfig) || hasHandled;
  }
  
  public boolean Trigger(String aTrigger)
  {    
    if(myTriggers != null)
    {
      if(myTriggers.HasChild(aTrigger))
      {
        if(Trigger(myTriggers.GetChild(aTrigger)))
          return true;        
      }
    }    
   
    if(aTrigger.equals("OnReset"))
      Reset();
    
    if(OnTrigger(aTrigger))
      return true;
      
    for(Pawn actor : myActors.values())
    {
      if(actor.OnTrigger(aTrigger))
        return true;
    }
    
    if(aTrigger.equals("OnSubmit"))
    {
      boolean isCorrect = true;
      Code code = null;
      for(Pawn pawn : myActorsInDrawOrder)
      {
        if(pawn.myIsVisible)
        {
          if(pawn.getClass() == Code.class)
          {
            code = (Code)pawn;
            isCorrect &= code.myIsCorrect;
          }
        }
      }
      if(code != null)
      {
        code.OnSubmit(isCorrect);
      }
    }
    
    return false;
  }
  
  public boolean OnTrigger(String aTrigger) { return false; }
  public boolean OnTrigger(ConfigData aConfig) { return false; }
  
  public boolean OnClicked()
  {    
    if(myHoveredActor != null)
    {
      return myHoveredActor.Clicked();
    }
    for(Pawn actor : myActors.values())
    {
      if(actor.IsMouseOver())
      {
        mySelectedActor = actor;
        break;
      }
    }
    return false;
  }
  
  public void ReloadLevel()
  {
       SetNextLevel(myName, null);
  }
  
  public void SetNextLevel(String aLevelName, String aPreviousLevel)
  {
    Level newLevel = new Level(aLevelName, aPreviousLevel);
    gsManager.AddToQueue(newLevel); 
    ourNeedsToFadeMusic = false;
    if(newLevel.myBackgroundMusic != null)
      if(!ourSoundManager.myCurrentMusicName.equals(newLevel.myBackgroundMusic))
        ourNeedsToFadeMusic = true;
        
    if(newLevel.myHasNoMusic == true)
    {
      ourNeedsToFadeMusic = true;
      //ourSoundManager.StopMusic();
    }
    myIsActive = false;
  }
  
  public void PushLevel(String aLevelName)
  {
    gsManager.AddState(new Level(aLevelName, null));
  }
  
  public float GetFadePercent() { return myFadePercent; }

  public Textfield AddTextField(String aName)
  {
    Textfield textField = cp5.addTextfield(aName, 100,100, 64, 32).setAutoClear(false).setColorBackground(InputBackgroundColor).setColorForeground(InputForgroundColor).setColorActive(InputActiveColor);
    textField.align(CENTER, CENTER, CENTER, CENTER);
    Label c = textField.getCaptionLabel();
    c.hide();
    myControlNames.add(aName);
    return textField;
  }
  
  public Textlabel AddTextLabel(String aName)
  {
    Textlabel textLabel = cp5.addTextlabel(aName, "", 32, 32).setColor(color(255,255,255,255)).setFont(font);
    myControlNames.add(aName);
    return textLabel;
  }
  
  // Member Variables
  GameStateState myState;
  GameStateState myNextState; 
  LevelConfig myLevelConfig;  
  ConfigData myTriggers;
  Texture myBackground = null;
  Pawn myHoveredActor = null;
  Pawn mySelectedActor = null;
  HashMap<String, Pawn> myActors = new HashMap<String, Pawn>();
  ArrayList<Pawn> myActorsInDrawOrder = new ArrayList<Pawn>();
  ArrayList<String> myControlNames = new ArrayList<String>();
  LocText myTextToDisplay;
  
  boolean myHasNoMusic = false;
  Movie myMovie = null;
  
  String myName;
  float myFadeInTime;
  float myFadeOutTime;
  int myFadeColor;

  boolean myShowCursor = true;
  boolean myIsActive;
  float myFadePercent;
  float myTimeInState;
  float myTimeActive;
  boolean myDrawWhileTransitioning;
  String myBackgroundMusic = null;
  
  Actor myPlaceableActor = null;
};
class GameStateManager
{
  GameStateManager()
  {
    myCurrentStates = new ArrayList<GameState>();
    myQueue = new ArrayList<GameState>();
  }
  
  public boolean AddState(GameState aState)
  {
    //println("Add State: " + aState.myName);
    myCurrentState = aState;
    myCurrentStates.add(aState);
    DebugPrint("Add State: " + aState.myName);
    return true;
  }
  
  public void ClearStates()
  {
    LogLn("Clearning States");
    myCurrentStates.clear();
  }
  
  public void RemoveState(GameState aState)
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
  
  public boolean Update(float aDeltaTime)
  {
    if(myCurrentState == null)
      return false;
    
    if(myCurrentState.Update(aDeltaTime))
    {
      RemoveState(myCurrentState);
      return true;
    }
    
    //background(0,0,0,255);      
    for(int i = 0; i < myCurrentStates.size(); i++)
    {
      fill(255);
      myCurrentStates.get(i).Draw();
    }
    return true;
  }
  
  public boolean ProcessInput(char aKey)
  {
    if(myCurrentState.myIsActive == false)
      return true;
      
    for(int i = myCurrentStates.size() - 1; i >= 0; i--)
      if(myCurrentStates.get(i).ProcessInput(aKey))
        return true;
        
        
    return false;
  }
  
  public boolean MouseClick()
  {
    if(myCurrentState.myIsActive == false)
      return true;
      
    for(int i = myCurrentStates.size() - 1; i >= 0; i--)
      if(myCurrentStates.get(i).OnClicked())
        return true;
        
    return false;
  }
  
  public void AddToQueue(GameState aState)
  {
    myQueue.add(aState);
  }
  
  public void ClearQueue()
  {
    myQueue.clear();
  }
  
  public void DebugPrint(String aMessage)
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
int ourLevelNumber = 0;

ArrayList<String> ourLevelStack = new ArrayList<String>();

class Level extends GameState
{
  Level(String aLevelName, String aPreviousLevel)
  {    
    super(aLevelName);
    ourLevelNumber++;
    myLevelNumber = ourLevelNumber;
    myPreviousLevel = aPreviousLevel;
    if(myPreviousLevel != null)
      ourLevelStack.add(myPreviousLevel);
  }
  
  public String GetInstructionName(int anIndex)
  {
    return myName + "_Instruction_" + anIndex;
  }
  
  public boolean OnInit()
  {
    ConfigData initData = myLevelConfig.GetChild("Init");
    
    if(myLevelConfig.HasChild("Timeline"))
      myTimeline = myLevelConfig.GetChild("Timeline");
    else
      myTimeline = new ConfigData(); 
      
     if(myLevelConfig.HasChild("Code"))
        myCode = myLevelConfig.GetChild("Code");
        
     if(myLevelConfig.HasChild("Instructions"))
     {
       myInstructions = myLevelConfig.GetChild("Instructions");
       if(!CheckFlags(myInstructions))
       {
           myInstructions = null;
       }
         
       while(myInstructions != null)
       {
         if(!myInstructions.HasChild(str(myNumberOfInstructions)))
           break;
         
         Actor instruction = new Actor(GetInstructionName(myNumberOfInstructions));
         instruction.myDrawLayer = 4;
         instruction.Init(myInstructions.GetChild(str(myNumberOfInstructions)));
         AddToLevel(instruction);
         myNumberOfInstructions++;
       }
       if(myNumberOfInstructions > 0)
         ChangeInstructions(0);
    }
    LogLn("myNumberOfInstructions: " + myNumberOfInstructions + " " + myName);
    boolean result = super.OnInit();
   
    return result;
  }  
  
  public void OnSetFromConfig(ConfigData aConfig) 
  {
    if(aConfig.HasData("OnStart"))
    {
      FireTrigger(aConfig.GetData("OnStart"));
    }
  }
  
  public boolean OnUpdate(float aDeltaTime)   
  {
    float lastFrameTime = myTimeActive - aDeltaTime;
    if(myTimeline != null)
    {
      HashMap<String, ConfigData> temp = new HashMap<String, ConfigData>();
      //Iterator<Map.Entry<String, ConfigData> > iter = myTimeline.myChildren.keySet().iterator();
      temp.putAll(myTimeline.myChildren);
      for(String s : temp.keySet())
      {
        float time = Float.parseFloat(s);
        if(/*time > lastFrameTime &&*/time < myTimeActive)
        {
          ConfigData data = myTimeline.myChildren.get(s);
          if(data.HasData("TriggerName"))
          {
            Trigger(data.GetData("TriggerName"));
          }
          else
          {
            Trigger(data);
          }
          myTimeline.myChildren.remove(s);
          
         myTimeline.DebugPrint(0);
        }
      }
    }    
    
    return super.OnUpdate(aDeltaTime);
  }
  
  public void ChangeInstructions(int anInstruction)
  {
    if(myCurrentInstruction == anInstruction)
      return;
      
      if(myCurrentInstruction >= 0)
        myActors.get(GetInstructionName(myCurrentInstruction)).SetVisible(false);
        
      myCurrentInstruction = anInstruction;
      myActors.get(GetInstructionName(myCurrentInstruction)).StartFadeIn(2);
      
      if(myActors.containsKey("PreviousButton")) 
        myActors.get("PreviousButton").myIsDisabled = myCurrentInstruction == 0;
      if(myActors.containsKey("NextButton"))
        myActors.get("NextButton").myIsDisabled = myCurrentInstruction >= myNumberOfInstructions - 1;
  }
  
  public void AddDelayedTrigger(ConfigData aConfig)
  {
    float delay = Float.parseFloat(aConfig.GetData("Delay"));
    float triggerTime = myTimeActive + delay;
    myTimeline.myChildren.put(str(triggerTime), aConfig.GetChild("Trigger"));
  }
  
  public void AddDelayedTrigger(float aDelay, ConfigData aConfig)
  {
    float triggerTime = myTimeActive + aDelay;
    myTimeline.myChildren.put(str(triggerTime), aConfig);
  }
  
  public boolean OnTrigger(ConfigData aConfig)
  {
    if(aConfig.HasData("HideInstructions"))
    {      
      if(myCurrentInstruction >= 0)
        myActors.get(GetInstructionName(myCurrentInstruction)).myIsVisible = false;
        
      if(myActors.containsKey("PreviousButton")) 
        myActors.get("PreviousButton").SetVisible(false);
      
      if(myActors.containsKey("NextButton"))
        myActors.get("NextButton").SetVisible(false);
    }
    return false;
  }
  
  public boolean OnTrigger(String aTrigger)
  {
    LogLn("Trigger: " + aTrigger);
    if(aTrigger.equals("TRIGGER_LEVEL_BACK"))
    {
      String previousLevel = ourLevelStack.get(ourLevelStack.size()-1);
      SetNextLevel(previousLevel, null);  
      ourLevelStack.remove(previousLevel);
      myIsActive = false;
      return true;
    }
    else if(aTrigger.equals("TRIGGER_NEXT_INSTRUCTION"))
    {
      if(myCurrentInstruction < myNumberOfInstructions - 1)
      {
        ChangeInstructions(myCurrentInstruction + 1);        
      }
      return true;
    }
    else if(aTrigger.equals("TRIGGER_PREVIOUS_INSTRUCTION"))
    {
      if(myCurrentInstruction > 0)
      {
        ChangeInstructions(myCurrentInstruction - 1);
      }
      return true;
    }
    else if(aTrigger.equals("TRIGGER_RELOAD_LEVEL"))
    {
      ReloadLevel();
      return true;
    }
    
    return false;
  }
  
  public void OnDraw()
  {      
    if(false && myCode != null)
    {
      fill(0,0,0); 
      textAlign(LEFT, TOP);
      String code = myCode.GetData("Text");
      code = code.replace("<br>", "\n");
      println(code);
      PVector pos = GetVector2FromLine(myCode.GetData("Position"));
      text(code, pos.x, pos.y);
    }
    
    /*tint(0, 153, 204);
    Texture t = new Texture("mothsinlivingroom.png");
    t.DrawFullScreen();
    noTint();*/
    
    if(myState != GameStateState.RUNNING)
    {
      super.OnDraw();
    }
  }
  
  public boolean ProcessInput(char aKey)
  {
    //println("key: " + aKey);
     if(aKey == ESC)
     {
       gsManager.AddState(new PauseMenu());
       return true;
     }
     else if(aKey == 'f' || aKey == 'F')
     {
       SetNextLevel(myLevelConfig.GetChild("Init").GetData("NextLevel"), null);
       return true;
     }    
     else if(aKey == 'r' || aKey == 'R')
     {
       ReloadLevel();
       return true;
     }      
     
     for(Pawn actor : myActors.values())
     {
       if(actor.ProcessInput(aKey))
         return true;
     }
    
    if(ourMouseInfo)
    {      
      if(myHoveredActor != null)
      {
        if(aKey == CODED && keyCode == CONTROL && mousePressed && (mouseButton == LEFT))
        {
          myHoveredActor.myPosition.x = mouseX;
          myHoveredActor.myPosition.y = mouseY;
          LogLn(myHoveredActor.myName + ": newPos(" + PApplet.parseFloat(mouseX)/PApplet.parseFloat(width) + ", " + PApplet.parseFloat(mouseY)/PApplet.parseFloat(height) + ")");
        }
        else
        {
          PVector sizeChange = new PVector(0,0);
          if(aKey == '+')
            sizeChange.x = 1;
          else if(aKey == '-')
            sizeChange.x = -1;
          else if(aKey == '1')
            sizeChange.y = 1;
          else if(aKey == '2')
            sizeChange.y = -1;
            
          if(sizeChange.magSq() != 0)
          {
             myHoveredActor.mySize.x += sizeChange.x;
             myHoveredActor.mySize.y += sizeChange.y;
              LogLn(myHoveredActor.myName + ": newScale(" + myHoveredActor.mySize.x/PApplet.parseFloat(width) + ", " + myHoveredActor.mySize.y/PApplet.parseFloat(height) + ")");
          }
        }
      }
    }
     return false;
  }
  
  public boolean OnClicked()
  {
    return super.OnClicked();
  }
    
  int myCurrentInstruction = -1;
  int myNumberOfInstructions = 0;
  int myLevelNumber;
  String myPreviousLevel;
  ConfigData myTimeline;
  ConfigData myCode;
  ConfigData myInstructions;  
};



class ConfigData
{
  public boolean SetData(BufferedReader aReader)
  {
    if(aReader == null)
    {
      Error("SetData Failed, aReader is null");
      return false;
    }
    
    int childDepth = 0;
    String line = null;
    int lineNumber = 0;
    while(true)
    {
      try
      {
        line = aReader.readLine();
        lineNumber++;
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
      
      line = line.trim();
      
      if(IsLineAComment(line))
        continue;
      
      if(IsLineStartOfTable(line))
      {
        childDepth++;
        String id = GetKeyFromLine(line);
        ConfigData data = new ConfigData();
        if(!data.SetData(aReader))
          return false;
          
        if(myChildren.containsKey(id))
        {
          Error("Already contains a entry called: " + id);
          return false;
        }
        myChildren.put(id, data);
        childDepth--;
        continue;
      }
      
      if(IsLineEndOfTable(line))
      {
        if(childDepth <= 0)
          return true;
          
        continue;
      }
      
      String theKey = GetKeyFromLine(line);
      String theValue = GetValueFromLine(line);
     if(myData.containsKey(theKey))
      {
        Error("Already contains a entry called: " + theKey);
        return false;
      }
      myData.put(theKey, theValue);
    }
    return true;
  }

  public boolean HasChild(String anID)
  {
    return myChildren.containsKey(anID);
  }

  public ConfigData GetChild(String anID)
  {
    if(myChildren.containsKey(anID))
      return myChildren.get(anID);
      
    Error("ERROR, FAILED TO GET CHILD: " + anID); //<>// //<>//
    return new ConfigData();
  }
  
  public boolean HasData(String anID)
  {
    return myData.containsKey(anID);
  }
  
  public String GetData(String anID)
  {
    if(myData.containsKey(anID))
      return myData.get(anID);
      
    Error("ERROR, FAILED TO GET DATA: " + anID);
    return "";
  }
  
  public void PrintIndention(int anIndention, String aString)
  {
    for(int i = 0; i < anIndention; i++)
      aString = "  " + aString;
    LogLn(aString);
  }
  
  public void DebugPrint(int anIndention)
  {
    for(Map.Entry entry : myData.entrySet())
    {
      PrintIndention(anIndention, entry.getKey() + " = " + entry.getValue());
    }
    
    for(Map.Entry entry : myChildren.entrySet())
    {
      PrintIndention(anIndention, entry.getKey() + " = ");
      PrintIndention(anIndention, "{");
      ConfigData d = (ConfigData)entry.getValue();
      d.DebugPrint(anIndention + 1);
      PrintIndention(anIndention, "}");
    }
  }
  
  public Set<String> GetChildKeys()
  {
    return myChildren.keySet();
  }
  
  HashMap<String, String> myData = new HashMap<String, String>();
  HashMap<String, ConfigData> myChildren = new HashMap<String, ConfigData>();
};

class LevelConfig
{
  LevelConfig(String aLevelConfig)
  {
    myConfigName = aLevelConfig;
    String filePath = dataPath("Levels/" + aLevelConfig + "/level.config");
    BufferedReader reader = createReader(filePath);
    if(reader == null)
    {
      Error("FAILED TO OPEN CONFIG: " + filePath);
      return;
    }
    
    myRoot = new ConfigData();
    myRoot.SetData(reader);
    DebugPrint();
  }
  
  public boolean HasChild(String anID)
  {
    return myRoot.HasChild(anID);
  }
  
  public ConfigData GetChild(String anID)
  {
    return myRoot.GetChild(anID);
  }
  
  public void DebugPrint()
  {
    LogLn("-----------");
    LogLn("Config: " + myConfigName);
    LogLn("");
    myRoot.DebugPrint(0);
    LogLn("-----------");
    LogLn("");
  }
  
  ConfigData myRoot;
  String myConfigName;
};
class LocManager
{
  LocManager() { myDefaultLanguage = "sv-SE"; } // "en-GB"
  
  public void LoadLanguage(String aLanguage)
  {
    HashMap<String, String> text = new HashMap<String, String>();
    LogLn("Loading: " + aLanguage);
    BufferedReader reader = createReader(dataPath(aLanguage + "/Text/main.txt"));
    String line = null;
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
        LogLn("End of file");
        break;
      }
        
      int index = line.indexOf(":");
      if(index == -1)
      {
        Warning("couldn't find ':'");
      }
      else
      {
        String theKey = line.substring(0, index);
        String theValue = line.substring(index+1);
        LogLn("key: " + theKey + ", value: " + theValue);
        text.put(theKey, theValue);
      }
    }
    myLocText.put(aLanguage, text);
    myCurrentLanguage = aLanguage;
  }
  
  
  public String GetText(LocText aLocText)
  {
    HashMap<String, String> text = myLocText.get(myCurrentLanguage);
    if(text.containsKey(aLocText.myTextID))
      return text.get(aLocText.myTextID);
      
    //println("Failed to find text for id '" + aLocText.myTextID + "' trying fallback language:
    
    return aLocText.myTextID;
  }
  
  public PImage GetTexture(String aTextureName)
  {
    if(myTextures.containsKey(aTextureName))
      return myTextures.get(aTextureName);
    
    String filePath = dataPath(GetImagePath() + aTextureName);
    LogLn("Try Loading Texture: " + filePath);
    File f = new File(filePath);
    if(!f.exists())
    {
      filePath = dataPath("Images/" + aTextureName);
      f = new File(filePath);
      if(!f.exists())
      {
        Error("FAILED TO GET IMAGE: " + aTextureName);
        return null;
      }
    }
    
    LogLn("Loading Texture: " + filePath);
    
    PImage image = loadImage(filePath);      
    if(image == null)
    {
      Error("FAILED TO GET IMAGE: " + aTextureName);
      return null;
    }
    
    //image.resize(width, height);
    myTextures.put(aTextureName, image);
    //LogLn("Failed to find text for id '" + aLocText.myTextID + "' trying fallback language:
    return image;
  }
  
  public String GetImagePath()
  {
    return myCurrentLanguage + "/Images/";
  }
  
  public void SwitchLanguage()
  {
    if(myCurrentLanguage == "en-GB")
      myCurrentLanguage = "sv-SE";
    else
      myCurrentLanguage = "en-GB";
      
    ReloadImages();    
  }
  
  public void SetLanguage(String aLanguage)
  {
    myCurrentLanguage = aLanguage;
    ReloadImages();  
  }
  
  public void ReloadImages()
  {
    myTextures.clear();
    for(Texture texture : myTextureList)
    {
      texture.ReloadImage();
    }
  }
  
  String myDefaultLanguage;  
  String myCurrentLanguage;
  HashMap<String, HashMap<String, String>> myLocText = new HashMap<String, HashMap<String, String>>(); 
  HashMap<String, PImage> myTextures = new HashMap<String, PImage>();
  ArrayList<Texture> myTextureList = new ArrayList<Texture>();
};

class LocText
{
  LocText(String aTextID) { myTextID = aTextID; }
  public String GetText()
  {
    return locManager.GetText(this);
  }
  
  public void DrawText(int aX, int aY)
  {
    noStroke();
    fill(255,255,255,255);
      text(GetText(), aX, aY);     
  }
  
  public void DrawText(PVector aPos)
  {
    DrawText((int)aPos.x, (int)aPos.y);     
  }
  
  String myTextID;
};

class Texture
{
  Texture(String aTextureName, Boolean aIsFullScreen) 
  { 
    myTextureID = aTextureName; 
    myIsFullScreen = aIsFullScreen;
    if(aIsFullScreen)
      GetTexture().resize(width, height);
    locManager.myTextureList.add(this);
  }
  
  public void ReloadImage()
  {
    if(myIsFullScreen)
      GetTexture().resize(width, height);
  }
  
  public void SetSize(PVector aSize)
  {
      GetTexture().resize((int)aSize.x, (int)aSize.y);
  }
  
  public PImage GetTexture() 
  {
    return locManager.GetTexture(myTextureID);
  }   
  
  public void Draw(PVector aPos, PVector aSize)
  {
    image(GetTexture(), aPos.x, aPos.y, aSize.x, aSize.y);
  }
  
  public void DrawBackground()
  {
    background(GetTexture());
  }
  
  public void DrawFullScreen()
  {
    image(GetTexture(), width/2, height/2, width, height);
  }
  
  String myTextureID;
  boolean myIsFullScreen;
}
class PauseMenu extends GameState
{
  PauseMenu() 
  { 
    super("PauseMenu");
    myFadeInTime = 0.25f;
    myFadeOutTime = 0.25f;
    myFadeColor = color(0,0,0,128);
    myDrawWhileTransitioning = false;
    myIsQuitting = false;
    
    myPauseTexture = new Texture("Quit_Background.png", false);
  }
  
  public boolean ProcessInput(char aKey)
  {
    LogLn("Process Input: " + aKey + "/" + ESC);
     if(aKey == ESC)
     {
       myIsActive = false;
       return true;
     }
     else if(aKey == 'q' || aKey == 'Q')
     {
       gsManager.AddToQueue(new FrontEnd());
       myIsActive = false;
       myFadeColor = color(0,0,0,255);
       myIsQuitting = true;
       return true;
     }
     return false;
  }
  
  public boolean OnTrigger(String aTrigger)
  {
    if(aTrigger.equals("TRIGGER_UNPAUSE"))
    {
       myIsActive = false;
      return true;
    }
    
    return false;
  }
  
  public float GetFadePercent()
  {
    if(myIsQuitting)
      return myFadePercent;
      
    return 1-myFadePercent;
  }
      
  public void Draw()
  {      
    OnDraw();
    if(myState == GameStateState.RUNNING)
    {
      fill(248, 236, 194, 255);
      PVector size = GetPercentToScreen(new PVector(0.4f, 0.375f));
      myPauseTexture.Draw(new PVector(width/2, height/2), size);
      //rect(width/2, height/2, size.x, size.y);
      //fill(0);
      //text("Pause", width/2, height/2);      
      for(Pawn actor : myActors.values())
      {
        actor.Draw(actor == myHoveredActor);
      }
    }
    
    DebugDraw();
  }
  
  boolean myIsQuitting;
  Texture myPauseTexture;
};
PVector ourBoundingBoxBuffer = new PVector(width * 0.1f, height * 0.1f);

class Pawn implements Comparable<Pawn> 
{
  Pawn(String aName)
  {
    myName = aName;
  }
  
  public int compareTo(Pawn aPawn)
  {
    return constrain(myDrawLayer - aPawn.myDrawLayer, -1, 1); 
  }
    
  public void Init(ConfigData aConfig)
  {
    myConfig = aConfig;
      
    SetFromConfig(myConfig);
      
    OnInit(); 
    
    if(myConfig.HasChild("IfFlags"))
    {
      ConfigData ifFlags = myConfig.GetChild("IfFlags");
      for(String theKey : ifFlags.GetChildKeys())
      {
        ConfigData action = ifFlags.GetChild(theKey); 
        if(CheckFlags(action))
        {
          SetFromConfig(action);          
        }
      }
    }
    
    if(myConfig.HasChild("IfFlagSet"))
    {
      ConfigData ifFlagSet = myConfig.GetChild("IfFlagSet");
      for(String theKey : ifFlagSet.GetChildKeys())
      {
        if(ourSaveGame.HasFlagSet(theKey))
        {
          SetFromConfig(ifFlagSet.GetChild(theKey));
        }
      }
    }
    if(myConfig.HasChild("IfFlagNotSet"))
    {
      ConfigData ifFlagNotSet = myConfig.GetChild("IfFlagNotSet");
      for(String theKey : ifFlagNotSet.GetChildKeys())
      {
        if(!ourSaveGame.HasFlagSet(theKey))
        {
          SetFromConfig(ifFlagNotSet.GetChild(theKey));
        }
      }
    }
  }
  
  public void SetFromConfig(ConfigData aConfig)
  {
    if(aConfig.HasData("IsHidden"))
      myIsVisible = !aConfig.GetData("IsHidden").equals("true");      
         
    if(aConfig.HasData("StartPosition"))
      myPosition = GetVector2FromLine(aConfig.GetData("StartPosition"));
      
    if(myConfig.HasData("IsDisabled"))
      myIsDisabled = myConfig.GetData("IsDisabled").equals("true");
      
    if(aConfig.HasData("DrawLayer"))
      myDrawLayer = Integer.parseInt(aConfig.GetData("DrawLayer"));
      
    OnSetFromConfig(aConfig);
  }
  
  public boolean Trigger(ConfigData aConfig)
  {
    boolean handled = false;
    if(aConfig.HasData("SetVisible"))
    {
      SetVisible(aConfig.GetData("SetVisible").equals("true"));
      handled = true;
    }
    if(aConfig.HasData("StartFadeIn"))
    {
      StartFadeIn(Float.parseFloat(aConfig.GetData("StartFadeIn")));
      handled = true;
    }
    if(aConfig.HasData("StartFadeOut"))
    {
      StartFadeOut(Float.parseFloat(aConfig.GetData("StartFadeOut")));
      handled = true;
    }
    
    if(aConfig.HasData("SetPosition"))
    {
      myPosition = GetVector2FromLine(aConfig.GetData("SetPosition"));
    }
    
    return OnTrigger(aConfig) | handled; 
  }
  
  public void Update(float aDeltaTime)
  {
    if(myIsFadingIn || myIsFadingOut)
    {
      if(!myIsVisible)
      { //<>// //<>//
        SetVisible(true);
      }
      
      float length = myFadeEndTime - myFadeStartTime;
      float timeSinceStart = ourFrameRate.myLastTime - myFadeStartTime;
      myFadePercent = timeSinceStart / length;
      if(myIsFadingOut)
        myFadePercent = 1 - myFadePercent;
      
      if(myFadeEndTime <= ourFrameRate.myLastTime)
      {
        if(myIsFadingIn)
          myFadePercent = 1;
        
        if(myIsFadingOut)  
        {
          myFadePercent = 0;
          SetVisible(false);
        }
        myIsFadingIn = false;
        myIsFadingOut = false;
        
      }
    }
    
    if(!myIsVisible)
      return;
      
    OnUpdate(aDeltaTime);
  }
  
  public void StartFadeIn(float aTime)
  {
      myFadeStartTime = ourFrameRate.myLastTime;
      myFadeEndTime = myFadeStartTime + (1000 * aTime);
      myIsFadingIn = true;
  }
  
  public void StartFadeOut(float aTime)
  {
      myFadeStartTime = ourFrameRate.myLastTime;
      myFadeEndTime = myFadeStartTime + (1000 * aTime);
      myIsFadingOut = true;
  }
  
  public void Draw(boolean isSelected)
  {      
    if(!myIsVisible)
      return;
      
    tint(255, 255 * myFadePercent);
    OnDraw(isSelected);
  }
  
  public boolean Clicked()
  {
    if(!myIsVisible)
      return false;
      
    if(!IsSelectable())
      return false;
      
    return OnClicked();
  }
  
  public boolean IsSelectable()
  {
    return myIsSelectable;
  }
    
  public PVector GetBoundingBoxSize()
  {
    return new PVector(mySize.x + ourBoundingBoxBuffer.x, mySize.y + ourBoundingBoxBuffer.y);
  }
  
  public void DebugDraw(boolean aIsSelected)
  {    
    if(!myIsVisible)
      return;
    // TODO:CW - STYLE  
    pushStyle();
    stroke(255, 0,0);  
    noFill();
    rectMode(CENTER);
    
    OnDebugDraw(aIsSelected);
    
    PVector boundingBox = GetBoundingBoxSize();
    rect(myPosition.x, myPosition.y, boundingBox.x, boundingBox.y);
    
    noStroke();
    popStyle();
  }
  
  public boolean IsMouseOver()
  {      
    if(!myIsVisible)
      return false;
      
    PVector boundingBox = GetBoundingBoxSize();
    if((myPosition.x + boundingBox.x/2) < mouseX)
      return false;
      
    if((myPosition.x - boundingBox.x/2) > mouseX)
      return false;
      
    if((myPosition.y + boundingBox.y/2) < mouseY)
      return false;
      
    if((myPosition.y - boundingBox.y/2) > mouseY)
      return false;     
      
    return true;
  }
  
  public boolean ProcessInput(char aKey)
  {
    if(!myIsVisible)
      return false;
      
    return OnProcessInput(aKey);
  }
  
  public void SetVisible(boolean aIsVisible)
  {
    if(myIsVisible == aIsVisible)
      return;
      
    if(!aIsVisible)
      myIsFadingIn = false;
    else
      myIsFadingOut = false;
    
    LogLn("SetVisible (" + myName + ") - " + aIsVisible);
    myIsVisible = aIsVisible;
    if(myIsVisible && myConfig.HasData("OnShow"))
      FireTrigger(myConfig.GetData("OnShow"));
    else if(!myIsVisible && myConfig.HasData("OnHide"))
      FireTrigger(myConfig.GetData("OnHide"));
    OnVisibilityChanged();
  }
  
  // Virtual Functions
  public void OnInit() {}
  public void OnSetFromConfig(ConfigData aConfig) {}
  public boolean OnTrigger(ConfigData aConfig) { return false; }
  public boolean OnTrigger(String aTrigger) { return false; }
  public void OnUpdate(float aDeltaTime) {}
  public void OnDraw(boolean isSelected) {}
  public boolean OnClicked() { return false; }
  public void OnDebugDraw(boolean aIsSelected) {}
  public boolean OnProcessInput(char aKey) { return false; }
  public void OnVisibilityChanged() {}
  
  // Variable
  String myName = "INVALID";
  PVector myPosition = new PVector(width/2, height/2);
  PVector mySize = new PVector(100, 100);  
  boolean myIsSelectable = false;
  boolean myIsDisabled = false;
  boolean myIsVisible = true;
  boolean myIsFadingIn = false;
  boolean myIsFadingOut = false;
  float myFadeStartTime = -1;
  float myFadeEndTime = -1;
  float myFadePercent = 1;
  int myDrawLayer = 0;
  
  ConfigData myConfig = null;
};


public boolean CheckFlags(ConfigData aConfig)
{    
  if(aConfig.HasChild("CheckAllFlags"))
  {
    ConfigData checkFlags = aConfig.GetChild("CheckAllFlags");
    for(String theFlag : checkFlags.myData.keySet())
    {
      if(ourSaveGame.HasFlagSet(theFlag) != IsTrue(checkFlags.GetData(theFlag)))
        return false;
    }   
    return true;
  } 
  else if(aConfig.HasChild("CheckAnyFlags"))
  {
    ConfigData checkFlags = aConfig.GetChild("CheckAnyFlags");
    for(String theFlag : checkFlags.myData.keySet())
    {
      if(ourSaveGame.HasFlagSet(theFlag) == IsTrue(checkFlags.GetData(theFlag)))
        return true;
    }
    return false;
  }
  return true;
}

class SaveGame
{
  public void SetFlag(String aFlagName)
  {
    LogLn("SetFlag: " + aFlagName);
    myFlags.add(aFlagName);
  }
  
  public void ClearFlag(String aFlagName)
  {
    LogLn("ClearFlag: " + aFlagName);
    myFlags.remove(aFlagName);  
  }
  
  public void UpdateFlags(ConfigData aConfig)
  {
    for(String flag : aConfig.myData.keySet())
    {
      if(IsTrue(aConfig.GetData(flag)))
        SetFlag(flag);          
      else
        ClearFlag(flag);
    }
  }
  
  public boolean HasFlagSet(String aFlagName)
  {
    return myFlags.contains(aFlagName);
  }
  
  public void NewGame()
  {
    myFlags.clear();
  }
  
  public void PrintFlags()
  {
    LogLn("Flags: ");
    for(Object flag : myFlags.toArray())
    {
      LogLn(" - " + flag);
    }
    LogLn();
  }
  
  // Variables
  HashSet<String> myFlags = new HashSet<String>();
};
boolean ourNeedsToFadeMusic = false;
  
class SoundManager
{
  public void PlayMusic(String aFileName)
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
  
  public void Update(float aDeltaTime)
  {
    if(myDuckTime > ourFrameRate.myLastTime)
    {
      SetMusicVolume(0.1f);
    }
    else// if(myDuckTime > 0)
    {
      SetMusicVolume(lerp(myCurrentVolume, 1, 0.05f));
    }   
    if(myIsMuted)
    {
      SetMusicVolume(0);
    }
    
    if(myCurrentMusic != null)
    {
      int timePlaying = millis() - myMusicStartTime;
      float timePlayingF = PApplet.parseFloat(timePlaying) / 1000;
      if(myCurrentMusic.duration() < timePlayingF + 1)  // Hack to loop sounds without it crashing... :'(
      {
        myCurrentMusic.jump(1);
        myMusicStartTime = millis();
      }
    }
  }
  
  public boolean PlayMusic(SoundFile aSound)
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
  
  public void StopMusic()
  {
    if(myCurrentMusic != null)
    {
      println("stopMusic");
      SetMusicVolume(0.001f);
      myCurrentMusic.stop();
      myCurrentMusic = null;
    }
    //myIsMuted = true;
  }
  
  public void SetMusicVolume(float aVolume)
  {
    if(myCurrentMusic != null)
    {
      //LogLn("SetMusicVolume: " + aVolume + ": MaxVolume" + myMaxVolume);
      myCurrentVolume = aVolume;
      myCurrentMusic.amp(aVolume * myMaxVolume);
    }
  }
  
  public void PlayErrorSound()
  {
    if(myErrorSound == null)
      myErrorSound = new SoundFile(ourThis, "Audio/ErrorSound.wav");
    
    myDuckTime = ourFrameRate.myLastTime + 2000;
    myErrorSound.play();
  }
  
  public void PlaySuccessSound()
  {
    if(mySuccessSound == null)
      mySuccessSound = new SoundFile(ourThis, "Audio/SuccessSound.wav");
      
    myDuckTime = ourFrameRate.myLastTime + 2000;
    mySuccessSound.play();
  }
  
  public void ToggleMute()
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
class SplashScreen extends GameState
{
  SplashScreen() { super("SplashScreen"); }
  public boolean OnInit()
  {
    background(0);
    myUpdateTime = 2;
    return super.OnInit();
  }
  /*
  boolean OnStart(float aDeltaTime) { return true; }
  boolean OnEnd(float aDeltaTime) { return true; }
  */
  public boolean OnUpdate(float aDeltaTime) 
  {
    myUpdateTime -= aDeltaTime;
    
    return myUpdateTime <= 0; 
  }
  
  float myUpdateTime;
  public void OnDraw()
  {
    //text("Splash Screen", width/2, height/2);
    
    super.OnDraw();
  }
};
enum TextInputTypes
{
  FLOAT,
  INTEGER,
  VECTOR2I,
  VECTOR2F
};

class TextInput extends Pawn
{
  //TextInput(String aType, ConfigData aConfig)
  TextInput(String aName)
  {
    super(aName);
    myIsSelectable = true;
    //myParent = aParent;
    //myInputBox = gsManager.myCurrentState.AddTextField("Test");  
  }
  
  public void OnInit()
  {    
    myCurrentPos = myPosition.copy();
    
    
    //myInputBox.setPosition(myPosition.x, myPosition.y).setSize(100, 50);
    
    String type = myConfig.GetData("Type");
    if(type.equals("Vector2i"))
    {
      myType = TextInputTypes.VECTOR2I;
      myInputBox.setInputFilter(ControlP5.INTEGER);  
    }
    
    if(myConfig.HasData("Text"))
      myText = new LocText(myConfig.GetData("Text"));
      
    if(myConfig.HasData("StartValue"))
    {
      myCurrentValue = myConfig.GetData("StartValue");      
      myInputBox.setValue(myCurrentValue);
    }
      
    myInputBox.setVisible(myIsVisible);
  }
  
  public void OnDraw(boolean aIsSelected)
  { 
    textAlign(LEFT, TOP);
    String resolvedText = myText.GetText();
    resolvedText = resolvedText.replaceAll("%s", myCurrentValue);    
    noStroke();
    if(myIsEditing)
      fill(255, 0, 0, 255);
    else
      fill(255, 255, 255, 255);
    mySize = new PVector(textWidth(resolvedText), 32);
    text(resolvedText, myPosition.x, myPosition.y);
  }
  
  public void OnVisibilityChanged()
  {
    myInputBox.setVisible(myIsVisible);
  }
  
  public void OnDebugDraw(boolean aIsSelected)
  {
    rectMode(CORNER);
  }
  
  public boolean OnProcessInput(char aKey)
  {
    if(!myIsEditing)
      return false;
    
    if(aKey >= '0' && aKey <= '9')
    {
      myCurrentValue = str(aKey);
      return true;
    }   
    
    return false;
  }
  
  public boolean IsMouseOver()
  {
    if(myInputBox.isMouseOver())
      return true;
      
    if((myPosition.x + mySize.x) < mouseX)
      return false;
      
    if((myPosition.x) > mouseX)
      return false;
      
    if((myPosition.y + mySize.y) < mouseY)
      return false;
      
    if((myPosition.y) > mouseY)
      return false;     
      
    return true;
  }
  
  public boolean OnClicked()
  {
    if(myIsEditing == false)
    {
      myCarrotPosition = myCurrentValue.length();
    }
    myIsEditing = true;
    return true;
  }
  
  TextInputTypes myType;
  
  boolean myHasMaxValue = false;
  boolean myHasMinValue = false;
  boolean myHasStartValue = false;
  LocText myText;
  Textfield myInputBox;
  
  int myCarrotPosition = 0;
  boolean myIsEditing = false;
  String myCurrentValue;
  
  PVector myCurrentPos;
  
  //ArrayList
}


public Pawn CreatePawn(String aName, ConfigData aConfig)
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

public String GetKeyFromLine(String aLine)
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

public String GetValueFromLine(String aLine)
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

public boolean GetBoolFromLine(String aLine)
{
  return GetValueFromLine(aLine).equals("true");
}

public boolean IsTrue(String aString)
{
  return aString.equals("true");
}

public boolean IsLineAComment(String aLine)
{
  return aLine.indexOf("//") == 0;
}

public boolean IsLineStartOfTable(String aLine)
{
  String text = aLine;
  int index = aLine.indexOf("=");
  if(index != -1)
  {
    text = text.substring(index+1).trim();
  }
  return text.indexOf("{") == 0;
}

public boolean IsLineEndOfTable(String aLine)
{
  String text = aLine.trim();
  int index = text.indexOf("}");
  if(index == -1)
    return false;
    
  return index == text.length() - 1;
}

public PVector GetVector2FromLine(String aLine)
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
      int xVal = PApplet.parseInt(xPercent * width);
      
      index = theValue.indexOf(")", index2);
      if(index != -1)
      {
        String yString = theValue.substring(index2+1, index).trim();
        float yPercent = Float.parseFloat(yString);
        int yVal = PApplet.parseInt(yPercent * height);
        return new PVector(xVal, yVal);
      }
    }
  }
 
  Error("FAILED TO GET VECTOR FROM LINE: " + aLine);
  return new PVector(0,0);
}

public int GetColorFromLine(String aLine)
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

public PVector GetRelativeSize(PVector aSourceSize)
{
  return new PVector(aSourceSize.x / ourSourceResolution.x * width, aSourceSize.y / ourSourceResolution.y * height);
}

public PVector GetRelativeSize(PImage aSourceImage)
{
  return new PVector(aSourceImage.width / ourSourceResolution.x * width, aSourceImage.height / ourSourceResolution.y * height);
}

public PVector GetPercentToScreen(PVector aPos)
{
  return new PVector(aPos.x * width, aPos.y * height);
}

public PVector GetScreenToPercent(PVector aPos)
{
  return new PVector(aPos.x / width, aPos.y / height);
}

public String LogPrefix()
{
  return "[" + ourFrameRate.myTotalFrames + "] ";
}

public void LogLn(String aString)
{
  if(ourIsLogging)
    println(LogPrefix() + aString);
}

public void LogLn()
{
  if(ourIsLogging)
    println();
}

public void Log(String aString)
{
  if(ourIsLogging)
    print(aString);
}

public void Warning(String aWarningMessage)
{
  println(LogPrefix() + "[WARN] " + aWarningMessage);
}

public void Error(String anErrorMessage)
{
  println(LogPrefix() + "[ERROR] " + anErrorMessage);
  ourSoundManager.PlayErrorSound();
  exit();
}
  public void settings() {  fullScreen(FX2D); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "ProgrammingGame" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
