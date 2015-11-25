#include "ofApp.h"
#define _USE_MATH_DEFINES
#include <math.h>

//--------------------------------------------------------------
void ofApp::setup(){
    
    //ofLog(OF_LOG_SILENT);
    ofSetFrameRate(120);
    ofSetVerticalSync(true);
    ofEnableSmoothing();
    
    //check what device to display correct ratio
    if(ofxiOSGetDeviceType()== OFXIOS_DEVICE_IPHONE ){
        ipad = false;
   
            splash.load("splashiPhone.png");
            sphereRadius = 22; //retina
            speed = 120;
            snd_iPhone.load("sounds/JH_MN_Maskenbau_AudioOnly_01.mp3");
        
    }

    if(ofxiOSGetDeviceType()== OFXIOS_DEVICE_IPAD ){
        ipad = true;
        
        if(ofGetWidth() >= 1500) {
            splash.load("splashiPad.png");
            sphereRadius = 22; //retina
            speed = 120;
        }
        else {
            splash.load("splashNonRet.png");
            sphereRadius = 11; //non retina
            speed = 240;
        }
        //cout << "ipad" << endl;
        // load sounds///////////////////////////////////////////////////////////////
        snd[0].load("sounds/Masken bauen.mp3"); //
        snd[1].load("sounds/wie alles begann.mp3");
        snd[2].load("sounds/Partnerschaft.mp3");
        snd[3].load("sounds/Berufung.mp3");
        for(int i = 0; i < 4; i++ ){
            snd[i].setVolume(0.9);
        }

    }
    
    
    //image sequence///////////////////////////////////////////////////////////////
    imgCounter = 1000;
    img.loadImageThreaded( "imgs/Maskenbauer_" + ofToString(imgCounter)+".jpg" );//file );
    imgBg.loadImageThreaded( "imgs/Maskenbauer_" + ofToString(imgCounter)+".jpg" );//file );

    //fbo///////////////////////////////////////////////////////////////
    fbo.allocate(3584, 1792); //image size of Ricoh Theta jpgs
    font.load("font/EDITION_.TTF", 7, true, true, true, 1000, 600);
    font.setLetterSpacing(1.037);
    ofSetCircleResolution(200);
    
    glEnable(GL_POINT_SMOOTH); // use circular points instead of square points
    //glPointSize(3); // make the points bigger
    //glEnable(GL_CULL_FACE);
    //glCullFace(GL_BACK);
    
    //camera.setupPerspective();
    camera.setVFlip(false);
    camera.setPosition(0, 0, 0);
    coreMotion.setupAttitude(CMAttitudeReferenceFrameXMagneticNorthZVertical);

    orientation = ofGetOrientation();
    
    ofDisableDepthTest();
    ofDisableNormalizedTexCoords();
    start = false;
    frameCounter = 0;
}

//--------------------------------------------------------------
void ofApp::update(){
    
    if(start){
        frameCounter++;
        if(frameCounter%speed == 0){
            loading = !loading;
            if(loading){
                
                imgCounter++;
                if(imgCounter>1081)imgCounter = 1000;
                img.loadImageThreaded( "imgs/Maskenbauer_" + ofToString(imgCounter)+".jpg" );
                //cout << "img"<< imgCounter << ", frameCounter = "<< frameCounter << endl;
                
            }
            else{
                
                imgCounter++;
                if(imgCounter>1081)imgCounter = 1000;
                imgBg.loadImageThreaded( "imgs/Maskenbauer_" + ofToString(imgCounter)+".jpg" );
                //cout << "imgBg"<< imgCounter << ", frameCounter = "<< frameCounter << endl;
                
            }
        }
    }
    img.update();
    imgBg.update();
    
    
    coreMotion.update();
    
    // attitude
    quat = coreMotion.getQuaternion();
    ofQuaternion landscapeFix(-quat.y(), quat.x(), quat.z(), quat.w());
    ofQuaternion portraitFix(quat.x(), quat.y(), quat.z(), quat.w());
    camera.setOrientation(portraitFix);

    if(ipad){
    checkPos();
    }
}

