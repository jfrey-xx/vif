
/**
 
 Testing oculus rift with shader, from https://github.com/ixd-hof/Processing
 
 Origin at level with the eye, world unit: 1 meter
 
 FIXME: shaders are off compared to lib version
 
 */

import geomerative.*;
import SimpleOculusRift.*;
import remixlab.proscene.*;
import remixlab.dandelion.core.*; // eg for Frame
import remixlab.dandelion.geom.*; // eg for Vec

// used by text* for streams
import edu.ucsd.sccn.LSL;
import AULib.*;

Scene proscene;
Frame mainFrame;
Frame textFrame;
float rotateLookX = 0;
float rotateLookY = 0;

PShader barrel;
int eye_width = 640;
int eye_height = 800;
PGraphics fb;
PGraphics scene;

textUniverse universe;

// scale of text
float scale;

// position for FPS
PVector positionFPS = new PVector(0, 0, -5);

//----------------SETUP---------------------------------
void setup() {
  size(1280, 800, P3D);
  frameRate(30);

  // Create framebuffer
  fb = createGraphics(width, height, P3D);
  // Create PGraphics for actual scene
  scene = createGraphics(eye_width, eye_height, P3D);

  // Load fragment shader for oculus rift barrel distortion
  barrel = loadShader("barrel_frag.glsl");

  proscene = new Scene(this, scene);
  proscene.addDrawHandler(this, "mainDrawing");
  // disable keyboard action: we will handle it ourselves
  proscene.disableKeyboardAgent();

  // our eye is the center of the world
  proscene.eye().setPosition(new Vec(0, 0, 0));

  mainFrame = new Frame(proscene);
  textFrame = new Frame(proscene);
  textFrame.setReferenceFrame(mainFrame);

  // world/font ratio = 10
  scale = 0.01;
  universe = new textUniverse(this, proscene.pg(), proscene, textFrame, scale, "data.json");
}


// apply head transformation to frame (both from oculus and keyboard)
void updateReferenceFrame() {
  // yaw, pitch, roll
  Quat head = new Quat(rotateLookX, rotateLookY, 0);
  textFrame.setRotation(head);
}

//----------------DRAW---------------------------------


void draw() {
  float cursorX = mouseX/2;
  float cursorY = mouseY;

  updateReferenceFrame();

  background(0);

  scene.beginDraw();
  proscene.beginDraw();

  proscene.endDraw();
  scene.endDraw();

  blendMode(ADD);

  // Render left eye
  set_shader("left");
  shader(barrel);
  fb.beginDraw();
  fb.background(0);
  // fb.image(scene, 50, 0, eye_width, eye_height);
  fb.image(scene, 0, 0, eye_width, eye_height);
  // show a cursor that is affected by shader, compensate for cursor size
  fb.rect(cursorX-5, cursorY-5, 10, 10);
  fb.endDraw();
  image(fb, 0, 0);

  resetShader();

  // Render right eye
  set_shader("right");
  shader(barrel);
  fb.beginDraw();
  fb.background(0);
  // fb.image(scene, eye_width-50, 0, eye_width, eye_height);
  fb.image(scene, eye_width, 0, eye_width, eye_height);
  fb.rect(cursorX+eye_width-5, cursorY-5, 10, 10);
  fb.endDraw();
  image(fb, 0, 0);

  textPicking.setCursor(new Vec(cursorX, cursorY, 0));
}

public void mainDrawing(Scene s) {
  PGraphics pg = s.pg();

  pg.background(255);

  pg.pushMatrix();

  // text
  pg.pushMatrix();
  textFrame.applyTransformation();
  // show debug with current matrix
  universe.draw();
  pg.popMatrix();  

  // deal with FPS (have to place it manually)
  pg.pushMatrix();
  pg.translate(positionFPS.x, positionFPS.y, positionFPS.z);
  pg.fill(0, 0, 255);
  pg.scale(scale);
  pg.text(frameRate, 10, 10);
  pg.popMatrix();


  pg.popMatrix();
}

// reset / set orientation
void keyPressed() {
  println("Key pressed: [", key, "]");
  if (key == ' ') {
    println("reset head orientation and position");
    proscene.eye().setPosition(new Vec(0, 0, 0));
    rotateLookX = 0;
    rotateLookY = 0;
  } else if (keyCode == UP) {
    println("look up");
    rotateLookX -= 0.1;
  } else if (keyCode == DOWN) {
    println("look down");
    rotateLookX += 0.1;
  } else if (keyCode == LEFT) {
    println("look down");
    rotateLookY += 0.1;
  } else if (keyCode == RIGHT) {
    println("look down");
    rotateLookY -= 0.1;
  }
}

void set_shader(String eye)
{
  float x = 0.0;
  float y = 0.0;
  float w = 0.5;
  float h = 1.0;
  float DistortionXCenterOffset = 0.25;
  float as = w/h;

  float K0 = 1.0f;
  float K1 = 0.22f;
  float K2 = 0.24f;
  float K3 = 0.0f;

  float scaleFactor = 0.7f;

  if (eye == "left")
  {
    x = 0.0f;
    y = 0.0f;
    w = 0.5f;
    h = 1.0f;
    DistortionXCenterOffset = 0.25f;
  } else if (eye == "right")
  {
    x = 0.5f;
    y = 0.0f;
    w = 0.5f;
    h = 1.0f;
    DistortionXCenterOffset = -0.25f;
  }

  barrel.set("LensCenter", x + (w + DistortionXCenterOffset * 0.5f)*0.5f, y + h*0.5f);
  barrel.set("ScreenCenter", x + w*0.5f, y + h*0.5f);
  barrel.set("Scale", (w/2.0f) * scaleFactor, (h/2.0f) * scaleFactor * as);
  barrel.set("ScaleIn", (2.0f/w), (2.0f/h) / as);
  barrel.set("HmdWarpParam", K0, K1, K2, K3);
}

//////////////////////////////////////////////
