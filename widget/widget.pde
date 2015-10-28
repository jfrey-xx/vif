
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
  surface.setResizable(true);

  // init geomerative
  RG.init(this); 
  RCommand.setSegmentLength(10);
  RCommand.setSegmentator(RCommand.UNIFORMLENGTH);

  // world/font ratio = 10
  area = new textArea(this.g, new PVector (40, 30), new PVector (0, 0, 50), 0.1);
  area.loadText("");

  proscene = new Scene(this);
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