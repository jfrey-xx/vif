
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

  private boolean debug = true;
  
  // size (x,y): planar size of the area. Warning: probably overflow because of words too long
  // position (x,y,z): position in space
  // scale: font (100 pixel size) to world ratio
  textArea(PGraphics pg,  textPicking pick, PVector size, PVector position, float scale) {
    this.pg = pg;
    this.scale = scale;

    // fixed 100 pixels font size
    holder = new textHolder(pg, pick, "FreeSans.ttf", fontSize, scale);

    setSize(size);
    setPosition(position);
  }

  private void setSize(PVector size) {
    this.size = size;
    // update holder size as well
    holder.setWidth(size.x);
  }

  private void setPosition(PVector position) {
    this.position = position;
  }

  // stub for populating textHolder
  public void loadText(String text) {
    holder.addText("one");
    holder.addText("second", textType.BEAT);
    holder.addText(" et un et deux", textType.EMPHASIS);
    holder.addText("nst nstnstnst aw ", textType.SHAKE);
  }

  public void draw() {
    pg.pushMatrix();
    pg.translate(position.x, position.y, position.z);
    holder.draw();
    if (debug) {
      holder.drawDebug();
    }

    // textArea limits
    pg.pushStyle();
    pg.fill(0, 255, 0, 200);
    pg.strokeWeight(fontSize * scale *2);
    pg.rect(0, 0, size.x, size.y);
    pg.popStyle();

    pg.popMatrix();
  }
}