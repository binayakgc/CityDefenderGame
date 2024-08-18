/*************************************************************************************************
 * Assignment 3 -  A simple style Cty Defender Game 
 * Author : Group Project Utsab Gyawali / Kabir GC / Kishor  - COSC 101 
 * This program generates random bomb from top bottom the player must defend 
 * the cities using the shooter. The game has 2 levels the first level has 
 * time limit of 60 second with slower speed bombs falling, along with 100 ammos limit.
 * If all cities gets destroyed or the ammo is finished the game is over for both
 * levels. In second level the speed of bomb is increased to increase the difficulty 
 * Time limit is still 60 second but the amount of ammo is doubled. 
 * If user is able to defend atleast one city the lvl 1 is progressed to level 2. 
 * before starting level 2 the score calculation info is given with bonus score 
 * for defended city and remaining ammo which is added to total score for next level. 
 * The added explosion feature is if a bomb falls
 * under explosion fire of another bomb it also explodes represented by yellow circle
 * for fire, gray for smoke
 * 
 * How to Run:
 * 1. Save the code as a `.pde` file (e.g., fly_swatter.pde).
 * 2. Open the Processing development environment (https://processing.org/).
 * 3. Install the Processing Sound library from "Sketch" -> "Import Library" 
 * and select "Manage library" search 
 * and install Sound package from Processing Foundation
 * 3. Click "File" -> "Open" and select your saved code file.
 * 4. Press "Run" to execute the program.
 **************************************************************************************************/
import processing.sound.*;
// initialization and assignment of Variables used

//added by kishor
int numCities = 6;
float tankX;
float tankY;
float angle;
float cityWidth;
int score = 0;
int[] cityDestroy;
int bonusScore;

// added by kabir
float bombsDropped = 0;
float maxBombs = 30;
int destroyedCities = 0;
SoundFile inGameSound, gunSound, bombExplosionSound, shotBombCollisionSound,welcomeSound,level1CompletionSound, gameOverSound, winSound;

//added by utsab
welcome welcomeScreen;
int level = 0;
int ammo;
int maxAmmo;
int timer;
int totalScore = 0;
boolean gamePause = false;
ArrayList<Explosion> explosions = new ArrayList<Explosion>();

// Declare a variable to hold the tank image by kishor 
PImage imgTank, imgMountain, imgCity, imgCollision, imgDestroyedHouse, imgBomb;

// Arrays to hold the shots
ArrayList<Float> shotX = new ArrayList<Float>();
ArrayList<Float> shotY = new ArrayList<Float>();
ArrayList<Float> shotDirX = new ArrayList<Float>();
ArrayList<Float> shotDirY = new ArrayList<Float>();

// Arrays to hold the falling bombs
ArrayList<Float> bombX = new ArrayList<Float>();
ArrayList<Float> bombY = new ArrayList<Float>();

// Arrays to hold collision positions and types
ArrayList<Float> collisionX = new ArrayList<Float>();
ArrayList<Float> collisionY = new ArrayList<Float>();
ArrayList<Integer> collisionType = new ArrayList<Integer>(); // 0: tank, 1: building, 2: bomb

float shotSpeed = 7.0; // speed of the anti missile 
float bombSpeed = 0.5; // Initial bomb speed


Explosion explosionManager = new Explosion(0, 0, 0, explosions);
 
/*************************************************************************************************
 * Setup() - Initialise all required values for our program. Run only once
 *************************************************************************************************/
