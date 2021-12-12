import processing.sound.*;
int numSounds = 8; 
SoundFile [] sounds;
int explosionParticles = 100;
int numStar = 1000;
int numBullets = 4;
int numPlanes = 20;
int level = 0;
int highscore = 100;
int gomillis;
int lvlmillis;
boolean introMode = true;
boolean GameOverMode = false;
boolean levelMode = false;
float planeWidth = 100;
float planeHeight = 40;
float bulletWidth = 20;
float bulletHeight = 20;
//Declaring variables(Traver)
float[] planeXSpeed = new float[numPlanes];
float[] planeX = new float[numPlanes];
float[] planeY = new float[numPlanes];
float[] planeTurnPoint = new float[numPlanes];
boolean[] planeAlive = new boolean[numPlanes];

int score = 0;
//Declaring variables(Teague)
PFont pixelFont;
PImage cannonImg;
PImage baseImg;
PImage shipImgRight;
PImage shipImgLeft;
boolean keyRight = false;
boolean keyLeft = false;
float death;
float gunbaseX;
float gunbaseY;
float guntipX;  
float guntipY;
float gunAng;
float gunLength;
float angNum = 0.05;
float bSpeed = 10;
float baseOffset;
float x;
float y;   
float[] expX = new float[numPlanes];
float[] expY = new float[numPlanes];
int[] expMillis = new int[numPlanes];
boolean[] explosionAlive = new boolean[numPlanes];
boolean[] bulletAlive = new boolean[numBullets];
float[] bX = new float[numBullets];
float[] bY = new float[numBullets];
float[] bDX = new float[numBullets];
float[] bDY = new float[numBullets];
float[] starX = new float[numStar];
float[] starY = new float[numStar];
float[] speed = new float[numStar];
PImage[] expImg = new PImage[6];




void setup(){
  //setting up turret(Teague)
  size(800,800,P2D);
  sounds = new SoundFile[numSounds];
  cannonImg = loadImage("rtype.png");
  baseImg = loadImage("base.png");
  shipImgRight = loadImage("rtypeShipRight.png");
  shipImgLeft = loadImage("rtypeShipLeft.png");
  expImg[0] = loadImage("exp1.png");
  expImg[1] = loadImage("exp2.png");
  expImg[2] = loadImage("exp3.png");
  expImg[3] = loadImage("exp4.png");
  expImg[4] = loadImage("exp5.png");
  expImg[5] = loadImage("exp6.png");
  sounds[0] = new SoundFile(this, "boom1.wav");
  sounds[1] = new SoundFile(this, "boom2.wav");
  sounds[2] = new SoundFile(this, "boom3.wav");
  sounds[3] = new SoundFile(this, "boom4.wav");
  sounds[4] = new SoundFile(this, "Touch.wav");
  sounds[5] = new SoundFile(this, "VictoryBigX.wav");
  sounds[6] = new SoundFile(this, "VictorySmallX.wav");
  sounds[7] = new SoundFile(this, "Wind.wav");
  pixelFont = createFont("pixelfont2.ttf",50);
  textFont(pixelFont);
  gunLength = cannonImg.height;
  gunbaseX = 400;
  gunbaseY = 778;
  guntipX = 400;
  guntipY = 600;
  baseOffset = 10;
  for(int i = 0; i<numStar;i++){
    starX[i] = random(0, width);
    starY[i] = random(0, height);
    speed[i] = random(1, 5);
  }
  //initGame();
}

boolean firePressed = false;

void keyPressed(){
  if(keyCode==RIGHT) keyRight = true;
  if(keyCode==LEFT) keyLeft = true;
  if(keyCode==CONTROL){
   firePressed = true;
   // if(bX=originX&&bY=originY);
    }
   }

void keyReleased(){
  if(keyCode==RIGHT) keyRight = false;
  if(keyCode==LEFT) keyLeft = false;
}


void initGame(){
  for(int i = 0; i<numPlanes; i++){
    planeAlive[i] = false;
  } 
  score = 0;
  level = 0;
  spawnPlane();
  sounds[5].play(1, 1.0);
  for(int j = 0; j<numBullets; j++){
    bulletAlive[j] = false;
  } 
}

