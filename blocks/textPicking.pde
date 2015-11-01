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

  public boolean debug = false;

  textPicking(Scene scene, PVector position, float scale) {
    this.scene = scene;
    this.position = scene.toVec(position);
    this.scale = scale;
  }

  void setFrame(Frame frame) {
    this.frame = frame;
  }

  // create a new interaction point to the relative position
  textPicker getNewPicker() {
    return new textPicker(this);
  }

  // should be updated by sketch
  public void setCursor (Vec screenCursor) {
    cursor =  screenCursor;
  }
}

// this one is actually used for picking
// FIXME: does not handle transformation on drawing (eg translate a chunk in z)
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
    topLeft = new Vec(topLeftX, topLeftY, 0);
    bottomRight = new Vec(bottomRightX, bottomRightY);

    //       topLeft = new Vec(topLeftX*pick.scale, topLeftY*pick.scale, 0);
    //   bottomRight = new Vec(bottomRightX*pick.scale, bottomRightY*pick.scale);

    boundsSet = true;
  }

  // debug
  void draw() {
    // placeholders for pickup zone in screen space
    if (pick.debug) {

      println("*****");

      Vec topLeftScreen = pick.scene.eye().projectedCoordinatesOf(pick.frame.inverseCoordinatesOf(topLeft));
      Vec bottomRightScreen = pick.scene.eye().projectedCoordinatesOf(pick.frame.inverseCoordinatesOf(bottomRight));


      //  Vec topLeftScreen = pick.scene.eye().projectedCoordinatesOf(pick.frame.inverseTransformOf(topLeft));
      // Vec bottomRightScreen = pick.scene.eye().projectedCoordinatesOf(pick.frame.inverseTransformOf(bottomRight));


      println("topLeft", topLeftScreen, ", bottomRight:", bottomRightScreen );

      float topX = modelX(topLeftScreen.x(), topLeftScreen.y(), topLeftScreen.z());
      float topY = modelY(topLeftScreen.x(), topLeftScreen.y(), topLeftScreen.z());
      float topZ = modelZ(topLeftScreen.x(), topLeftScreen.y(), topLeftScreen.z());

      println("topX:", topX, "topY:", topY);

      float botX = modelX(bottomRightScreen.x(), bottomRightScreen.y(), bottomRightScreen.z());
      float botY = modelY(bottomRightScreen.x(), bottomRightScreen.y(), bottomRightScreen.z());
      float botZ = modelZ(bottomRightScreen.x(), bottomRightScreen.y(), bottomRightScreen.z());

      PGraphics pg = pick.scene.pg();
      pg.pushStyle();
      pg.fill(123, 231, 98, 128);
      pg.rect(topX, topY, botX - topX, botY - topY);
      pg.popStyle();

      println("*****");


      // Vec Eye =  pick.scene.eye().eyeCoordinatesOf(topLeftScreen);
      // Vec bottomRightEye =  pick.scene.eye().eyeCoordinatesOf(bottomRightScreen);

      //  Vec bottomRightEye =  pick.scene.eye().eyeCoordinatesOf(bottomRightScreen);

      //  Vec topLeftEye =  pick.scene.eye().projectedCoordinatesOf(topLeftScreen, pick.frame);

      Vec topLeftEye =  pick.scene.projectedCoordinatesOf(topLeftScreen);

      Vec bottomRightEye =  pick.scene.eye().eyeCoordinatesOf(bottomRightScreen);

      // Vec bottomRightEye =  pick.scene.eye().projectedCoordinatesOf(bottomRightScreen, pick.frame);

      Mat mdlview = new Mat();
      pick.scene.getModelView(mdlview);
      Vec test = pick.scene.eye().projectedCoordinatesOf(mdlview, pick.frame.localInverseCoordinatesOf(bottomRight), mainFrame);

      println("topLeftEye", topLeftEye, ", bottomRightEye:", bottomRightEye);
      println("test", test);
      println("---");
    }
  }

  boolean isPicked() {
    boolean picked = false;
    if (boundsSet && pick.cursor != null) {
      // look how boundaries translates to word space
      Vec topLeftWorld = pick.frame.inverseCoordinatesOf(topLeft);
      Vec bottomRightWorld = pick.frame.inverseCoordinatesOf(bottomRight);

      // then to screen space
      Vec topLeftScreen = pick.scene.eye().projectedCoordinatesOf(topLeftWorld);
      Vec bottomRightScreen = pick.scene.eye().projectedCoordinatesOf(bottomRightWorld);

      Vec topLeftWorldbis = pick.scene.eye().projectedCoordinatesOf(topLeft, pick.frame);
      Vec bottomRightWorldbis = pick.scene.eye().projectedCoordinatesOf(bottomRight, pick.frame);

      if (pick.debug) {
        println("cursor:", pick.cursor);
        println("topLeftWorld:", topLeftWorld, ", bottomRightWorld:", bottomRightWorld);
        println("topLeftWorldbis:", topLeftWorldbis, ", bottomRightWorldbis:", bottomRightWorldbis);
        println("topLeftScreen :", topLeftScreen, ", bottomRightScreen:", bottomRightScreen);
      }

      // one hell of a if to handle each axis both ways
      picked = abs(topLeftScreen.x() - pick.cursor.x()) <  abs(topLeftScreen.x() - bottomRightScreen.x()) + threshold && abs(bottomRightScreen.x() - pick.cursor.x()) <  abs(topLeftScreen.x() - bottomRightScreen.x()) + threshold &&
        abs(topLeftScreen.y() - pick.cursor.y()) <  abs(topLeftScreen.y() - bottomRightScreen.y()) + threshold&& abs(bottomRightScreen.y() - pick.cursor.y()) <  abs(topLeftScreen.y() - bottomRightScreen.y()) + threshold&&
        abs(topLeftScreen.z() - pick.cursor.z()) <  abs(topLeftScreen.z() - bottomRightScreen.z()) + threshold && abs(bottomRightScreen.z() - pick.cursor.z()) <  abs(topLeftScreen.z() - bottomRightScreen.z()) + threshold;
    }

    return picked;
  }
}

