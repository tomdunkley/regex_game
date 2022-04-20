import java.util.regex.PatternSyntaxException;
import processing.core.PApplet;
import processing.core.PFont;
import processing.core.PImage;
import processing.data.StringList;
import processing.data.Table;
import processing.data.TableRow;
import processing.sound.SoundFile;
import processing.video.Movie;


boolean somethingSelected = false;

PFont oswReg;

Runnable currentRunnable;

Runnable nextRunnable;

String[] names;

PImage menuBG;

Table oldHistory;

public float x(float xLoc) {
  return width * xLoc;
}

public float y(float yLoc) {
  return height * yLoc;
}


public void setup() {
  oldHistory = loadTable("data/userData/_default.csv", "header");
  menuBG = loadImage("data/imageAssets/animation/alleyBackground.jpg");
  menuBG.resize(width, height);
  menuBG.filter(11, 5.0F);
  background(menuBG);
  PImage titlebaricon = loadImage("data/imageAssets/animation/securityRobot.png");
  this.surface.setIcon(titlebaricon);
  names = loadStrings("data/textAssets/names.txt");
  oswReg = createFont("data/fonts/Oswald-Regular.ttf", x(0.02F));
  this.currentRunnable = new MainMenu();
  this.currentRunnable.initialise();
}

public void draw() {
  this.currentRunnable.step();
  if (this.nextRunnable != null) {
    this.currentRunnable = this.nextRunnable;
    this.currentRunnable.initialise();
  } 
  this.nextRunnable = this.currentRunnable.stopRunning();
}

public void keyPressed() {
  this.currentRunnable.onKeyPress();
}

public void mouseReleased() {
  this.currentRunnable.onMouseRelease();
}

public void mousePressed() {
  this.currentRunnable.onMousePress();
}

public void movieEvent(Movie m) {
  m.read();
}

class Animation {
  int robotImage = 2;
  
  Boolean skip = Boolean.valueOf(false);
  
  float amountMoved = 0.0F;
  
  int step;
  
  int index;
  
  StringList checkList;
  
  String[] whitelist;
  
  String[] blacklist;
  
  String pattern;
  
  String failcase = null;
  
  SoundFile[] soundfiles;
  
  SoundFile[] noMatch;
  
  Display animationScreen;
  
  String list;
  
  String name;
  
  Boolean allowedIn;
  
  Animation(String[] whiteList, String[] blackList, String correctPattern) {
    this.soundfiles = new SoundFile[] { new SoundFile(regex_game_remake_2022.this, "data/audioAssets/matchfound1.wav"), new SoundFile(regex_game_remake_2022.this, "data/audioAssets/disappointedcrowd.mp3") };
    this.noMatch = new SoundFile[11];
    int i;
    for (i = 0; i < this.noMatch.length; i++)
      this.noMatch[i] = new SoundFile(regex_game_remake_2022.this, "data/audioAssets/nomatch/" + i + ".wav"); 
    this.pattern = correctPattern;
    this.whitelist = whiteList;
    this.blacklist = blackList;
    this.animationScreen = new Display(new Visible[0], "data/imageAssets/animation/alleyBackground.jpg");
    this.animationScreen.addVisibleImage("data/imageAssets/animation/alleyBackgroundWindows.png", 0.0F, 0.0F, 1.0F, 1.0F);
    this.animationScreen.addVisibleImage("data/imageAssets/animation/securityRobot.png", 0.26F, 0.48F, 0.19F, 0.42F);
    this.animationScreen.addVisibleImage("data/imageAssets/animation/robot.png", 1.0F, 0.68F, 0.1F, 0.22F);
    this.animationScreen.addVisibleImage("data/imageAssets/animation/redRobot.png", 1.0F, 0.68F, 0.1F, 0.22F);
    this.step = 0;
    this.checkList = new StringList();
    for (i = 0; i < 2; i++) {
      for (int j = 0; j < 5; j++)
        this.checkList.append(String.valueOf(str(i)) + str(j)); 
    } 
    this.checkList.shuffle();
    this.index = 0;
  }
  
