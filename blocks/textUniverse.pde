/**
 
 Makes the text world tick.
 
 */

import geomerative.*;
import processing.core.*;
import java.util.*;
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

  // availables areas
  Map <String, textAreaData> areasStock;

  // currently active areas
  Map <String, textArea> areas;

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
    areasStock = new LinkedHashMap<String, textAreaData>();
    areas = new LinkedHashMap<String, textArea>();
    triggers = new ArrayList();

    // load text area data, add to stock, grab those to init on start
    textAreaData[]  areaData = textParser.getAreasData("");
    for (int i = 0; i < areaData.length; i++) {
      areasStock.put(areaData[i].id, areaData[i]);
      // check if should go live
      if (areaData[i].atStart) {
        enableArea(areaData[i].id);
      }
    }
  }

  // WIP fade out for selected area
  void disableArea(String id) {
    areas.remove(id);
  }

  // WIP new challenger incoming
  void enableArea(String id) {
    textAreaData data = areasStock.get(id);
    if (data == null) {
      // TODO: exception
      parent.println("Error, no area associated to id [", id, "]");
      return;
    }
    textArea area = new textArea(this, data.size, data.position, data.id);
    area.loadText(data.content);
    areas.put(data.id, area);
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
    for (String key : areas.keySet()) { 
      areas.get(key).draw();
    }

    // apply triggers effects, if any
    // NB: working on copy as safeguard since triggers could do *anything*
    for (textTrigger trig : new ArrayList<textTrigger>(triggers)) {
      if (trig.isActive() && trig.pickedRatio() >= 1 && trig.action != null) {
        if (trig.action.done()) {
          trig.disable();
        } else {
          trig.action.fire(this);
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