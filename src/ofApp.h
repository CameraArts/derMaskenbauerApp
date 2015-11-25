#pragma once

#include "ofMain.h"
#include "ofxiOS.h"
//#include "ofxiOSExtras.h"
#include "ofxCoreMotion.h"
#include "ofxThreadedImage.h"

class ofApp : public ofxiOSApp {
	
    public:
        void setup();
        void update();
        void draw();
        void exit();
	
        void touchDown(ofTouchEventArgs & touch);
        void touchMoved(ofTouchEventArgs & touch);
        void touchUp(ofTouchEventArgs & touch);
        void touchDoubleTap(ofTouchEventArgs & touch);
        void touchCancelled(ofTouchEventArgs & touch);

        void lostFocus();
        void gotFocus();
        void gotMemoryWarning();
        void deviceOrientationChanged(int newOrientation);

    void checkPos();
    int currentPos;
    
    ofEasyCam cam;
    ofVboMesh mesh;
    ofImage splash;
    ///////////////////
    ofFbo fbo;
    ofTrueTypeFont font;
    ///////////////////
    int sphereRadius;
    float compass, zenith_x, zenith_y;
    float xCounter, yCounter, zCounter;
    bool xReverse, zReverse;
    
    ofxCoreMotion coreMotion;
    ofCamera camera;
    ofxiOSSoundPlayer snd[4];
    ofxiOSSoundPlayer   snd_iPhone;
    bool playedAlready;
    int frameCounter;
    int imgCounter;
    int totalImages;
    int freq;
    int speed;
    
    bool ipad;
    
    ofxThreadedImage img;
    ofxThreadedImage imgBg;
    string file;
    bool loading;
    
    bool start;
    ofQuaternion quat;
    int orientation;
    int frameRate;
    
};


