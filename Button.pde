/* Code for Tetris
 * By Kevin Zeng
 */

/**
 * Button Class
 */
class Button {
  private float x;
  private float y;
  private float width;
  private float height;
  private int highlightColor = color(204);
  private int normalColor = color(255);
  private String text;
  public boolean over = false; //whether or not the mouse is over this button

  /**
  * Constructor for the button
  */
  public Button(float x, float y, float w, float h, String txt) {
    this.x = x;
    this.y = y;
    this.width = w;
    this.height = h;
    this.text = txt;
  }

  /**
  * Draws the button at its specified x,y position 
  */
  public void disp(float mouseX, float mouseY) {
    update(mouseX, mouseY);

    if (over) {
      fill(highlightColor);
    } else {
      fill(normalColor);
    }
    stroke(255);
    rect(x, y, width, height);

    fill(0);
    textFont(Tetris.font, Tetris.btnFontSize);
    textAlign(CENTER);
    text(text, x+width/2, y+ height/2+ Tetris.btnFontSize/2);
  }

  /**
  * Updates the over variable depending on if the mouse is over the button 
  */
  private void update(float mouseX, float mouseY) {
    over = overRect(mouseX, mouseY);
  }

  /**
  * Detects whether the mouse is over the button
  */
  private boolean overRect(float mouseX, float mouseY) {
    if (mouseX >= x && mouseX <= x+width &&
      mouseY >= y && mouseY <= y+height) {
      return true;
    } else {
      return false;
    }
  }
}
