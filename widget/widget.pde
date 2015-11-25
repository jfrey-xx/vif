
/**
 
 Testing creation of a text widget
 
 */

import geomerative.*;
import remixlab.proscene.*;
import remixlab.dandelion.core.*; // eg for Frame
import remixlab.dandelion.geom.*; // eg for Vec

// used by text* for streams
import edu.ucsd.sccn.LSL;
import AULib.*;

Scene proscene;
Frame mainFrame;
textUniverse universe;

float rotateLookX = 0;
float rotateLookY = 0;

// scale of text
float worldRatio, zoomFactor;

// position for FPS
PVector positionFPS = new PVector(0, 0, -3);

//----------------SETUP---------------------------------
void setup() {
  size(1280, 800, P3D);
  frameRate(30);
  noSmooth(); // just to be able to move window around

  proscene = new Scene(this);
  // disable keyboard action: we will handle it ourselves
  proscene.disableKeyboardAgent();

  mainFrame = new Frame(proscene);

  // our eye is the center of the world
  proscene.eye().setPosition(new Vec(0, 0, 0));

  // world ratio
  worldRatio = 0.01;
  // halve text size
  zoomFactor = 0.5;
  universe = new textUniverse(this, this.g, proscene, mainFrame, worldRatio, zoomFactor, "data.json");
}

// apply head transformation from keyboard)
void updateReferenceFrame() {
  Quat head = new Quat(-rotateLookX, 0, 0);
  head.compose(new Quat(0, -rotateLookY, 0));
  mainFrame.setRotation(head);
}

void draw() {
  updateReferenceFrame();

  clear();
  background(255);

  // deal with FPS (have to place it manually)
  pushMatrix();
  translate(positionFPS.x, positionFPS.y, positionFPS.z);
  fill(0, 0, 255);
  scale(worldRatio);
  text(frameRate, 10, 10);
  popMatrix();

  // text
  pushMatrix();
  mainFrame.applyTransformation();
  universe.draw();
  popMatrix();

  // could pick before...
  textPicking.setCursor(new Vec(mouseX, mouseY, 0));

  if (keyPressed) {
    processKeyboard();
  }
}

// set orientation
// NB: used instead of  keyPressed() to handle repetition
void processKeyboard() {
  float step = 0.05;
  if (keyCode == UP) {
    rotateLookX -= step;
  } else if (keyCode == DOWN) {
    rotateLookX += step;
  } else if (keyCode == LEFT) {
    rotateLookY += step;
  } else if (keyCode == RIGHT) {
    rotateLookY -= step;
  }
}