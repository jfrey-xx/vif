
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

PGraphics fb;

//----------------SETUP---------------------------------
void setup() {
  size(1280, 800, P3D);
  frameRate(30);

  // Create framebuffer
  fb = createGraphics(1280, 800, P3D);

  // init geomerative
  RG.init(this); 
  RCommand.setSegmentLength(10);
  RCommand.setSegmentator(RCommand.UNIFORMLENGTH);

  proscene = new Scene(this, fb);
  proscene.addDrawHandler(this, "mainDrawing");

  // our eye is the center of the world
  proscene.eye().setPosition(new Vec(0, 0, 0));

  // place frame
  PVector position = new PVector (0, 0, -5);
  float scale = 0.01;

  pick = new textPicking(proscene, position, scale);

  // world/font ratio = 10
  area = new textArea(fb, pick, new PVector (4, 3), position, scale);
  area.loadText("");

  oculusRiftDev = new SimpleOculusRift(this, (PGraphics3D) fb, SimpleOculusRift.RenderQuality_Middle, false);
}

//----------------DRAW---------------------------------


void draw() {
  fb.beginDraw();
  fb.endDraw();

  oculusRiftDev.draw();
  // clear();
  // onDrawScene(0);

  pick.setCursor(new Vec(mouseX, mouseY, 0));
}

void onDrawScene(int eye, PMatrix3D proj, PMatrix3D modelview)
{
  proscene.beginDraw();
  proscene.setProjection(proscene.toMat(proj));
  proscene.setModelView(proscene.toMat(modelview));
  proscene.endDraw();
}

public void mainDrawing(Scene s) {
  PGraphics pg = s.pg();

  pg.background(255);
  drawGrid(pg, new PVector(0, floorDist, 0), 10, 10);

  // fix orientation
  // fb.rotateY(PI);
  //fb.scale(-1);
  // text
  area.draw();

  pg.fill(0, 0, 255);
  pg.scale(0.01);
  pg.text(frameRate, 10, 10);

  // show a cursor that is affected by shader, compensate for offset and cursor size
  pg.rect(mouseX-5, mouseY-5, 10, 10);
}

void keyPressed() {
  // center camera ??
  //scene.camera().fitScreenRegion(descArea);
  println("reset head orientation");
  oculusRiftDev.resetOrientation();
}

void drawGrid(PGraphics pg, PVector center, float length, int repeat)
{
  pg.pushMatrix();
  pg.translate(center.x, center.y, center.z);
  float pos;

  for (int x=0; x < repeat+1; x++)
  {
    pos = -length *.5 + x * length / repeat;

    pg.line(-length*.5, 0, pos, 
    length*.5, 0, pos);

    line(pos, 0, -length*.5, 
    pos, 0, length*.5);
  }
  pg.popMatrix();
}

//////////////////////////////////////////////