void update(){
  updateBullets();

  if (!levelMode){
    if (firePressed) spawnBullet();
    int planeCount = updatePlane();
    if (planeCount == -1) { 
      GameOverMode = true;
      gomillis = millis();
    }
    if (planeCount == 0) {
      level += 1;
      sounds[6].play(1, 1.0);
      spawnPlane();
    }
    planeCollision();
  }
}
void draw(){ 
  //planes and bullets and explosion(teague)
  if(introMode) introDraw();
  else if(GameOverMode) GameOverDraw();
  else {
    background(0);
    update();
    moveGun();
    starField(starX,starY,speed);
    explosionDraw();
    if (!levelMode) drawPlane();
    else {
      fill(r % 255,g % 255,b % 255);
      r+=5; g+=3; b+=7;
      textAlign(CORNER,CENTER);
      text("ENTERING LEVEL",width/2-270,height/2);
      text(level,width/2+240,height/2);
      textAlign(CORNER,CORNER);
      if(millis()>lvlmillis+1000) levelMode = false;
    }
    drawBullets();
    drawScore();
    drawGun();
  }
}   

void drawGun(){
  imageMode(CORNER);
  drawBaseRotatedSprite(gunbaseX,gunbaseY,gunAng,cannonImg);
  image(baseImg,gunbaseX-baseImg.width/2,gunbaseY-baseImg.height/2+baseOffset);
}

void moveGun(){
  if(keyRight && gunAng<HALF_PI){
    gunAng+=angNum;
  }
  if(keyLeft && gunAng>-HALF_PI){
    gunAng-=angNum;
  }
}

void spawnBullet(){
  firePressed = false;
  sounds[4].play(1, 1.0);
  float x = gunbaseX+sin(gunAng)*gunLength;
  float y = gunbaseY-cos(gunAng)*gunLength;
  for(int i = 0; i<numBullets; i++){
    if(bulletAlive[i]==false){
      bDX[i]=sin(gunAng)*bSpeed;
      bDY[i]=cos(gunAng)*bSpeed;
      bX[i] = x;
      bY[i] = y;
      bulletAlive[i] = true;
      break;
    }
  }
}

void drawBullets(){
  for(int i = 0; i<numBullets; i++){
    if(bulletAlive[i]==true){
      fill(255);
      ellipse(bX[i],bY[i],bulletWidth,bulletHeight);
    }
  }
}

void updateBullets(){
  for(int i = 0; i<numBullets; i++){
    if(bulletAlive[i]==true){
      bX[i] += bDX[i];
      bY[i] -= bDY[i];
      //bounds check
      if(bY[i]>800 || bY[i]<0 || bX[i]>800 || bX[i]<0) bulletAlive[i]=false;
    }
  }
}

  
void drawBaseRotatedSprite(float x, float y, float angle, PImage img){
  noStroke();
  beginShape();
  texture(img);
  float imgW = img.width;
  float imgH = img.height;
  float imgW2 = imgW / 2;
  float imgH2 = imgH / 2;
  float sinImgW2 = sin(angle)*imgW2;
  float cosImgW2 = cos(angle)*imgW2;
  float sinImgH = sin(angle)*imgH;
  float cosImgH = cos(angle)*imgH;
  
  
  vertex(x-cosImgW2+sinImgH, y-cosImgH-sinImgW2, 0, 0);
  vertex(x+cosImgW2+sinImgH, y-cosImgH+sinImgW2, imgW, 0);
  vertex(x+cosImgW2-sinImgW2, y+cosImgW2+sinImgW2, imgW, imgH);
  vertex(x-cosImgW2-sinImgW2, y+cosImgW2-sinImgW2, 0, imgH);
  endShape();  
}

void starField(float x[], float y[], float speed[]){
  noStroke();
    for(int i = 0; i<100; i++){
      rect(x[i], y[i],6,6);
    
      x[i] = x[i] - speed[i];
      if(x[i] < 0) {
        x[i] = width;
    }
  }
}

void spawnPlane(){
  levelMode = true;
  lvlmillis = millis();
//Initializing variables to make planes and make the planes move (Traver)
  int numnewplanes = level + 5;
  if (numnewplanes>numPlanes) numnewplanes=numPlanes;
  for(int i=0;i<numnewplanes;i++){
    //Filling the variables of the plane randomly(Traver)
    float speed=random(0,2+level*3)+6;
    planeXSpeed[i]=speed+int(random(-2,0))*2*(speed);
    planeX[i]=int(random(1,width));
    planeY[i]=random(-planeHeight*5,height/3);
    planeAlive[i] = true;
    planeTurnPoint[i] = width/4 + random(0,width/4);
   } 
}

