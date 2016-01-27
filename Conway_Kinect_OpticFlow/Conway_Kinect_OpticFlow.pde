import gab.opencv.*;
import controlP5.*;

import org.openkinect.freenect.*;
import org.openkinect.processing.*;

// GLSL version of Conway's game of life, ported from GLSL sandbox:
// http://glsl.heroku.com/e#207.3
// Exemplifies the use of the ppixels uniform in the shader, that gives
// access to the pixels of the previous frame.
PShader conway;
PGraphics pg;

Kinect kinect;
OpenCV opencv;

// Depth image
PImage depthImg;
PImage smallDepthImg;
PImage motionImg;
int[] backgroundPixels;
int[] motion;
int[][] buffer;
int numBuffers = 3;  // helps reduce noise
int numDepthPixels = 640*480;

// Control panel
ControlP5 cp5;
controlP5.Slider min;
controlP5.Slider max;
float minThreshold;
float maxThreshold;

// show debug
boolean bDebug = false;

void setup() {
  size(800,600, P3D);    

  // setup controls
  cp5 = new ControlP5(this);
  min = cp5.addSlider("minThreshold")
     .setPosition(50,50)
     .setRange(0.0,3.0)
     .setValue(1.66)
     ;
  max = cp5.addSlider("maxThreshold")
     .setPosition(50,70)
     .setRange(0.0,3.0)
     .setValue(2.8)
     ;
  min.hide();  // hide GUI to start
  max.hide();  // hide GUI to start

  // setup the kinect
  kinect = new Kinect(this);
  kinect.initDepth();

  // setup OpenCV
  opencv = new OpenCV(this, 128, 96);

  // setup the shader
  pg = createGraphics(width, height, P2D);
  pg.noSmooth();
  conway = loadShader("conway_gradient_02.glsl");
  conway.set("resolution", float(pg.width), float(pg.height));  
  conway.set("kinectResolution", float(kinect.width), float(kinect.height));
  
  int numMotionPixels = opencv.width * opencv.height;
  motion = new int[numMotionPixels];
  buffer = new int[numBuffers][numDepthPixels];
  
  motionImg = createImage(opencv.width, opencv.height, RGB);
  smallDepthImg = createImage(opencv.width, opencv.height, RGB);
  // save background image at start
  backgroundPixels = new int[numDepthPixels];
  saveBackground();
}

void draw() {
  // Pass depth texture to shader in correct orientation
  depthImg = kinect.getDepthImage();
  depthImg.loadPixels();
  
  smallDepthImg.loadPixels();
  int ratio = depthImg.width/smallDepthImg.width;
  for(int y=0; y<smallDepthImg.height; y++){
    for(int x=0; x<smallDepthImg.width; x++){
      int smallIndex = y*smallDepthImg.width + x;
      int bigIndex = y*ratio*depthImg.width + x*ratio;
      smallDepthImg.pixels[smallIndex] = depthImg.pixels[bigIndex];
    }
  }
  smallDepthImg.updatePixels();
  // open cv for optic flow
  opencv.loadImage(smallDepthImg);
  opencv.calculateOpticalFlow();

  //// calculate the total motion
  //// zero the motion array
  //for(int i=0; i<motion.length; i++) {
  //  motion[i] = 0;
  //}
  
  //// go through video to find motion
  //for(int i=0; i<depthImg.pixels.length; i++) {
  //  color col = Math.abs(depthImg.pixels[i] - backgroundPixels[i]);
  //  int R = (col >> 16) & 0xFF;
  //  int G = (col >> 8) & 0xFF;
  //  int B = col & 0xFF;
  //  int brightness = (R + G + B) / 3;  // 0-255
    
  //  int delta = 0;
  //  for(int j=0; j<numBuffers; j++) {
  //    delta += buffer[j][i];
  //  }
  //  delta /= numBuffers;
  //  delta -= brightness;
  //  delta = delta < 0 ? delta * -1 : delta;  // absolute value
  //  motion[i] = delta;
    
  //  // shift buffers
  //  for(int j=numBuffers-1; j>=0; j--) {
  //    if(j==0)
  //      buffer[j][i] = brightness;
  //    else
  //      buffer[j][i] = buffer[j-1][i];
  //  }
  //}
  
  //store motion in a PImage
  motionImg.loadPixels();
  for(int i=0; i<motion.length; i++) {
   float flow = opencv.getAverageFlow().mag();
   //flow = map(flow, 0, 1.0, 0, 255.0);
   motionImg.pixels[i] = color(flow, flow, flow);//motion[i], motion[i], motion[i]);
  }
  motionImg.updatePixels();
  
  // flip image to send to shader
  //for (int y = 0; y < depthImg.height; y++) {
  //  for (int x = 0; x < depthImg.width; x++) {
  //    depthImg.pixels[(depthImg.height-y-1)*depthImg.width+x] = depthImg.pixels[y*depthImg.width+x];
  //  }
  //} 
  conway.set("time", millis()/1000.0);
  conway.set("depthImg", motionImg);  
  conway.set("minThreshold", minThreshold);
  conway.set("maxThreshold", maxThreshold);
  pg.beginDraw();
  pg.shader(conway);
  // make black and white
  pg.rect(0, 0, pg.width, pg.height);
  pg.endDraw();  
  image(pg, 0, 0, width, height);
 
  // draw depth image
  if(bDebug) {
    image(depthImg, 0, 0, 256, 192);
    image(motionImg, 256, 0, 256, 192);
    String txt = "framerate:" + frameRate;
    text(txt, 10, 10); 
  }
}

void saveBackground() {
  depthImg = kinect.getDepthImage();
  depthImg.loadPixels();
  
  for(int i=0; i<numDepthPixels; i++) {
    backgroundPixels[i] = depthImg.pixels[i];
  }
}

void keyPressed() {
 if( key == ' ' ) {
   // clear background
   saveBackground();
 }
 else if( key == 'd' ) {
   bDebug = !bDebug;
   if(bDebug) {
     min.show();
     max.show();
   }
   else {
     min.hide();
     max.hide();
   }
 }
}