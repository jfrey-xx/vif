
import geomerative.*;

RFont font;
String myText = "Points on Outline";
textHolder desc;

float lastWidth;
float lastHeight;


//----------------SETUP---------------------------------
void setup() {
  size(800, 900);
  lastWidth = width;
  lastHeight = height;
  surface.setResizable(true);
  RG.init(this); 


  //CONFIGURE SEGMENT LENGTH AND MODE
  //SETS THE SEGMENT LENGTH BETWEEN TWO POINTS ON A SHAPE/FONT OUTLINE
  RCommand.setSegmentLength(10);//ASSIGN A VALUE OF 10, SO EVERY 10 PIXELS
  RCommand.setSegmentator(RCommand.UNIFORMLENGTH);

  desc = new textHolder("FreeSans.ttf", 100);
  desc.setWidth(lastWidth*0.66);
  desc.addText("one");
  desc.addText("second", textType.BEAT);
  desc.addText(" et un et deux", textType.EMPHASIS);
  desc.addText("nst nstnstnst aw ll nrst nrstnstnstnstnrst s s s ");
}

//----------------DRAW---------------------------------


// check if window was resized and update internal state
boolean sizeChanged() {
  boolean change = false;
  if (lastWidth != width) {
    lastWidth = width;
    change = true;
  }
  if (lastHeight != height) {
    lastHeight = height;
    change = true;
  }
  return change;
}

void draw() {
  if (sizeChanged()) {
    desc.setWidth(lastWidth*0.66);
  }
  clear();
  background(255);
  fill(255, 0, 0);
  noStroke();
  text(frameRate, 10, 10);
  translate(0, 0);
  desc.draw();
  desc.drawDebug();
}

//////////////////////////////////////////////