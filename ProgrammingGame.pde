GameStateManager gsManager = new GameStateManager();
LocManager locManager = new LocManager();
AnimationManager ourAnimManager = new AnimationManager();
PFont font;

FrameRate ourFrameRate;
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
  ourFrameRate = new FrameRate();
  //fullScreen();
  //size(1280,800, FX2D);
  size(1280,800);
  font = loadFont("WhiteRabbit-32.vlw");
  textFont(font);
  noStroke();
  colorMode(RGB, 256);
  frameRate(120);
  rectMode(CENTER);
  imageMode(CENTER);

  textSize(32);
  textAlign(CENTER, CENTER);
  gsManager.AddState(new SplashScreen());
  gsManager.AddToQueue(new FrontEnd());
  locManager.LoadLanguage("sv-SE");
  locManager.LoadLanguage("en-GB");
  
  text("word", width/2, height/2);
}

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
    ourMouseInfo = !ourMouseInfo;
    
  if(key == 'q' || key == 'Q')
    ourIsLogging = !ourIsLogging;
    
  key = 0;
  keyCode = 0;
}

void mouseClicked()
{
  if(gsManager.MouseClick())
  {
  }
}

void Update()
{
  ourFrameRate.Update();
  
  gsManager.Update(ourFrameRate.myDeltaTime);
  
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