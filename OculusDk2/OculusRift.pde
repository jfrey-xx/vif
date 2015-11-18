/*
 Copyright (c) 2015, Sunao Hashimoto All rights reserved.
 
 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:
 * Redistributions of source code must retain the above copyright notice, 
 this list of conditions and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright notice, 
 this list of conditions and the following disclaimer in the documentation 
 and/or other materials provided with the distribution.
 * Neither the name of the kougaku-navi nor the names of its contributors 
 may be used to endorse or promote products derived from this software 
 without specific prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL <COPYRIGHT HOLDER> BE LIABLE FOR ANY
 DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

/*
 Thanks a lot for the following codes.
 
 jherico/jovr
 https://github.com/jherico/jovr
 
 JOVR – Java bindings for Oculus Rift SDK 0.4.2.0 | Laht's blog
 http://laht.info/jovr-java-bindings-for-oculus-rift-sdk-0-4-0/
 
 ixd-hof/Processing
 https://github.com/ixd-hof/Processing/tree/master/Examples/Oculus%20Rift/OculusRift_Basic
 
 xohm/SimpleOculusRift
 https://github.com/xohm/SimpleOculusRift
 
 mactkg/pg_jack_p3d.pde
 https://gist.github.com/mactkg/66f99c9563c6a043e14e
 
 Solved: Using a Quaternion and Vector to construct a camera view matrix
 https://social.msdn.microsoft.com/Forums/en-US/ec92a231-2dbf-4f3e-b7f5-0a4d9ea4cae2 
 */

//import static com.oculusvr.capi.OvrLibrary.ovrDistortionCaps.*;
//import static com.oculusvr.capi.OvrLibrary.ovrHmdType.*;
//import static com.oculusvr.capi.OvrLibrary.ovrRenderAPIType.*;
//import static com.oculusvr.capi.OvrLibrary.ovrTrackingCaps.*;

import com.oculusvr.capi.EyeRenderDesc;
import com.oculusvr.capi.FovPort;
import com.oculusvr.capi.GLTexture;
import com.oculusvr.capi.Hmd;
import com.oculusvr.capi.OvrLibrary;
import com.oculusvr.capi.OvrLibrary.ovrHmdCaps;
import com.oculusvr.capi.OvrVector2i;
import com.oculusvr.capi.OvrVector3f;
import com.oculusvr.capi.Posef;
import com.oculusvr.capi.RenderAPIConfig;




import com.oculusvr.capi.Hmd;
import com.oculusvr.capi.OvrQuaternionf;
import com.oculusvr.capi.OvrVector3f;
import com.oculusvr.capi.TrackingState;
import java.lang.reflect.Method;

class OculusRift {

  // Parameters for DK2
  private final int oculus_width  = 1920; // for DK2
  private final int oculus_height = 1080; // for DK2
  private final float fov_deg     = 100;  // for DK2
  private final float z_near      = 10;
  private final float z_far       = 100000;

  private final float scaleFactor   = 2.11;
  private final float imageScaling  = 2.27;
  private final int   imageShiftX   = 437;
  private final int   imageCutWidth = 0;
  private final float sensingScale  = 1000.0;  // for millimeter

  private PApplet _parent;
  private PGraphics pg_backup;
  private Method  onDrawSceneMethod;

  private PGraphics3D scene;
  private PGraphics fb;
  private PShader barrel;

  private Hmd hmd;
  private boolean isUsingHeadTracking;
  private PMatrix3D headMatrix;
  private PMatrix3D correctionMatrix;

  float ipd;
  float  eyeHeight;
  PMatrix3D [] projections = new PMatrix3D[2];

  private final FovPort fovPorts[] =
    (FovPort[])new FovPort().toArray(2);

  protected final Posef[] poses = 
    (Posef[])new Posef().toArray(2);


  // -------------------------------------------------------------
  // Public


  // Constructor
  public OculusRift(PApplet app) {
    _parent = app;




    int eye_width = oculus_width/2;
    int eye_height = oculus_height;    
    scene = (PGraphics3D) createGraphics( eye_width, eye_height, P3D);
    fb = createGraphics(oculus_width, oculus_height, P3D);

    barrel = loadShader("barrel_frag.glsl");
    onDrawSceneMethod = getMethodRef( _parent, "onDrawScene", new Class[] {
      int.class
      }
      );

    correctionMatrix = new PMatrix3D();
    headMatrix = new PMatrix3D();
    isUsingHeadTracking = false;
  }