  public Boolean step() {
    if (this.index == 10) {
      if (this.failcase == null)
        this.failcase = getFailCase(this.pattern); 
      if (keyPressed && key == '\n') {
        background(menuBG);
        fill(0);
        text("LOADING...", x(0.502F), y(0.5F));
        text("LOADING...", x(0.5F), y(0.502F));
        fill(255);
        text("LOADING...", x(0.5F), y(0.5F));
        return Boolean.valueOf(false);
      } 
      background(menuBG);
      textAlign(3);
      if (this.failcase == null) {
        text("SUCCESS", x(0.5F), y(0.4F));
      } else {
        text("FAIL", x(0.5F), y(0.4F));
        for (int i = 0; i < 5; i++) {
          if (this.whitelist[i].equals(this.failcase)) {
            text(String.valueOf(this.failcase) + " WAS BARRED", x(0.5F), y(0.5F));
          } else if (this.blacklist[i].equals(this.failcase)) {
            text(String.valueOf(this.failcase) + " GOT THROUGH", x(0.5F), y(0.5F));
          } 
        } 
      } 
      text("PRESS ENTER TO CONTINUE", x(0.5F), y(0.6F));
      return Boolean.valueOf(true);
    } 
    if (this.skip.booleanValue()) {
      if (!keyPressed)
        this.index = 10; 
      return Boolean.valueOf(true);
    } 
    Boolean lastStepDone = Boolean.valueOf(false);
    if (this.step == 0) {
      if (this.checkList.get(this.index).charAt(0) == '0') {
        this.list = "white";
        this.name = this.whitelist[PApplet.parseInt((new StringBuilder(String.valueOf(this.checkList.get(this.index).charAt(1)))).toString())];
      } else {
        this.list = "black";
        this.name = this.blacklist[PApplet.parseInt((new StringBuilder(String.valueOf(this.checkList.get(this.index).charAt(1)))).toString())];
      } 
      if (match(this.name, this.pattern) != null) {
        this.allowedIn = Boolean.valueOf(true);
      } else {
        this.allowedIn = Boolean.valueOf(false);
      } 
      if (this.list == "black") {
        this.robotImage = 3;
      } else {
        this.robotImage = 2;
      } 
      if (this.index != 0)
        delay(100); 
      this.animationScreen.display();
      this.step++;
    } else if (this.step == 1) {
      delay(65);
      this.animationScreen.display();
      this.step++;
    } else if (this.step == 2) {
      delay(65);
      if (this.amountMoved <= 0.4F) {
        this.animationScreen.visibles[this.robotImage].move(-0.02F, 0.0F);
        this.amountMoved += 0.02F;
        this.animationScreen.display();
      } else {
        this.step++;
      } 
    } else if (this.step == 3) {
      delay(65);
      this.animationScreen.display();
      text("H", x(0.6F), y(0.6F));
      this.step++;
    } else if (this.step == 4) {
      delay(65);
      this.animationScreen.display();
      text("HI", x(0.6F), y(0.6F));
      this.step++;
    } else if (this.step == 5) {
      delay(65);
      this.animationScreen.display();
      text("HI ", x(0.6F), y(0.6F));
      this.step++;
    } else if (this.step == 6) {
      delay(65);
      this.animationScreen.display();
      text("HI I", x(0.6F), y(0.6F));
      this.step++;
    } else if (this.step == 7) {
      delay(65);
      this.animationScreen.display();
      text("HI I'", x(0.6F), y(0.6F));
      this.step++;
    } else if (this.step == 8) {
      delay(65);
      this.animationScreen.display();
      text("HI I'M", x(0.6F), y(0.6F));
      this.step++;
    } else if (this.step == 9) {
      delay(200);
      this.animationScreen.display();
      text("HI I'M " + this.name, x(0.6F), y(0.6F));
      this.step++;
    } else if (this.step == 10) {
      delay(900);
      this.animationScreen.display();
      if (this.allowedIn.booleanValue()) {
        this.soundfiles[0].play();
      } else {
        int rn = PApplet.parseInt(random(-7.5F, 10.5F));
        if (rn < 0)
          rn = 0; 
        this.noMatch[rn].play();
        while (this.noMatch[rn].isPlaying())
          println("playing"); 
      } 
      this.step++;
    } else if (this.step == 11) {
      if (this.list == "white" && !this.allowedIn.booleanValue()) {
        int rn = PApplet.parseInt(random(0.5F, 4.5F));
        SoundFile soundfile = new SoundFile(regex_game_remake_2022.this, "data/audioAssets/annoyedrobot/" + rn + ".wav");
        soundfile.play();
      } 
      this.step++;
    } else if (this.step == 12) {
      delay(65);
      if (this.amountMoved <= 1.1F && !this.allowedIn.booleanValue()) {
        this.animationScreen.visibles[this.robotImage].move(-0.02F, 0.0F);
        this.amountMoved += 0.02F;
        this.animationScreen.display();
      } else {
        this.step++;
      } 
    } else if (this.step == 13) {
      delay(65);
      if (this.amountMoved <= 0.55F && this.allowedIn.booleanValue()) {
        this.animationScreen.visibles[this.robotImage].move(-0.02F, 0.0F);
        this.amountMoved += 0.02F;
        this.animationScreen.display();
      } else {
        this.step++;
      } 
    } else if (this.step == 14) {
      this.animationScreen.visibles[this.robotImage].move(this.amountMoved, 0.0F);
      this.amountMoved = 0.0F;
      this.animationScreen.display();
      this.step++;
    } else if (this.step == 15) {
      delay(65);
      lastStepDone = Boolean.valueOf(true);
      this.step = 0;
      this.index++;
    } 
    if (lastStepDone.booleanValue() && ((this.list == "black" && this.allowedIn.booleanValue()) || (this.list == "white" && !this.allowedIn.booleanValue()))) {
      if (this.allowedIn.booleanValue()) {
        this.soundfiles[1].play();
        this.animationScreen.visibles[0].move(1.1F, 0.0F);
      } 
      this.animationScreen.display();
      this.failcase = this.name;
      this.index = 10;
    } 
    return Boolean.valueOf(true);
  }
  
  public void skip() {
    this.skip = Boolean.valueOf(true);
  }
  
  public String getFailCase(String pattern) {
    int i;
    for (i = 0; i < this.whitelist.length; i++) {
      String[] testMatch = match(this.whitelist[i], pattern);
      if (testMatch == null)
        return this.whitelist[i]; 
    } 
    for (i = 0; i < this.blacklist.length; i++) {
      String[] testMatch = match(this.blacklist[i], pattern);
      if (testMatch != null)
        return this.blacklist[i]; 
    } 
    return null;
  }
}

class VisibleImage implements Visible {
  float xLoc;
  
  float yLoc;
  
  PImage image;
  
  VisibleImage(String imageFile, float x, float y, float wid, float hgt) {
    xLoc = x(x);
    yLoc = y(y);
    image = loadImage(imageFile);
    image.resize(PApplet.parseInt(x(wid)), PApplet.parseInt(y(hgt)));
  }
  
  VisibleImage(String imageFile, float x, float y) {
    xLoc = x(x);
    yLoc = y(y);
    image = loadImage(imageFile);
  }
  
  public void display() {
    image(image, xLoc, yLoc);
  }
  
  public void move(float x, float y) {
    xLoc += x(x);
    yLoc += y(y);
  }
}

class Display {
  Visible[] visibles;
  
  PImage bg;
  
  Display(Visible[] itemsToDisplay, String backgroundLocation) {
    this.visibles = itemsToDisplay;
    this.bg = loadImage(backgroundLocation);
    this.bg.resize(width, height);
  }
  
  public void display() {
    background(this.bg);
    for (int i = 0; i < this.visibles.length; i++)
      this.visibles[i].display(); 
  }
  
  public void addVisible(Visible visible) {
    this.visibles = (Visible[])concat(this.visibles, new Visible[] { visible });
  }
  
  public void addVisibleImage(String imageLocation, float x, float y) {
    this.visibles = (Visible[])concat(this.visibles, new VisibleImage(imageLocation, x, y));
  }
  
  public void addVisibleImage(String imageLocation, float x, float y, float wid, float hgt) {
    this.visibles = (Visible[])concat(this.visibles, new Visible[] { new VisibleImage(imageLocation, x, y, wid, hgt) });
  }
}

class VisibleRectConstructor implements Visible {
  float xLoc;
  
  float yLoc;
  
  float xLen;
  
  float yLen;
  
  public void display() {
    rect(xLoc, yLoc, xLen, yLen);
  }
  
  public void move(float x, float y) {
    xLoc -= x(x);
    yLoc -= y(y);
  }
}

class VisibleRect extends VisibleRectConstructor {
  VisibleRect(float x, float y, float wid, float hgt) {
    xLoc = x(x);
    yLoc = y(y);
    xLen = x(wid);
    yLen = y(hgt);
  }
}

class Button extends VisibleRectConstructor {
  String stringValue;
  
  PImage image;
  
  Runnable buttonAction;
  
