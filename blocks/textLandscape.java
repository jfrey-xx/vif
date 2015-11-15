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

  // for objects
  float sunAngle = 0;

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



  // orbiting sun to give sense of direction
  // radius: how far away
  // frequency: speed of sun
  void drawSun(float radius, float frequency) {

    // sunAngle: at 0 rises, at 180 it going to be night again
    sunAngle += frequency;
    sunAngle %= 360;

    // 1 when zenith, 0 when night
    float ratioUp;

    if (sunAngle > 270 || sunAngle < 90) {
      ratioUp = 0;
    } else {
      ratioUp = (sunAngle < 180) ? sunAngle - 90 : 270 - sunAngle ;  
      ratioUp /= 90;
    }

    pg.pushMatrix();
    pg.pushStyle();

    float x = parent.sin(parent.radians(sunAngle))*radius;
    float y = parent.cos(parent.radians(sunAngle))*radius;

    // fade in when sun appears
    pg.fill(255, 255, 128, 255*ratioUp);
    pg.stroke(255, 255, 128, 255*ratioUp);

    // from east to west, sligtly north
    pg.translate(-x, y, -radius/2);
    pg.sphere(radius/20);

    pg.popStyle();
    pg.popMatrix();
  }


  void draw() {
    // for grid, let's say we're seated
    float floorDist = 2; 

    pg.pushMatrix();
    frame.applyTransformation();

    drawSun(50, (float)0.25);
    drawGrid(floorDist, 50, 25);


    pg.popMatrix();
  }
}