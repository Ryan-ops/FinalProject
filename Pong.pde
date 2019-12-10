

import processing.serial.*;
import ddf.minim.*;//To play sound files.

Serial myPort;
int[] position;
int lunch_pad = 100;
int larg_pad = 15;
int dim_ball = 20;
float p1pos,p2pos;
float x,y,vx,vy;
float int_x,int_y;
int bounce;
boolean start = false;
boolean int_start = true;
int points1,points2;
boolean win = false;
boolean title = true;
boolean pause = false;

Minim minim;
AudioPlayer sound_ping;
AudioPlayer sound_pong;

void setup(){
  size(800,600);
  int_x = width/2;
  int_y = height/2;
  noCursor();
  //printArray(Serial.list());
  myPort = new Serial(this, Serial.list()[2], 9600);
  myPort.bufferUntil('\n');
  textFont(loadFont("H-B.vlw"),80);
  textAlign(CENTER);
  //Sound
  minim=new Minim(this);
  sound_ping=minim.loadFile("ping.mp3");
  sound_pong=minim.loadFile("pong.mp3");
}

void draw(){
 if(!pause){ 
  if(win){
    score();
    if(points1>points2){
      textAlign(CENTER,CENTER);
      textSize(130);
      text("WIN",width*0.25,height/2);
      text("LOSE",width*0.75,height/2);
      textSize(100);
    }
    else{
      textAlign(CENTER,CENTER);
      textSize(130);
      text("LOSE",width*0.25,height/2);
      text("WIN",width*0.75,height/2);
      textSize(100);
    }
  }
  
  if(title){
    background(0);
    title_screen();
    fill(255);
  }
  
  if(start){
    textSize(100);
    background(0,247,62);
    field();
    fill(255);
    score();
    if(int_start){
      x = int_x;
      y = int_y;
      vx = random(2,3)*rnd_sign();
      vy = random(2,3)*rnd_sign();
      bounce = 0;
      int_start = !int_start;
    }
    // place 
    place_pad();
    // ball
    ball();
    }
 }
}

void serialEvent (Serial myPort) {
  // reads the string data
  String string = myPort.readStringUntil('\n');
 
  if (string != null) {
    //removes the empty spaces 
    string = trim(string);
    // Save position
    position = get_position(string);
    //printArray(position);
  }
}

float rnd_sign(){
  float n = random(-1,1);
  if(n>=0){
    return 1.0;
  }
  else{
    return -1.0;
  }
}

void field(){
  stroke(255);
  strokeWeight(2);
  fill(0,247,62);
  rectMode(CORNER);
  rect(0,0,width,10);
  rect(0,height-10,width,10);
  strokeWeight(2);
 
  int segments=25;
  for(int i=0;i<segments;i++){
    if(i%2==0){
      line(width/2,i*(height/segments),width/2,i*(height/segments)+(height/segments));
    }
  }
  noFill();
  ellipse(width/2,height/2,150,150);
}

void title_screen(){
  stroke(255);
  strokeWeight(2);
  fill(0,247,62);
  rectMode(CORNER);
  rect(0,0,width,10);
  rect(0,height-10,width,10);
  strokeWeight(2);
  // Title
  textAlign(CENTER,CENTER);
  textSize(100);
  text("Let's play \nPING PONG",width/2,height*0.35);
  textSize(50);
  text("S : START      P : PAUSE",width/2,height*0.8);
}

int[] get_position(String data){
  return int(split(data,'-'));
}

void place_pad(){
  p1pos = map(position[0],0,1023,10+lunch_pad/2,height-(10+lunch_pad/2));
  p2pos = map(position[1],0,1023,10+lunch_pad/2,height-(10+lunch_pad/2));
  rectMode(CENTER);
  rect(20+larg_pad/2,p1pos,larg_pad,lunch_pad,5);
  rect(width-(20+larg_pad/2),p2pos,larg_pad,lunch_pad,5);
}

void ball(){
  fill(255);
  stroke(255);
  ellipse(x,y,dim_ball,dim_ball);
  x=x+vx;
  y=y+vy;
  
  //Vertical collision
  if(y<10+dim_ball/2 || y>height-(10+dim_ball/2)){
    vy=-vy;
    //play pong sound
    sound_ping.pause();
    sound_ping.rewind();
    sound_pong.pause();
    sound_pong.rewind();
    sound_pong.play();
  }
  //Collision with pads
  if((vx<0 && x<20+larg_pad+dim_ball/2 && x>20+larg_pad/2 && y>=p1pos-lunch_pad/2 && y<=p1pos+lunch_pad/2) || (vx>0 && x>width-(20+larg_pad+dim_ball/2) && x<width-(20+larg_pad/2) && y>=p2pos-lunch_pad/2 && y<=p2pos+lunch_pad/2)){
    if(bounce<20){
      vx = -1.1*vx;
      bounce++;
    }
    else{
      vx = -vx;
    }
    //play ping sound
    sound_pong.pause();
    sound_pong.rewind();
    sound_ping.pause();
    sound_ping.rewind();
    sound_ping.play();
  }
  //Points keeper
  if(x<0){
    points2++;
    int_start = true;
  }
  if(x>width){
    points1++;
    int_start = true;
  }
}

void score(){
  text(points1,(width/2)*0.85,height/6);
  text(points2,(width/2)*1.15,height/6);
  // Award the winner
  if(points1 == 5){
    win = true;
    start = false;
  }
  if(points2 == 5){
    win = true;
    start = false;
  }
}

void keyPressed(){
  if(key == 's' && !pause){
    start = !start;
    int_start = true;
    points1 = 0;
    points2 = 0;
    title = !title;  
  }
  if(win){
    win = false;
    start = false;
    title = true;
  }
  if(key == 'p' && start){
    pause = !pause;
  }
}