  Button(Runnable Action, float xLocation, float yLocation, float xLength, float yLength, String displayValue) {
    xLoc = x(xLocation);
    yLoc = y(yLocation);
    xLen = x(xLength);
    yLen = y(yLength);
    this.stringValue = displayValue;
    this.buttonAction = Action;
  }
  
  Button(Runnable Action, float xLocation, float yLocation, PImage displayPImage) {
    xLoc = x(xLocation);
    yLoc = y(yLocation);
    image = displayPImage;
    this.buttonAction = Action;
  }
  
  Button(Runnable Action, float xLocation, float yLocation, float xLength, float yLength, PImage displayPImage) {
    xLoc = x(xLocation);
    yLoc = y(yLocation);
    image = displayPImage;
    image.resize(round(x(xLength)), round(y(yLength)));
    this.buttonAction = Action;
  }
  
  Button(float xLocation, float yLocation, float xLength, float yLength, String displayValue) {
    xLoc = x(xLocation);
    yLoc = y(yLocation);
    xLen = x(xLength);
    yLen = y(yLength);
    this.stringValue = displayValue;
  }
  
  public void display() {
    if (image == null) {
      rect(xLoc, yLoc, xLen, yLen);
      fill(0);
      textSize(0.4F * yLen);
      textAlign(3);
      text(this.stringValue, xLoc + 0.5F * xLen, yLoc + 0.66F * yLen);
      fill(255);
      textSize(x(0.02F));
    } else {
      image(image, xLoc, yLoc);
    } 
  }
  
  public void display(float x, float y) {
    if (image == null) {
      rect(x, y, xLen, yLen);
      fill(0);
      text(this.stringValue, xLoc + 0.5F * xLen, yLoc + 0.66F * yLen);
      fill(255);
    } else {
      image(image, x, y);
    } 
  }
  
  public Boolean checkIfPressed() {
    return (mousePressed && mouseX > xLoc && mouseY > yLoc && mouseX < xLoc + xLen && mouseY < yLoc + yLen) ? Boolean.valueOf(true) : Boolean.valueOf(false);
  }
  
  public void onClick() {
    this.buttonAction.initialise();
  }
}

class Regex implements Visible {
  float xLoc;
  
  float yLoc;
  
  float wid;
  
  int lastMouseX = -1;
  
  int lastMouseY = -1;
  
  String stringValue;
  
  String regexp;
  
  String inputType;
  
  String description = null;
  
  boolean isSelected;
  
  boolean isMovable = true;
  
  public void display() {
    if (this.stringValue.equals("Abc") && !this.isSelected && this.description == null) {
      if (mouseHere()) {
        rect(xLoc, yLoc - y(0.062F), x(0.22F), y(0.062F));
        fill(0);
        textAlign(37);
        text("You must enter a character!", xLoc + 15.0F, yLoc - y(0.062F), x(0.22F), y(0.062F));
      } 
      fill(255.0F, 50.0F, 50.0F);
    } 
    rect(xLoc, yLoc, this.wid, this.wid);
    fill(0);
    textAlign(3);
    text(this.stringValue, xLoc + 0.5F * this.wid, yLoc + 0.66F * this.wid);
    fill(255);
    if (mouseHere() && !somethingSelected && this.description != null) {
      textLeading(x(0.022F));
      rect(xLoc - x(0.2F), yLoc, x(0.2F), x(0.032F + 0.022F * (this.description.length() / 25)));
      textAlign(37);
      fill(0);
      text(this.description, xLoc - x(0.195F), yLoc, x(0.19F), x(0.032F + 0.022F * (this.description.length() / 25)));
      textAlign(3);
      fill(255);
    } 
  }
  
  public void move(float x, float y) {
    xLoc -= x(x);
    yLoc -= y(y);
  }
  
  Regex(float xLocation, float yLocation, String displayValue, String regexValue) {
    xLoc = x(xLocation);
    yLoc = y(yLocation);
    this.wid = x(0.04F);
    this.stringValue = displayValue;
    this.regexp = regexValue;
    this.inputType = "none";
    this.description = getDescription(regexValue);
  }
  
  Regex(float xLocation, float yLocation) {
    xLoc = x(xLocation);
    yLoc = y(yLocation);
    this.wid = x(0.04F);
    this.inputType = ":letter";
    this.stringValue = "Abc";
    this.regexp = "{A}}";
    this.description = getDescription(":letter");
  }
  
  public boolean mouseHere() {
    return (mouseX < xLoc + this.wid && mouseY < yLoc + this.wid && mouseY > yLoc && mouseX > xLoc);
  }
  
  public boolean mousePressedHere() {
    return (mouseHere() && mousePressed);
  }
  
  public void updateLocation() {
    if (this.stringValue.equals("Abc"))
      this.inputType = ":letter"; 
    if (!mousePressedHere() && this.isSelected) {
      this.isSelected = mousePressed;
      somethingSelected = mousePressed;
    } else if (mousePressedHere() && !this.isSelected && !somethingSelected) {
      this.isSelected = true;
      somethingSelected = true;
    } 
    if (!this.isSelected) {
      this.lastMouseX = -1;
      this.lastMouseY = -1;
    } else if (this.lastMouseX == -1) {
      this.lastMouseX = mouseX;
      this.lastMouseY = mouseY;
    } else {
      float changeX = (mouseX - this.lastMouseX);
      float changeY = (mouseY - this.lastMouseY);
      xLoc += changeX;
      yLoc += changeY;
      this.lastMouseX = mouseX;
      this.lastMouseY = mouseY;
    } 
    if (this.isSelected)
      this.description = null; 
    if (this.inputType.equals(":letter") && (this.stringValue.equals("_") || this.stringValue.equals("Abc") || this.stringValue.equals("")))
      if (this.isSelected) {
        if (PApplet.parseInt((millis() / 100)) % 2 == 0) {
          this.stringValue = "";
        } else {
          this.stringValue = "_";
        } 
      } else {
        this.stringValue = "Abc";
      }  
    if (keyPressed && this.isSelected && this.inputType.equals(":letter") && 
      match((new StringBuilder(String.valueOf(key))).toString(), "[a-z]") != null) {
      this.regexp = (new StringBuilder(String.valueOf(key))).toString().toUpperCase();
      this.stringValue = (new StringBuilder(String.valueOf(key))).toString().toUpperCase();
    } 
  }
  
  public boolean isOverPattern(Pattern pattern) {
    float X1 = pattern.xLoc, Y1 = pattern.yLoc;
    float X2 = X1 + this.wid * pattern.count, Y2 = Y1 + this.wid * pattern.count;
    float x1 = xLoc, y1 = yLoc;
    float x2 = x1 + this.wid, y2 = y1 + this.wid;
    return (((x1 > X1 && x1 < X2) || (x2 > X1 && x2 < X2)) && ((y1 > Y1 && y1 < Y2) || (y2 > Y1 && y2 < Y2)));
  }
  
