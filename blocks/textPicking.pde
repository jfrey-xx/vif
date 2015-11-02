/**
 
 Abstracts proscene object picking
 
 */

import processing.core.*;
import remixlab.proscene.*;
import remixlab.dandelion.core.*;
import remixlab.dandelion.geom.*;

// this one holds reference (scene / position)
class textPicking {
  private PApplet parent;
  public Scene scene;
  private Vec position;
  public Frame frame;
  // how long for selection (ms)
  public int selectionDelay = 1000;

  // font2world scale in order to get the bounding box right
  float scale;
  // frame coordinate of the cursor -- set by sketch
  static Vec cursor;

  public boolean debug = false;

  textPicking(PApplet parent, Scene scene, PVector position, float scale) {
    this.parent = parent;
    this.scene = scene;
    this.position = scene.toVec(position);
    this.scale = scale;
  }

  void setFrame(Frame frame) {
    this.frame = frame;
  }

  // create a new interaction point to the relative position
  textPicker getNewPicker() {
    return new textPicker(parent, this);
  }

  // should be updated by sketch
  // NB: same cursor for all 
  public static void setCursor (Vec screenCursor) {
    cursor =  screenCursor;
  }
}

// this one is actually used for picking
// NB: draw() should be called (at least) once per loop for updating status
class textPicker {
  private PApplet parent;
  
  // we dont want to mess with different plane, puth the picking has a slight inacurracy, take a zone (in pixels) around frame
  private final float threshold = 1;

  // serve as init flag for picking
  boolean boundsSet = false;
  Vec topLeft, bottomRight;
  textPicking pick;

  // flag for pick and timer (in ms) since picked
  private boolean picked = false;
  int startPicked = -1;
  int timePicked = -1;

  textPicker(PApplet parent, textPicking pick) {
    this.parent = parent;
    this.pick = pick;
  }

  // set position (handles internally reference position
  void setBoundaries(float topLeftX, float topLeftY, float bottomRightX, float bottomRightY) {
    topLeft = new Vec(topLeftX, topLeftY, 0);
    bottomRight = new Vec(bottomRightX, bottomRightY);
    boundsSet = true;
  }

  // may draw debug, update also
  void draw() {
    update();
  }

  private void update() {
    picked = false;
    if (boundsSet && pick.cursor != null) {
      // look how boundaries translates to word space
      Vec topLeftWorld = pick.frame.inverseCoordinatesOf(topLeft);
      Vec bottomRightWorld = pick.frame.inverseCoordinatesOf(bottomRight);

      // then to screen space
      Vec topLeftScreen = pick.scene.eye().projectedCoordinatesOf(topLeftWorld);
      Vec bottomRightScreen = pick.scene.eye().projectedCoordinatesOf(bottomRightWorld);

      // one hell of a if to handle each axis both ways
      picked = parent.abs(topLeftScreen.x() - pick.cursor.x()) <  parent.abs(topLeftScreen.x() - bottomRightScreen.x()) + threshold && parent.abs(bottomRightScreen.x() - pick.cursor.x()) <  parent.abs(topLeftScreen.x() - bottomRightScreen.x()) + threshold &&
        parent.abs(topLeftScreen.y() - pick.cursor.y()) <  parent.abs(topLeftScreen.y() - bottomRightScreen.y()) + threshold&& parent.abs(bottomRightScreen.y() - pick.cursor.y()) <  parent.abs(topLeftScreen.y() - bottomRightScreen.y()) + threshold&&
        parent.abs(topLeftScreen.z() - pick.cursor.z()) <  parent.abs(topLeftScreen.z() - bottomRightScreen.z()) + threshold && parent.abs(bottomRightScreen.z() - pick.cursor.z()) <  parent.abs(topLeftScreen.z() - bottomRightScreen.z()) + threshold;
    }
    // reset timer if nothing
    if (!picked) {
      startPicked = -1;
      timePicked = -1;
    } 
    // start or update timer otherwise
    else { 
      if ( timePicked < 0) {
        startPicked = parent.millis();
        timePicked = 0;
      } else {
        timePicked = parent.millis() - startPicked;
      }
    }
  }

  // update and return picked
  public boolean isPicked() {
    return picked;
  }

  // -1: not picked
  // between 0 and 1: ratio before timesUp
  public float pickedRatio() {
    if (!isPicked()) {
      return -1;
    }
    if (timePicked >= pick.selectionDelay || pick.selectionDelay <= 0) {
      return 1;
    }
    return ( (float)timePicked / pick.selectionDelay);
  }
}