//--------------------------------------------------------------
void ofApp::draw(){
    ofBackgroundGradient(ofColor::gray, ofColor::black, OF_GRADIENT_CIRCULAR);
    
    
    if(start){
        // zenith
        ofQuaternion qzx, qzy, qzz;
        qzx.set(sin(zenith_x/2*M_PI/180.0),0,0,cos(zenith_x/2*M_PI/180.0));
        qzy.set(0,sin(-zenith_y/2*M_PI/180.0),0,cos(-zenith_y/2*M_PI/180.0));
        qzz.set(0,0,sin(compass/2*M_PI/180.0),cos(compass/2*M_PI/180.0));
        ofMatrix4x4 m44(qzx*qzy);
        //ofMatrix4x4 m_yaw(qzz);

        camera.begin();
        ofPushMatrix();
        //glScalef(1,zoom,zoom);
        //ofMultMatrix(m_yaw); // adjust north
        ofMultMatrix(m44.getInverse());
        ofMatrix4x4 rot(0,-1,0,0,
                        0,0,-1,0,
                        1,0,0,0,
                        0,0,0,1);
        ofMultMatrix(rot);
        
        
        if(img.isReadyToDraw()){
            img.bind();
            ofDrawSphere(sphereRadius);
            img.unbind();
        }
        else if(imgBg.isReadyToDraw()){
            imgBg.bind();
            ofDrawSphere(sphereRadius);
            imgBg.unbind();
        }
        
        if (ipad) {

        ///////////////////////////////////////////////////////////////FBO
        fbo.begin();
        glEnable(GL_LINE_SMOOTH);
        ofClear(0, 0, 0, 0);
        glBlendFuncSeparate(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA, GL_ONE, GL_ONE_MINUS_SRC_ALPHA);

        
        ofSetLineWidth(2);
        
        if(orientation==1){ //only activate interview interface in portrait mode
            //masken bauen
            if(currentPos == 1){
                if(snd[0].isPlaying()) {
                    ofFill();
                    ofSetColor(255, 80, 80, 200);
                    ofRectRounded(40, 770, 210, 210, 2);
                    ofNoFill();
                    ofRectRounded(40, 770, 210, 210, 2);
                    ofSetColor(255, 255, 255, 255);
                    font.drawString("Masken\n bauen", (40 + 50), 880);
                }
                else {
                    ofFill();
                    ofSetColor(80, 80, 80, 150);
                    ofRectRounded(40, 770, 210, 210, 2);
                    ofNoFill();
                    ofSetColor(255, 255, 255, 255);
                    ofRectRounded(40, 770, 210, 210, 2);
                    font.drawString("Masken\n bauen", (40 + 50), 880);
                }
            }
            //wie alles begann
            else if(currentPos == 2){
                if(snd[1].isPlaying()) {
                    ofFill();
                    ofSetColor(255, 80, 80, 200);
                    ofRectRounded(773, 730, 210, 210, 2);
                    ofNoFill();
                    ofRectRounded(773, 730, 210, 210, 2);
                    ofSetColor(255, 255, 255, 255);
                    font.drawString("Wie Alles\n  begann", (773 + 45), 840);
                }
                else {
                    ofFill();
                    ofSetColor(80, 80, 80, 150);
                    ofRectRounded(773, 730, 210, 210, 2);
                    ofNoFill();
                    ofSetColor(255, 255, 255, 255);
                    ofRectRounded(773, 730, 210, 210, 2);
                    font.drawString("Wie Alles\n  begann", (773 + 45), 840);
                }
            }
            //partnerschaft
            else if(currentPos == 3){
                if(snd[2].isPlaying()) {
                    ofFill();
                    ofSetColor(255, 80, 80, 200);
                    ofRectRounded(1728, 730, 210, 210, 2);
                    ofNoFill();
                    ofRectRounded(1728, 730, 210, 210, 2);
                    ofSetColor(255, 255, 255, 255);
                    font.drawString("Partnerschaft", (1728 +5), 810);
                }
                else {
                    ofFill();
                    ofSetColor(80, 80, 80, 150);
                    ofRectRounded(1728, 730, 210, 210, 2);
                    ofNoFill();
                    ofSetColor(255, 255, 255, 255);
                    ofRectRounded(1728, 730, 210, 210, 2);
                    font.drawString("Partnerschaft", (1728+5), 810);
                }
            }
            //berufung
            else if(currentPos == 4){
                if(snd[3].isPlaying()) {
                    ofFill();
                    ofSetColor(255, 80, 80, 200);
                    ofRectRounded(2982, 500, 210, 210, 2);
                    ofNoFill();
                    ofRectRounded(2982, 500, 210, 210, 2);
                    ofSetColor(255, 255, 255, 255);
                    font.drawString("Berufung", (2982 + 45), 580);
                }
                else {
                    ofFill();
                    ofSetColor(80, 80, 80, 150);
                    ofRectRounded(2982, 500, 210, 210, 2);
                    ofNoFill();
                    ofSetColor(255, 255, 255, 255);
                    ofRectRounded(2982, 500, 210, 210, 2);
                    font.drawString("Berufung", (2982 + 45), 580);
                }
            }
        }//if orientation ends
        // end
        fbo.end();
        ///////////////////////////////////////////////////////////////FBO END
        
        //////////////////////////////////////////////
        fbo.getTextureReference().bind();
        ofDrawSphere(sphereRadius);
        fbo.getTextureReference().unbind();
        //////////////////////////////////////////////
        }//if ipad ends
        
        ofPopMatrix();
        camera.end();
        
    }
    
    else{
        splash.draw(0, 0, ofGetWidth(), ofGetHeight());
    }
}