  public String getDescription(String regex) {
    Table descTable = loadTable("data/textAssets/descriptions.csv", "header");
    try {
      return descTable.findRow(regex, 0).getString(1);
    } catch (NullPointerException nullpointerException) {
      return null;
    } 
  }
}

class Pattern implements Visible {
  Regex[] individual;
  
  float xLoc;
  
  float yLoc;
  
  float wid = x(0.04F);
  
  int count;
  
  int maxLen = 15;
  
  Pattern(Regex[] regexArray, float xLocation, float yLocation) {
    this.individual = regexArray;
    xLoc = xLocation;
    yLoc = yLocation;
    this.count = this.individual.length;
    for (int i = 0; i < this.count; i++) {
      (this.individual[i]).xLoc = xLoc + i * 0.04F;
      (this.individual[i]).yLoc = yLoc;
    } 
  }
  
  public String getPattern() {
    String regexValue = "";
    for (int i = 0; i < this.count; i++)
      regexValue = regexValue.concat((this.individual[i]).regexp); 
    return regexValue;
  }
  
  public void display() {
    for (int i = 0; i < this.count; i++)
      this.individual[i].display(); 
  }
  
  public void move(float x, float y) {}
  
  public boolean addToPattern(Regex regex, float maxX) {
    if (regex == null || this.count == this.maxLen)
      return false; 
    if (regex.yLoc + regex.wid > y(yLoc) && regex.xLoc > x(xLoc) - this.wid && (regex.xLoc < x(xLoc) + this.individual.length * this.wid || regex.xLoc < x(maxX))) {
      float x1 = regex.xLoc, x2 = regex.xLoc + this.wid;
      Regex[] temp = new Regex[this.count + 1];
      boolean added = false;
      for (int i = 0; i <= this.count; i++) {
        if (added) {
          temp[i] = this.individual[i - 1];
        } else if ((x(xLoc) + i * this.wid > x1 && x2 > x(xLoc) + i * this.wid) || (x1 < x(maxX) && i == this.count)) {
          temp[i] = regex;
          added = true;
        } else {
          temp[i] = this.individual[i];
        } 
      } 
      if (added)
        this.individual = temp; 
      this.count = this.individual.length;
      return added;
    } 
    return false;
  }
  
  public Regex pop(int index) {
    if (index >= this.individual.length || index < 0)
      return null; 
    Regex[] temp = new Regex[this.individual.length - 1];
    for (int i = 0; i < index; i++)
      temp[i] = this.individual[i]; 
    Regex returnValue = this.individual[index];
    for (int j = index; j < this.individual.length - 1; j++)
      temp[j] = this.individual[j + 1]; 
    this.individual = temp;
    this.count = this.individual.length;
    return returnValue;
  }
  
  public void updateLocation() {
    for (int i = 0; i < this.count && 
      !(this.individual[i]).isSelected; i++) {
      (this.individual[i]).xLoc = x(xLoc + i * 0.04F);
      (this.individual[i]).yLoc = y(yLoc);
    } 
  }
}

class EnterUsername implements Runnable {
  TypeBox input;
  
  public void initialise() {
    textAlign(3);
    textFont(oswReg);
    background(menuBG);
    this.input = new TypeBox(0.1F, 0.8F, 0.8F, 0.1F);
  }
  
  public void step() {
    background(menuBG);
    textSize(x(0.08F));
    fill(0);
    text("ENTER USERNAME", x(0.503F), y(0.2F));
    text("ENTER USERNAME", x(0.5F), y(0.203F));
    fill(255);
    text("ENTER USERNAME", x(0.5F), y(0.2F));
    this.input.display();
  }
  
  public void onKeyPress() {
    this.input.checkForUpdates();
  }
  
  public void onMouseRelease() {}
  
  public void onMousePress() {}
  
  public Runnable stopRunning() {
    if (keyPressed && key == '\n' && this.input.stringValue.length() > 0) {
      background(menuBG);
      fill(0);
      text("LOADING...", x(0.502F), y(0.5F));
      text("LOADING...", x(0.5F), y(0.502F));
      fill(255);
      text("LOADING...", x(0.5F), y(0.5F));
      return new LearnMode(this.input.stringValue);
    } 
    return null;
  }
}

class TypeBox implements Visible {
  float xLoc;
  
  float yLoc;
  
  float wid;
  
  float hgt;
  
  String stringValue = "";
  
  TypeBox(float xLocation, float yLocation, float xWidth, float yWidth) {
    xLoc = x(xLocation);
    yLoc = y(yLocation);
    this.wid = x(xWidth);
    this.hgt = y(yWidth);
  }
  
  public void display() {
    rect(xLoc, yLoc, this.wid, this.hgt);
    textAlign(3);
    textSize(x(0.04F));
    fill(0);
    text(this.stringValue, xLoc + 0.5F * this.wid, yLoc + 0.8F * this.hgt);
    fill(255);
    textSize(x(0.02F));
  }
  
  public void checkForUpdates() {
    if (key == '\b' && this.stringValue.length() >= 2) {
      this.stringValue = this.stringValue.substring(0, this.stringValue.length() - 1);
    } else if (key == '\b') {
      this.stringValue = "";
    } else if (match((new StringBuilder(String.valueOf(key))).toString(), "[A-Z]|[a-z]| ") != null && this.stringValue.length() < 15) {
      this.stringValue = String.valueOf(this.stringValue) + key;
    } 
  }
  
  public void move(float x, float y) {
    xLoc += x(x);
    yLoc += y(y);
  }
}

class LearnMode implements Runnable {
  Button button = null;
  
  String username;
  
  Pattern ptrn;
  
  Regex regex;
  
  Regex[] regexOptions = new Regex[0];
  
  PImage bg;
  
  Regex[] rgxArray = new Regex[0];
  
  String[] whitelist;
  
  String[] blacklist;
  
  String failtext = "";
  
  String failcasetext = "";
  
  String learningTile;
  
  Runnable doneState = null;
  
  int attempts = 0;
  
  Animation animation;
  
  Boolean animating = Boolean.valueOf(false);
  
  Boolean firstStepAfterAnimating = Boolean.valueOf(false);
  
  int maxLength = 15;
  
