/**
 
 Show cues to indicate ground and direction
 
 */

import processing.core.*;
import remixlab.proscene.*;
import remixlab.dandelion.core.*; // eg for Frame

class textLandscape {

  PApplet parent;
  Frame frame;
  PGraphics pg;
  float worldRatio;

  textLandscape(textUniverse universe) {
    this.parent = universe.parent;
    this.pg = universe.pg;
    frame = new Frame(universe.scene);
    frame.setReferenceFrame(universe.frame);
    frame.scale(worldRatio);
  }


  // grid that will fadeout in distance
  void drawGrid(float floorDist, float length, int repeat)
  {
    pg.pushMatrix();
    pg.pushStyle();

    // put on the ground
    pg.translate(0, floorDist, 0);
    pg.rotateX(parent.PI/2);

    // transparent color, thicker rectangles
    pg.fill(255, 0);
    pg.strokeWeight(2);


    float size = length / repeat;
    float ratio = 1;

    // starts from corner
    for (int i= (int) -length/2; i < length/2; i++)
    {
      for (int j= (int) -length/2; j < length/2; j++)
      {
        // draw starts with boundaries, compute how far we are from corner, increase fade effect
        // (NB: do not use dist to corner to have "roundy shape" result) 
        ratio = (float) 1.5 * parent.dist(i, j, 0, 0) / (length/2);
        // clamp value, that could be too high because of length/2
        if (ratio > 1) {
          ratio = 1;
        }
        // fade on alpha
        pg.stroke(200, 255 - ratio * 255);
        pg.rect(i, j, size/2, size/2);
      }
    }
    
    pg.popStyle();
    pg.popMatrix();
  }


  void draw() {
    // for grid, let's say we're seated
    float floorDist = 2; 

    pg.pushMatrix();
    frame.applyTransformation();

    drawGrid(floorDist, 50, 25);

    pg.popMatrix();
  }
}