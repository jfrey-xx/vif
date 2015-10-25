
import geomerative.*;

RFont font;
String myText = "Points on Outline";
textHolder desc;


//----------------SETUP---------------------------------
void setup() {
  size(800, 600);
  background(255);
  RG.init(this); 
  font = new RFont("FreeSans.ttf", 100, CENTER);

  //CONFIGURE SEGMENT LENGTH AND MODE
  //SETS THE SEGMENT LENGTH BETWEEN TWO POINTS ON A SHAPE/FONT OUTLINE
  RCommand.setSegmentLength(10);//ASSIGN A VALUE OF 10, SO EVERY 10 PIXELS
  RCommand.setSegmentator(RCommand.UNIFORMLENGTH);

  desc = new textHolder(myText, font);
}

//----------------DRAW---------------------------------

void draw() {
  fill(255, 0, 0);
  noStroke();
  translate(width/2, height/2);
  desc.draw();
}

//////////////////////////////////////////////