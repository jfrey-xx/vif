
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

Scene proscene;

textPicking pick;
textArea area;


//----------------SETUP---------------------------------
void setup() {
  size(1280, 800, P3D);
  frameRate(30);
  // noSmooth();

  // init geomerative
  RG.init(this); 
  RCommand.setSegmentLength(10);
  RCommand.setSegmentator(RCommand.UNIFORMLENGTH);

  proscene = new Scene(this);

  // place frame
  PVector position = new PVector (0, 0, -5);
  float scale = 0.01;

  pick = new textPicking(proscene, position, scale);

  // world/font ratio = 10
  area = new textArea(this.g, pick, new PVector (4, 3), position, scale);
  area.loadText("");

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

  // fix orientation
  rotateY(PI);
  scale(-1);
  // text
  area.draw();

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

