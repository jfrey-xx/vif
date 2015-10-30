
/**
 
 Testing creation of a text widget
 
 */

import geomerative.*;
import remixlab.proscene.*;


Scene proscene;

textArea area;
textPicking pick;

//----------------SETUP---------------------------------
void setup() {
  size(1280, 800, P3D);
  frameRate(30);
  noSmooth(); // for processing 2 compatibility

  // init geomerative
  RG.init(this); 
  RCommand.setSegmentLength(10);
  RCommand.setSegmentator(RCommand.UNIFORMLENGTH);

  proscene = new Scene(this);
  proscene.setPickingVisualHint(true);

  // place frame
  PVector position = new PVector (0, 0, 50);
  float scale = 0.1;
  
  pick = new textPicking(proscene, position, scale);

  // world/font ratio = 10
  area = new textArea(this.g, pick, new PVector (40, 30), position, scale);
  area.loadText("");
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
  
  // pick *after* rendering
  pick.setCursor(proscene.pointUnderPixel(new Point(mouseX, mouseY)));
}

void keyPressed() {
}
