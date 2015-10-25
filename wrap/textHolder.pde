
/** 
 Hold one sequence of text, handles multiple lines
 */

import geomerative.*;

import java.util.Arrays;

class textHolder {

  private String text = "";
  private RFont font;
  private RGroup group;
  private RGroup groupPoly;
  private ArrayList<RPoint> points;
  private int fontSize;

  textHolder(String fontFile, int fontSize) {
    this.fontSize = fontSize;
    font = new RFont(fontFile, fontSize, LEFT); // left align by default
    group = new RGroup();
    points = new ArrayList();

    println("Font line spacing: ", font.getLineSpacing());
  }


  // append text to right
  // TODO: optional space
  private void addText(String newText) {
    this.text += newText;

    // translate new group to the correct position
    RGroup newGroup = font.toGroup(newText);
    if (group.getWidth() > 0) {
      println("Old group width: ", group.getWidth());
      newGroup.translate(group.getWidth(), 0);
    }
    group.addGroup(newGroup); 
    groupPoly = group.toPolygonGroup();
    //ACCESS POINTS ON MY FONT/SHAPE OUTLINE
    points.addAll(Arrays.asList(groupPoly.getPoints()));
  }

  // bounding box
  public void drawDebug() {
    pushStyle();
    stroke(0);
    noFill();
    rect(group.getTopLeft().x, group.getTopLeft().y, group.getWidth(), group.getHeight());
    popStyle();
  }

  public void draw() {
    //DRAW ELLIPSES AT EACH OF THESE POINTS
    for (int i=0; i<points.size(); i++) {
      ellipse(points.get(i).x, points.get(i).y, 5, 5);
    }
  }
}