void setup() {
  // Set up the canvas size and background color
  size(1000, 800);

//load images 
  imgMountain = loadImage("background.jpg");
  imgMountain.resize(1000, 800);

  imgCity = loadImage("cnd.png");
  imgCity.resize(100, 200);

  // Load the tank image and resize it
  imgTank = loadImage("tank.png");
  imgTank.resize(50, 50);

  // Load the collision image and resize it
  imgCollision = loadImage("blast.png");
  imgCollision.resize(150, 150);

  // Load the destroyed house image and resize it
  imgDestroyedHouse = loadImage("cbd.png");
  imgDestroyedHouse.resize(100, 200);

// load bomb image
  imgBomb = loadImage("bomb.png"); 
  imgBomb.resize(30, 50); 

  // Create an initial Explosion instance
  new Explosion(0, 0, 0, explosions);

  cityDestroy = new int[numCities]; // Initialize city no of city variable
  for (int i = 0; i < numCities; i++) {
    cityDestroy[i] = 0; // Initially, all buildings are not destroyed
  }
  cursor(CROSS);
  
  //sound
  inGameSound = new SoundFile(this,"mixkit-video-game-bomb-alert-2803.wav");
  gunSound = new SoundFile(this, "mixkit-short-laser-gun-shot-1670.wav");
  bombExplosionSound = new SoundFile(this, "classic-explosion-fx_140bpm.wav");
  shotBombCollisionSound = new SoundFile(this, "atom-bomb-explosion-fx_129bpm.wav");
  welcomeSound = new SoundFile(this, "mixkit-game-level-music-689.wav");
  level1CompletionSound = new SoundFile(this, "mixkit-completion-of-a-level-2063.wav");
  gameOverSound = new SoundFile(this, "mixkit-retro-arcade-game-over-470.wav");
  winSound = new SoundFile(this, "mixkit-game-level-completed-2059.wav");
  
  
  //welcome screen added by utsab 
  welcomeScreen = new welcome();
  level = 0; // Start on the welcome screen
  
  // Stop any currently playing sounds
  level1CompletionSound.stop();
  welcomeSound.stop();
}

/*************************************************************************************************
 * startLevel(int lvl) -  function to take level input for level 1 or 2 based
 * on the value passed it also resets elements for new level
 *************************************************************************************************/

void startLevel(int lvl) {
  level = lvl;
  ammo = lvl == 1 ? 100 : 200; // condition to give ammo 100 for lvl 1 and 200 for lvl 2 
  maxAmmo = ammo;
  timer = 60;

  // Stop any currently playing sounds
  level1CompletionSound.stop();
  welcomeSound.stop();
  
  // Reset game elements for the new level
  for (int i = 0; i < numCities; i++) {
    cityDestroy[i] = 0;
  }
  shotX.clear();
  shotY.clear();
  shotDirX.clear();
  shotDirY.clear();
  bombX.clear();
  bombY.clear();
  collisionX.clear();
  collisionY.clear();
  collisionType.clear();
  bombsDropped = 0;
  destroyedCities = 0;

  // Increase bomb speed for level 2
  if (lvl == 2) {
    score = totalScore;
    bombSpeed = 2; // Faster bombs in level 2
  } else {
    bombSpeed = 0.5; // Reset bomb speed for level 1
  }
}

boolean gameOver = false; // Flag to track the game over state

/**********************************************************************************************************
 * draw() -  function to iteratively render all the elements of game 
 ***********************************************************************************************************/
void draw() {
  background(imgMountain); //background changed by from mountain to current one 

  if (level == 0) {
    welcomeScreen.display(); // keep display welcome screen if lvl 0 initial condition
  } else {
    if (!gamePause && timer > 0 && ammo > 0 
    && !gameOver && destroyedCities !=numCities  ) {
      
      //if (!inGameSound.isPlaying()) {
      //      inGameSound.play();
      //  }

      // draw functions if game is not over or not paused 
      
      drawFeatures();
      drawTank();
      updateAndDrawShots();
      updateAndDrawbombs();
      drawCollisions();
      explosionManager.updateExplosions(explosions);

      // Display timer, score, and ammo on top right screen
      fill(255);
      textSize(24);
      text("Time: " + timer, 20, 50);
      text("Score: " + score, 20, 80);
      text("Ammo: " + ammo, 20, 110);
      text("Destroyed Cities: " + destroyedCities, 20, 140);
      
      // Add a new bomb periodically with timer countdown
      if (frameCount % 60 == 0) {
        timer--; 
        if (bombsDropped < maxAmmo) { // Add bomb only if the timer is still running
          bombX.add(random(width));
          bombY.add(0.0);
          bombsDropped++;
        }
      }
    } else {
      checkLevelCompletion(); // to check level progress
    }
  }
}

