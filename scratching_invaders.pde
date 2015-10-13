Stage fg;
Stage bg;
Sprite player;

static int rotationStyle_AllAround=0;
static int rotationStyle_LeftRight=1;
static int rotationStyle_DontRotate=2;
boolean[] keyIsDown = new boolean[256];
boolean[] arrowDown = new boolean[4];
static int upArrow=0;
static int downArrow=1;
static int leftArrow=2;
static int rightArrow=3;

String gamestate = "playing";
int level = 0;
int score = 0;
int lives = 3;
int laserTimeout = 0; 
int enemyMoveTimer = 0;
int playerRespawnTimer = 0;
int UFOTimer = 0;
float enemyMoveSpeed = 50;
float newEnemyDirection = 0;
ArrayList<Sprite> shields = new ArrayList<Sprite>();
ArrayList<Sprite> playerLasers = new ArrayList<Sprite>();
ArrayList<Sprite> enemies = new ArrayList<Sprite>();
ArrayList<Sprite> enemyLasers = new ArrayList<Sprite>();
Sprite ufo;

void setup() {
  size(500, 500);
  bg = new Stage(this);
  fg = new Stage(this);
  
  bg.addBackdrop("images/starfield-bg.png");
  fg.addBackdrop("images/starfield-fg.png");
  bg.setBackdrop(0);
  fg.setBackdrop(0);
  
  player = new Sprite(this);
  player.addCostume("images/laser base.png");
  player.setCostume(0);
  player.size = 80;
  setupFirstLevel();
  
  ufo = new Sprite(this);
  ufo.addCostume("images/ufo.png");
  ufo.size = 20;
  newUFO();
}

void draw() {
  if (gamestate=="playing") gameloop();
  if (gamestate=="gameover") gameoverscreen();
}

void gameoverscreen() {
  if (keyIsDown[' '] && fg.timer() > 1) setupFirstLevel();
  //if (keyIsDown[' ']) gamestate="playing";
  background(0);
  drawLabels();
}
  
void gameloop() {
  background(10);
  
  movePlayerShip();
  movePlayerLasers();
  moveEnemies();
  moveEnemyLasers();
  moveUFO();
  
  drawShields();
  drawLabels();
  
  if (enemies.size()<2) { enemyMoveSpeed = 3; } // last enemy rushes
  if (enemies.size()<1) { setupNextLevel(); } // if all enemies destroyed, spawn more!
}

void moveUFO() {
  if (!ufo.visible) {
    if (UFOTimer > 0) {
      UFOTimer--;
    } else if (UFOTimer == 0) {
      int UFOdir = (int)random(0,2);
      ufo.pos.x = 500*UFOdir;
      ufo.pos.y = 45;
      if (UFOdir == 0) ufo.direction=0; else ufo.direction=180;
      ufo.show();
    } 
  } else {
    ufo.move(2);
    if (ufo.pos.x < 0 || ufo.pos.x > width) newUFO();
    ufo.draw();
  } 
}

void newUFO() {
  ufo.hide();
  UFOTimer = (int)random(500,1500);
}

void keyPressed() {
 if (key<256) {
   keyIsDown[key] = true; 
  }
 if (key==CODED) {
   switch (keyCode) {
     case UP: arrowDown[upArrow]=true; break;
     case DOWN: arrowDown[downArrow]=true; break;
     case LEFT: arrowDown[leftArrow]=true;  break;
     case RIGHT: arrowDown[rightArrow]=true; break;
   }
 }
}

void keyReleased() {
 if (key<256) {
   keyIsDown[key] = false;  
 }
  if (key==CODED) {
   switch (keyCode) {
     case UP: arrowDown[upArrow]=false; break;
     case DOWN: arrowDown[downArrow]=false; break;
     case LEFT: arrowDown[leftArrow]=false;  break;
     case RIGHT: arrowDown[rightArrow]=false; break;
   }
 }
}

void setupFirstLevel() {
  player.show();
  level = 0;
  score = 0;
  gamestate="playing";
  setupPlayer();
  setupNextLevel();
}

void setupPlayer() {
  player.show();
  player.goToXY(width/2,475);
  playerRespawnTimer--;
}

void removeAll(ArrayList list) {
  while (list.size() > 0)
    list.remove(0);
}

void setupNextLevel() {
  level++; 
  // erase old sprites if any
  removeAll(enemies);
  removeAll(enemyLasers);
  removeAll(playerLasers);
  // every 4th level, respawn shields
  if (level % 4 == 1) { removeAll(shields); spawnShields(); }
  spawnEnemies();
}

