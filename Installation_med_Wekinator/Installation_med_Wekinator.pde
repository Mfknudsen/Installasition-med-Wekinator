import processing.video.*;
import processing.sound.*;
import oscP5.*;
import netP5.*;

int numPixelsOrig;
int numPixels;
boolean first = true;

int boxWidth = 64/2;
int boxHeight = 48/2;

int numHoriz = 640/boxWidth;
int numVert = 480/boxHeight;

color[] downPix = new color[numHoriz * numVert];


Capture video;
SoundFile sound;

OscP5 oscP5;
NetAddress dest;


float a = 0;
float b = a;

void setup() {
  String[] cameras = Capture.list();

  if (cameras == null) {
    println("Failed to retrieve the list of available cameras, will try the default...");
    video = new Capture(this, 640, 480);
  } if (cameras.length == 0) {
    println("There are no cameras available for capture.");
    exit();
  } else {

   video = new Capture(this, 640, 480);
    
    // Start capturing the images from the camera
    video.start();
    
    numPixelsOrig = video.width * video.height;
    loadPixels();
    noStroke();
  }
  
  /* start oscP5, listening for incoming messages at port 12000 */
  oscP5 = new OscP5(this,12000);
  dest = new NetAddress("127.0.0.1",6448);
  
  surface.setSize(640, 480);
  
  sound = new SoundFile(this, "Hotel-California-Solo-The-Eagles-Acoustic-Guitar-Cover.mp3");
  sound = new SoundFile(this, "");
}

void draw() {
  
  if (video.available() == true) {
    video.read();
    
    video.loadPixels(); // Make the pixels of video available

  int boxNum = 0;
  int tot = boxWidth*boxHeight;
  for (int x = 0; x < 640; x += boxWidth) {
     for (int y = 0; y < 480; y += boxHeight) {
        float red = 0, green = 0, blue = 0;
        
        for (int i = 0; i < boxWidth; i++) {
           for (int j = 0; j < boxHeight; j++) {
              int index = (x + i) + (y + j) * 640;
              red += red(video.pixels[index]);
              green += green(video.pixels[index]);
              blue += blue(video.pixels[index]);
           } 
        }
       downPix[boxNum] =  color(red/tot, green/tot, blue/tot);
       fill(downPix[boxNum]);
       
       int index = x + 640*y;
       red += red(video.pixels[index]);
       green += green(video.pixels[index]);
       blue += blue(video.pixels[index]);
       rect(x, y, boxWidth, boxHeight);
       boxNum++;

     } 
  }
  if(frameCount % 2 == 0)
    sendOsc(downPix);
  }
  surface.setSize(640, 480);

  PImage img = video.get();
  img.resize(640, 480);
  image(img, 0,0);
  
  if(a != b){
    SelectAndPlaySong(a);
    b = a;
  }
}

void SelectAndPlaySong(float i){
  if(sound.isPlaying()){
   sound.stop();
  }
   if(i == 1){
      //No file or sound is played.
   } else if(i == 2){
     //Guitar.
     sound = new SoundFile(this, "Hotel-California-Solo-The-Eagles-Acoustic-Guitar-Cover.mp3");
     sound.amp(0.1);
     println("Playing soundfile: 'Hotel-California-Solo-The-Eagles-Acoustic-Guitar-Cover.mp3'");
     sound.loop();
   } else if(i == 3){
     //Trummer.
     sound = new SoundFile(this, "");
     sound.amp(0.1);
     println("Playing soundfile: ''");
     sound.loop();
   } else if(i == 4){
     //Piano.
     sound = new SoundFile(this, "");
     sound.amp(0.1);
     println("Playing soundfile: ''");
     sound.loop();
   } else if(i == 5){
     //Trumpet.
     sound = new SoundFile(this, "");
     sound.amp(0.1);
     println("Playing soundfile: ''");
     sound.loop();
   }
}

void sendOsc(int[] px) {
  OscMessage msg = new OscMessage("/wek/inputs");
 // msg.add(px);
   for (int i = 0; i < px.length; i++) {
      msg.add(float(px[i])); 
   }
  oscP5.send(msg, dest);
}

void oscEvent(OscMessage theOscMessage){
  if(theOscMessage.checkAddrPattern("/wek/outputs")){
    a = theOscMessage.get(0).floatValue();
}
}