  LearnMode(String user) {
    this.username = user;
    Boolean done = Boolean.valueOf(false);
    while (!done.booleanValue()) {
      String[] tiles = getTilesFromTable(oldHistory);
      this.learningTile = tiles[0];
      if (this.learningTile.equals(":letter")) {
        int rn = PApplet.parseInt(random(0.5F, tiles.length - 0.5F));
        this.learningTile = tiles[rn];
        tiles[rn] = tiles[0];
        tiles[0] = this.learningTile;
      } 
      String correctptrn = null;
      while (correctptrn == null)
        correctptrn = generatePatternFromTiles(tiles); 
      String incorrectptrn = generateIncorrectPattern(correctptrn);
      String betterptrn = generateBetterPattern(correctptrn);
      this.maxLength = correctptrn.replace("{2}", "{").replace("[^", "-").length();
      this.regexOptions = new Regex[tiles.length];
      for (int i = 0; i < tiles.length; i++) {
        if (tiles[i].equals(":letter")) {
          this.regexOptions[i] = new Regex(0.9F, 0.1F * (i + 1));
        } else {
          this.regexOptions[i] = new Regex(0.9F, 0.1F * (i + 1), tiles[i], tiles[i]);
        } 
      } 
      this.failtext = "PRESS GO";
      this.failcasetext = "TO TEST";
      String[][] lists = getLists(correctptrn, incorrectptrn, betterptrn);
      if (lists != null) {
        this.whitelist = lists[0];
        this.blacklist = lists[1];
        done = Boolean.valueOf(true);
      } 
    } 
  }
  
  public String generateIncorrectPattern(String correctPattern) {
    if (this.learningTile.equals(".")) {
      int index = correctPattern.indexOf(this.learningTile);
      String start = correctPattern;
      start = start.substring(0, index);
      String end = correctPattern;
      end = end.substring(index + 1);
      return String.valueOf(start) + end;
    } 
    if (this.learningTile.equals("^") || this.learningTile.equals("$"))
      return correctPattern.replace(this.learningTile, ""); 
    if (this.learningTile.equals("[^"))
      return correctPattern.replace("^", ""); 
    if (this.learningTile.equals("?") || this.learningTile.equals("*")) {
      int index = correctPattern.indexOf(this.learningTile);
      String start = correctPattern;
      start = start.substring(0, index - 1);
      String end = correctPattern;
      end = end.substring(index + 1);
      return String.valueOf(start) + ".+" + end;
    } 
    if (this.learningTile.equals("+")) {
      int index = correctPattern.indexOf(this.learningTile);
      String start = correctPattern;
      start = start.substring(0, index - 1);
      String end = correctPattern;
      end = end.substring(index + 1);
      return correctPattern.charAt(index - 2) + correctPattern.charAt(index - 1) + "|" + correctPattern.charAt(index - 1) + correctPattern.charAt(index + 1);
    } 
    if (this.learningTile.equals("{2}"))
      return correctPattern.replace("{2}", ""); 
    if (this.learningTile.equals("[")) {
      String start = correctPattern.replace("]*", "]");
      start = start.substring(0, correctPattern.indexOf("["));
      String end = correctPattern;
      end = end.substring(correctPattern.indexOf("]") + 1);
      return String.valueOf(start) + ".*" + end;
    } 
    if (this.learningTile.equals("-"))
      return correctPattern.replace("[^", "_").replace("[", "[^").replace("_", "["); 
    if (this.learningTile.equals("(") || this.learningTile.equals("|")) {
      String start = correctPattern;
      start = start.substring(0, correctPattern.indexOf("("));
      String end = correctPattern;
      end = end.substring(correctPattern.indexOf(")") + 1);
      return correctPattern.substring(0, correctPattern.indexOf(")")).replace("(", "").replace("\001", "").replace("\002", "");
    } 
    if (match(this.learningTile, "\\d") != null)
      return correctPattern.replace("\\1", "").replace("\\2", ""); 
    if (match((new StringBuilder(String.valueOf(correctPattern.charAt(0)))).toString(), "[+?*]|[{]\\d[}]") != null)
      correctPattern = correctPattern.substring(1); 
    return correctPattern;
  }
  
  public String generateBetterPattern(String correctPattern) {
    if (this.learningTile.equals("*")) {
      int index = correctPattern.indexOf(this.learningTile);
      String start = correctPattern;
      start = start.substring(0, index);
      String end = correctPattern;
      end = end.substring(index + 1);
      return String.valueOf(start) + end;
    } 
    if (this.learningTile.equals("?"))
      return correctPattern.replace("?", ""); 
    if (this.learningTile.equals("+")) {
      int index = correctPattern.indexOf(this.learningTile);
      return correctPattern.replace(this.learningTile, str(correctPattern.charAt(index - 1)));
    } 
    if (this.learningTile.equals("[")) {
      int index = correctPattern.indexOf(this.learningTile);
      String start = correctPattern;
      start = start.substring(0, index + 1);
      String end = correctPattern;
      end = end.substring(index + 2);
      return String.valueOf(start) + "^1" + end;
    } 
    if (this.learningTile.equals("(")) {
      String firstGroup = correctPattern.substring(correctPattern.indexOf("("), correctPattern.indexOf(")") + 1);
      return String.valueOf(firstGroup) + firstGroup;
    } 
    if (match(this.learningTile, "\\d") != null)
      return ""; 
    return correctPattern;
  }
  
