
OculusRift oculus;

import geomerative.*;
import remixlab.proscene.*;
import remixlab.dandelion.core.*; // eg for Frame
import remixlab.dandelion.geom.*; // eg for Vec

// used by text* for streams
import edu.ucsd.sccn.LSL;
import AULib.*;

//boolean sketchFullScreen() {
//  return isFullScreen;
//}

// main scene, look control by keyboard
Scene proscene;
Frame mainFrame;
Frame textFrame;

textUniverse universe;

// scale of text
float worldRatio, zoomFactor;

// position for FPS
PVector positionFPS = new PVector(0, 0, -5);

// user's orientation
PVector position = new PVector(0, 0);

// for interaction, will adapt mouse position to VR
float cursorX = 0;
float cursorY = 0;

void setup() {
  size( 1920, 1080, P3D );
  frameRate(30);

  oculus = new OculusRift(this);
  oculus.enableHeadTracking();

  proscene = new Scene(this, scene);
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
  universe = new textUniverse(this, scene, proscene, textFrame, worldRatio, zoomFactor, "data.json");
}

// apply head transformation to frame (both from oculus and keyboard)
void updateReferenceFrame() {
  // retrieve headset orientation
  float[] orien = oculus.sensorOrientation();

  // apparently it's not truely euler angles, use same method as in source to get matrix
  // apply on the fly correct hand and keyboard transform
  //  PMatrix3D pmat = new PMatrix3D();
  // pmat.rotateY(orientation.x +  rotateLookY);
  // pmat.rotateX(-orientation.y + rotateLookX);
  // pmat.rotateZ(-orientation.z);

  // convert to proscene format and apply
  textFrame.setRotation(new Quat(orien[0], -orien[1], orien[2], orien[3]));
}

void draw() {
  updateReferenceFrame();
  oculus.draw();

  // adapt mouse movement to buffer size and pass info
  cursorX = mouseX * 0.5;
  cursorY = mouseY;
  textPicking.setCursor(new Vec(cursorX, cursorY, 0));
}

// Scene for OculusRift
void onDrawScene(int eye) {
  // stereo is easy with HMD: cameras are //
  if (eye == LEFT) {
    proscene.camera().setPosition(new Vec (-oculus.ipd()/2, 0, 0));
  } else {
    proscene.camera().setPosition(new Vec (oculus.ipd()/2, 0, 0));
  }
  proscene.beginDraw();
  proscene.endDraw();
}


public void mainDrawing(Scene s) {
  PGraphics pg = s.pg();

  pg.background(255);

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



void keyPressed() {
  // Reset head state
  if (key==' ') {
    // oculus.resetHeadState();
  }

  // Move
  if (keyCode==LEFT) {
    position.x += 20;
  }
  if (keyCode==RIGHT) {
    position.x -= 20;
  }
  if (keyCode==UP) {
    position.z += 20;
  }
  if (keyCode==DOWN) {
    position.z -= 20;
  }
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
  // pg.pushMatrix();
  // pg.translate(0, 0, topLeftEye.z());
  // pg.box(hudWidth, hudHeight, hudThickness);
  // pg.popMatrix();

  // virtual cursor
  pg.pushMatrix();
  pg.translate(virtualCursorX, virtualCursorY, virtualCursorZ);
  pg.box(cursorSize, cursorSize, hudThickness);
  pg.popMatrix();
  pg.popStyle();
}