/**********************************************************************************************************
 * checkLevelCompletion() -  function by utsab to check current level progress 
 * and condition if it matches to progress into next level .
 ***********************************************************************************************************/

void checkLevelCompletion() {
  boolean allHousesDestroyed = false;
  if (destroyedCities == numCities) {
    allHousesDestroyed = true;
  }
  if ( allHousesDestroyed || ammo == 0) { // Loss condition
    gameOver(false);
  } else if (level == 1 && !allHousesDestroyed) { // Level 1 win condition
    levelCompleteScreen();
  } else if (level == 2 && !allHousesDestroyed ) { // Level 2 win condition
    gameOver(true);
  }
}

/**********************************************************************************************************
 * levelCompleteScreen() -  function to pause game to avoid array iteration error 
 * and display information of game bonus calculation and all.
 ***********************************************************************************************************/

boolean playedLevel1CompletionSound = false;

void levelCompleteScreen() {
  gamePause = true; // flag to pause the game 
  //informations with black background
  background(0); 
  textSize(32);
  fill(255);
  text("Level 1 Complete!", width / 2 - 150, height / 2 - 50);
  text("Your Score: " + score, width / 2 - 100, height / 2);
  text("Remaining Ammo: " + ammo, width / 2 - 120, height / 2 + 50);
  // give bonus score for remaining ammos * 2  and remaining cities * 20
  bonusScore = ammo * 2 + numCities - destroyedCities * 20; 
  totalScore = score + bonusScore;
  text("Bonus Score: " + bonusScore, width / 2 - 110, height / 2 + 100);
  text("Total Score: " + totalScore, width / 2 - 100, height / 2 + 150);
  text("Press any Key to proceed to Level 2", width / 2 - 180, height / 2 + 200);
  
  if (!playedLevel1CompletionSound && level == 1) {
    gunSound.stop();
    shotBombCollisionSound.stop();
    bombExplosionSound.stop(); // Stop the bombExplosionSound
    level1CompletionSound.play(); // Play the level 1 completion sound
    playedLevel1CompletionSound = true; // Set the flag to true after playing the sound
  } else if (playedLevel1CompletionSound && !level1CompletionSound.isPlaying()) {
    if (!welcomeSound.isPlaying()) {
      welcomeSound.play();
      }// Play the welcome sound for the next level when level1CompletionSound finishes
  }
}

/**********************************************************************************************************
 * gameOver() -  function by utsab to check game over condition with win or loss .
 ***********************************************************************************************************/
void gameOver(boolean won) {
  //background(0);
  gamePause = true;
  textSize(50);
  fill(won ? 255 : 0,255, 0); // different color for win and loss
  text(won ? "You Win!" : "Game Over!", width / 2 - 100, height / 2 -10);
  textSize(32);
  fill(255);
  text("Total Score: " + totalScore, width / 2 - 125, height / 2 + 50);
  
  shotBombCollisionSound.stop();
  bombExplosionSound.stop(); // Stop the bombExplosionSound
  gunSound.stop();
  if (won) {
     // Play the win sound
    if (!winSound.isPlaying()) {
            
            winSound.play();
            
        }
  } else {
     // Play the game over sound
    if (!gameOverSound.isPlaying()) {

            gameOverSound.play();
        }
  }
  
  noLoop(); // Stop the game loop
}

/**********************************************************************************************************
 * drawFeatures() -  function to draw city and distroyed city  .
 ***********************************************************************************************************/
