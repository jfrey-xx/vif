
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

//----------------SETUP---------------------------------
void setup() {
  size(1280, 800, P3D);
  frameRate(30);
  noSmooth(); // just to be able to move window around

  proscene = new Scene(this);
  mainFrame = new Frame(proscene);

  // place the eye toward south
  proscene.eye().setPosition(new Vec(0, 0, 40));

  // world/font ratio = 10
  float scale = 0.1;
  universe = new textUniverse(this, this.g, proscene, mainFrame, scale, "data.json");
}

//----------------DRAW---------------------------------


void draw() {
  clear();
  background(255);

  // FPS
  fill(0, 0, 255);
  text(frameRate, 0, 0);

  // text
  universe.draw();

  // could pick before...
  textPicking.setCursor(new Vec(mouseX, mouseY, 0));
}

void keyPressed() {
}