  public String[][] getLists(String correctptrn, String incorrectptrn, String betterptrn) {
    String[] white = new String[5];
    String[] black = new String[5];
    int whitecounter = 0;
    int blackcounter = 0;
    Boolean incorrectAdded = Boolean.valueOf(false);
    Boolean betterAdded = Boolean.valueOf(false);
    for (int i = 0; i < names.length; i++) {
      if (match(names[i], correctptrn) == null) {
        if (match(names[i], incorrectptrn) != null)
          incorrectAdded = Boolean.valueOf(true); 
        if (blackcounter < 5) {
          black[blackcounter] = names[i];
          blackcounter++;
        } else if (match(names[i], incorrectptrn) != null) {
          black[PApplet.parseInt(random(-0.5F, 4.5F))] = names[i];
        } 
      } else {
        if (match(names[i], betterptrn) != null)
          betterAdded = Boolean.valueOf(true); 
        if (whitecounter < 5) {
          white[whitecounter] = names[i];
          whitecounter++;
        } else if (match(names[i], betterptrn) != null) {
          white[PApplet.parseInt(random(-0.5F, 4.5F))] = names[i];
        } 
      } 
    } 
    if (blackcounter == 5 && whitecounter == 5 && betterAdded.booleanValue() && incorrectAdded.booleanValue())
      return new String[][] { white, black }; 
    return null;
  }
     //<>//
  public String[] getTilesFromTable(Table history) {
    String[] returnTiles = { ":letter" };
    boolean done = false;
    int rowIndex = 0; //<>//
    while (!done) {
      TableRow row = history.getRow(rowIndex);
      float rowSum = getRowSum(row);
      if (rowSum <= 1.0F || (random(1.0F) < 0.3F && returnTiles.length < 4)) {
        returnTiles = concat(new String[] { row.getString(0) }, returnTiles);
        if (row.getString(0).equals("[") || row.getString(0).equals("[^"))
          returnTiles = concat(returnTiles, new String[] { "]" }); 
        if (row.getString(0).equals("("))
          returnTiles = concat(returnTiles, new String[] { ")", "+" }); 
        if (row.getString(0).equals("-"))
          returnTiles = concat(returnTiles, new String[] { "[", "]" }); 
        if (row.getString(0).equals("\\1") || row.getString(0).equals("\\2"))
          returnTiles = concat(returnTiles, new String[] { "(", ")" }); 
        if (rowSum <= 1.0F)
          done = true; 
      } 
      rowIndex++;
      if (rowIndex >= history.getRowCount())
        break; 
    } 
    if (returnTiles.length == 0)
      returnTiles = history.getStringColumn("Tile"); 
    Boolean closeSquareState = Boolean.valueOf(false), openSquareState = Boolean.valueOf(false), plusState = Boolean.valueOf(false), openBracketState = Boolean.valueOf(false), closeBracketState = Boolean.valueOf(false);
    int i;
    for (i = 1; i < returnTiles.length; i++) {
      if (returnTiles[i] == "[")
        if (openSquareState.booleanValue()) {
          returnTiles[i] = returnTiles[returnTiles.length - 1];
          returnTiles = shorten(returnTiles);
        } else {
          openSquareState = Boolean.valueOf(true);
        }  
      if (i < returnTiles.length && returnTiles[i] == "]")
        if (closeSquareState.booleanValue()) {
          returnTiles[i] = returnTiles[returnTiles.length - 1];
          returnTiles = shorten(returnTiles);
        } else {
          closeSquareState = Boolean.valueOf(true);
        }  
      if (i < returnTiles.length && returnTiles[i] == "+")
        if (plusState.booleanValue()) {
          returnTiles[i] = returnTiles[returnTiles.length - 1];
          returnTiles = shorten(returnTiles);
        } else {
          plusState = Boolean.valueOf(true);
        }  
      if (i < returnTiles.length && returnTiles[i] == "(")
        if (openBracketState.booleanValue()) {
          returnTiles[i] = returnTiles[returnTiles.length - 1];
          returnTiles = shorten(returnTiles);
        } else {
          openBracketState = Boolean.valueOf(true);
        }  
      if (i < returnTiles.length && returnTiles[i] == ")")
        if (closeBracketState.booleanValue()) {
          returnTiles[i] = returnTiles[returnTiles.length - 1];
          returnTiles = shorten(returnTiles);
        } else {
          closeBracketState = Boolean.valueOf(true);
        }  
    } 
    if (returnTiles[0].equals("("))
      for (i = 0; i < returnTiles.length; i++) {
        if (returnTiles[i].equals("[") || returnTiles[i].equals("[^") || returnTiles[i].equals("]")) {
          returnTiles[i] = returnTiles[returnTiles.length - 1];
          returnTiles = shorten(returnTiles);
        } 
      }  
    return returnTiles;
  }
  
  public float getRowSum(TableRow row) {
    float total = 0.0F;
    for (int i = 1; i < 5; i++) {
      if (row.getFloat(str(i)) == row.getFloat(str(i)))
        total += row.getFloat(str(i)); 
    } 
    return total;
  }
  
