
/**
 
 Set semantical types for pieces of text -- and position, and size.
 
 */

import processing.core.*;

enum textType { 
  REGULAR, EMPHASIS, SHAKE, BEAT
};

  // where to put text
enum textPosition {
  // NORTH: 5 unit in front, and so on
  NORTH("NORTH", new PVector(0, 0, -5)), 
    EAST("EAST", new PVector(5, 0, 0)), 
    SOUTH("SOUTH", new PVector(0, 0, 5)), 
    WEST("WEST", new PVector(-5, 0, 0));

  private String text;
  private PVector position;

  textPosition(String text, PVector position) {
    this.text = text;
    this.position = position;
  }

  // return a copy of position
  public PVector getPosition() {
    return this.position.copy();
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
  MEDIUM("MEDIUM", new PVector(4, 3));

  private String text;
  private PVector size;

  textSize(String text, PVector size) {
    this.text = text;
    this.size = size;
  }

  // return a copy of position
  public PVector getSize() {
    return this.size.copy();
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