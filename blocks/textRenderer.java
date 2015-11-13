
import geomerative.*;
import processing.core.*;

/** 
 Handle animation and drawing (transforms of the former applied before latter).
 */
public class textRenderer {

  // where we will draw into
  private PGraphics pg;
  private PApplet parent;

  // will draw according to a ratio
  float fontSize;
  RFont font;

  textRenderer(PApplet parent, PGraphics pg, String fontFile, float fontSize) {
    this.parent = parent;
    this.fontSize = fontSize;
    this.pg = pg;
    this.font = new RFont(fontFile, (int) fontSize, parent.LEFT); // left align by default
  }

  // set default colors background/foreground
  // NB: push/pop systyle suposedly handled by caller
  public void areaDraw(RGroup group) {
    pg.noStroke();
    // set a background -- solarized colorscheme
    pg.fill(253, 246, 227, 200);
    pg.rect(group.getTopLeft().x, group.getTopLeft().y, group.getWidth(), group.getHeight());
    // text black by default
    pg.fill(101, 123, 131, 255);
  }

  public void textDraw(textChunk chunk) {
    RGroup group = chunk.group;
    textType type = chunk.type;
    textAnim anim = chunk.anim;
    float pickedRatio = chunk.pickedRatio();

    // for anim
    pg.pushStyle();
    pg.pushMatrix();

    // anim slightly in front to avoid z-buffer problem
    pg.translate(0, 0, fontSize/100);

    // call anim only if a trigger is occurring
    if (pickedRatio >= 0) {

      switch(anim) {
      case SHADOW:
        textAnimShadow(group, pickedRatio);
        break;
      case HEART:
        textAnimHeart(group, pickedRatio);
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
    pg.pushMatrix();

    // text slightly in front to avoid z-buffer problem
    pg.translate(0, 0, fontSize/100);

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
    //DRAW ELLIPSES AT EACH OF THESE POINTS
    for (int i=0; i<points.length; i++) {
      pg.ellipse(points[i].x, points[i].y, fontSize/20, fontSize/20);
    }
  }

  private void textDrawShake(RGroup group) {
    RGroup groupPoly = group.toPolygonGroup();
    RPoint[] points = groupPoly.getPoints();
    pg.fill(220, 50, 47);
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
    pg.fill(7, 54, 66, 255-c);
    pg.rect(group.getTopLeft().x, group.getTopLeft().y, group.getWidth(), group.getHeight());
  }

  // bump for heart
  // ratio: between 0 and 1
  private void textAnimHeart(RGroup group, float ratio) {
    // scale from center
    pg.translate(group.getCenter().x, group.getCenter().y);
    pg.scale(1+ratio);
    pg.translate(-group.getCenter().x, -group.getCenter().y);
  }

  // do nothing for none...
  private void textAnimNone(RGroup group, float ratio) {
  }
}