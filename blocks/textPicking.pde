/**
 
 Abstracts proscene object picking
 
 */

import remixlab.dandelion.core.*;
import remixlab.dandelion.geom.*;

// this one holds reference (scene / position)
class textPicking {
  Scene scene;
  Vec position;
  Frame frame;
  // font2world scale in order to get the bounding box right
  float scale;
  // frame coordinate of the cursor -- set by sketch
  Vec cursor;

  textPicking(Scene scene, PVector position, float scale) {
    this.scene = scene;
    this.position = scene.toVec(position);
    this.scale = scale;
    frame = new InteractiveFrame(scene);
    frame.setPosition(this.position);
  }

  // create a new interaction point to the relative position
  textPicker getNewPicker() {
    return new textPicker(this);
  }

  // should be updated by sketch
  public void setCursor (Vec screenCursor) {
    cursor =  screenCursor;

    //// convert from scene to frame
    //if (sceneCursor != null) {
    //  cursor = frame.coordinatesOf(sceneCursor);
    //} else {
    //  cursor = null;
    //}
  }
}

// this one is actually used for picking
class textPicker {
  // we dont want to mess with different plane, puth the picking has a slight inacurracy, take a zone (in pixels) around frame
  private final float threshold = 1;

  boolean boundsSet = false;
  Vec topLeft, bottomRight;
  textPicking pick;


  textPicker(textPicking pick) {
    this.pick = pick;
  }

  // set position (handles internally reference position
  void setBoundaries(float topLeftX, float topLeftY, float bottomRightX, float bottomRightY) {
    topLeft = new Vec(topLeftX*pick.scale, topLeftY*pick.scale, 0);
    bottomRight = new Vec(bottomRightX*pick.scale, bottomRightY*pick.scale);
    boundsSet = true;
  }

  // debug
  void draw() {
    if (isPicked()) {
      rect(topLeft.x()/pick.scale, topLeft.y()/pick.scale, (bottomRight.x() - topLeft.x())/pick.scale, (bottomRight.y() - topLeft.y())/pick.scale);
    }
  }

  boolean isPicked() {
    boolean picked = false;
    if (boundsSet && pick.cursor != null) {
      // look how boundaries translates to word space
      Vec topLeftWorld = pick.frame.inverseCoordinatesOf(topLeft);
      Vec bottomRightWorld = pick.frame.inverseCoordinatesOf(bottomRight);
      // then so screen space
      Vec topLeftScreen = pick.scene.eye().projectedCoordinatesOf(topLeftWorld);
      Vec bottomRightScreen = pick.scene.eye().projectedCoordinatesOf(bottomRightWorld);

      picked =  pick.cursor.x() > topLeftScreen.x()-threshold && pick.cursor.y() >  topLeftScreen.y()-threshold && pick.cursor.z() >  topLeftScreen.z()-threshold &&
        pick.cursor.x() < bottomRightScreen.x()+threshold && pick.cursor.y() >  bottomRightScreen.y()+threshold && pick.cursor.z() >  bottomRightScreen.z()+threshold;
    }
    return picked;

    //Vec frameCursorTopLeft = coordinatesOf

    //return boundsSet && pick.cursor != null &&
    //  pick.cursor.x() > topLeftX && pick.cursor.y() > topLeftY &&
    //  pick.cursor.x() < bottomRightX && pick.cursor.y() < bottomRightY &&
    //  pick.cursor.z() > -threshold &&  pick.cursor.z() < threshold;
  }
}