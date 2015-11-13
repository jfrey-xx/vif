
/**
 Testing SimpleOculusRift Library
 
 Origin at level with the eye, 100 pixels == 1 decimeter
 
 Head orientation to commands camera
 
 */

import geomerative.*;
import remixlab.proscene.*;
import remixlab.dandelion.core.*; // eg for Frame
import remixlab.dandelion.geom.*; // eg for Vec
import SimpleOculusRift.*;

SimpleOculusRift   oculusRiftDev;
PGraphics fb;
// modelview returned by oculus
PMatrix3D modelview;

// for grid, let's say we're seated
float floorDist = 1.; 

// main scene, look control by keyboard
Scene proscene;
Frame mainFrame;
Frame textFrame;
float rotateLookX = 0;
float rotateLookY = 0;

textUniverse universe;


// scale of text
float worldRatio, zoomFactor;

// position for FPS
PVector positionFPS = new PVector(0, 0, -5);

// for interaction, will adapt mouse position to VR
float cursorX = 0;
float cursorY = 0;

//----------------SETUP---------------------------------
void setup() {
  size(1280, 800, P3D);
  frameRate(30);

  // Create framebuffer
  fb = createGraphics(640, 800, P3D);


  proscene = new Scene(this, fb);
  // add callback for draws
  proscene.addDrawHandler(this, "mainDrawing");
  // disable keyboard action: we will handle it ourselves
  proscene.disableKeyboardAgent();

  // our eye is the center of the world
  proscene.eye().setPosition(new Vec(0, 0, 0));

  mainFrame = new Frame(proscene);
  textFrame = new Frame(proscene);
  textFrame.setReferenceFrame(mainFrame);

  // world ratio
  worldRatio = 0.01;
  // halve text size
  zoomFactor = 0.5;
  universe = new textUniverse(this, fb, proscene, textFrame, worldRatio, zoomFactor, "data.json");

  oculusRiftDev = new SimpleOculusRift(this, (PGraphics3D) fb, SimpleOculusRift.RenderQuality_Middle, false);
}

//----------------DRAW---------------------------------


void draw() {   
  updateReferenceFrame();

  fb.beginDraw();
  fb.endDraw();
  oculusRiftDev.draw();

  // adapt mouse movement to buffer size and pass info
  cursorX = mouseX * fb.width / width;
  cursorY = mouseY * fb.height / height;
  textPicking.setCursor(new Vec(cursorX, cursorY, 0));
}

void onDrawScene(int eye, PMatrix3D proj, PMatrix3D modelview)
{
  proscene.beginDraw();
  this.modelview =  modelview;
  proscene.setProjection(proscene.toMat(proj));
  proscene.endDraw();
}

// apply head transformation to frame (both from oculus and keyboard)
void updateReferenceFrame() {
  // yaw, pitch, roll -- NB: again refeference is not the same from oculus and from proscene, hence weirdities to come with Y/X
  PVector orientation = oculusRiftDev.sensorOrientation();
  orientation.x -= rotateLookY;
  orientation.y += rotateLookX;
  Quat head = new Quat(orientation.y, -orientation.x, orientation.z);
  textFrame.setRotation(head);
}

public void mainDrawing(Scene s) {
  PGraphics pg = s.pg();

  pg.background(255);
  drawGrid(pg, new PVector(0, -floorDist, 0), 10, 10);

  // fix orientation
  s.rotateY(PI);
  s.scale(-1);

  // text
  pg.pushMatrix();
  textFrame.applyTransformation();
  // show debug with current matrix
  universe.draw();
  pg.popMatrix();  

  // deal with FPS (have to place it manually)
  pg.pushMatrix();
  pg.translate(positionFPS.x, positionFPS.y, positionFPS.z);
  pg.fill(0, 0, 255);
  pg.scale(worldRatio);
  pg.text(frameRate, 10, 10);
  pg.popMatrix();

  // nice HUD for cursor indication
  drawHud(s);
}


// reset / set orientation
void keyPressed() {
  println("Key pressed: [", key, "]");
  if (key == ' ') {
    println("reset head orientation and position");
    oculusRiftDev.resetOrientation();
    proscene.eye().setPosition(new Vec(0, 0, 0));
    rotateLookX = 0;
    rotateLookY = 0;
  } else if (keyCode == UP) {
    println("look up");
    rotateLookX -= 0.1;
  } else if (keyCode == DOWN) {
    println("look down");
    rotateLookX += 0.1;
  } else if (keyCode == LEFT) {
    println("look down");
    rotateLookY += 0.1;
  } else if (keyCode == RIGHT) {
    println("look down");
    rotateLookY -= 0.1;
  }
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

// cue for cursor
// FIXME: will break with scene manipulation. should use plane equation a projected line
void drawHud(Scene s) {
  Camera c = s.camera();
  PGraphics pg = s.pg();

  // virtual sreen posisition in world unit
  float worldZ = -4.9;
  // confert unit to coeff between eye planes (cf proscene doc)
  float screenZ =  c.zFar() / (c.zFar() - c.zNear()) * (1.0f - c.zNear() / (-worldZ));
  // get virtual srceen coordinates
  Vec topLeftScreen = new Vec(0, 0, screenZ);
  Vec bottomRightScreen = new Vec(c.screenWidth(), c.screenHeight(), screenZ);
  // corresponding world coordinates
  Vec topLeftEye = c.unprojectedCoordinatesOf(topLeftScreen);
  Vec bottomRightEye = c.unprojectedCoordinatesOf(bottomRightScreen);

  // println("topLeftScreen:", topLeftScreen, "topLeftEye:", topLeftEye, "bottomRightScreen:", bottomRightScreen, "bottomRightEye", bottomRightEye);

  // virtual screen size
  float hudWidth = bottomRightEye.x() - topLeftEye.x();
  float hudHeight = bottomRightEye.y() - topLeftEye.y();
  float hudThickness = 0.01;
  // virtual cursor size
  float cursorSize =  hudWidth*0.05; // ratio of virtual screen width
  float virtualCursorX = topLeftEye.x() + hudWidth * cursorX / c.screenWidth();
  float virtualCursorY = topLeftEye.y() + hudHeight * cursorY / c.screenHeight();
  // make thigs very right, adapt z do scene transformations (eg with mouse)
  float virtualCursorZ =  c.unprojectedCoordinatesOf(new Vec(cursorX, cursorY, screenZ)).z();


  pg.pushStyle();
  pg.fill(0, 0, 128, 5);

  // virtual srceen in center
  pg.pushMatrix();
  pg.translate(0, 0, topLeftEye.z());
  pg.box(hudWidth, hudHeight, hudThickness);
  pg.popMatrix();

  // virtual cursor
  pg.pushMatrix();
  pg.translate(virtualCursorX, virtualCursorY, virtualCursorZ);
  pg.box(cursorSize, cursorSize, hudThickness);
  pg.popMatrix();
  pg.popStyle();
}
//////////////////////////////////////////////