  public String generatePatternFromTiles(String[] tiles) {
    String pattern = "";
    int index = 0;
    int squareBracketState = 0;
    int bracketState = 0;
    int groupAdded = 0;
    String tileAdding = "";
    int ptrnLength = PApplet.parseInt(random(1.5F, (2 * tiles.length)));
    int dotCount = 0;
    for (int i = 0; i < tiles.length; i++) {
      if (tiles[i] == ".") {
        dotCount = 1;
        break;
      } 
    } 
    while (bracketState != 0 || squareBracketState != 0 || pattern.length() < ptrnLength || match((new StringBuilder(String.valueOf(pattern.charAt(pattern.length() - 1)))).toString(), "[+?*{)]") != null) {
      index = PApplet.parseInt(random(-0.5F, tiles.length - 0.5F));
      tileAdding = tiles[index];
      if (tileAdding.equals(":letter"))
        {tileAdding = str(PApplet.parseChar(PApplet.parseInt(random(64.5F, 90.5F)))); }
      if (squareBracketState == 0 && pattern.length() > ptrnLength && (tiles[0] == "(" || match(tiles[0], "\\\\d") != null) && pattern.charAt(pattern.length() - 1) != '(')
        if (bracketState == 0) {
          if (groupAdded != 0) {
            tileAdding = tiles[0];
          } else {
            tileAdding = "(";
          } 
        } else {
          tileAdding = ")";
        }  
      if (pattern.length() > ptrnLength && (tiles[0].equals("[") || tiles[0].equals("[^")))
        if (squareBracketState == 0) {
          tileAdding = tiles[0];
        } else {
          pattern = String.valueOf(pattern) + "A";
          tileAdding = "]";
        }  
      if (match(tileAdding, "[A-Z]") != null && (pattern.length() == 0 || (pattern.charAt(pattern.length() - 1) != tileAdding.charAt(0) && pattern.charAt(pattern.length() - 1) != ')')) && (squareBracketState == 0 || random(1.0F) < 0.05F))
        if (match(tiles[0], "\\d") != null) {
          (new String[6])[0] = "A";
          (new String[6])[1] = "E";
          (new String[6])[2] = "M";
          (new String[6])[3] = "R";
          (new String[6])[4] = "S";
          (new String[6])[5] = ".";
          pattern = String.valueOf(pattern) + (new String[6])[PApplet.parseInt(random(-0.5F, 3.5F))];
        } else {
          pattern = String.valueOf(pattern) + tileAdding;
        }  
      if (tileAdding.equals("|") && squareBracketState == 0)
        pattern = String.valueOf(pattern) + tileAdding; 
      if (tiles[0] != "+" && match(tileAdding, "[\\\\][a-z]|[.]") != null && (pattern.length() == 0 || (pattern.charAt(pattern.length() - 1) != ')' && pattern.charAt(pattern.length() - 1) != '.' && pattern.charAt(pattern.length() - 1) != '+' && squareBracketState == 0)))
        pattern = String.valueOf(pattern) + tileAdding; 
      if (match(tileAdding, "\\d") != null && tileAdding.charAt(0) == '\\' && PApplet.parseInt(tileAdding.charAt(1)) - 48 <= groupAdded && pattern.length() != 0 && bracketState == 0 && squareBracketState == 0)
        pattern = String.valueOf(pattern) + tileAdding; 
      if (squareBracketState == 0 && match(tileAdding, "[+?*]|[{]\\d[}]") != null && pattern.length() != 0 && (
        !tileAdding.equals("{2}") || !tiles[0].equals("{2}") || pattern.charAt(pattern.length() - 1) == ']' || random(1.0F) < 0.1F))
        if (pattern.charAt(pattern.length() - 1) == ')' || pattern.charAt(pattern.length() - 1) == ']') {
          pattern = String.valueOf(pattern) + tileAdding;
        } else if (match((new StringBuilder(String.valueOf(pattern.charAt(pattern.length() - 1)))).toString(), "[A-z]") != null && pattern.charAt(pattern.length() - 1) != ']') {
          (new String[3])[0] = "A";
          (new String[3])[1] = "I";
          (new String[3])[2] = "U";
          (new String[6])[0] = "L";
          (new String[6])[1] = "S";
          (new String[6])[2] = "E";
          (new String[6])[3] = "O";
          (new String[6])[4] = "T";
          (new String[6])[5] = ".";
          pattern = String.valueOf(pattern.substring(0, pattern.length() - 1)) + (new String[3])[PApplet.parseInt(random(-0.5F, 2.5F))] + (new String[6])[PApplet.parseInt(random(-0.5F, 4.5F + dotCount))] + tileAdding;
        }  
      if (tileAdding.equals("[") && squareBracketState == 0 && bracketState == 0) {
        squareBracketState = 1;
        pattern = String.valueOf(pattern) + tileAdding;
      } 
      if (tileAdding.equals("[^") && squareBracketState == 0 && bracketState == 0) {
        squareBracketState = 1;
        pattern = String.valueOf(pattern) + tileAdding;
      } 
      if (tileAdding.equals("-") && squareBracketState == 0 && bracketState == 0) {
        int j = PApplet.parseInt(random(64.5F, 89.5F));
        pattern = String.valueOf(pattern) + "[" + PApplet.parseChar(j) + "-" + PApplet.parseChar(PApplet.parseInt(random(j + 0.5F, 90.5F))) + "]";
        squareBracketState = 0;
      } 
      if ((pattern.length() != 0 || match(tiles[0], "\\d") != null) && tileAdding.equals("(") && bracketState == 0 && squareBracketState == 0 && ((groupAdded != 0 && match(tiles[0], "\\d") == null) || groupAdded == 0)) {
        bracketState = 1;
        pattern = String.valueOf(pattern) + tileAdding;
      } 
      if (tileAdding.equals("]") && squareBracketState == 1 && pattern.charAt(pattern.length() - 1) != '[' && pattern.charAt(pattern.length() - 2) != '[') {
        squareBracketState = 0;
        pattern = String.valueOf(pattern) + tileAdding;
      } 
      if (tileAdding.equals(")") && bracketState == 1 && pattern.charAt(pattern.length() - 1) != '(' && (pattern.charAt(pattern.length() - 2) != '(' || match(tiles[0], "\\d") != null)) {
        bracketState = 0;
        pattern = String.valueOf(pattern) + tileAdding;
        groupAdded++;
      } 
      if (tileAdding.equals("^") && 
        pattern.length() == 0)
        pattern = String.valueOf(pattern) + tileAdding; 
    } 
    int rn = PApplet.parseInt(random(-0.5F, (tiles.length - 1)));
    if (tiles[rn].equals("$") || tiles[0].equals("$"))
      pattern = String.valueOf(pattern) + "$"; 
    if (pattern.indexOf(this.learningTile) != -1 || this.learningTile == ":letter")
      return pattern; 
    return null;
  }
  
  public void initialise() {
    this.bg = loadImage("data/imageAssets/backgrounds/circuit.jpg");
    textAlign(3);
    textFont(oswReg);
    this.bg.resize(width, height);
    this.bg.filter(11, 5.0F);
    this.ptrn = new Pattern(this.rgxArray, 0.1F, 0.86F);
    this.ptrn.maxLen = this.maxLength;
    this.regex = null;
    this.button = new Button(0.9F, 0.8725F, 0.05F, 0.075F, "GO");
    background(this.bg);
  }
  
  public void step() {
    if (this.animating.booleanValue()) {
      this.firstStepAfterAnimating = Boolean.valueOf(true);
      this.animating = this.animation.step();
      if (!this.animating.booleanValue()) {
        String failcase = this.animation.failcase;
        if (failcase == null) {
          this.failtext = "SUCCESS";
          this.failcasetext = "";
          nextLevel();
        } else {
          this.failtext = "FAIL";
          this.failcasetext = failcase;
        } 
      } 
      if (this.animation.index != 10)
        this.button.display(); 
      return;
    } 
    if (this.firstStepAfterAnimating.booleanValue())
      this.button = new Button(0.9F, 0.8725F, 0.05F, 0.075F, "GO"); 
    this.firstStepAfterAnimating = Boolean.valueOf(false);
    background(this.bg);
    line(x(0.095F), y(0.9F), x(0.105F + 0.04F * this.maxLength), y(0.9F));
    ellipse(x(0.095F), y(0.9F), x(0.005F), x(0.005F));
    ellipse(x(0.105F + 0.04F * this.maxLength), y(0.9F), x(0.005F), x(0.005F));
    rect(x(0.1F), y(0.1F), x(0.3F), y(0.7F));
    rect(x(0.5F), y(0.1F), x(0.3F), y(0.7F));
    textAlign(37);
    fill(0);
    text("WHITELIST (ALLOWED IN)", x(0.11F), y(0.15F));
    text("BLACKLIST (NOT ALLOWED IN)", x(0.51F), y(0.15F));
    int i;
    for (i = 0; i < this.whitelist.length; i++)
      text(this.whitelist[i], x(0.11F), y(0.2F + i * 0.05F)); 
    for (i = 0; i < this.blacklist.length; i++)
      text(this.blacklist[i], x(0.51F), y(0.2F + i * 0.05F)); 
    textAlign(3);
    fill(255);
    textSize(x(0.017F));
    textLeading(x(0.018F));
    text(String.valueOf(this.failtext) + "\n" + this.failcasetext, x(0.85F), y(0.9F));
    textSize(x(0.02F));
    for (i = 0; i < this.regexOptions.length; i++)
      this.regexOptions[i].display(); 
    if (this.regex != null)
      this.regex.updateLocation(); 
    this.ptrn.updateLocation();
    this.ptrn.display();
    if (this.button != null)
      this.button.display(); 
    if (this.regex != null)
      this.regex.display(); 
  }
  
