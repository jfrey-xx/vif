/**
 
 Show cues to indicate ground and direction
 
 Set background color for whole scene...
 
 */

import processing.core.*;
import remixlab.proscene.*;
import remixlab.dandelion.core.*; // eg for Frame

class textLandscape {

  PApplet parent;
  Frame frame;
  PGraphics pg;
  float worldRatio;

  // day speed
  float frequency = (float)0.25;

  // for objects
  float sunAngle = 0;
  // 1 when sun zenith, 0 when night
  float dayRatio = 0;
  // the opposite
  float nightRatio = 1;

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

  // update sun position and compute dayRatio
  private void update() {
    // sunAngle: at 0 rises, at 180 it going to be night again
    sunAngle += frequency;
    sunAngle %= 360;

    if (sunAngle > 270 || sunAngle < 90) {
      dayRatio = 0;
      nightRatio = (sunAngle <= 90) ? 90 - sunAngle: sunAngle - 270 ;  
      nightRatio /= 90;
    } else {
      nightRatio = 0;
      dayRatio = (sunAngle <= 180) ? sunAngle - 90 : 270 - sunAngle ;  
      dayRatio /= 90;
    }
  }

  // orbiting sun to give sense of direction
  // radius: how far away
  void drawSun(float radius) {
    pg.pushMatrix();
    pg.pushStyle();

    float x = parent.sin(parent.radians(sunAngle))*radius;
    float y = parent.cos(parent.radians(sunAngle))*radius;

    // fade in when sun appears
    pg.fill(255, 255, 128, 255*dayRatio);
    pg.stroke(255, 255, 128, 255*dayRatio);

    // from east to west, sligtly north
    pg.translate(-x, y, -radius/2);
    pg.sphere(radius/20);

    pg.popStyle();
    pg.popMatrix();
  }

  // background is a clue about time of day
  void drawBackground() {
    pg.background(255 - 255*nightRatio);
  }


  void draw() {
    update();

    // for grid, let's say we're seated
    float floorDist = 2; 

    pg.pushMatrix();
    frame.applyTransformation();

    drawBackground();
    drawSun(50);
    drawGrid(floorDist, 50, 25);


    pg.popMatrix();
  }
}