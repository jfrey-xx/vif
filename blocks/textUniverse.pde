/**
 
 Makes the text world tick.
 
 */

import geomerative.*;
import processing.core.*;
import java.util.ArrayList; 
import remixlab.proscene.*;
import remixlab.dandelion.core.*; // eg for Frame
import remixlab.dandelion.geom.*; // eg for Vec

class textUniverse {
  // static methods may appear in the future, for now use flag to init once
  private boolean init = false;

  PApplet parent;
  PGraphics pg;
  Scene scene;
  Frame frame;

  // world scale
  float scale;

  // currently active areas
  ArrayList <textArea> areas;

  // currently active actions
  ArrayList <textAction> actions;

  textUniverse(PApplet parent, PGraphics pg, Scene scene, Frame refFrame, float scale) {
    if (!init) {
      // init geomerative
      RG.init(parent); 
      RCommand.setSegmentLength(10);
      RCommand.setSegmentator(RCommand.UNIFORMLENGTH);
      init = true;
    }

    this.parent = parent;
    this.pg = pg;
    this.scene = scene;
    this.frame = refFrame;
    this.scale = scale;
    areas = new ArrayList();
    actions = new ArrayList();

    // load text areas
    textAreaData[]  areaData = textParser.getAreasData("");
    for (int i = 0; i < areaData.length; i++) {
      areas.add(new textArea(this, areaData[i].size, areaData[i].position));
      areas.get(i).loadText(areaData[i].content);
    }
  }

  public void draw() {
    for (textArea area : areas) {
      area.draw();
    }
  }
}