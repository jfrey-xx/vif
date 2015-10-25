
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
  private float fontLineSpacing;
  private float fontWordSpacing;

  // width limit, will wrap if go beyond
  private float maxWidth = -1;

  textHolder(String fontFile, int fontSize) {
    this.fontSize = fontSize;
    font = new RFont(fontFile, fontSize, LEFT); // left align by default
    fontLineSpacing = font.getLineSpacing();
    println("Font line spacing: ", fontLineSpacing);
    // cannot get just a space apparently..
    fontWordSpacing = font.toGroup("a w").getWidth() - font.toGroup("aw").getWidth();
    println("Font word spacing: ", fontWordSpacing);
  }

  public void setWidth(float maxWidth) {
    this.maxWidth = maxWidth;
  }

  // append text to right, wrap to max width, split by words
  private void addText(String newText) {
    text += newText;

    // rebuild group
    RGroup newGroup = new RGroup();

    // TODO: check against double white spaces and all
    String[] words = text.split(" ");
    println("Adding: [", newText, "], new nb words: ", words.length);

    for (int i=0; i < words.length; i++) {
      println("Adding: ", words[i]);
      RGroup wGroup = font.toGroup(words[i]);
      // if we already got something to compare with...
      if (newGroup.getWidth() > 0) {
        // if new word would overflow, linebreak
        if (newGroup.getWidth() + wGroup.getWidth() > maxWidth) {
          println("New line");
          wGroup.translate(0, fontLineSpacing);
        } else {
          println("Append");
          wGroup.translate(newGroup.getWidth()+fontWordSpacing, 0);
        }
      }
      newGroup.addGroup(wGroup);
    }


    group = newGroup;
    groupPoly = group.toPolygonGroup();

    //ACCESS POINTS ON MY FONT/SHAPE OUTLINE
    points = new ArrayList();
    points.addAll(Arrays.asList(groupPoly.getPoints()));
  }

  // bounding box
  public void drawDebug() {
    if (group.countElements() > 0) {
      pushStyle();
      stroke(0);
      noFill();
      rect(group.getTopLeft().x, group.getTopLeft().y, group.getWidth(), group.getHeight());
      popStyle();
    }

    // width limit
    if (maxWidth > 0) {
      pushStyle();
      fill(255, 0, 0);
      rect(0, 0, maxWidth, 2);
      popStyle();
    }
  }

  public void draw() {
    //DRAW ELLIPSES AT EACH OF THESE POINTS
    for (int i=0; i<points.size(); i++) {
      ellipse(points.get(i).x, points.get(i).y, 5, 5);
    }
  }
}