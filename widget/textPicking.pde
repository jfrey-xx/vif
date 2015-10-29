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
  // screen cordinates of the cursor
  float cursorX = -1;
  float cursorY = -1;

  textPicking(Scene scene, PVector position) {
    this.scene = scene;
    this.position = scene.toVec(position);
    frame = new InteractiveFrame(scene);
    frame.setPosition(this.position);
  }

  // create a new interaction point to the relative position
  textPicker getNewPicker() {
    return new textPicker(this);
  }

  // should be updated by sketch
  public void setCursor (float x, float y) {
    cursorX = x;
    cursorY = y;
  }
}

// this one is actually used for picking
class textPicker {
  textPicking pick;

  Vec position;

  textPicker(textPicking pick) {
    this.pick = pick;
    this.position = pick.position.get();
  }

  // set position (handles internally reference position
  void setPosition(PVector newPosition) {
    position = pick.position.get();
    position.add(pick.scene.toVec(newPosition));
  }

  // For the outside word use Processing classes at most
  PVector getPosition() {
    return pick.scene.toPVector(position);
  }

  void draw() {
  }

  boolean isPicked() {
    pick.scene.pointUnderPixel(new Point(pick.cursorX, pick.cursorY));
    return false;
    // return scene.grabsAnyAgentInput(frame);
  }
}