int updatePlane() { //snakes on a plane
  //Plane (Traver)
  int planesAliveCount =0;
  for(int i=0;i<planeXSpeed.length;i++){
     if(planeAlive[i]){
        planesAliveCount = 1;
        planeX[i]+=planeXSpeed[i];
        planeTurnPoint[i]-=abs(planeXSpeed[i]);
        if(planeTurnPoint[i]<0){
          planeY[i]+=planeHeight/2;
          planeXSpeed[i]*=-1;
          planeTurnPoint[i] = random(width/2,width);
        }  
        if(planeY[i]>(gunbaseY-cos(gunAng)*gunLength) && abs(gunbaseX - planeX[i])<40){
          for(int j =0; j<6; j++){
            explosionSpawn(random(gunbaseX-40,gunbaseX+40),random(gunbaseY-cos(gunAng)*gunLength, gunbaseY));
          }
          planesAliveCount = -1;
           break;
        }
        if(planeY[i]>(height)) planeY[i]-=height;
        if(planeX[i]>(width+planeWidth)) {
          planeXSpeed[i] = -abs(planeXSpeed[i]);
          planeY[i]+=planeHeight*2;
        }
        if(planeX[i]< (-planeWidth)) {
          planeXSpeed[i] = abs(planeXSpeed[i]);
          planeY[i]+=planeHeight*2;
        }  
     }
  }
  return(planesAliveCount);
}

void drawPlane() {
  //Plane (Traver)
  fill(6, 138, 61);
  imageMode(CENTER);
  for(int i=0;i<planeXSpeed.length;i++){
     if(planeAlive[i]){
         if (planeXSpeed[i] < 0) 
           image(shipImgLeft,planeX[i],planeY[i],planeWidth,planeHeight);
         else
           image(shipImgRight,planeX[i],planeY[i],planeWidth,planeHeight);
        }
     }
imageMode(CORNER);     
}

void planeCollision(){
for (int o = 0; o<numPlanes; o++) {
  if (planeAlive[o]) {
    for (int i = 0; i<numBullets; i++){
      if (bulletAlive[i]) {
        if ((abs(planeX[o] - bX[i]) < (planeWidth/2 + bulletWidth/2)) && (abs(planeY[o] - bY[i]) < (planeHeight/2 + bulletHeight/2))){
          planeAlive[o] = false;
          bulletAlive[i] = false;
          explosionSpawn(planeX[o],planeY[o]);
          score += level+1;
        }
      }
    }
  }
}
}

void drawScore(){
  if(score>highscore)
    highscore=score;
  textAlign(CORNER, CORNER);
  fill(255,0,0);
  textSize(45);
  text("1UP",width - width/5, 31);
  text("HI",width / 2 - 100,31);
  fill(255);
  text(highscore,width /2 - 100,72); 
  text(score,width - width/5,72); 
  
}

int r,g,b;

void introInit(){
  gunAng=0;  
  r=int(random(255));
  g=int(random(255));
  b=int(random(255));
  
}

void introUpdate(){
  r+=1;
  g+=3;
  b+=2;
  updateBullets();
  if (firePressed) {
    introMode = false;
    initGame();
  }
}

void introDraw(){
  introUpdate();
  background(0);
  starField(starX,starY,speed);
  textAlign(CENTER,CENTER);
  fill(255,0,0);
  //textSize(50);
  text("PRESS FIRE <ctrl>",width/2,height/2);
  fill(r % 255, g % 255, b % 255);
  text("DON'T LOOK UP!",width/2,height/3);
  drawScore();

}
 
int gotextsize;

void GameOverUpdate(){
  gotextsize = (millis() - gomillis)/20 + 1;
  if(gotextsize >= 200){
    GameOverMode = false;
    firePressed = false;
    introMode = true;
    textSize(50);
  }
}

void GameOverDraw(){ 
  background(0);
  
  GameOverUpdate();
  starField(starX,starY,speed);
  drawPlane();
  drawBullets();
  drawScore();
  image(baseImg,gunbaseX-baseImg.width/2,gunbaseY-baseImg.height/2+baseOffset);
  explosionDraw();
  fill(255,0,0);
  textAlign(CENTER,CENTER);
  textSize(gotextsize);
  text("GAME OVER!",width/2,height/2);
  fill(255,255,255);
}   

void explosionSpawn(float x,float y){
  sounds[int(random(0,4))].play(1, 1.0);
  for(int i = 0; i<numPlanes; i++){
    if(!explosionAlive[i]){
      explosionAlive[i] = true;
      expMillis[i] = millis();
      expX[i] = x;
      expY[i] = y;
      break;
    }
  }
}

void explosionDraw(){
  for(int i = 0; i<numPlanes; i++){
    if(explosionAlive[i]){
      int frame = (millis()-expMillis[i])/100;
      imageMode(CENTER);
      if(frame<6) {
        image(expImg[frame],expX[i],expY[i],expImg[frame].width*4,expImg[frame].height*4);
      }  
      else
        explosionAlive[i] = false;
    }
  } 
}  
