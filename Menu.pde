/* Code for Tetris
 * By Kevin Zeng
 */

import java.util.*;

/**
 * Menu Class
 * Contains a map of all its buttons and a title
 */
class Menu {

  private Map<String, Button> buttonMap;
  private String title;

  /**
   * Constructor for a new menu
   * @param buttons the buttons in the menu
   * @param title Title for menu, which also gets drawn
   */
  public Menu(Map<String, Button> buttons, String title) {
    this.buttonMap = buttons;
    this.title = title;
  }

  /**
   * Draws the menu with all the buttons
   */
  public void disp(float mouseX, float mouseY) {
    textAlign(CENTER);
    textFont(Tetris.font, titleFontSize);
    outlineText(title, MENU_BTN_LEFT+MENU_BTN_WIDTH/2, MENU_BTN_TOP-MENU_BTN_HEIGHT/2);
    for (Button btn : buttonMap.values()) {
      btn.disp(mouseX, mouseY);
    }
  }

  /**
   * Returns the map of the buttons
   * @return a map of the buttons
   */
  public Map<String, Button> getButtons() {
    return this.buttonMap;
  }
}