  public void onKeyPress() {
    if (key == '\b')
      this.doneState = new MainMenu(); 
  }
  
  public void setupAnimation(String pattern) {
    this.animating = Boolean.valueOf(true);
    this.animation = new Animation(this.whitelist, this.blacklist, pattern);
  }
  
  public void nextLevel() { //<>// //<>//
    for (int i = 0; i < this.ptrn.individual.length; i++) {
      try { //<>//
        TableRow currentRow = oldHistory.findRow((this.ptrn.individual[i]).stringValue, 0); //<>//
        if (currentRow != null) { //<>//
          for (int j = 5; j >= 2; j--) { //<>//
            println(currentRow.getFloat(j - 1));
            println(str(currentRow.getFloat(j - 1)).equals("NaN"));
            if (!str(currentRow.getFloat(j - 1)).equals("NaN")) //<>//
              currentRow.setFloat(j, currentRow.getFloat(j - 1));  //<>//
          }  //<>//
          currentRow.setFloat(1, 1.0F / PApplet.parseFloat(this.attempts)); //<>//
        }  //<>//
      } catch (NullPointerException nullpointerException) { //<>//
        break; //<>//
      }  //<>//
    }  //<>//
    this.doneState = new LearnMode(this.username); //<>//
  }
  
  public Runnable stopRunning() {
    if (this.doneState != null) {
      background(menuBG);
      fill(0);
      text("LOADING...", x(0.502F), y(0.5F));
      text("LOADING...", x(0.5F), y(0.502F));
      fill(255);
      text("LOADING...", x(0.5F), y(0.5F));
    } 
    return this.doneState;
  }
  
  public void onMouseRelease() {
    if (!this.ptrn.addToPattern(this.regex, 0.7F)) {
      this.regex = null;
      somethingSelected = false;
    } 
  }
  
  public void onMousePress() {
    if (this.animating.booleanValue()) {
      if (this.button.checkIfPressed().booleanValue())
        this.animation.skip(); 
      return;
    } 
    if (this.button != null && this.button.checkIfPressed().booleanValue() && 
      this.button.stringValue.equals("GO")) {
      try {
        match(this.blacklist[0], this.ptrn.getPattern());
      } catch (PatternSyntaxException patternSyntaxException) {
        this.failtext = "FAIL";
        this.failcasetext = "INVALID\nEXPRESSION";
        this.regex = null;
        this.attempts++;
        return;
      } 
      setupAnimation(this.ptrn.getPattern());
      this.attempts++;
      this.button.stringValue = "SKIP";
    } 
    int i;
    for (i = 0; i < this.regexOptions.length; i++) {
      if (this.regexOptions[i].mousePressedHere()) {
        this.regex = new Regex((this.regexOptions[i]).xLoc / width, (this.regexOptions[i]).yLoc / width + (this.regexOptions[i]).wid * (1.1F + i * 1.1F) / width, (this.regexOptions[i]).stringValue, (this.regexOptions[i]).regexp);
        return;
      } 
    } 
    for (i = 0; i < this.ptrn.individual.length; i++) {
      if (this.ptrn.individual[i].mousePressedHere()) {
        this.regex = this.ptrn.pop(i);
        if (this.regex != null) {
          somethingSelected = true;
          this.regex.isSelected = true;
          return;
        } 
      } 
    } 
    this.regex = null;
  }
}

class Menu implements Runnable {
  Button[] buttons;
  
  PImage background = null;
  
  Menu(Button[] buttonArray) {
    this.buttons = buttonArray;
  }
  
  Menu() {
    buttons = new Button[0];
  }
  
  public void initialise() {
    textFont(oswReg);
    textAlign(3);
  }
  
  public void step() {
    if (background != null) {
      background(background);
    } else {
      background(menuBG);
    } 
    for (int i = 0; i < this.buttons.length; i++)
      this.buttons[i].display(); 
  }
  
  public void onKeyPress() {}
  
  public void onMouseRelease() {}
  
  public void onMousePress() {}
  
  public Runnable stopRunning() {
    for (int i = 0; i < this.buttons.length; i++) {
      if (this.buttons[i].checkIfPressed().booleanValue())
        return (this.buttons[i]).buttonAction; 
    } 
    return null;
  }
}

class MainMenu extends Menu {
  MainMenu() {
    buttons = new Button[] { new Button(new EnterUsername(), 0.3F, 0.1F, 0.4F, 0.2F, "Play"), new Button(new Tutorial(), 0.3F, 0.4F, 0.4F, 0.2F, "Tutorial"), new Button(new Quit(), 0.3F, 0.7F, 0.4F, 0.2F, "Quit") };
  }
}

class Tutorial implements Runnable {
  Movie REGX;
  
  PImage fg;
  
  Tutorial() {
    this.REGX = new Movie(regex_game_remake_2022.this, "imageAssets/RGX.mp4");
    this.REGX.volume(10.0F);
    this.fg = loadImage("data/imageAssets/backgrounds/tv.png");
    this.fg.resize(width, height);
  }
  
  public void initialise() {
    this.REGX.loop();
  }
  
  public void step() {
    fill(0);
    rect(0.0F, 0.0F, width, height);
    fill(255);
    image((PImage)this.REGX, x(0.23F), y(0.15F), x(0.41F), y(0.54F));
    image(this.fg, 0.0F, 0.0F);
  }
  
  public void onKeyPress() {}
  
  public void onMouseRelease() {}
  
  public void onMousePress() {}
  
  public Runnable stopRunning() {
    if (keyPressed && key == '\b') {
      this.REGX.stop();
      return new MainMenu();
    } 
    return null;
  }
}

class Quit implements Runnable {
  public void initialise() {
    exit();
  }
  
  public void step() {}
  
  public void onKeyPress() {}
  
  public void onMouseRelease() {}
  
  public void onMousePress() {}
  
  public Runnable stopRunning() {
    return null;
  }
}

public void settings() {
  fullScreen();
}

static interface Runnable {
  void initialise();
  
  void step();
  
  void onKeyPress();
  
  void onMouseRelease();
  
  void onMousePress();
  
  Runnable stopRunning();
}

static interface Visible {
  public static final boolean isMovable = false;
  
  void display();
  
  void move(float param1Float1, float param1Float2);
}
