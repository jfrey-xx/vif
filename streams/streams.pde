

import edu.ucsd.sccn.LSL;
import AULib.*;

void setup() {
  size(800, 600, P3D);
  frameRate(60);

  println("init with first value:", textState.getStreamValue("heart"));

  println("init with first value:", textState.getStreamValue("no_heart"));
}


void draw() {
  clear();
  // println("time:", millis(), "value:", textState.getStreamValue("heart"));

  pushMatrix();
  float s1 = textState.getStreamValue("heart");
  translate(200, 200);
  sphere(s1 * 100);
  popMatrix();

  pushMatrix();
  float s2 = textState.getStreamValue("breath");
  translate(400, 200);
  sphere(s2 * 100);
  popMatrix();


  pushMatrix();
  float s3 = textState.getStreamValue("no_heart");
  translate(600, 200);
  sphere(s3 * 100);
  popMatrix();
}