// to draw city image in the window
void drawFeatures() {
  // Calculate the width of each city based on canvas width and number of cities
  cityWidth = width / float(numCities);

  // Calculate the starting x-coordinate for the first city
  float startX = (width - ((numCities - 1) * cityWidth)) / 2;

  // Draw cities on the left side of the cannon
  for (int i = 0; i < 3; i++) {
    float x = startX + i * cityWidth;
    float y = height / 1.06;
    if (i < cityDestroy.length) { // Check if the index is within the bounds
      if (cityDestroy[i] == 0) {
        drawCity(x, y, imgCity.width, imgCity.height / 2);
      } else if (cityDestroy[i] == 1) {
        drawDestroyedHouse(x, y, imgCity.width, imgCity.height / 2);
      }
    }
  }

  // Draw cities on the right side of the cannon
  for (int i = 3; i < numCities; i++) {
    float x = startX + (i * cityWidth);
    float y = height / 1.06;
    if (i < cityDestroy.length) { // Check if the index is within the bounds
      if (cityDestroy[i] == 0) {
        drawCity(x, y, imgCity.width, imgCity.height / 2);
      } else if (cityDestroy[i] == 1) {
        drawDestroyedHouse(x, y, imgCity.width, imgCity.height / 2);
      }
    }
  }
}
// display non distroyed city
void drawCity(float x, float y, float cityWidth, float cityHeight) {
  // Draw the building image
  image(imgCity, x, y, cityWidth, cityHeight);
}
// display destroyed city (previously house)
void drawDestroyedHouse(float x, float y, float cityWidth, float cityHeight) {
  // Draw the destroyed house image
  image(imgDestroyedHouse, x, y, cityWidth, cityHeight);
}

/**********************************************************************************************************
 * drawTank() -  function to draw tank and rotating feature 
 ***********************************************************************************************************/
// for tank to move around from a same position
void drawTank() {
  // Calculate the x and y-coordinates for the tank
  tankX = width / 2;
  tankY = height - imgTank.height / 2;

  // Calculate the direction vector from the tank to the cursor
  float dirX = mouseX - tankX;
  float dirY = mouseY - tankY;

  // Normalize the direction vector
  float mag = sqrt(dirX * dirX + dirY * dirY);
  dirX /= mag;
  dirY /= mag;

  // Calculate the transformation matrix
  PVector dir = new PVector(dirX, dirY);
  PVector up = new PVector(0, -1); // The tank's default up direction
  float angle = PVector.angleBetween(up, dir);

  // Move the origin to the tank's position
  pushMatrix();
  translate(tankX, tankY);

  // Calculate the cross product to determine the direction of rotation
  PVector cross = up.cross(dir);
  if (cross.z < 0) {
    angle = -angle;
  }

  // Rotate the coordinate system by the calculated angle
  rotate(angle);

  // Draw the tank image with its center at the origin
  imageMode(CENTER);
  image(imgTank, 0, 0);

  // Restore the original coordinate system
  popMatrix();
}

/**********************************************************************************************************
 * updateAndDrawShots() - updated function by kabir to update shot collision and shot mechanism.
 *                        Originally done by Kishwor.
 ***********************************************************************************************************/
boolean[] shotPlayedSound;
void updateAndDrawShots() {
  if (!shotX.isEmpty() && !shotY.isEmpty() && !shotDirX.isEmpty() && !shotDirY.isEmpty()) { 
    
    if (shotPlayedSound == null || shotPlayedSound.length != shotX.size()) {
      shotPlayedSound = new boolean[shotX.size()]; // Initialize or resize the shotPlayedSound array
    }
    
    // Check if the ArrayLists are not empty
    for (int i = shotX.size() - 1; i >= 0; i--) {
      shotX.set(i, shotX.get(i) + shotDirX.get(i) * shotSpeed);
      shotY.set(i, shotY.get(i) + shotDirY.get(i) * shotSpeed);
      fill(255, 0, 0); // Red color for the dot
      ellipse(shotX.get(i), shotY.get(i), 10, 10); // Draw a small circle (dot)

      // Check for collisions with bombs from tank
      if (!bombX.isEmpty() && !bombY.isEmpty()) { // Check if the ArrayLists are not empty
        for (int j = bombX.size() - 1; j >= 0; j--) {
          if (dist(shotX.get(i), shotY.get(i), bombX.get(j), bombY.get(j)) < 15) {
            // Handle bomb being hit by shot
            handleCollision(j, 2); // bomb collision
            score += 4;
            totalScore += 4;  // Increment totalScore, not just score
            //ammo--; // Decrement ammo
            shotX.remove(i);
            shotY.remove(i);
            shotDirX.remove(i);
            shotDirY.remove(i);
            break;
          }
        }
      }
    }
  }
}

