/**
 
 Show cues to indicate ground and direction
 
 Set background color for whole scene...
 
 */

import processing.core.*;
import remixlab.proscene.*;
import remixlab.dandelion.core.*; // eg for Frame

class textLandscape {
  // day speed
  final float frequency = (float)0.25;
  // we have to populate that
  final int nbStars = 250;
  // limit of the landscape
  final int radius = 50;
  // for grid, let's say we're seated
  final float floorDist = 6; 

  // solarized base03
  final PVector dayColor = new PVector(253, 246, 227);
  // solarized base3
  final PVector nightColor = new PVector(0, 43, 54);

  PApplet parent;
  Frame frame;
  PGraphics pg;
  float worldRatio;

  // holds x/y angles
  PVector [] stars;

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

    initStars();
  }

  // randomely set stard
  private void initStars() {
    stars = new PVector[nbStars];
    float theta, phi, x, y, z;

    for ( int i = 0; i < nbStars; i++) {
      // angles in visible hemisphere
      theta = parent.random(parent.PI);
      phi = parent.PI + parent.random(parent.PI);
      //Convert spherical coordinates into Cartesian coordinates
      x = parent.cos(theta) * parent.sin(phi) * radius;
      y = parent.sin(theta) * parent.sin(phi) * radius;
      z = parent.cos(phi) * radius;
      // add to table
      stars[i] = new PVector(x, y, z);
    }
  }

  // grid that will fadeout in distance
  private void drawGrid(float floorDist, int repeat)
  {
    pg.pushMatrix();
    pg.pushStyle();

    // put on the ground
    pg.translate(0, floorDist, 0);
    pg.rotateX(parent.PI/2);

    // transparent color, thicker rectangles
    pg.fill(255, 0);
    pg.strokeWeight(2);

    float size = radius / repeat;
    float ratio = 1;

    // starts from corner
    for (int i= (int) -radius/2; i < radius/2; i++)
    {
      for (int j= (int) -radius/2; j < radius/2; j++)
      {
        // draw starts with boundaries, compute how far we are from corner, increase fade effect
        // (NB: do not use dist to corner to have "roundy shape" result) 
        ratio = (float) 1.5 * parent.dist(i, j, 0, 0) / (radius/2);
        // clamp value, that could be too high because of length/2
        if (ratio > 1) {
          ratio = 1;
        }
        // fade on alpha, base 0 color
        pg.stroke(131, 148, 150, 255 - ratio * 255);
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
  private void drawSun() {
    // if it's night, nothing to show
    if (dayRatio == 0) {
      return;
    }

    pg.pushMatrix();
    pg.pushStyle();

    float x = parent.sin(parent.radians(sunAngle))*radius;
    float y = parent.cos(parent.radians(sunAngle))*radius;

    // fade in when sun appears

    // solarized yellow not that pretty
    // pg.fill(181, 137, 0, 255*dayRatio);
    // pg.stroke(181, 137, 0, 255*dayRatio);

    pg.fill(255, 255, 0, 255*dayRatio);
    pg.noStroke();

    // from east to west, sligtly north
    pg.translate(x, y, -radius/2);
    pg.sphere(radius/20);

    pg.popStyle();
    pg.popMatrix();
  }

  // background is a clue about time of day
  private void drawBackground() {

    // ratio (1/span) that will be used as transition zone
    float span = 6;

    // night
    if (nightRatio >= 1/span) {
      pg.background(nightColor.x, nightColor.y, nightColor.z);
    }
    // day
    else if (dayRatio >= 1/span) {
      pg.background(dayColor.x, dayColor.y, dayColor.z);
    }
    // in-between
    else {
      float transition = (nightRatio >= 0) ? -nightRatio: dayRatio;
      // 0 to 1
      transition += 1/span;
      transition *= span;

      float Rcol = parent.lerp(nightColor.x, dayColor.x, transition);
      float Gcol = parent.lerp(nightColor.y, dayColor.y, transition);
      float Bcol = parent.lerp(nightColor.z, dayColor.z, transition);
      pg.background(Rcol, Gcol, Bcol);
    }
  }

  // dots in the night
  private void drawStars() {
    if (nightRatio == 0) {
      return;
    }

    pg.pushStyle();
    // base3
    pg.stroke(253, 246, 227);

    for ( int i = 0; i < nbStars; i++) {
      pg.pushMatrix();
      pg.point(stars[i].x, stars[i].y, stars[i].z);
      pg.popMatrix();
    }
    pg.popStyle();
  }

  void draw() {
    update();

    pg.pushMatrix();
    frame.applyTransformation();

    drawBackground();
    drawSun();
    drawStars();
    drawGrid(floorDist, 25);


    pg.popMatrix();
  }
}
