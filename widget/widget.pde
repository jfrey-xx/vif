
/**
 
 Testing creation of a text widget
 
 */

import geomerative.*;
import remixlab.proscene.*;
import remixlab.dandelion.core.*; // eg for Frame
import remixlab.dandelion.geom.*; // eg for Vec

Scene proscene;
Frame mainFrame;

textArea area, area2;
textPicking pick;

//----------------SETUP---------------------------------
void setup() {
  size(1280, 800, P3D);
  frameRate(30);
  noSmooth(); // just to be able to move window around
  // init geomerative
  RG.init(this); 
  RCommand.setSegmentLength(10);
  RCommand.setSegmentator(RCommand.UNIFORMLENGTH);

  proscene = new Scene(this);
  mainFrame = new Frame(proscene); // for later use

  // place frame
  PVector position = new PVector (0, 0, 50);
  float scale = 0.1;

  // world/font ratio = 10
  area = new textArea(this, this.g, proscene, mainFrame, new PVector (40, 30), position, scale);
  area.loadText("");

  area2 = new textArea(this, this.g, proscene, mainFrame, new PVector (40, 30), new PVector (-100, 0, 50), scale);
  area2.loadText("");
}

//----------------DRAW---------------------------------


void draw() {
  clear();
  background(255);

  fill(0, 255, 0);
  box(40);

  // FPS
  fill(0, 0, 255);
  text(frameRate, 0, 0);

  // text
  area.draw();
  area2.draw();

  // could pick before...
  textPicking.setCursor(new Vec(mouseX, mouseY, 0));
}

void keyPressed() {
}