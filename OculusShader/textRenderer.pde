
import geomerative.*;

public void textDraw(PGraphics pg, RGroup group, textType type) {
  pg.pushStyle();
  pg.fill(0);
  pg.noStroke();
  pg.pushMatrix();
  switch (type) {
  case EMPHASIS:
    textDrawEmphasis(pg, group);
    break;
  case SHAKE:
    textDrawShake(pg, group);
    break;
  case BEAT:
    textDrawBeat(pg, group);
    break;
  default:
    textDrawRegular(pg, group);
    break;
  }
  pg.popMatrix();
  pg.popStyle();
}

private void textDrawRegular(PGraphics pg, RGroup group) {
  group.toShape().draw(pg);
}

private void textDrawEmphasis(PGraphics pg, RGroup group) {
  RGroup groupPoly = group.toPolygonGroup();
  RPoint[] points = groupPoly.getPoints();
  pg.fill(0);
  //DRAW ELLIPSES AT EACH OF THESE POINTS
  for (int i=0; i<points.length; i++) {
    pg.ellipse(points[i].x, points[i].y, 5, 5);
  }
}

private void textDrawShake(PGraphics pg, RGroup group) {
  RGroup groupPoly = group.toPolygonGroup();
  RPoint[] points = groupPoly.getPoints();
  pg.fill(255, 0, 0);
  //DRAW ELLIPSES AT EACH OF THESE POINTS
  for (int i=0; i<points.length; i++) {
    float noise = random(4);
    pg.ellipse(points[i].x, points[i].y, 5+noise, 5+noise);
  }
}

private void textDrawBeat(PGraphics pg, RGroup group) {
  pg.translate(0, 0, 50);

  // beat and fade
  float noise = random(0.1);

  // scale from center
  pg.translate(group.getCenter().x, group.getCenter().y);
  pg.scale(1+noise);
  pg.translate(-group.getCenter().x, -group.getCenter().y);

  pg.fill(0+20*noise);

  RGroup groupPoly = group.toPolygonGroup();
  RPoint[] points = groupPoly.getPoints();
  //DRAW ELLIPSES AT EACH OF THESE POINTS
  for (int i=0; i<points.length; i++) {
    pg.ellipse(points[i].x, points[i].y, 5, 5);
  }
}
