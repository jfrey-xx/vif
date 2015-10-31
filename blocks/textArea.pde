
/**
 
 Container for textHolder, handle interaction
 
 */

class textArea {

  final private int fontSize = 100;
  private textHolder holder;
  private PGraphics pg;
  private PVector size;
  private PVector position;
  private float scale;
  private Frame frame;

  private boolean debug = true;

  // size (x,y): planar size of the area. Warning: probably overflow because of words too long
  // position (x,y,z): position in space
  // scale: font (100 pixel size) to world ratio
  textArea(PGraphics pg, Scene scene, PVector size, PVector position, float scale) {
    this.pg = pg;
    this.scale = scale;
    frame = new Frame(proscene);
    frame.setReferenceFrame(mainFrame);
    frame.setScaling(scale);

    pick = new textPicking(scene, position, scale);
    pick.setFrame(frame);
    pick.debug = true;

    // fixed 100 pixels font size
    holder = new textHolder(pg, pick, "FreeSans.ttf", fontSize);

    setSize(size);
    setPosition(position);
  }

  private void setSize(PVector size) {
    this.size = size;
    // update holder -- convert on the fly ratio because it knows nothing about boundaries
    holder.setWidth(size.x/scale);
  }

  private void setPosition(PVector position) {
    this.position = position;
    frame.setPosition(new Vec(position.x, position.y, position.z));
  }

  // stub for populating textHolder
  public void loadText(String text) {
  //  holder.addText("one");
  //  holder.addText("second", textType.BEAT);
  //  holder.addText(" et un et deux", textType.EMPHASIS);
    holder.addText("nst nstnstnst aw ", textType.SHAKE);
  }

  public void draw() {
    frame.applyTransformation();

    pg.pushMatrix();
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
  }

  public textPicking getPick() {
    return pick;
  }
}