// **** 
void movePlayerShip() {
  if (playerRespawnTimer > 0) playerRespawnTimer--;
  if (playerRespawnTimer == 0) setupPlayer();
  else {
    if (player.xSpeed>0) player.xSpeed -= 0.25; 
    if (player.xSpeed<0) player.xSpeed += 0.25;
    if (arrowDown[leftArrow])
      if (player.xSpeed >= -8) player.xSpeed -= 0.5;
    if (arrowDown[rightArrow]) 
      if (player.xSpeed <= 8) player.xSpeed += 0.5;
    player.pos.x += player.xSpeed;

    if (keyIsDown[' '] && player.visible) firePlayerLaser();
    player.draw();
    laserTimeout--;
  }
}

void firePlayerLaser() {
  if (laserTimeout>0) { }
  else if (playerLasers.size()<1) { 
    playerLasers.add(new Sprite(this));
    playerLasers.get(playerLasers.size()-1).addCostume("images/green laser.png");
    playerLasers.get(playerLasers.size()-1).size=300;
    playerLasers.get(playerLasers.size()-1).pos.x = player.pos.x;
    playerLasers.get(playerLasers.size()-1).pos.y = player.pos.y;
    playerLasers.get(playerLasers.size()-1).direction = 90;
    laserTimeout = 35; 
  }
}

void movePlayerLasers() {
  boolean removeThis=false;
  if (playerLasers.size() > 0) {
    for (int currentLaser=0;currentLaser<playerLasers.size();currentLaser++) {
      playerLasers.get(currentLaser).move(5);
      playerLasers.get(currentLaser).draw();
      
      // check if we need to remove laser b/c it hit an enemy
      removeThis=false;
      if (playerLasers.get(currentLaser).touchingSprite(ufo)) {
        newUFO();
        score += (int)random(0,4) * 100;
        removeThis = true;
      }
      for (int currentEnemy=0; currentEnemy<enemies.size(); currentEnemy++) {
        if (playerLasers.get(currentLaser).touchingSprite(enemies.get(currentEnemy))) {
          removeThis=true;
          score += enemies.get(currentEnemy).pointValue; 
          enemies.remove(currentEnemy);
          currentEnemy--;
          enemyMoveSpeed -= 0.5;
        }
      }
      // check if we need to remove the laser b/c it hit a shield
      for (int thisShield = 0; thisShield < shields.size(); thisShield++) {
        if (playerLasers.get(currentLaser).touchingSprite(shields.get(thisShield))) {
          shields.get(thisShield).nextCostume();
          if (shields.get(thisShield).costumeNumber == 0) { shields.remove(thisShield); thisShield--; }
          removeThis = true;
        }
      }
      // check if laser has moved off screen
      if (playerLasers.get(currentLaser).pos.y < 0) removeThis=true;
      // remove laser from game if above conditions have been met
      if (removeThis) {
        playerLasers.remove(currentLaser);
        currentLaser--;
      }
    }
  }
}

String costumeForRow(int row) {
  switch (row) {
    case 0: return "images/invader3-";
    case 1: 
    case 2: return "images/invader2-"; 
    case 3:
    case 4:  return "images/invader1-";  
  }
  return "error";
}

void spawnShields() {
  int numberOfShields = 0;
  for (int currentShield = 0; currentShield < 4; currentShield++) {
    for (int row = 0; row < 5; row++) {
      for (int col = 0; col < 10; col++) {
        shields.add(new Sprite(this));
        shields.get(numberOfShields).addCostume("images/shield dot.png");
        shields.get(numberOfShields).size = 200;
        shields.get(numberOfShields).pos.x = -20+(width/5)+(currentShield*(width/5))+(col*4);
        shields.get(numberOfShields).pos.y = 425+(row*4);
        numberOfShields++;
      }
    }
  }
}

void drawShields() {
  int numberOfShields = shields.size();
  for (int thisShield = 0; thisShield < numberOfShields; thisShield++) {
    shields.get(thisShield).draw();
  }
}

int pointsForRow(int row) {
  switch (row) {
    case 0: return 30;
    case 1:
    case 2: return 20;
    case 3:
    case 4: return 10;
  }
  return -99;
}

void spawnEnemies() {
  int numberOfEnemies = enemies.size();
  enemyMoveSpeed = 75-((level-1)*2);
  for (int enemyY = 0; enemyY < 5; enemyY++) {
    for (int enemyX = 0; enemyX < 11; enemyX++) {
      enemies.add(new Sprite(this));
      enemies.get(numberOfEnemies).addCostume(costumeForRow(enemyY)+"1.png");
      enemies.get(numberOfEnemies).addCostume(costumeForRow(enemyY)+"2.png");
      enemies.get(numberOfEnemies).pointValue = pointsForRow(enemyY);
      enemies.get(numberOfEnemies).setCostume(0);
      enemies.get(numberOfEnemies).size=35;
      enemies.get(numberOfEnemies).pos.x = 75+(enemyX*35);
      enemies.get(numberOfEnemies).pos.y = 50+(level*30)+(enemyY*30);
      enemies.get(numberOfEnemies).direction = 0;
      numberOfEnemies = enemies.size();
    }
  }
}

