
import geomerative.*;
import remixlab.proscene.*;
import remixlab.dandelion.core.*; // eg for Frame
import remixlab.dandelion.geom.*; // eg for Vec

// used by text* for streams
import edu.ucsd.sccn.LSL;
import AULib.*;

// handler for dk2 orientation and for drawing
OculusRift oculus;

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
float rotateLookX;
float rotateLookY;

// correction for neutral head position
Quat headCorrection = new Quat();

// for interaction, will adapt mouse position to VR
float cursorX = 0;
float cursorY = 0;

void setup() {
  // FIXME: workaround for LSLLink to find LSL lib, seems that jovr and its JNA collide otherwise
  System.setProperty("jna.library.path", sketchPath("code"));
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

  // reinit orientation
  resetHeadState();
}

// apply head transformation to frame (both from oculus and keyboard)
void updateReferenceFrame() {
  // retrieve headset orientation, new quaternion out of it
  float[] orien = oculus.sensorOrientation();
  Quat qorien = new Quat(orien[0], -orien[1], orien[2], orien[3]);

  // may reset orientation
  qorien.multiply(headCorrection);

  // two-step corretion for key board input
  Quat look = new Quat();
  look.fromEulerAngles(rotateLookY, 0, 0);
  qorien.multiply(look);
  look.fromEulerAngles(0, -rotateLookX, 0);
  qorien.multiply(look);

  textFrame.setRotation(qorien);
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

  if (keyPressed) {
    processKeyboard();
  }
}

// set orientation
// NB: used instead of  keyPressed() to handle repetition
void processKeyboard() {
  // Reset head state
  if (key==' ') {
    resetHeadState();
    println("reset head orientation");
  }

  // Move
  if (keyCode==LEFT) {
    rotateLookX += 0.1;
  }
  if (keyCode==RIGHT) {
    rotateLookX -= 0.1;
  }
  if (keyCode==UP) {
    rotateLookY += 0.1;
  }
  if (keyCode==DOWN) {
    rotateLookY -= 0.1;
  }
} 

// Update head correction to reset head position
void resetHeadState() {
  float[] orien = oculus.sensorOrientation();
  headCorrection = new Quat(orien[0], -orien[1], orien[2], orien[3]).inverse();
}

// cue for cursor
// FIXME: will break with scene manipulation. should use plane equation a projected line
void drawHud(Scene s) {
  Camera c = s.camera();
  PGraphics pg = s.pg();

  // virtual sreen posisition in world unit
  float worldZ = -4;
  // confert unit to coeff between eye planes (cf proscene doc)
  float screenZ =  c.zFar() / (c.zFar() - c.zNear()) * (1.0f - c.zNear() / (-worldZ));
  // get virtual srceen coordinates
  Vec topLeftScreen = new Vec(0, 0, screenZ);
  Vec bottomRightScreen = new Vec(c.screenWidth(), c.screenHeight(), screenZ);
  // corresponding world coordinates
  Vec topLeftEye = c.unprojectedCoordinatesOf(topLeftScreen);
  Vec bottomRightEye = c.unprojectedCoordinatesOf(bottomRightScreen);

  // virtual screen size
  float hudWidth = bottomRightEye.x() - topLeftEye.x();
  float hudHeight = bottomRightEye.y() - topLeftEye.y();
  float hudThickness = 0.01;
  // virtual cursor size
  float cursorSize =  hudWidth*0.01; // ratio of virtual screen width
  float virtualCursorX = topLeftEye.x() + hudWidth * cursorX / c.screenWidth();
  float virtualCursorY = topLeftEye.y() + hudHeight * cursorY / c.screenHeight();
  // make thigs very right, adapt z do scene transformations (eg with mouse)
  float virtualCursorZ =  c.unprojectedCoordinatesOf(new Vec(cursorX, cursorY, screenZ)).z();

  pg.pushStyle();
  pg.fill(200, 200);

  // virtual cursor
  pg.pushMatrix();
  pg.translate(virtualCursorX, virtualCursorY, virtualCursorZ);
  pg.box(cursorSize, cursorSize, hudThickness);
  pg.popMatrix();
  pg.popStyle();
}