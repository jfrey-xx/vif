
/**
 
 Container for textHolder, handle interaction
 
 FIXME: size for (in)visible trigger set with holder boundaries at the moment.
 
 */

import processing.core.*;
import remixlab.proscene.*;
import remixlab.dandelion.core.*; // eg for Frame
import remixlab.dandelion.geom.*; // eg for Vec

class textArea {
  private textHolder holder;
  private textUniverse universe;
  private PApplet parent;
  private PGraphics pg;
  private Scene scene;
  private PVector size;
  private PVector position;
  private float scale;
  private Frame frame;
  private String id; // specific ID in this universe
  textPicking pick;
  // triggers associated to current area, populated and registered on load(), unregistered on unload() 
  private textTrigger[] triggers;
  private textRenderer txtrdr;

  // time to die in ms
  final private int dyingTime = 2000;
  // 1: running; 0: dying; -1: dead
  private int status = 1;
  // timer for dying
  private int startDying = -1;


  private boolean debug = false;


  // size (x,y): planar size of the area. Warning: probably overflow because of words too long
  // position (x,y,z): position in space
  textArea(textUniverse universe, PVector size, PVector position, String id) {
    this.universe = universe;
    this.parent = universe.parent;
    this.pg = universe.pg;
    this.scene = universe.scene;
    // the size will depend on worldRatio and zoom factor
    scale = universe.worldRatio * universe.zoomFactor;
    this.id = id;
    frame = new Frame(scene);
    frame.setReferenceFrame(universe.frame);
    frame.setScaling(scale);

    pick = new textPicking(parent, scene, position, scale);
    pick.setFrame(frame);

    this.size = size;
    this.position = position;


    // rotate frame
    lookAtViewer();
    // put in right position
    centerFrame();
  }

  // position frame; if has holder will put group center in designed position
  private void centerFrame() {
    float shiftX = 0;
    float shiftY = 0;

    if (holder != null) {
      shiftX = holder.group.getWidth() * scale / 2;
      shiftY = holder.group.getHeight() * scale / 2;
    }

    // since translation is applied before rotation, we have to take into account the coordinates change
    Vec shift = frame.rotation().rotate(new Vec(shiftX, shiftY));
    frame.setTranslation(new Vec(position.x - shift.x(), position.y - shift.y(), position.z - shift.z()));
  }

  // rotate the frame so it faces viewer (proscene eye)
  private void lookAtViewer() {
    // work on a copy of the eye to get a "lookAt" orientation
    Eye cam = scene.eye().get();
    cam.lookAt(new Vec(position.x, position.y, position.z));
    Rotation theLook = cam.orientation();
    frame.setRotation(theLook);
  }

  // stub for populating textHolder
  public void load(textAreaData data) {
    String[] texts = data.getChunksText();
    textType[] types = data.getChunksType();
    textAnim[] anim = data.getChunksAnim();
    triggers = data.getChunksTrigger(pick);
    textAction[] actions = data.getChunksAction(this.id);
    textStyle style = data.getStyle();

    txtrdr = textRenderer.getRenderer(parent, pg, style);
    holder = new textHolder(parent, pg, txtrdr);
    // update holder -- convert on the fly ratio because it knows nothing about boundaries
    holder.setWidth(size.x/scale);

    // register actions
    // TODO: rethink archi, proper exceptions
    if (triggers.length == actions.length) {
      for (int i = 0; i < triggers.length; i++) {
        if (triggers[i] != null) {
          triggers[i].setAction(actions[i]);
        }
      }
    } else
    {
      parent.println("Error, triggers/actions length mismatch");
    }

    // TODO: proper exception
    if (texts.length == types.length && texts.length == triggers.length) {
      for (int i = 0; i < texts.length; i++) {
        holder.addText(texts[i], types[i], triggers[i], anim[i]);
      }

      // once holder's group is computed, set outer area -- usefull for (in)visible triggers
      for (int i = 0; i < triggers.length; i++) {
        if (triggers[i] != null) {
          triggers[i].setBoundariesArea(holder.group.getTopLeft().x, holder.group.getTopLeft().y, holder.group.getBottomRight().x, holder.group.getBottomRight().y);
        }
      }

      // inform dispatcher
      universe.registerTriggers(triggers);
    } else {
      parent.println("Error, texts/types/triggers length mismatch");
    }

    // now it's grown up, let's recondiser position
    centerFrame();
  }

  // call that before area is disabled
  public void unload() {
    if (status == 1) { 
      universe.unregisterTriggers(triggers);
      status = 0;
      startDying = parent.millis();
    }
  }

  // return true once fadeout done
  public boolean isDead() {
    return status == -1;
  }

  public void draw() {

    if (status == 0) {
      if (parent.millis() - startDying > dyingTime) {
        status = -1;
      }
    }

    // nothing more once dead
    if (isDead()) {
      return;
    }

    pg.pushMatrix();
    frame.applyTransformation();

    if (holder != null) {
      holder.draw();
      if (debug) {
        holder.drawDebug();

        // textArea limits
        pg.pushStyle();
        pg.fill(0, 255, 0, 200);
        pg.strokeWeight(txtrdr.fontSize * scale *2);
        pg.rect(0, 0, size.x/scale, size.y/scale);
        pg.popStyle();
      }
    }

    pg.popMatrix();
  }
}

