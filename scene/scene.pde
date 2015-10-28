
import geomerative.*;
import remixlab.proscene.*;
import remixlab.dandelion.geom.*;

Scene scene;

RFont font;
textHolder desc;
Rect descArea;


//----------------SETUP---------------------------------
void setup() {
  size(800, 900, P3D);
  surface.setResizable(true);
  RG.init(this); 


  //CONFIGURE SEGMENT LENGTH AND MODE
  //SETS THE SEGMENT LENGTH BETWEEN TWO POINTS ON A SHAPE/FONT OUTLINE
  RCommand.setSegmentLength(10);//ASSIGN A VALUE OF 10, SO EVERY 10 PIXELS
  RCommand.setSegmentator(RCommand.UNIFORMLENGTH);

  desc = new textHolder(this.g, "FreeSans.ttf", 100);
  desc.setWidth(600);
  desc.addText("one");
  desc.addText("second", textType.BEAT);
  desc.addText(" et un et deux", textType.EMPHASIS);
  desc.addText("nst nstnstnst aw ", textType.SHAKE);

  scene = new Scene(this);
  descArea = new Rect(0, 0, (int)desc.group.getWidth(), (int)desc.group.getHeight()); 
  println("Rectarea center:", descArea.centerX(), ",", descArea.centerY());
}

//----------------DRAW---------------------------------


void draw() {
  clear();
  background(255);
  desc.draw();
  desc.drawDebug();
  fill(0, 0, 255);
  text(frameRate, 10, 10);
}

void keyPressed() {
  // center camera ??
  scene.camera().fitScreenRegion(descArea);
}
//////////////////////////////////////////////