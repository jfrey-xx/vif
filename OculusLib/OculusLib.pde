
/**
 Testing SimpleOculusRift Library
 
 Origin at level with the eye, 100 pixels == 1 meter
 
 Head orientation to commands camera
 
 */

import geomerative.*;
import remixlab.proscene.*;
import remixlab.dandelion.geom.*;
import SimpleOculusRift.*;

SimpleOculusRift   oculusRiftDev;
float floorDist = 1.; // for grid, let's say we're seated

Scene scene;

RFont font;
textHolder desc;
Rect descArea;


//----------------SETUP---------------------------------
void setup() {
  noSmooth();
  size(1280, 800, P3D);
  frameRate(30);
  //surface.setResizable(true);
  RG.init(this); 


  //CONFIGURE SEGMENT LENGTH AND MODE
  //SETS THE SEGMENT LENGTH BETWEEN TWO POINTS ON A SHAPE/FONT OUTLINE
  RCommand.setSegmentLength(10);//ASSIGN A VALUE OF 10, SO EVERY 10 PIXELS
  RCommand.setSegmentator(RCommand.UNIFORMLENGTH);

  // 100 pixels for font will be one meter, in here, 
  desc = new textHolder(this.g, "FreeSans.ttf", 100, 0.01);
  desc.setWidth(6);
  desc.addText("one");
  desc.addText("second", textType.BEAT);
  desc.addText(" et un et deux", textType.EMPHASIS);
  desc.addText("nst nstnstnst aw ", textType.SHAKE);

  scene = new Scene(this);
  descArea = new Rect(0, 0, (int)desc.group.getWidth(), (int)desc.group.getHeight()); 
  println("Rectarea center:", descArea.centerX(), ",", descArea.centerY());

  oculusRiftDev = new SimpleOculusRift(this, SimpleOculusRift.RenderQuality_Middle);
}

//----------------DRAW---------------------------------


void draw() {
  oculusRiftDev.draw();

  // onDrawScene(0);
}

void onDrawScene(int eye)
{ 
  clear();
  background(255);
  drawGrid(new PVector(0, -floorDist, 0), 10, 10);

  translate(0, 0, -5);
  // fix orientation
  rotateY(PI);
  scale(-1);
  desc.draw();
  desc.drawDebug();
  fill(0, 0, 255);
  scale(0.01);
  text(frameRate, 10, 10);
}

void keyPressed() {
  // center camera ??
  //scene.camera().fitScreenRegion(descArea);
  println("reset head orientation");
  oculusRiftDev.resetOrientation();
}

void drawGrid(PVector center, float length, int repeat)
{
  pushMatrix();
  translate(center.x, center.y, center.z);
  float pos;

  for (int x=0; x < repeat+1; x++)
  {
    pos = -length *.5 + x * length / repeat;

    line(-length*.5, 0, pos, 
    length*.5, 0, pos);

    line(pos, 0, -length*.5, 
    pos, 0, length*.5);
  }
  popMatrix();
}

//////////////////////////////////////////////