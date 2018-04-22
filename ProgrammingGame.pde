import controlP5.*;

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


void FireTrigger(String aTrigger)
{
  if(aTrigger.equals("TRIGGER_QUIT_GAME"))
  {
    exit();
    return;
  }
  gsManager.myCurrentState.Trigger(aTrigger);
}

void setup()  
{
  ourThis = this;
  ourFrameRate = new FrameRate();
  fullScreen(FX2D);
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
 //<>// //<>//
void Fade(float aFadePercent, color aFadeColor)
{
  pushStyle();
  //color fillColor = g.fillColor;
  fill(red(aFadeColor), green(aFadeColor), blue(aFadeColor), alpha(aFadeColor) * aFadePercent);
  //println("Fade: " + aFadePercent);
  rect(width/2, height/2, width, height);
  //fill(fillColor);
  popStyle();
}

void keyPressed()
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

void mouseClicked()
{
  if(gsManager.MouseClick())
  {
  }
}

// Called every time a new frame is available to read
void movieEvent(Movie m) {
  m.read();
}

void controlEvent(ControlEvent theEvent) 
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

void Update()
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
    text("Mouse Pos: (" + mouseX + ", " + mouseY + ")\nMouse Percent: (" + float(mouseX)/float(width) + ", " + float(mouseY)/float(height) + ")", 0, 0);
    
  }
}










void draw()
{
  Update();
}