//--------------------------------------------------------------
void ofApp::exit(){
    if(ipad){
        
        for(int i = 0; i < 4; i++){
            snd[i].stop();
        }
    }
}

//--------------------------------------------------------------
void ofApp::touchDown(ofTouchEventArgs & touch){
    
    
}

//--------------------------------------------------------------
void ofApp::touchMoved(ofTouchEventArgs & touch){
    
}

//--------------------------------------------------------------
void ofApp::touchUp(ofTouchEventArgs & touch){
    if(ipad){
    
    if(start){
        
        //creating a mask
        if(currentPos == 1){//(m.x <= 110 && m.x >= 85 && m.y <= -40 && m.y >= -60 && m.z <= -65 && m.z >= -85){//portrait 96 -49 -75
            for(int i = 0; i < 4; i++){
                if(i !=0){
                    if(snd[i].isPlaying()) {
                        snd[i].stop();
                        snd[i].setPositionMS(0);
                    }
                }
            }
            if(snd[0].isPlaying()) snd[0].stop();
            else snd[0].play();
            cout << "portrait creating a mask"<<endl;
        }
        
        //how we met::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
        else if(currentPos == 2){//(m.x <= 80 && m.x >= 63 && m.y <= -36 && m.y >= -56 && m.z <= -70 && m.z >= -88){//portrait 73 -46 -68
            for(int i = 0; i < 4; i++){
                if(i !=1){
                    if(snd[i].isPlaying()) {
                        snd[i].stop();
                        snd[i].setPositionMS(0);
                    }
                }
            }
            if(snd[1].isPlaying()) snd[1].stop();
            else snd[1].play();
            cout << "portrait how we met"<<endl;
            
        }
        
        
        //strong relationship:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
        
        else if(currentPos==3){//(m.x <= 90 && m.x >= 68 && m.y <= -40 && m.y >= -60 && m.z <= -41 && m.z >= -61){//portrait 78.041 -51.679 -51.502
            for(int i = 0; i < 4; i++){
                if(i !=2){
                    if(snd[i].isPlaying()) {
                        snd[i].stop();
                        snd[i].setPositionMS(0);
                    }
                }
            }
            if(snd[2].isPlaying()) snd[2].stop();
            else snd[2].play();
            cout << "portrait strong relationship"<<endl;
        }
        //devotion::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
        else if(currentPos==4){//(m.x <= 110 && m.x >= 80 && m.y <= -20 && m.y >= -50 && m.z <= -85 && m.z >= -100){//portrait 96.622 -38.098 -90.343 //90.429 -35.452 -90.856
            for(int i = 0; i < 4; i++){
                if(i !=3){
                    if(snd[i].isPlaying()) {
                        snd[i].stop();
                        snd[i].setPositionMS(0);
                    }                }
            }
            if(snd[3].isPlaying()) snd[3].stop();
            else snd[3].play();
            cout << "portrait devotion "<<endl;
        }
        
        
        
        //everywhere else::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
        else {
            for(int i = 0; i < 4; i++){
                if(snd[i].isPlaying()) snd[i].stop();
            }
        }
    }
    }
    else{//if not ipad touch anywhere to hear the interview
        if(start){
            if(snd_iPhone.isPlaying())snd_iPhone.stop();
            else snd_iPhone.play();
        }
    }
    
    //////////////////start screen////////////////////////////
    if(!start) {
        if(touch.y > ofGetHeight()*0.75){
            string url = "http://cameraarts.ch";
                                                       
                                                       [[UIApplication sharedApplication] openURL:[NSURL URLWithString: [[[[NSString alloc] initWithCString: url.c_str()]stringByAddingPercentEscapesUsingEncoding: NSASCIIStringEncoding] autorelease]   ]];
            
        }
        else{
        if(img.isReadyToDraw() && imgBg.isReadyToDraw()){
            ofEnableDepthTest();
            ofEnableNormalizedTexCoords();
            start = true;
        }
        }
    }
    
    
}

