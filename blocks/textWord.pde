/**
 
 Atomic unit for text.
 
 TODO: handle picking at word level. 
 
 */

import geomerative.*;

class textWord {
  RGroup group;
  String text;
  textWord(RGroup group, String text) {
    this.group =group;
    this.text = text;
  }
}