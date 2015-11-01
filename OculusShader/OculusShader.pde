
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
Frame mainFrame;
Frame textFrame;
float rotateLookX = 0;
float rotateLookY = 0;

float floorDist = 1.; // for grid, let's say we're seated


RFont font;
textHolder desc;


PShader barrel;
int eye_width = 640;
int eye_height = 800;
PGraphics fb;
PGraphics scene;

textPicking pick;
textArea area;

// position and scale of text
PVector position;
float scale;

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
  // disable keyboard action: we will handle it ourselves
  proscene.disableKeyboardAgent();


  // our eye is the center of the world
  proscene.eye().setPosition(new Vec(0, 0, 0));

  mainFrame = new Frame(proscene);
  textFrame = new Frame(proscene);
  textFrame.setReferenceFrame(mainFrame);

  // place frame
  position = new PVector (0, 0, -5);
  scale = 0.01;

  // world/font ratio = 10
  area = new textArea(proscene.pg(), proscene, textFrame, new PVector (4, 3), position, scale);
  area.loadText("");
  pick = area.getPick();
  pick.debug = true;
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

  pick.setCursor(new Vec(cursorX , cursorY, 0));
}

public void mainDrawing(Scene s) {
  PGraphics pg = s.pg();

  pg.background(255);

  pg.pushMatrix();
  drawGrid(pg, new PVector(0, floorDist, 0), 10, 10);
  
  // text
  pg.pushMatrix();
  textFrame.applyTransformation();
  // show debug with current matrix
  area.draw();
  pg.popMatrix();  

  // deal with FPS (have to place it manually)
  pg.pushMatrix();
  pg.translate(position.x, position.y, position. z);
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