void moveEnemies() {
  boolean reverseDirection = false;
  if (enemyMayFire()) {
    int theFiringEnemy = (int)random(0,enemies.size());
    fireEnemyLaser(enemies.get(theFiringEnemy).pos.x,enemies.get(theFiringEnemy).pos.y);
  }
  if (enemyMoveTimer > enemyMoveSpeed) {
    enemyMoveTimer = 0;
    for (int currentEnemy=0;currentEnemy<enemies.size();currentEnemy++) {
      enemies.get(currentEnemy).move(10);
      enemies.get(currentEnemy).nextCostume();
      for (int currentShield = 0; currentShield < shields.size(); currentShield++) {
        if (enemies.get(currentEnemy).touchingSprite(shields.get(currentShield))) {
          shields.remove(currentShield);
          currentShield--;
        }
      }
      if (enemies.get(currentEnemy).pos.x > width-5 || enemies.get(currentEnemy).pos.x < 5) {
        reverseDirection = true;
      }
    }
    if (reverseDirection) {
      if (newEnemyDirection == 180) newEnemyDirection = 0; else newEnemyDirection = 180;
      enemyMoveSpeed -= 2;
      for (int currentEnemy=0;currentEnemy<enemies.size();currentEnemy++) {
        enemies.get(currentEnemy).direction = newEnemyDirection;
        enemies.get(currentEnemy).move(10);
        enemies.get(currentEnemy).pos.y += 15;
        if (enemies.get(currentEnemy).pos.y > 450) endTheGame();
      }
   }
  } else enemyMoveTimer++;
    
  for (int currentEnemy=0;currentEnemy<enemies.size();currentEnemy++) {
    enemies.get(currentEnemy).draw();
  }
 
}

boolean enemyMayFire() {
  if ( random(0,200) < 1+(level*2) ) return true;
  else return false;
}

void fireEnemyLaser(float laserX, float laserY) {
  if (enemyLasers.size()<3) {
    int newLaser=enemyLasers.size();
    enemyLasers.add(new Sprite(this));
    enemyLasers.get(newLaser).addCostume("images/white laser.png");
    enemyLasers.get(newLaser).size=300;
    enemyLasers.get(newLaser).pos.x = laserX;
    enemyLasers.get(newLaser).pos.y = laserY;
    enemyLasers.get(newLaser).direction = 270;
  }
}

void moveEnemyLasers() {
  boolean removeThis = false;
  for (int currentLaser = 0; currentLaser < enemyLasers.size(); currentLaser++) {
    enemyLasers.get(currentLaser).move(4);
    if (enemyLasers.get(currentLaser).touchingSprite(player)) {
      playerLosesLife();
      removeThis = true;
    }
    if (enemyLasers.get(currentLaser).pos.y > height) removeThis = true;
    for (int thisShield = 0; thisShield < shields.size(); thisShield++) {
      if (enemyLasers.get(currentLaser).touchingSprite(shields.get(thisShield))) {
        shields.get(thisShield).nextCostume();
        if (shields.get(thisShield).costumeNumber == 0) { shields.remove(thisShield); thisShield--; }
        removeThis = true;
      }
    }
    if (removeThis) {
      enemyLasers.remove(currentLaser);
      currentLaser--;
      removeThis = false;
    } else enemyLasers.get(currentLaser).draw();
  }
}

void playerLosesLife() {
  //player.setCostume(exploded);
  // animate somehow?
  player.hide();
  lives--;
  if (lives < 1) endTheGame();
  playerRespawnTimer = 250;
}

void drawLabels() {
  if (gamestate=="playing") {
    textSize(16);
    fill(255);
    text("Level: "+level, 10, 20);
    text("Score: "+score, width/2-25, 20);
    text("Lives: "+lives, width-75, 20);  // Text wraps within text box
  }
  if (gamestate=="gameover") {
    fill(255);
    textSize(32);
    text("Game Over", 170, 200);  // Text wraps within text box
    textSize(48);
    text(""+score, 230, 250);  // Text wraps within text box
  }
}

void endTheGame() {
  player.hide();
  gamestate = "gameover";
  fg.resetTimer();
}
