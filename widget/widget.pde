
/**
 
 Testing creation of a text widget
 
 */

import geomerative.*;
import remixlab.proscene.*;
import remixlab.dandelion.core.*; // eg for Frame
import remixlab.dandelion.geom.*; // eg for Vec

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

// apply head transformation to frame (both from oculus and keyboard)
void updateReferenceFrame() {
  mainFrame.setRotation(new Quat(rotateLookX, rotateLookY, 0));
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
}


// set orientation
void keyPressed() {
  if (keyCode == UP) {
    rotateLookX -= 0.1;
  } else if (keyCode == DOWN) {
    rotateLookX += 0.1;
  } else if (keyCode == LEFT) {
    rotateLookY += 0.1;
  } else if (keyCode == RIGHT) {
    rotateLookY -= 0.1;
  }
}

