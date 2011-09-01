import jmcvideo.*;
import processing.opengl.*;

import javax.media.opengl.*;

import netP5.NetAddress;
import oscP5.OscMessage;
import oscP5.OscP5;

JMCMovieGL myVideo1, myVideo2;

getVideos contentTable;

OscP5 oscP5;
NetAddress myRemoteLocation;

GL gl;

int pvw, pvh;
String[] vids;
int vidNum1 = 0;
int vidNum2 = 0;

int test;
int user = 1;
int test2;
int user2;

int rowCount;

void setup() {

  /*
		 * try { quicktime.QTSession.open(); } catch (quicktime.QTException qte)
   		 * { qte.printStackTrace(); }
   		 */

  size(800, 400, OPENGL);
  frameRate(30);

  contentTable = new getVideos("videos.csv");
  rowCount = contentTable.getRowCount();

  vids = new String[rowCount];

  for (int i = 0; i < rowCount; i++) {
    vids[i] = contentTable.getString(i, 0);
  }

  println(vids.length + " Videos Loaded. Starting application.");

  myVideo1 = movieFromDataPath(vids[vidNum1]);
  myVideo2 = movieFromDataPath(vids[vidNum2]);

  myVideo1.loop();
  myVideo2.loop();

  //  myVideo1.setMute(true); //Doesn't work, here at least
  //  myVideo2.setMute(true);

  oscP5 = new OscP5(this, 12000);
  myRemoteLocation = new NetAddress("127.0.0.1", 12000);
}

void draw() {
  background(0);

  PGraphicsOpenGL pgl = (PGraphicsOpenGL) g;

  gl = pgl.beginGL();

  {
    // Include if(stmt) to manage the width of video.
    // How to avoid stretching?

    // myVideo1.frameImage(gl, 40);
    if (user == 2) {
      myVideo1.image(gl, -width / 2 - 5, 0, width, height);
      myVideo2.image(gl, width / 2 + 5, 0, width, height);
    } 
    else {
      myVideo1.image(gl, 0, 0, width, height); //This should be a dynamic function
    }
  }
  pgl.endGL();
}

//OSC for testing
void keyPressed() {

  if (key == CODED) {

    if (keyCode == UP) {
      OscMessage myMessage = new OscMessage("/VIDEO");
      test++;
      user = 1; // Need to set dynamically

      myMessage.add(test);
      myMessage.add(user);

      if (test == rowCount) {
        test = 0;
      }

      oscP5.send(myMessage, myRemoteLocation);
    }
    if (keyCode == DOWN) {
      OscMessage myMessage = new OscMessage("/VIDEO");
      test++;
      test2++;
      user = 2; //not good
      user2 = 2;

      myMessage.add(test);
      myMessage.add(user);
      myMessage.add(test2);
      myMessage.add(user2);

      if (test == rowCount) {
        test = 0;
      }
      if (test2 == rowCount) {
        test2 = 0;
      }

      oscP5.send(myMessage, myRemoteLocation);
    }
    if (keyCode == LEFT) {
      OscMessage myMessage = new OscMessage("/KEYFRAME");
      //Set int to 0 or 1, then why not set to BOOLEAN?
    }
  }
}

//setBounds(float x, float y, float w, float h) or frameVideo(float frameWidth, float frameHeight, float inset)

//eliminate tearing
void enableVSync() {
  PGraphicsOpenGL pgl = (PGraphicsOpenGL) g;
  GL gl = pgl.beginGL();
  gl.setSwapInterval(1);
  pgl.endGL();
}


//OSC RECEIVE

/* int int (ii) User (eg. User 1), Video (eg. Video 4)
 
 int int int int (iiii) User (eg. User 1), Video (eg. Video 4), User (eg. User 2), Video (eg. Video 7) */

void oscEvent(OscMessage theOscMessage) {

  println(theOscMessage.typetag());

  if (theOscMessage.checkAddrPattern("/KEYFRAME") == true) { //Controls video playhead
    int playHead = theOscMessage.get(0).intValue();

    println(myVideo1.getCurrentTime());
    myVideo1.setCurrentTime(0); //This can be set dynamically to choose the location of the playhead
  }

  if (theOscMessage.checkAddrPattern("/VIDEO") == true) {

    if (theOscMessage.checkTypetag("ii")) { //Single user if stmt
      int videoNum1 = theOscMessage.get(0).intValue();
      int userNum1 = theOscMessage.get(1).intValue(); // changes global

      // user variable
      println("Video: " + videoNum1 + "  User: " + userNum1);

      //Video switcher
      myVideo1.switchVideo(vids[videoNum1]);

      //      loopVideo();

      myVideo1.loop();

      println(user);

      return;
    }

    if (theOscMessage.checkTypetag("iiii")) {

      int videoNum1 = theOscMessage.get(0).intValue();
      int userNum1 = theOscMessage.get(1).intValue(); // changes global

      int videoNum2 = theOscMessage.get(2).intValue(); //This is reversed from what we discussed. I will fix this.
      int userNum2 = theOscMessage.get(3).intValue(); // changes global

      // user variable
      println("Video: " + videoNum1 + "  User: " + userNum1);
      println("Video: " + videoNum2 + "  User: " + userNum2);

      myVideo1.switchVideo(vids[videoNum1]);
      myVideo2.switchVideo(vids[videoNum2]);

      myVideo1.loop();
      myVideo2.loop();
      println(user);
      return;
    }
  }
}


//Function not needed
//void loopVideo() {
//  println("CALLED");
//}

JMCMovieGL movieFromDataPath(String filename) {
  return new JMCMovieGL(this, filename, RGB);
}

