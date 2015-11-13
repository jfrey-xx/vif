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

  textParser parser;

  // world scale
  float scale;

  // availables areas
  Map <String, textAreaData> areasStock;

  // currently active areas
  Map <String, textArea> areas;

  // areas soon to be removed
  ArrayList <String> dyingAreas;

  // Will monitor triggers from here
  ArrayList <textTrigger> triggers;

  textUniverse(PApplet parent, PGraphics pg, Scene scene, Frame refFrame, float scale, String file) {
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
    dyingAreas = new ArrayList();
    triggers = new ArrayList();

    // load text area data, add to stock, grab those to init on start
    parser = new textParser(parent, file);
    textAreaData[]  areaData = parser.getAreasData();

    for (int i = 0; i < areaData.length; i++) {
      areasStock.put(areaData[i].id, areaData[i]);
      // check if should go live
      if (areaData[i].atStart) {
        enableArea(areaData[i].id);
      }
    }
  }

  // Adding area to list to be cleaned
  void disableArea(String id) {
    dyingAreas.add(id);
  }

  // two-steps removal (cf disableArea) 'cause may have several triggers at the same time, typically upon init
  private void cleanArea() {
    for (String areaID : dyingAreas) {
      parent.println("unloading area:", areaID);
      textArea area = areas.get(areaID);
      // may attempt to remove twice the same, e.g. two "goto"
      if (area != null) {
        area.unload();
        areas.remove(areaID);
      }
    }
    dyingAreas.clear();
  }

  // New challenger incoming. 
  // NB: Won't reload an area if already present 
  void enableArea(String id) {
    textAreaData data = areasStock.get(id);
    if (data == null) {
      // TODO: exception
      parent.println("Error, no area associated to id [", id, "]");
      return;
    }
    if (areas.get(id) != null) {
      parent.println("Warning, not loading area [", id, "] because it is already active");
      return;
    }
    // adjust position and size with scale -- no mult() in processing 2xxx
    textArea area = new textArea(this, new PVector(data.size.x * scale, data.size.y * scale), new PVector(data.position.x*scale, data.position.y*scale, data.position.z*scale), data.id);
    area.load(data);
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
    for (String key : areas.keySet ()) { 
      areas.get(key).draw();
    }

    // apply triggers effects, if any
    // NB: working on copy as safeguard since triggers could do *anything*
    // FIXME: remove old triggers?? (e.g. dead areas)
    for (textTrigger trig : new ArrayList<textTrigger> (triggers)) {
      if (trig.isActive() && trig.waitingFire() && trig.action != null) {
        if (trig.action.done()) {
          trig.disable();
        } else {
          trig.action.fire(this);
        }
      }
    }

    // cleanup if needed
    cleanArea();
  }

  // add new triggers to the watch list
  void registerTriggers(textTrigger[] newTrigs) {
    for (int i = 0; i < newTrigs.length; i++) {
      if (newTrigs[i] != null) {
        triggers.add(newTrigs[i]);
      }
    }
  }

  // disable and remove triggers from watch list
  void unregisterTriggers(textTrigger[] oldTrigs) {
    for (int i = 0; i < oldTrigs.length; i++) {
      if (oldTrigs[i] != null) {
        oldTrigs[i].disable();
        if (!triggers.remove(oldTrigs[i])) {
          parent.println("Error while unregistering trigger, not present in list.");
        }
      }
    }
  }
}