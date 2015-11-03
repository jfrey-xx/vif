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

  // Will monitor triggers from here
  // TODO: possibility to unregister old triggers
  ArrayList <textTrigger> triggers;

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
    triggers = new ArrayList();

    // load text areas
    textAreaData[]  areaData = textParser.getAreasData("");
    for (int i = 0; i < areaData.length; i++) {
      areas.add(new textArea(this, areaData[i].size, areaData[i].position));
      areas.get(i).loadText(areaData[i].content);
    }
  }

  public void draw() {
    // update triggers
    for (textTrigger trig : triggers) {
      // pass on disabled triggers or that had done their actions
      if (trig.isActive() && (trig.action == null || !trig.action.done())) {
        trig.draw();
      }
    }

    // update text world
    for (textArea area : areas) {
      area.draw();
    }

    // apply triggers effects, if any
    for (textTrigger trig : triggers) {
      if (trig.isActive() && trig.pickedRatio() >= 1 && trig.action != null) {
        if (trig.action.done()) {
          trig.disable();
        } else {
          trig.action.fire(this);
          parent.println("fire!");
        }
      }
    }
  }

  // add new triggers to the watch list
  void registerTriggers(textTrigger[] newTrigs) {
    for (int i = 0; i < newTrigs.length; i++) {
      if (newTrigs[i] != null) {
        triggers.add(newTrigs[i]);
      }
    }
  }
}