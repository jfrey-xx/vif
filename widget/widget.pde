
/**
 
 Testing creation of a text widget
 
 */

import geomerative.*;
import remixlab.proscene.*;


Scene proscene;

textArea area;


//----------------SETUP---------------------------------
void setup() {
  size(1280, 800, P3D);
  frameRate(30);
  noSmooth();
  //surface.setResizable(true);

  // init geomerative
  RG.init(this); 
  RCommand.setSegmentLength(10);
  RCommand.setSegmentator(RCommand.UNIFORMLENGTH);

  proscene = new Scene(this);
  proscene.setPickingVisualHint(true);
  
  // place frame
  PVector position = new PVector (0, 0, 50);
  textPicking pick = new textPicking(proscene, position);
  
  // world/font ratio = 10
  area = new textArea(this.g, pick, new PVector (40, 30), position, 0.1);
  area.loadText("");
}

//----------------DRAW---------------------------------


void draw() {
  clear();
  background(255);

  // FPS
  fill(0, 0, 255);
  text(frameRate, 0, 0);

  // text
  area.draw();
}

void keyPressed() {
}
