
/**
 
 Set semantical types for pieces of text -- and position, and size.
 
 Units for position and size is in pixels, textUniverse will adjust with scale before passin to textArea.
 
 */

import processing.core.*;
import remixlab.dandelion.geom.*; // for Rotation

// how to draw text
enum textType { 
  REGULAR, EMPHASIS, LINK, STRONG
};

  // how to animate (for triggers)
enum textAnim {
  NONE, SHADOW, HEART
};

  // where to put text
enum textPosition {
  // NORTH: 5 unit in front, and so on
  NORTH("NORTH", new PVector(0, 0, -500), true), 
    EAST("EAST", new PVector(500, 0, 0)), 
    SOUTH("SOUTH", new PVector(0, 0, 500)), 
    WEST("WEST", new PVector(-500, 0, 0));

  private String text;
  private PVector position;
  // is position relative to player's orientation
  private boolean relative = false;

  textPosition(String text, PVector position) {
    this(text, position, false);
  }

  textPosition(String text, PVector position, boolean relative) {
    this.text = text;
    this.position = position;
    this.relative = relative;
  }

  // return vector representing position in world coordinate
  // orientation: where the player is facing
  public PVector getVector(Rotation orientation) {
    if (relative) {
      Vec pos = orientation.inverse().rotate(new Vec(position.x, position.y, position.z));
      Quat rot = (Quat) orientation;
      widget.println("rotation:", rot.eulerAngles());
      widget.println("position before:", position);
      widget.println("position after:", pos);
      return new PVector(pos.x(), pos.y(), pos.z());
    }
    // .copy() not in processing 2...
    return new PVector(position.x, position.y, position.z);
  }

  // return enum from string, insensitive to case
  // idea from: http://stackoverflow.com/a/2965252
  public static textPosition fromString(String text) {
    if (text != null) {
      for (textPosition pos : textPosition.values()) {
        if (text.equalsIgnoreCase(pos.text)) {
          return pos;
        }
      }
    }
    return null;
  }
}

// size of text
enum textSize {
  MEDIUM("MEDIUM", new PVector(1000, 1500));

  private String text;
  private PVector size;

  textSize(String text, PVector size) {
    this.text = text;
    this.size = size;
  }

  // return a copy of position
  public PVector getSize() {
    return new PVector(size.x, size.y);
  }

  // return enum from string, insensitive to case
  // idea from: http://stackoverflow.com/a/2965252
  public static textSize fromString(String text) {
    if (text != null) {
      for (textSize siz : textSize.values()) {
        if (text.equalsIgnoreCase(siz.text)) {
          return siz;
        }
      }
    }
    return null;
  }
}