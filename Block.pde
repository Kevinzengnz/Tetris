/* Code for Tetris
 * By Kevin Zeng
 */

/**
 * Block class
 * For each individual block in the tetris field
 */
class Block {
  private boolean locked = false;
  private int colour = color(255, 255, 255);
  private int opacityEffect = 255;
  private float rotation = 0;

  /**
   * draws the current block at the specified position and size
   */
  public void disp(float left, float top, float size) {
    pushMatrix();
    translate(left, top);
    rotate(rotation);

    fill(this.colour, opacityEffect);
    square(0, 0, size);

    noFill();
    stroke(0, opacityEffect);
    square(0, 0, size);

    popMatrix();
  }

  /**
   * Sets the color of this block
   * @param c color to change to
   */
  public void setColor(int c) {
    this.colour = c;
  }

  /**
   * Sets the opacity of this block
   * @param o opacity to change to
   */
  public void setOpacity(int o) {
    this.opacityEffect = o;
  }

  /**
   * Gets the opacity of this block
   * @return block opacity
   */
  public int getOpacity() {
    return opacityEffect;
  }

  /**
   * Gets the color of this block
   * @return block color
   */
  public int getColor() {
    return colour;
  }

  /**
   * Locks this block
   */
  public void lock() {
    this.locked = true;
  }

  /**
   * Unlocks this block
   */
  public void unlock() {
    this.locked = false;
  }

  /**
   * Returns whether this block is locked
   * @return the locked field
   */
  public boolean isLocked() {
    return locked;
  }

  /**
   * Sets the rotation of this block
   * @param r angle to change to
   */
  public void setRotation(float r) {
    this.rotation = r;
  }

  /**
   * Returns the rotation of this block
   */
  public float getRotation() {
    return this.rotation;
  }
}
