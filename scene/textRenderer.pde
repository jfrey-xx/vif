
import geomerative.*;

public void textDraw(RGroup group, textType type) {
  pushStyle();
  fill(0);
  noStroke();
  pushMatrix();
  switch (type) {
  case EMPHASIS:
    textDrawEmphasis(group);
    break;
  case SHAKE:
    textDrawShake(group);
    break;
  case BEAT:
    textDrawBeat(group);
    break;
  default:
    textDrawRegular(group);
    break;
  }
  popMatrix();
  popStyle();
}

private void textDrawRegular(RGroup group) {
  group.toShape().draw();
}

private void textDrawEmphasis(RGroup group) {
  RGroup groupPoly = group.toPolygonGroup();
  RPoint[] points = groupPoly.getPoints();
  fill(0);
  //DRAW ELLIPSES AT EACH OF THESE POINTS
  for (int i=0; i<points.length; i++) {
    ellipse(points[i].x, points[i].y, 5, 5);
  }
}

private void textDrawShake(RGroup group) {
  RGroup groupPoly = group.toPolygonGroup();
  RPoint[] points = groupPoly.getPoints();
  fill(255, 0, 0);
  //DRAW ELLIPSES AT EACH OF THESE POINTS
  for (int i=0; i<points.length; i++) {
    float noise = random(4);
    ellipse(points[i].x, points[i].y, 5+noise, 5+noise);
  }
}

private void textDrawBeat(RGroup group) {
  translate(0, 0, 50);

  // beat and fade
  float noise = random(0.1);

  // scale from center
  translate(group.getCenter().x, group.getCenter().y);
  scale(1+noise);
  translate(-group.getCenter().x, -group.getCenter().y);

  fill(0+20*noise);

  RGroup groupPoly = group.toPolygonGroup();
  RPoint[] points = groupPoly.getPoints();
  //DRAW ELLIPSES AT EACH OF THESE POINTS
  for (int i=0; i<points.length; i++) {
    ellipse(points[i].x, points[i].y, 5, 5);
  }
}