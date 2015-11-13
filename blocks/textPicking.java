/**
 
 Object picking using proscene. Implements textTrigger.
 
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

  textVisible getNewVisible(boolean onVisible) {
    return new textVisible(parent, this, onVisible);
  }

  // should be updated by sketch
  // NB: same cursor for all 
  public static void setCursor (Vec screenCursor) {
    cursor =  screenCursor;
  }
}

// if area is visible or not by eye
class textVisible extends textTrigger {
  boolean boundsAreaSet = false;
  textPicking pick;
  boolean onVisible;
  Vec topLeftArea, bottomRightArea;

  // onVisible: if true will trigger when is visible, when invisible otherwise
  textVisible(PApplet parent, textPicking pick, boolean onVisible) {
    super(parent);
    this.pick = pick;
    this.onVisible = onVisible;
    setDelay(1000);
  }

  Eye.Visibility visibility() {
    if (boundsAreaSet) {
      Vec topLeftAreaWorld = pick.frame.inverseCoordinatesOf(topLeftArea);
      Vec bottomRightAreaWorld = pick.frame.inverseCoordinatesOf(bottomRightArea);
      Eye.Visibility vis = pick.scene.boxVisibility(topLeftAreaWorld, bottomRightAreaWorld);
      return vis;
    }
    return Eye.Visibility.INVISIBLE;
  }

  @Override
    protected boolean update() {
    Eye.Visibility vis = visibility();
    if (vis == Eye.Visibility.VISIBLE && onVisible) {
      return true;
    }
    if (vis == Eye.Visibility.INVISIBLE && !onVisible) {
      return true;
    }
    return false;
  }

  // set position (handles internally reference position)
  @Override
    void setBoundariesArea(float topLeftX, float topLeftY, float bottomRightX, float bottomRightY) {
    topLeftArea = new Vec(topLeftX, topLeftY, 0);
    bottomRightArea = new Vec(bottomRightX, bottomRightY, 0);
    boundsAreaSet = true;
  }
}

// this one is actually used for picking -- reuse algo from textVisible
// NB: draw() should be called (at least) once per loop for updating status
class textPicker extends textVisible {

  // we dont want to mess with different plane, puth the picking has a slight inacurracy, take a zone (in pixels) around frame
  private final float threshold = 1;

  // serve as init flag for picking
  boolean boundsSet = false;
  Vec topLeft, bottomRight;
  textPicking pick;

  textPicker(PApplet parent, textPicking pick) {
    super(parent, pick, true);
    this.pick = pick;
    setDelay(1000);
  }

  // set position (handles internally reference position)
  @Override
    void setBoundariesChunk(float topLeftX, float topLeftY, float bottomRightX, float bottomRightY) {
    topLeft = new Vec(topLeftX, topLeftY, 0);
    bottomRight = new Vec(bottomRightX, bottomRightY, 0);
    boundsSet = true;
    super.setBoundariesArea(topLeftX, topLeftY, bottomRightX, bottomRightY);
  }

  // intercepts call for area; here it'll be chunk size
  @Override
    void setBoundariesArea(float topLeftX, float topLeftY, float bottomRightX, float bottomRightY) {
    return;
  }

  @Override
    protected boolean update() {
    boolean picked = false;
    if (boundsSet && boundsAreaSet && pick.cursor != null) {
      // look how boundaries translates to world space
      Vec topLeftWorld = pick.frame.inverseCoordinatesOf(topLeft);
      Vec bottomRightWorld = pick.frame.inverseCoordinatesOf(bottomRight);

      // then to screen space
      Vec topLeftScreen = pick.scene.eye().projectedCoordinatesOf(topLeftWorld);
      Vec bottomRightScreen = pick.scene.eye().projectedCoordinatesOf(bottomRightWorld);

      // one hell of a if to handle each axis both ways
      picked = parent.abs(topLeftScreen.x() - pick.cursor.x()) <  parent.abs(topLeftScreen.x() - bottomRightScreen.x()) + threshold && parent.abs(bottomRightScreen.x() - pick.cursor.x()) <  parent.abs(topLeftScreen.x() - bottomRightScreen.x()) + threshold &&
        parent.abs(topLeftScreen.y() - pick.cursor.y()) <  parent.abs(topLeftScreen.y() - bottomRightScreen.y()) + threshold&& parent.abs(bottomRightScreen.y() - pick.cursor.y()) <  parent.abs(topLeftScreen.y() - bottomRightScreen.y()) + threshold&&
        parent.abs(topLeftScreen.z() - pick.cursor.z()) <  parent.abs(topLeftScreen.z() - bottomRightScreen.z()) + threshold && parent.abs(bottomRightScreen.z() - pick.cursor.z()) <  parent.abs(topLeftScreen.z() - bottomRightScreen.z()) + threshold;

      // check that chunk is visible on screen -- could be behind
      if (picked && visibility() == Eye.Visibility.INVISIBLE) {
        picked = false;
      }
    }
    return picked;
  }
}
