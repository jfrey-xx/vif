
/**
 
 Container for textHolder, handle interaction
 
 */

import processing.core.*;
import remixlab.proscene.*;
import remixlab.dandelion.core.*; // eg for Frame
import remixlab.dandelion.geom.*; // eg for Vec

class textArea {

  final private int fontSize = 100;
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

  private boolean debug = false;

  // size (x,y): planar size of the area. Warning: probably overflow because of words too long
  // position (x,y,z): position in space
  // scale: font (100 pixel size) to world ratio
  textArea(textUniverse universe, PVector size, PVector position, String id) {
    this.universe = universe;
    this.parent = universe.parent;
    this.pg = universe.pg;
    this.scene = universe.scene;
    this.scale = universe.scale;
    this.id = id;
    frame = new Frame(scene);
    frame.setReferenceFrame(universe.frame);
    frame.setScaling(scale);

    pick = new textPicking(parent, scene, position, scale);
    pick.setFrame(frame);

    // fixed 100 pixels font size
    holder = new textHolder(parent, pg, "FreeSans.ttf", fontSize);

    setSize(size);
    setPosition(position);

    lookAtViewer();
  }

  // rotate the frame so it faces viewer (proscene eye)
  public void lookAtViewer() {
    // work on a copy of the eye to get a "lookAt" orientation
    Eye cam = scene.eye().get();
    cam.lookAt(frame.position());
    Rotation theLook = cam.orientation();
    frame.setOrientation(theLook);
  }

  private void setSize(PVector size) {
    this.size = size;
    // update holder -- convert on the fly ratio because it knows nothing about boundaries
    holder.setWidth(size.x/scale);
  }

  private void setPosition(PVector position) {
    this.position = position;
    frame.setTranslation(new Vec(position.x, position.y, position.z));
  }

  // stub for populating textHolder
  public void load(textAreaData data) {
    String[] texts = data.getChunksText();
    textType[] types = data.getChunksType();
    textAnim[] anim = data.getChunksAnim();
    textTrigger[] triggers = data.getChunksTrigger(pick);
    textAction[] actions = data.getChunksAction(this.id);

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
      // inform dispatcher
      universe.registerTriggers(triggers);
    } else {
      parent.println("Error, texts/types/triggers length mismatch");
    }
  }

  public void draw() {
    pg.pushMatrix();
    frame.applyTransformation();

    holder.draw();
    if (debug) {
      holder.drawDebug();

      // textArea limits
      pg.pushStyle();
      pg.fill(0, 255, 0, 200);
      pg.strokeWeight(fontSize * scale *2);
      pg.rect(0, 0, size.x/scale, size.y/scale);
      pg.popStyle();
    }

    pg.popMatrix();
  }
}