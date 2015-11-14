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

  // worldRatio: world unit to pixels ratio. Eg. use fontSize 100 and worldRatio 0.01 for good-looking 10cm font size. Also scale position, i.e. larger and further / smaller and closer
  float worldRatio;
  // influence 2D size of text (both font size and textArea size), not position. Handy if fonts and text areas too big / too small.
  float zoomFactor;

  // availables areas
  Map <String, textAreaData> areasStock;

  // currently active areas
  Map <String, textArea> areas;

  // areas soon to be removed
  Map <String, textArea> dyingAreas;

  // Will monitor triggers from here
  ArrayList <textTrigger> triggers;

  // by default no zoom
  textUniverse(PApplet parent, PGraphics pg, Scene scene, Frame refFrame, float worldRatio, String file) {
    this(parent, pg, scene, refFrame, worldRatio, 1, file);
  }

  textUniverse(PApplet parent, PGraphics pg, Scene scene, Frame refFrame, float worldRatio, float zoomFactor, String file) {
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
    this.worldRatio =  worldRatio;
    this.zoomFactor = zoomFactor;
    areasStock = new LinkedHashMap<String, textAreaData>();
    areas = new LinkedHashMap<String, textArea>();
    dyingAreas = new LinkedHashMap<String, textArea>();
    triggers = new ArrayList();

    // enable update of camera frustrum for (in)visible trigger
    // TODO: left disabled if no such trigger
    scene.enableBoundaryEquations();

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
    dyingAreas.put(id, areas.get(id));
  }

  // two-steps removal (cf disableArea) 'cause may have several triggers at the same time, typically upon init
  private void cleanArea() {
    if (!dyingAreas.isEmpty()) {
      // store keys to be removed, avoid concurrent modification exception
      ArrayList<String> ids = new ArrayList();
      // update text world
      for (String key : dyingAreas.keySet ()) {
        textArea area =  dyingAreas.get(key);
        area.unload();
        if (area.isDead()) {
          parent.println("unloading area:", key);
          ids.add(key);
        }
      }
      for (String id : ids) {
        areas.remove(id);
        dyingAreas.remove(id);
      }
    }
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
    // adjust position with worldRatio and size with scale (worldRatio * zoomFactor)
    textArea area = new textArea(this, new PVector(data.size.x * worldRatio * zoomFactor, data.size.y * worldRatio * zoomFactor), new PVector(data.position.x*worldRatio, data.position.y*worldRatio, data.position.z*worldRatio), data.id);
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