  // Enable head tracking
  public boolean enableHeadTracking() {
    Hmd.initialize();
    hmd = Hmd.create(0);

    if (0 == hmd.configureTracking(
      com.oculusvr.capi.OvrLibrary.ovrTrackingCaps.ovrTrackingCap_Orientation | 
      com.oculusvr.capi.OvrLibrary.ovrTrackingCaps.ovrTrackingCap_Position, 0)) {
      throw new IllegalStateException(
        "Unable to start the sensor");
    }


    ipd = hmd.getFloat(OvrLibrary.OVR_KEY_IPD, OvrLibrary.OVR_DEFAULT_IPD);
    println("ipd:", ipd);

    eyeHeight = hmd.getFloat(OvrLibrary.OVR_KEY_EYE_HEIGHT, OvrLibrary.OVR_DEFAULT_EYE_HEIGHT);
    println("eyeHeight:", eyeHeight);

    for (int eye = 0; eye < 2; ++eye) {
      fovPorts[eye] = hmd.DefaultEyeFov[eye];

      println("uptan", eye, ":", fovPorts[eye].UpTan);
      println("lefttan", eye, ":", fovPorts[eye].LeftTan);

      OvrMatrix4f toto =   Hmd.getPerspectiveProjection(
        fovPorts[eye], 0.1f, 1000000f, false);

      projections[eye] = new PMatrix3D();
      projections[eye].set(toto.M);
      println("proj matrix eye");
      projections[eye].print();

      // change right-hand to left-hand
      // projections[eye].preApply(
      //   1, 0, 0, 0, 
      //   0, -1, 0, 0, 
      //   0, 0, 1, 0, 
      //   0, 0, 0, 1
      //   );
      // projections[eye].scale(1, -1, 1);

      println("after correction");
      projections[eye].print();


      EyeRenderDesc eyeRenderDesc = hmd.getRenderDesc(eye, fovPorts[eye]);
      println( eyeRenderDesc.HmdToEyeViewOffset.x);
      println( eyeRenderDesc.HmdToEyeViewOffset.y);
      println( eyeRenderDesc.HmdToEyeViewOffset.z);


      //GLTexture texture = eyeTextures[eye];
      //TextureHeader header = texture.ogl.Header;
      //header.API = ovrRenderAPI_OpenGL;
      //header.TextureSize = hmd.getFovTextureSize(
      //  eye, fovPorts[eye], 1.0f);
      //header.RenderViewport.Size = header.TextureSize; 
      //header.RenderViewport.Pos = new OvrVector2i(0, 0);
    }


    if (hmd == null) {
      isUsingHeadTracking = false;
    } else {
      isUsingHeadTracking = true;
      resetHeadState();
    }
    return isUsingHeadTracking;
  }

  // Reset head state by current state.
  public void resetHeadState() {
    PMatrix3D m = getMatrixFromSensor();
    m.invert();
    correctionMatrix = m;
  }

  // Get corrected head state matrix.
  public PMatrix3D getMatrix() {
    PMatrix3D m = getMatrixFromSensor();
    m.apply(correctionMatrix);
    return m;
  }

  // Draw oculus image
  public void draw() {
    updateHeadState();

    // retrieve eye position -- do not care about prediction
    // OvrVector3f[] test = new OvrVector3f[2];
    // hmd.getEyePoses(0, test);

    // println("eye0:", test[0].x, test[0].y, test[0].z);
    // println("eye1:", test[1].x, test[1].y, test[1].z);


    int imageMode = _parent.g.imageMode;
    _parent.imageMode(CENTER);
    _parent.blendMode(ADD);
    _parent.background(0);

    // Render left eye
    beginScene(0);
    runOnDrawSceneMethod(LEFT);
    endScene();
    set_shader(LEFT);
    _parent.shader(barrel);    
    fb.beginDraw();
    fb.background(0);
    fb.image( scene, 50, 0 );    
    fb.fill(0);
    fb.rect( 0, 0, imageCutWidth, fb.height);
    fb.rect( scene.width-imageCutWidth, 0, imageCutWidth, scene.height);    
    fb.endDraw();
    _parent.image(fb, _parent.width/2 + imageShiftX, _parent.height/2, fb.width*imageScaling, fb.height*imageScaling);
    _parent.resetShader();

    // Render right eye
    beginScene(1);
    runOnDrawSceneMethod(RIGHT);
    endScene();
    set_shader(RIGHT);
    _parent.shader(barrel);
    fb.beginDraw();
    fb.background(0);
    fb.image( scene, scene.width-50, 0 );
    fb.fill(0);
    fb.rect( scene.width, 0, imageCutWidth, scene.height );
    fb.rect( fb.width - imageCutWidth, 0, imageCutWidth, fb.height );
    fb.endDraw();
    _parent.image(fb, _parent.width/2 - imageShiftX, _parent.height/2, fb.width*imageScaling, fb.height*imageScaling);   
    _parent.resetShader();

    _parent.blendMode(BLEND);
    _parent.imageMode(imageMode);
  }


