/* Code for Tetris
 * By Kevin Zeng
 */
 
/**
* Particle class
* Lasts for a certain amount of frames before it dies
*/
class Particle {
  private static final float SIZE = Tetris.SIZE/10;

  private final int lifespan = 20; //amount of frames before it is considered dead
  private int timer = 0; 
  private float x; //x position
  private float y; //y position
  private float vX; //x velocity
  private float vY; //y velocity
  private int colour = color(255);

  /**
   * Constructor for a new particle
   */
  public Particle(float x, float y, float vX, float vY) {
    this.x = x;
    this.y = y;
    this.vX = vX;
    this.vY = vY;
  }

  /**
   * Displays the particle centered at its x,y
   */
  public void disp() {
    noStroke();
    fill(colour);
    square(x-SIZE/2, y-SIZE/2, SIZE);
  }

  /**
   * Moves the particle by vX,vY, and increments its timer
   */
  public void move() {
    this.x += vX;
    this.y += vY;
    timer += 1;
  }

  /**
   * Checks if this particle has exceeded its lifespan
   * @return true if the timer is greater than or equal to the lifespan
   */
  public boolean checkDead() {
    return timer >= lifespan;
  }
}
