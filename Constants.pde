/* Code for Tetris
 * By Kevin Zeng
 */

//Constants for the game
public static final int FIELD_WIDTH = 400; //width of game field
public static final int HEIGHT = 800;
public static final int ROWS = 20;
public static final int COLS = 10;
public static final float SIZE = (float)FIELD_WIDTH/10; //size of each block in the game
public static final float BOARD_LEFT = (float)FIELD_WIDTH/2;
public final int FIELD_COLOUR = color(20);

//Constants for the hold box
private static final float HOLD_WIDTH = 4 * SIZE;
private static final float HOLD_HEIGHT = 3 * SIZE;
private static final float HOLD_LEFT = BOARD_LEFT - HOLD_WIDTH-SIZE/2;
private static final float HOLD_TOP = (float) (HEIGHT / 10.0);

//Constants for the next queue box
private static final float NEXT_WIDTH = 4 * SIZE;
private static final float NEXT_HEIGHT = 3 * visibleNextQueueSize * SIZE;
private static final float NEXT_LEFT = BOARD_LEFT + FIELD_WIDTH + SIZE/2;
private static final float NEXT_TOP = (float) (HEIGHT / 10.0);

//Constants for the score box
private static final float SCORE_BOX_WIDTH = 4 * SIZE;
private static final float SCORE_BOX_HEIGHT = 6 * SIZE;
private static final float SCORE_BOX_LEFT = BOARD_LEFT - SCORE_BOX_WIDTH-SIZE/2;
private static final float SCORE_BOX_TOP = NEXT_TOP * 4;

//Button Constants
private static final float PAUSE_BTN_WIDTH = HOLD_WIDTH;
private static final float PAUSE_BTN_HEIGHT = (float)(2.0/3.0) * HOLD_HEIGHT;
private static final float PAUSE_BTN_LEFT = NEXT_LEFT;
private static final float PAUSE_BTN_TOP = NEXT_TOP + NEXT_HEIGHT + PAUSE_BTN_HEIGHT;

public static final float MENU_BTN_WIDTH = FIELD_WIDTH * (float)2/3;
public static final float MENU_BTN_HEIGHT = (float)HEIGHT/10;
public static final float MENU_BTN_LEFT = BOARD_LEFT + (float)FIELD_WIDTH/2 - MENU_BTN_WIDTH/2;
public static final float MENU_BTN_TOP = (float)HEIGHT/2 - MENU_BTN_HEIGHT/2;
