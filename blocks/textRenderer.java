
import geomerative.*;
import processing.core.*;

/** 
 Handle animation and drawing (transforms of the former applied before latter)
 */
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
    textAnim anim = chunk.anim;
    float pickedRatio = chunk.pickedRatio();



    // for anim
    pg.pushStyle();
    pg.pushMatrix();

    // text black by default
    pg.fill(0);

    // call anim only if a trigger is occurring
    if (pickedRatio >= 0) {

      switch(anim) {
      case SHADOW:
        textAnimShadow(group, pickedRatio);
        break;
        // nothing particular otherwise
      case NONE:
      default:
        textAnimNone(group, pickedRatio);
        break;
      }
    }

    // for drawing
    pg.pushStyle();
    //pg.noStroke();
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
    // draw
    pg.popMatrix();
    pg.popStyle();
    // anim
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

  // shadow get darker for picking
  // ratio: between 0 and 1
  private void textAnimShadow(RGroup group, float ratio) {
    float c = parent.lerp(255, 0, ratio);
    pg.fill(c);
    pg.rect(group.getTopLeft().x, group.getTopLeft().y, group.getWidth(), group.getHeight());
  }

  // do nothing for none...
  private void textAnimNone(RGroup group, float ratio) {
  }
}