
/**
 
 Testing oculus rift with shader, from https://github.com/ixd-hof/Processing
 
 Origin at level with the eye, world unit: 1 meter
 
 FIXME: shaders are off compared to lib version
 
 */

import geomerative.*;
import SimpleOculusRift.*;
import remixlab.proscene.*;
import remixlab.dandelion.geom.*;

Scene proscene;

float floorDist = 1.; // for grid, let's say we're seated


RFont font;
textHolder desc;


PShader barrel;
int eye_width = 640;
int eye_height = 800;
PGraphics fb;
PGraphics scene;


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

  //surface.setResizable(true);
  RG.init(this); 

  //CONFIGURE SEGMENT LENGTH AND MODE
  //SETS THE SEGMENT LENGTH BETWEEN TWO POINTS ON A SHAPE/FONT OUTLINE
  RCommand.setSegmentLength(10);//ASSIGN A VALUE OF 10, SO EVERY 10 PIXELS
  RCommand.setSegmentator(RCommand.UNIFORMLENGTH);

  proscene = new Scene(this, scene);
  proscene.addDrawHandler(this, "mainDrawing");

  desc = new textHolder(proscene.pg(), "FreeSans.ttf", 100, 0.01);
  desc.setWidth(6);
  desc.addText("one");
  desc.addText("second", textType.BEAT);
  desc.addText(" et un et deux", textType.EMPHASIS);
  desc.addText("nst nstnstnst aw ", textType.SHAKE);

  println("physicalDistanceToScreen:", proscene.camera().physicalDistanceToScreen());
  println("distanceToSceneCenter:", proscene.camera().distanceToSceneCenter());
  
  // our eye is the center of the world
  proscene.eye().setPosition(new Vec(0, 0, 0));
}

//----------------DRAW---------------------------------


void draw() {
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
  fb.image(scene, 50, 0, eye_width, eye_height);
  fb.endDraw();
  image(fb, 0, 0);

  resetShader();

  // Render right eye
  set_shader("right");
  shader(barrel);
  fb.beginDraw();
  fb.background(0);
  fb.image(scene, eye_width-50, 0, eye_width, eye_height);
  fb.endDraw();
  image(fb, 0, 0);
}

public void mainDrawing(Scene s) {
  PGraphics pg = s.pg();

  pg.background(255);

  //  pg.translate(eye_width/2, eye_height/2, 0);

  pg.scale(1);

  pg.pushMatrix();
  //scene.translate(0, 100);
  pg.scale(1, 1, 1);
  drawGrid(pg, new PVector(0, floorDist, 0), 10, 10);
  pg.popMatrix();

  pg.pushMatrix();
  pg.translate(0, 0, -5);
  desc.draw();
  desc.drawDebug();
  pg.fill(0, 0, 255);
   scene.scale(0.01);
  pg.text(frameRate, 10, 10);
  pg.popMatrix();
}

void keyPressed() {
  println("distanceToSceneCenter:", proscene.camera().distanceToSceneCenter());
}

void drawGrid(PGraphics pg, PVector center, float length, int repeat)
{
  pg.pushMatrix();
  pg.translate(center.x, center.y, center.z);
  float pos;

  for (int x=0; x < repeat+1; x++)
  {
    pos = -length *.5 + x * length / repeat;

    pg.line(-length*.5, 0, pos, 
    length*.5, 0, pos);

    pg.line(pos, 0, -length*.5, 
    pos, 0, length*.5);
  }
  pg.popMatrix();
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