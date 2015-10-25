
import geomerative.*;

RFont font;
String myText = "Points on Outline";
textHolder desc;


//----------------SETUP---------------------------------
void setup() {
  size(800, 900);
  RG.init(this); 


  //CONFIGURE SEGMENT LENGTH AND MODE
  //SETS THE SEGMENT LENGTH BETWEEN TWO POINTS ON A SHAPE/FONT OUTLINE
  RCommand.setSegmentLength(10);//ASSIGN A VALUE OF 10, SO EVERY 10 PIXELS
  RCommand.setSegmentator(RCommand.UNIFORMLENGTH);

  desc = new textHolder("FreeSans.ttf", 100);
  desc.setWidth(700);
  desc.addText("one");
  desc.addText("second", textType.BEAT);
  desc.addText(" et un et deux", textType.EMPHASIS);
  desc.addText("nst nstnstnst aw ll nrst nrstnstnstnstnrst s s s ");
}

//----------------DRAW---------------------------------

void draw() {
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