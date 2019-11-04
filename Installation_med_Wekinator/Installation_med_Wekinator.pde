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


float SongNumber  = 1;
float CurrentSong = SongNumber;

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
  
  //Begynder at lytte til port 12000 og gør klar til at sende til port 6448.
  oscP5 = new OscP5(this,12000);
  dest = new NetAddress("127.0.0.1",6448);
  
  //Sætter størrelsen på sketcen.
  surface.setSize(640, 480);
  
  //Loader alle sangende der kan blive spillet.
  sound = new SoundFile(this, "Hotel-California-Solo-The-Eagles-Acoustic-Guitar-Cover.mp3");
  sound = new SoundFile(this, "Ludovico Einaudi - Ancora.mp3");
  sound = new SoundFile(this, "nothing's gonna change my love for you trumpet solo.mp3");
  println("Songs have been loaded.");
}

void draw() {
  //----------------------------Kode fra Kadenze--------------------------\\
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
  //----------------------------------------------------------------------------\\
  
  /*PImage img = video.get();
  img.resize(-640, 480);
  image(img, 0,0);
  */
  //Opretter en tekstboks til information for brugeren.
  fill(0);
  rect(0,450,640,50);
  fill(255);
  textAlign(CENTER);
  text("Vis et instrument og hør musik!",640/2,470);
  
  //Sikre at den ikke konstant vil sætte den samme sang på igen og igen, men i stedet kun vil starte en sang, hvis en ny skal sættes på.
  if(SongNumber  != CurrentSong){
    SelectAndPlaySong(SongNumber);
    CurrentSong = SongNumber;
  }
}

//Opretter en funktion, som skal skiftet til et andet instrument og derved en anden sang.
void SelectAndPlaySong(float i){
  //Hvis en sang er i gang med blive spillet, vil den blive stoppet.
  if(sound.isPlaying()){
    //Stopper sangen.
    sound.stop();
  }
  
  //Hvis funktionen får forskellige input, vil forskellige sange blive spillet.
   if(i == 1){
      //Ingen sang vil blive spillet.
   } else if(i == 2){
     //Guitar.
     //En guitar solo vil blive spillet.
     sound = new SoundFile(this, "Hotel-California-Solo-The-Eagles-Acoustic-Guitar-Cover.mp3");
     sound.amp(0.1);
     println("Playing soundfile: 'Hotel-California-Solo-The-Eagles-Acoustic-Guitar-Cover'");
     sound.loop();
   } else if(i == 3){
     //Piano.
     //En klaver solo vil blive spillet.
     sound = new SoundFile(this, "Ludovico Einaudi - Ancora.mp3");
     sound.amp(0.3);
     println("Playing soundfile: 'Ludovico Einaudi - Ancora'");
     sound.loop();
   } else if(i == 4){
     //Trumpet.
     //En trumpet solo vil blive spillet.
     sound = new SoundFile(this, "nothing's gonna change my love for you trumpet solo.mp3");
     sound.amp(0.3);
     println("Playing soundfile: 'Nothing's gonna change my love for you trumpet solo'");
     sound.loop();
   }
}

//Sender input til Wekinator via osc.
void sendOsc(int[] px) {
  OscMessage msg = new OscMessage("/wek/inputs");
   for (int i = 0; i < px.length; i++) {
     //Gemmer alle værdierne, som skal sendes til Wekinator.
     msg.add(float(px[i])); 
   }
  //Sender input til Wekinator.
  oscP5.send(msg, dest);
}

//Modtager Wekinators output.
void oscEvent(OscMessage theOscMessage){
  //Tjekker om det kommer fra Wekinator.
  if(theOscMessage.checkAddrPattern("/wek/outputs")){
    //Får hvilken sang der skal spilles fra Wekinator.
    SongNumber = theOscMessage.get(0).floatValue();
}
}