//--------------------------------------------------------------
void ofApp::touchDoubleTap(ofTouchEventArgs & touch){
//cout << "quat.x, quat.y = " << quat.x() << "' " << quat.y() << endl;
}

//--------------------------------------------------------------
void ofApp::touchCancelled(ofTouchEventArgs & touch){
    
}

//--------------------------------------------------------------
void ofApp::lostFocus(){
    for(int i = 0; i < 4; i++){
        snd[i].stop();
    }
    ofDisableDepthTest();
    ofDisableNormalizedTexCoords();
    start = false;
    
    
    
}

//--------------------------------------------------------------
void ofApp::gotFocus(){
    
}

//--------------------------------------------------------------
void ofApp::gotMemoryWarning(){
    
}

//--------------------------------------------------------------
void ofApp::deviceOrientationChanged(int newOrientation){
    //printf("orientation changed to %i\n", newOrientation);
    orientation = newOrientation;
}
void ofApp::checkPos(){
    
    
    //ofVec3f m = coreMotion.getMagnetometerData();
    if (ofxiOSGetDeviceType()== OFXIOS_DEVICE_IPHONE) {
    }
    else if (ofxiOSGetDeviceType()== OFXIOS_DEVICE_IPAD){
        //Masken bauen create a mask
        //  if(m.x <= 95 && m.x >= 74 && m.y <= -45 && m.y >= -60 && m.z <= -60 && m.z >= -87){//portrait 96 -49 -75//82.465 -53.619 -85.552 //85.297 -56.794 -79.050//103.701 -53.972 -75.970
        
        if(quat.x() > -0.50 && quat.x() < -0.27 && quat.y() > 0.3 && quat.y() < 0.6){
            currentPos = 1;
        }
        else if(quat.x() > 0.3 && quat.x() < 0.5 && quat.y() > -0.6 && quat.y() < -0.3){//0.3999-0.53211
            currentPos = 1;
        }
        //Wie alles begann how we met
        //else if(m.x <= 71 && m.x >= 55 && m.y <= -36 && m.y >= -65 && m.z <= -60 && m.z >= -88){//portrait 73 -46 -68 //62 -56 -71 //69.547 -60.498 -62.795 //71.847 -57.146 -75.628
        else if(quat.x() > -0.24 && quat.x() < 0.20){
            currentPos = 2;
        }
        //Partnerschaft strong relationship
        //else if(m.x <= 90 && m.x >= 65 && m.y <= -40 && m.y >= -70 && m.z <= -35 && m.z >= -61){//portrait 78.041 -51.679 -51.502 //81.226 -60.850 -50.476 //68.839 -60.145 -53.898//69.016 -52.913 -50.305
        else if(quat.x() > 0.30 && quat.x() < 0.54 && quat.y() > 0. && quat.y() < 0.5){
            
            currentPos = 3;
        }
        else if (quat.x() > -0.6 && quat.x() < -0.4 && quat.y() > -0.5 && quat.y() < -0.3){//-0.50017' -0.438133 quat.x, quat.y = -0.492288' -0.445228
            currentPos = 3;
        }
        //Berufung devotion
        //else if (m.x <= 110 && m.x >= 95 && m.y <= -20 && m.y >= -55 && m.z <= -75 && m.z >= -100){//portrait 96.622 -38.098 -90.343//104.586 -46.740 -86.065 //105.824 -52.913 -77.681 //
        else if(quat.x() > 0.3 && quat.x() < 0.6 && quat.y() >= -0.3 && quat.y() <= 0){
            currentPos = 4;
        }
        else if(quat.x() > -0.6 && quat.x() < -0.3 && quat.y() >= 0.1 && quat.y() <= 0.3){//quat.x, quat.y = -0.508707' 0.197238
            currentPos =4;
        }
        else{
            currentPos = 0;
        }
    }
}
