import java.util.ArrayList;


/**********************************************************************************************************
 * Explosion class by kabir to handle explosion and expansion of explosion fire 
 ***********************************************************************************************************/

class Explosion {
    float x, y;
    float radius;
    int lifespan;
    float maxRadius = 75; // Maximum radius of the explosion
    ArrayList<Explosion> explosions; // Declare a local ArrayList

    Explosion(float xPos, float yPos, float r, ArrayList<Explosion> explosions) {
        x = xPos;
        y = yPos;
        radius = r;
        lifespan = 60; // Adjust the lifespan as desired
        this.explosions = explosions; // Store the reference to the ArrayList
        this.explosions.add(this); // Add the new explosion to the list
    }

    void update() {
        lifespan--;

        // Gradually increase the radius of the explosion
        radius += (maxRadius - radius) * 0.04; // Adjust the rate of spread

        // Check for collisions with bombs
        if (!bombX.isEmpty() && !bombY.isEmpty()) { // Check if the ArrayLists are not empty
            for (int j = bombX.size() - 1; j >= 0; j--) {
                float distance = dist(bombX.get(j), bombY.get(j), x, y);
                if (distance < radius) {
                    handleCollision(j, 2); // Bomb collision
                     score += 4;
                }
            }
        }

        // Remove expired explosions
        if (isExpired()) {
            explosions.remove(this);
        }
    }

    void display() {
        if (lifespan > 0) {
            noStroke();
            for (int i = 0; i < 2; i++) {
                float alpha = map(i, 0, 1, 100, 200); // Map alpha value for transparency
                fill(128, 128, 128, alpha); // Gray color with varying transparency
                ellipse(x, y, radius * (i + 1), radius * (i + 1)); // Draw concentric circles with increasing size
            }
            for (int i = 0; i < 2; i++) {
                float alpha = map(i, 0, 1, 200, 100); // Map alpha value for transparency
                fill(255, 165, 0, alpha); // Orange color with varying transparency
                ellipse(x, y, radius * (i + 0.5), radius * (i + 0.5)); // Draw concentric circles with increasing size
            }
        }
    }

    boolean isExpired() {
        return lifespan <= 0;
    }

    void updateExplosions(ArrayList<Explosion> explosions) {
    for (int i = explosions.size() - 1; i >= 0; i--) {
        Explosion explosion = explosions.get(i);
        if (explosion.radius > 0) { // Skip the initial instance with radius 0
            explosion.update();
            explosion.display();
        }
    }
  }
}
