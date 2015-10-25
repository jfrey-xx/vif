
/** 
 Hold one sequence of text, handles multiple lines
 */

import geomerative.*;

class textHolder {

  private String text;
  private RFont font;
  private RGroup group;
  private RPoint[] points;

  textHolder(String text, RFont font) {

    this.text = text;
    this.font = font;

    //GROUP TOGETHER FONT & TEXT.
    group = new RGroup();
    group.addGroup(font.toGroup(myText)); 
    group = group.toPolygonGroup();

    //ACCESS POINTS ON MY FONT/SHAPE OUTLINE
    points = group.getPoints();
  }


  public void draw() {
    //DRAW ELLIPSES AT EACH OF THESE POINTS
    for (int i=0; i<points.length; i++) {
      ellipse(points[i].x, points[i].y, 5, 5);
    }
  }
}