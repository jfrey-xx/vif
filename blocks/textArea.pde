
/**
 
 Container for textHolder, handle interaction
 
 */

import processing.core.*;

class textArea {

  final private int fontSize = 100;
  private textHolder holder;
  private PApplet parent;
  private PGraphics pg;
  private Scene scene;
  private PVector size;
  private PVector position;
  private float scale;
  private Frame frame;

  private boolean debug = true;

  // size (x,y): planar size of the area. Warning: probably overflow because of words too long
  // position (x,y,z): position in space
  // scale: font (100 pixel size) to world ratio
  textArea(PApplet parent, PGraphics pg, Scene scene, Frame refFrame, PVector size, PVector position, float scale) {
    this.parent = parent;
    this.pg = pg;
    this.scene = scene;
    this.scale = scale;
    frame = new Frame(scene);
    frame.setReferenceFrame(refFrame);
    frame.setScaling(scale);

    pick = new textPicking(parent, scene, position, scale);
    pick.setFrame(frame);

    // fixed 100 pixels font size
    holder = new textHolder(pg, pick, "FreeSans.ttf", fontSize);

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
  public void loadText(String text) {
    String[] texts = textParser.getChunksText(text);
    textType[] types = textParser.getChunksType(text);

    // TODO: proper exception
    if (texts.length == types.length) {
      for (int i = 0; i < texts.length; i++) {
        holder.addText(texts[i], types[i]);
      }
    } else {
      println("Error, texts/types mismatch");
    }
  }

  public void draw() {
    pg.pushMatrix();
    frame.applyTransformation();

    holder.draw();
    if (debug) {
      holder.drawDebug();
    }

    // textArea limits
    pg.pushStyle();
    pg.fill(0, 255, 0, 200);
    pg.strokeWeight(fontSize * scale *2);
    pg.rect(0, 0, size.x/scale, size.y/scale);
    pg.popStyle();

    pg.popMatrix();

    // WIP
    this.update();
  }

  public textPicking getPick() {
    return pick;
  }

  // WIP: update state depending on selection
  private void update() {
    textChunk selected = holder.chunkSelected();
    if (selected != null) {
      frame.setScaling(scale*2);
    }
  }
}