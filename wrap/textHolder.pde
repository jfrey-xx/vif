
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
  ArrayList<RPoint> points;

  textHolder(RFont font) {
    this.font = font;
    group = new RGroup();
    points = new ArrayList();
  }

  private void addText(String newText) {
    this.text += newText;
    group.addGroup(font.toGroup(newText)); 
    groupPoly = group.toPolygonGroup();
    //ACCESS POINTS ON MY FONT/SHAPE OUTLINE
    points.addAll(Arrays.asList(groupPoly.getPoints()));

  }


  public void draw() {
    //DRAW ELLIPSES AT EACH OF THESE POINTS
    for (int i=0; i<points.size(); i++) {
      ellipse(points.get(i).x, points.get(i).y, 5, 5);
    }
  }
}