
/**********************************************************************************************************
 * Welcome class by utsab to handle welcome screen and how to play information 
 ***********************************************************************************************************/


class welcome {
  
  boolean playedWelcomeSound = false; // Flag to track if the welcome sound has been played
  void display() {
        //background(0); // Black background
        fill(255); // White text

        // Title
        textSize(50);
        textAlign(CENTER, CENTER);
        text("Welcome to City Defender!", width / 2, height / 4);

        // Instructions
        fill(150, 150, 150, 200); // Gray transparent 
        rect(width * 1/4 , height/2 - 125, 500, 200);
        fill(255); // Black text 
        textSize(24);
        textAlign(LEFT, TOP);
        text("How to Play:", width * 1/4 +20, height / 2 - 100);
        textSize(18);
        text("- Target bombs and click to fire.", width * 1/4 +20, height / 2 - 70);
        text("- Destroy bombs before they hit the buildings.", width * 1/4 +20, height / 2 - 40);
        text("- Earn points for each bomb destroyed.", width * 1/4 +20, height / 2 - 10);
        text("- Save as many buildings as you can before game time.", width * 1/4 +20, height / 2 + 20);

        
        fill(255); // White text
        textSize(30);
        text("Click To Start Game", width/2 - 125 , height * 3 / 4 + 15); 
        
      if (!playedWelcomeSound) {
        if (!welcomeSound.isPlaying()) {
        welcomeSound.play();
        }
        playedWelcomeSound = true; // Set the flag to true after playing the sound
      }

    }
    
    
}
