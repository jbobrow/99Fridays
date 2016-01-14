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

// Depth image
PImage depthImg;

// Control panel
ControlP5 cp5;
controlP5.Slider min;
controlP5.Slider max;
float minThreshold;
float maxThreshold;

// show debug
boolean bDebug = false;

void setup() {
  size(1024, 768, P3D);    

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

  // setup the shader
  pg = createGraphics(width, height, P2D);
  pg.noSmooth();
  conway = loadShader("conway.glsl");
  conway.set("resolution", float(pg.width), float(pg.height));  
  conway.set("kinectResolution", float(kinect.width), float(kinect.height));
}

void draw() {
  // Pass depth texture to shader in correct orientation
  depthImg = kinect.getDepthImage();
  depthImg.loadPixels();
  // flip image to send to shader
  //for (int y = 0; y < depthImg.height; y++) {
  //  for (int x = 0; x < depthImg.width; x++) {
  //    depthImg.pixels[(depthImg.height-y-1)*depthImg.width+x] = depthImg.pixels[y*depthImg.width+x];
  //  }
  //} 
  conway.set("time", millis()/1000.0);
  conway.set("depthImg", depthImg);  
  conway.set("minThreshold", minThreshold);
  conway.set("maxThreshold", maxThreshold);
  pg.beginDraw();
  pg.shader(conway);
  pg.rect(0, 0, pg.width, pg.height);
  pg.endDraw();  
  image(pg, 0, 0, width, height);
 
  // draw depth image
  if(bDebug) {
    image(depthImg, 0, 0, 256, 192);
  }
}

void keyPressed() {
 if( key == ' ' ) {
   // clear background
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