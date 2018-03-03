GameStateManager gsManager = new GameStateManager();
LocManager locManager = new LocManager();
AnimationManager ourAnimManager = new AnimationManager();

FrameRate ourFrameRate;
PVector ourSourceResolution = new PVector(2560, 1600);
boolean showFPS = false;
boolean ourMouseInfo = false;
boolean ourIsLogging = false;

boolean ourIsCtrlDown = false;


void FireTrigger(String aTrigger)
{
  gsManager.myCurrentState.Trigger(aTrigger);
}

void setup()
{
  //fullScreen();
  size(1280,800);
  noStroke();
  colorMode(RGB, 256);
  //frameRate(8);
  rectMode(CENTER);
  imageMode(CENTER);
  textSize(32);
  textAlign(CENTER, CENTER);
  gsManager.AddState(new SplashScreen());
  gsManager.AddToQueue(new FrontEnd());
  locManager.LoadLanguage("sv-SE");
  locManager.LoadLanguage("en-GB");
  ourFrameRate = new FrameRate();
}

void Fade(float aFadePercent, color aFadeColor)
{
  color fillColor = g.fillColor;
  fill(red(aFadeColor), green(aFadeColor), blue(aFadeColor), alpha(aFadeColor) * aFadePercent);
  rect(width/2, height/2, width, height);
  fill(fillColor);
}

void keyPressed()
{
  if(gsManager.ProcessInput(key))
    key = 0;
    
  if(key == 'l')
    locManager.SwitchLanguage();
    
  if(key == 'z')
    showFPS = !showFPS;
    
  if(key == 'x')
    ourMouseInfo = !ourMouseInfo;
    
  if(key == 'q')
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