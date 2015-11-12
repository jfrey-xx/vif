
import geomerative.*;
import processing.core.*;

public class textRenderer {

  // where we will draw into
  private PGraphics pg;
  private PApplet parent;

  // will draw according to a ratio
  float fontSize;

  textRenderer(PApplet parent, PGraphics pg, float fontSie) {
    this.parent = parent;
    this.fontSize = 100;
    this.pg = pg;
  }

  public void textDraw(textChunk chunk) {

    RGroup group = chunk.group;
    textType type = chunk.type;
    float pickedRatio = chunk.pickedRatio();

      // for debug, draw a background if picked
      if (pickedRatio >= 0) {
        pg.pushStyle();
        float c = parent.lerp(255, 0, pickedRatio);
        pg.fill(c);
        pg.rect(group.getTopLeft().x, group.getTopLeft().y, group.getWidth(), group.getHeight());
        pg.pushStyle();
      }

    pg.pushStyle();
    pg.fill(0);
    pg.noStroke();
    pg.pushMatrix();

    switch (type) {
    case EMPHASIS:
      textDrawEmphasis(group);
      break;
    case LINK:
      textDrawShake(group);
      break;
    case STRONG:
      textDrawBeat(group);
      break;
    default:
      textDrawRegular(group);
      break;
    }
    pg.popMatrix();
    pg.popStyle();
  }

  private void textDrawRegular(RGroup group) {
    group.toShape().draw(pg);
  }

  private void textDrawEmphasis(RGroup group) {
    RGroup groupPoly = group.toPolygonGroup();
    RPoint[] points = groupPoly.getPoints();
    pg.fill(0);
    //DRAW ELLIPSES AT EACH OF THESE POINTS
    for (int i=0; i<points.length; i++) {
      pg.ellipse(points[i].x, points[i].y, fontSize/20, fontSize/20);
    }
  }

  private void textDrawShake(RGroup group) {
    RGroup groupPoly = group.toPolygonGroup();
    RPoint[] points = groupPoly.getPoints();
    pg.fill(255, 0, 0);
    //DRAW ELLIPSES AT EACH OF THESE POINTS
    for (int i=0; i<points.length; i++) {
      float noise = parent.random(fontSize/20);
      pg.ellipse(points[i].x, points[i].y, fontSize/20+noise, fontSize/20+noise);
    }
  }

  private void textDrawBeat(RGroup group) {
    pg.translate(0, 0, fontSize/2);

    // beat and fade
    float noise = parent.random((float)0.1);

    // scale from center
    pg.translate(group.getCenter().x, group.getCenter().y);
    pg.scale(1+noise);
    pg.translate(-group.getCenter().x, -group.getCenter().y);

    pg.fill(0+20*noise);

    RGroup groupPoly = group.toPolygonGroup();
    RPoint[] points = groupPoly.getPoints();
    //DRAW ELLIPSES AT EACH OF THESE POINTS
    for (int i=0; i<points.length; i++) {
      pg.ellipse(points[i].x, points[i].y, fontSize/20, fontSize/20);
    }
  }
}