  // -------------------------------------------------------------
  // Private

  private void updateHeadState() {
    if (!isUsingHeadTracking) return;
    headMatrix = getMatrix();
  }

  private void applyHeadState() {
    if (!isUsingHeadTracking) return;
    applyMatrix(headMatrix);
  }

  private PMatrix3D getMatrixFromSensor() {
    TrackingState sensorState = hmd.getSensorState(Hmd.getTimeInSeconds());
    OvrVector3f pos = sensorState.HeadPose.Pose.Position;
    OvrQuaternionf quat = sensorState.HeadPose.Pose.Orientation;
    return calcMatrix(pos.x, pos.y, pos.z, quat.x, quat.y, quat.z, quat.w );
  }  

  private void runOnDrawSceneMethod(int eye) {
    try {
      onDrawSceneMethod.invoke( _parent, new Object[] { 
        (int)eye
        } 
        );
    } 
    catch (Exception e) {
    }
  }

  private Method getMethodRef(Object obj, String methodName, Class[] paraList) {
    Method ret = null;
    try {
      ret = obj.getClass().getMethod(methodName, paraList);
    }
    catch (Exception e) {
    }
    return ret;
  }

  private void beginScene(int eye) {
    
    scene.beginDraw();
    pg_backup = _parent.g;
    _parent.g = scene;
    resetMatrix();
    perspective( radians(fov_deg), scene.width*1.0/scene.height, z_near, z_far);
    applyHeadState();

    // ipd from m to mm
    float factor = 1000;

    // stereo easy with HMD since cameras are //
    if (eye == 0) {
      beginCamera();
      translate(ipd*factor/2, 0, 0);
      endCamera();
    } else {
      beginCamera();
      translate(-ipd*factor/2, 0, 0);
      endCamera();
    }
  }

  private void endScene() {
    _parent.g = pg_backup;
    scene.endDraw();
  }

  private void set_shader(int eye) {
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

    if (eye == LEFT) {
      x = 0.0f;
      y = 0.0f;
      w = 0.5f;
      h = 1.0f;
      DistortionXCenterOffset = 0.25f;
    } else if (eye == RIGHT) {
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

  private PMatrix3D calcMatrix(float px, float py, float pz, float qx, float qy, float qz, float qw) {
    PMatrix3D mat = new PMatrix3D();

    // calculate matrix terms
    float two_xSquared = 2 * qx * qx;
    float two_ySquared = 2 * qy * qy;
    float two_zSquared = 2 * qz * qz;
    float two_xy = 2 * qx * qy;
    float two_wz = 2 * qw * qz;
    float two_xz = 2 * qx * qz;
    float two_wy = 2 * qw * qy;
    float two_yz = 2 * qy * qz;
    float two_wx = 2 * qw * qx;

    // update view matrix orientation
    mat.m00 = 1 - two_ySquared - two_zSquared;
    mat.m01 = two_xy + two_wz;
    mat.m02 = two_xz - two_wy;
    mat.m10 = two_xy - two_wz;
    mat.m11 = 1 - two_xSquared - two_zSquared;
    mat.m12 = two_yz + two_wx;
    mat.m20 = two_xz + two_wy;
    mat.m21 = two_yz - two_wx;
    mat.m22 = 1 - two_xSquared - two_ySquared;

    // change right-hand to left-hand
    mat.preApply(
      1, 0, 0, 0, 
      0, -1, 0, 0, 
      0, 0, 1, 0, 
      0, 0, 0, 1
      );
    mat.scale(1, -1, 1);

    // Position    
    mat.m03 = sensingScale * pz;
    mat.m13 = sensingScale * py;
    mat.m23 = sensingScale * (-px);

    return mat;
  }
}