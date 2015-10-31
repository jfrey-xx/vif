
/**
 Testing SimpleOculusRift Library
 
 Origin at level with the eye, 100 pixels == 1 decimeter
 
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

PVector position;
float scale;

Frame mainFrame;

PMatrix3D modelview;

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
  println(proscene.info());
  proscene.addDrawHandler(this, "mainDrawing");
  // our eye is the center of the world
  proscene.eye().setPosition(new Vec(0, 0, 0));

  mainFrame = new Frame(proscene);

  // place frame
  position = new PVector (0, 0, -5);
  scale = 0.01;

  // world/font ratio = 10
  area = new textArea(fb, proscene, new PVector (4, 3), position, scale);
  area.loadText("");
  pick = area.getPick();

  oculusRiftDev = new SimpleOculusRift(this, (PGraphics3D) fb, SimpleOculusRift.RenderQuality_Middle, false);
}

//----------------DRAW---------------------------------


void draw() {
  fb.beginDraw();
  fb.endDraw();

  oculusRiftDev.draw();

  pick.setCursor(new Vec(mouseX, mouseY, 0));
}

void onDrawScene(int eye, PMatrix3D proj, PMatrix3D modelview)
{
  proscene.beginDraw();
  this.modelview =  modelview;
  //proscene.applyModelView(proscene.toMat(modelview));
  proscene.setProjection(proscene.toMat(proj));
  proscene.endDraw();

  println("modelview:");
  modelview.print();
}

public void mainDrawing(Scene s) {
  PGraphics pg = s.pg();

  pg.background(255);
  drawGrid(pg, new PVector(0, -floorDist, 0), 10, 10);

  // fix orientation
  pg.rotateY(PI);
  pg.scale(-1);

  // text
  proscene.pushModelView();


  // un fix orientation just the time to apply corect transformation
  pg.rotateY(-PI);
  proscene.applyModelView(proscene.toMat(modelview));
  pg.rotateY(PI);
  area.draw();

  proscene.popModelView();

  // deal with FPS (have to place it manually)
  pg.pushMatrix();
  pg.translate(position.x, position.y, position. z);
  pg.fill(0, 0, 255);
  pg.scale(scale);
  pg.text(frameRate, 10, 10);
  pg.popMatrix();

  // show a cursor that is affected by shader, compensate for offset and cursor size
  pg.pushMatrix();
  pg.translate(0, 0, -1);
  pg.scale(scale);
  pg.rect(mouseX-0.5, mouseY-0.5, 1, 1);
  pg.popMatrix();
}

void keyPressed() {
  // center camera ??
  //scene.camera().fitScreenRegion(descArea);
  println("reset head orientation");
  oculusRiftDev.resetOrientation();
  proscene.eye().setPosition(new Vec(0, 0, 0));
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

    pg.line(pos, 0, -length*.5, 
    pos, 0, length*.5);
  }
  pg.popMatrix();
}

//////////////////////////////////////////////

