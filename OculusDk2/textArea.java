
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
  // whether position is absolute or relative to current viewer orientation
  private boolean positionAbsolute;
  private float scale;
  private Frame frame;
  private String id; // specific ID in this universe
  textPicking pick;
  // triggers associated to current area, populated and registered on load(), unregistered on unload() 
  private textTrigger[] triggers;
  private textRenderer txtrdr;

  // time to die in ms
  final private int dyingTime = 500;
  final private int birthTime = 500;
  // 2: appearing, 1: running; 0: dying; -1: dead
  private int status = 2;
  // timer for birth / dying
  private int startDying = -1;
  private int startBirth = -1;

  // somme areas are just for triggers, will not draw holder in this case
  private boolean hasContent;

  private boolean debug = false;


  // size (x,y): planar size of the area. Warning: probably overflow because of words too long
  // position (x,y,z): position in space
  textArea(textUniverse universe, PVector size, textPosition position, String id) {
    this.universe = universe;
    this.parent = universe.parent;
    this.pg = universe.pg;
    this.scene = universe.scene;
    // the text size will depend on worldRatio and zoom factor
    scale = universe.worldRatio * universe.zoomFactor;
    this.id = id;
    frame = new Frame(scene);
    frame.setReferenceFrame(universe.frame);
    frame.setScaling(scale);

    pick = new textPicking(parent, scene, scale);
    pick.setFrame(frame);

    // adjust position with worldRatio, size with scale (worldRatio * zoomFactor),  position with worldRatio
    PVector pos = position.getVector();
    this.position = new PVector(pos.x * universe.worldRatio, pos.y * universe.worldRatio, pos.z * universe.worldRatio);
    this.positionAbsolute = position.isAbsolute();
    this.size = new PVector(size.x * scale, size.y * scale, size.z * scale);

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


    // if absolute, take into account reference frame to place in world coordinates
    if (positionAbsolute) {
      // since translation is applied before rotation, we have to take into account the coordinates change
      Vec shift = frame.rotation().rotate(new Vec(shiftX, shiftY));
      frame.setTranslation(new Vec(position.x - shift.x(), position.y - shift.y(), position.z - shift.z()));
    } 
    // if relative, just set position
    else {
      Vec shift = frame.orientation().rotate(new Vec(shiftX, shiftY));
      frame.setPosition(new Vec(position.x - shift.x(), position.y - shift.y(), position.z - shift.z()));
    }

    lookAtViewer();
  }

  // rotate the frame so it faces viewer (proscene eye)
  private void lookAtViewer() {
    // work on a copy of the eye to get a "lookAt" orientation
    Eye cam = scene.eye().get();
    cam.lookAt(new Vec(position.x, position.y, position.z));
    Rotation theLook = cam.orientation();

    // if absolute, acknowlegde reference frame
    if (positionAbsolute) {
      frame.setRotation(theLook);
    } 
    // relative, rotation in world coordinates
    else {
      frame.setOrientation(theLook);
    }
  }

  // stub for populating textHolder
  public void load(textAreaData data) {
    hasContent = data.hasContent();

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
    } else {
      parent.println("Error, texts/types/triggers length mismatch");
    }

    // now it's grown up, let's recondiser position
    centerFrame();

    // start fade in
    status = 2;
    startBirth = parent.millis();
  }

  // once appeared, register trigger -- NB: should not be called twice...
  private void launch() {
    // inform dispatcher
    universe.registerTriggers(triggers);
    status = 1;
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
    // used for fade effect
    float ratio = 1;

    switch(status) {
      // nothing more once dead
    case -1:
      return;
    case 0:
      if (parent.millis() - startDying > dyingTime) {
        status = -1;
        return;
      } else {
        // kind of fadout for dying
        ratio = 1 - (parent.millis() - startDying) / (float)dyingTime;
      }
      break;
    case 2:
      // let time for previous to die
      if (parent.millis() - startBirth <= dyingTime) {
        return;
      } else if (parent.millis() - startBirth > birthTime + dyingTime) {
        launch();
      } else {
        // fade in
        ratio = (parent.millis() - startBirth - dyingTime) / (float) (birthTime);
      }
    }

    // no need to go further if no content to draw
    if (!hasContent) {
      return;
    }

    pg.pushMatrix();
    frame.applyTransformation();

    txtrdr.setFade(ratio);

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