/************************************************************************************
 * updateAndDrawbombs() -  Updated function by kabir to update bombs on collision to objects.
 *                         Originally done by Kishwor.
 ************************************************************************************/
//kabir
void updateAndDrawbombs() {
  for (int i = bombX.size() - 1; i >= 0; i--) {
    bombY.set(i, bombY.get(i) + bombSpeed);
    fill(0, 0, 255); // Blue color for the bomb
    image(imgBomb, bombX.get(i), bombY.get(i)); // Draw a larger circle (bomb)

    // Check for collisions with the ground
    if (bombY.get(i) > height - 20) { // Adjust the ground level as needed
      // Display the collision effect image
      image(imgCollision, bombX.get(i) - imgCollision.width / 2, height - imgCollision.height / 2);
      // Remove the bomb after displaying the collision effect
      bombX.remove(i);
      bombY.remove(i);
    }

    // Check for collisions with the non-destroyed cities from bomb
    for (int j = 0; j < numCities; j++) {
      if (cityDestroy[j] == 0) { // Check if the city is not destroyed
        float cityX = j * cityWidth + cityWidth / 2;
        float cityY = height / 1.06;
        if (dist(bombX.get(i), bombY.get(i), cityX, cityY) < 50) {
          // Handle city being hit
          cityDestroy[j] = 1;
          destroyedCities++;
          handleCollision(i, 1); // Building collision
          break;
        }
      }
    }
  }
}
// handle collision from above function
void handleCollision(int index, int type) {
  collisionX.add(bombX.get(index));
  collisionY.add(bombY.get(index));
  collisionType.add(type);
  bombX.remove(index);
  bombY.remove(index);

  // Create a new explosion
  if (type == 2) { // Bomb collision
    new Explosion(collisionX.get(collisionX.size() - 1), collisionY.get(collisionY.size() - 1), 50, explosions);
    shotBombCollisionSound.play(); 
  } else if (type == 1) { // Building collision
    // Add a new collision for the building
    collisionX.add(collisionX.get(collisionX.size() - 1));
    collisionY.add(collisionY.get(collisionY.size() - 1));
    collisionType.add(1);
    bombExplosionSound.play(); // Play the bomb explosion sound
  }
}
// function to show the image of collision
void drawCollisions() {
  for (int i = collisionX.size() - 1; i >= 0; i--) {
    float x = collisionX.get(i);
    float y = collisionY.get(i);

    //if (collisionType.get(i) == 0) { // Tank collision
    //  ellipse(x, y, 10, 10);
    //} else
    if (collisionType.get(i) == 1) { // Building collision
      image(imgCollision, x - imgCollision.width / 2, y - imgCollision.height / 2);
    } else if (collisionType.get(i) == 2) { // Bomb collision
      ellipse(x, y, 10, 10);
    }

    // Remove the collision data after a while
    collisionX.remove(i);
    collisionY.remove(i);
    collisionType.remove(i);
  }
}

/**********************************************************************************************************
 * keyPressed() -  function to check keyword pressed conditions .
 ***********************************************************************************************************/


void keyPressed() {
  if (level == 1 && timer == 0) {
    startLevel(2);
    gamePause = false;
  }
}


/**********************************************************************************************************
 * mousePressed() -  function to check mouse pressed conditions .
 ***********************************************************************************************************/
void mousePressed() {
  if (level == 0) {
    startLevel(1);
    gamePause = false;
  } else if (ammo > 0) { // Check if there is ammo left before firing
    // Add a new shot to the arrays
    shotX.add(tankX);
    shotY.add(tankY);

    float dirX = mouseX - tankX;
    float dirY = mouseY - tankY;

    // Normalize the direction vector
    float mag = sqrt(dirX * dirX + dirY * dirY);
    dirX /= mag;
    dirY /= mag;

    shotDirX.add(dirX);
    shotDirY.add(dirY);
    if (!gamePause) {
      ammo--;
      gunSound.play();
    }
  }
}
