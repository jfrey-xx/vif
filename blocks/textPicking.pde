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
  public void setCursor (Vec sceneCursor) {
    // convert from scene to frame
    if (sceneCursor != null) {
      cursor = frame.coordinatesOf(sceneCursor);
    } else {
      cursor = null;
    }
  }
}

// this one is actually used for picking
class textPicker {
  // we dont want to mess with different plane, puth the picking has a slight inacurracy, take a zone (in pixels) around frame
  private final float threshold = 1;
  
  boolean boundsSet = false;
  float topLeftX, topLeftY, bottomRightX, bottomRightY;
  textPicking pick;


  textPicker(textPicking pick) {
    this.pick = pick;
  }

  // set position (handles internally reference position
  void setBoundaries(float topLeftX, float topLeftY, float bottomRightX, float bottomRightY) {
    this.topLeftX = topLeftX*pick.scale;// + pick.position.x();
    this.topLeftY = topLeftY*pick.scale;// + pick.position.y();
    this.bottomRightX = bottomRightX*pick.scale;// +  pick.position.x();
    this.bottomRightY = bottomRightY*pick.scale;// +  pick.position.y();
    boundsSet = true;
    println(this.topLeftX, this.topLeftY, this.bottomRightX, this.bottomRightY);
  }

  // debug
  void draw() {
    if (isPicked()) {
      rect(topLeftX/pick.scale, topLeftY/pick.scale, (bottomRightX - topLeftX)/pick.scale, (bottomRightY - topLeftY)/pick.scale);
    }
  }

  boolean isPicked() {
    return boundsSet && pick.cursor != null &&
      pick.cursor.x() > topLeftX && pick.cursor.y() > topLeftY &&
      pick.cursor.x() < bottomRightX && pick.cursor.y() < bottomRightY &&
      pick.cursor.z() > -threshold &&  pick.cursor.z() < threshold;
  }
}