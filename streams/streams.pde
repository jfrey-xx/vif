

import edu.ucsd.sccn.LSL;


void setup() {
  size(300, 100);
  frameRate(30);

  println("init with first value:", textState.getStreamValue("heart"));
}


void draw() {

  println("time:", millis(), "value:", textState.getStreamValue("heart"));
}