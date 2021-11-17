/* Code for Tetris
 * By Kevin Zeng
 */

import java.util.*;

/**
 * Tetris Game
 */

private Block[][] gameBoard = new Block[ROWS][COLS];
private Piece currentPiece = null;
private Piece holdPiece = null;
private boolean held = false; //user is only allowed to hold once per new piece
private HashSet<Integer> linesToClear; //Set of lines that needs to be cleared

//booleans for the different game states
private boolean running = false;
private boolean paused = false;
private boolean start = false;
private boolean gameOver = false;
private boolean toppedOut = false;

//booleans for different game modes
private boolean ultraMode = false;
private boolean endlessMode = false;
private boolean sprintMode = false;

//timers
private int gameTime = 0; //number of frames the game has been active
private int lastGravity = 0; //time since gravity was last done on a piece
private int lockTimer = 0; //time a piece has been in contact with bottom of field
private final int maxLockTime = 30; //amount of frames a piece has before it gets locked in
private int lockResets = 0;
private final int maxLockResets = 15;

//Scores and high scores
private int score = 0;
private int endlessHighScore = 0;
private int sprintBestTime = 0;
private int ultraHighScore = 0;

private static final int ULTRA_TIME = 120; //Seconds for ultra mode
private static final int SPRINT_LINES = 40; //Amount of lines required to clear sprint

private int level = 1; //current level, level multiplies the score obtained
private static final int MAX_LEVEL = 20; //maximum level reachable
//Gravity is expressed in unit G, where 1G = 1 cell per frame, and 0.1G = 1 cell per 10 frames
private double gravity = (float)1/100;
private int totalLines = 0;

private static final float[] GRAVITY_LEVELS = new float[]{0.0167, 0.0221, 0.027, 0.035, 0.047, 0.0636, 0.0879, 0.1236, 0.1775, 0.2598, 0.388, 0.59, 0.92, 1.46, 2.36, 4.0, 6.0, 9.0, 15.0, 20.0};

//Variables for movement
private boolean movingLeft = false;
private boolean movingRight = false;
private boolean rotateClockwise = false;
private boolean rotateCounterClockwise = false;
private boolean rotatedClockwise = false; //makes it so you can only rotate this direction once with each button press
private boolean rotatedCounterClockwise = false; //makes it so you can only rotate this direction once with each button press
private boolean softDropping = false;
private int dasCharge = 0; //DAS - delayed autoshift
private final int dasDelay = 10; //frames before piece begins auto shifting

//Fonts
public static PFont font;
public static final float btnFontSize = 30;
public static final float titleFontSize = 40;
public static final float scoreFontSize = 25;

//Menus
private Menu startMenu;
private Menu pauseMenu;
private Menu gameOverMenu;

//Pause Button
private Button pauseBtn;

//Particles and animation variables
private ArrayList<Particle> particles;
private boolean lineClearAnimation = false;
private int animationTimer = 0;

private Queue<Piece> nextPieceBag;
private static final int visibleNextQueueSize = 3;

private Block[][] holdBlocks = new Block[3][4];
private Block[][] nextBlocks = new Block[3*visibleNextQueueSize][4];

public void settings() {
  size(FIELD_WIDTH*2, HEIGHT);
}

public void setup() {
  font = createFont("Arial", 16, true); // Arial, 16 point, anti-aliasing on

  HashMap<String, Button> startBtnMap = new HashMap();
  Button endlessButton = new Button(MENU_BTN_LEFT, MENU_BTN_TOP, MENU_BTN_WIDTH, MENU_BTN_HEIGHT, "Endless");
  Button ultraButton = new Button(MENU_BTN_LEFT, MENU_BTN_TOP + MENU_BTN_HEIGHT, MENU_BTN_WIDTH / 2, MENU_BTN_HEIGHT, "Ultra");
  Button sprintButton = new Button(MENU_BTN_LEFT + MENU_BTN_WIDTH/2, MENU_BTN_TOP + MENU_BTN_HEIGHT, MENU_BTN_WIDTH / 2, MENU_BTN_HEIGHT, "Sprint");
  startBtnMap.put("Endless", endlessButton);
  startBtnMap.put("Ultra", ultraButton);
  startBtnMap.put("Sprint", sprintButton);
  startMenu = new Menu(startBtnMap, "TETRIS");
  start = true;
}

/**
 * Resets the game and all relevant variables
 */
public void reset() {
  nextPieceBag = new ArrayDeque();
  nextPieceBag.addAll(generateBag());
  nextPieceBag.addAll(generateBag());

  lockResets = 0;

  running = true;
  paused = false;
  start = false;
  gameOver = false;
  toppedOut = false;

  movingLeft =false;
  movingRight = false;
  softDropping = false;
  rotateClockwise = false;
  rotateCounterClockwise = false;

  //makes it so you can only rotate this direction once with each button press
  rotatedClockwise = false;
  rotatedCounterClockwise = false;

  animationTimer = 0;
  particles = new ArrayList();

  gameTime = 0;
  lockTimer = 0;
  score = 0;
  level = 1;
  gravity = (float)1/100;
  println(gravity);

  totalLines = 0;
  for (int i = 0; i < gameBoard.length; i++) {
    for (int j = 0; j < gameBoard[i].length; j++) {
      gameBoard[i][j] = new Block();
    }
  }
  for (int i = 0; i < holdBlocks.length; i++) {
    for (int j = 0; j < holdBlocks[i].length; j++) {
      holdBlocks[i][j] = new Block();
    }
  }
  for (int i = 0; i < nextBlocks.length; i++) {
    for (int j = 0; j < nextBlocks[i].length; j++) {
      nextBlocks[i][j] = new Block();
    }
  }
  currentPiece = nextPieceBag.poll();

  holdPiece = null;
  held = false;

  pauseBtn = new Button(PAUSE_BTN_LEFT, PAUSE_BTN_TOP, PAUSE_BTN_WIDTH, PAUSE_BTN_HEIGHT, "Pause");

  Map<String, Button> pauseBtnMap = new HashMap();
  Map<String, Button> gameOverBtnMap = new HashMap();

  Button resumeButton = new Button(MENU_BTN_LEFT, MENU_BTN_TOP, MENU_BTN_WIDTH, MENU_BTN_HEIGHT, "Resume");
  Button restartButton = new Button(MENU_BTN_LEFT, MENU_BTN_TOP+MENU_BTN_HEIGHT, MENU_BTN_WIDTH, MENU_BTN_HEIGHT, "Restart");
  Button quitButton = new Button(MENU_BTN_LEFT, MENU_BTN_TOP+2*MENU_BTN_HEIGHT, MENU_BTN_WIDTH, MENU_BTN_HEIGHT, "Quit");

  pauseBtnMap.put("Resume", resumeButton);
  pauseBtnMap.put("Restart", restartButton);
  pauseBtnMap.put("Quit", quitButton);
  gameOverBtnMap.put("Restart", restartButton);
  gameOverBtnMap.put("Quit", quitButton);
  pauseMenu = new Menu(pauseBtnMap, "Paused");
  gameOverMenu = new Menu(gameOverBtnMap, "GAME OVER");
}

/**
 * Pauses the game
 */
public void pauseGame() {
  running = false;
  paused = true;
}

/**
 * Pauses the game
 */
public void resumeGame() {
  running = true;
  paused = false;
}

/**
 * Returns to the start menu
 */
public void quitToStart() {
  start = true;
  paused = false;
  running = false;
  gameOver = false;
}

/**
 * Generates a shuffled list of seven pieces
 */
public List<Piece> generateBag() {
  List<Piece> newPieceList = new ArrayList<>(Arrays.asList(new Piece("i"), new Piece("j"), new Piece("l"), new Piece("o"), new Piece("s"), new Piece("z"), new Piece("t")));
  ;
  Collections.shuffle(newPieceList);
  return newPieceList;
}

/**
 * Generates a random piece out of 7
 * @return a piece
 */
public Piece generatePiece() {
  float r = random(7);
  if (r < 1) {
    return new Piece("i");
  } else if (r < 2) {
    return new Piece("j");
  } else if (r < 3) {
    return new Piece("l");
  } else if (r < 4) {
    return new Piece("o");
  } else if (r < 5) {
    return new Piece("s");
  } else if (r < 6) {
    return new Piece("z");
  } else if (r < 7) {
    return new Piece("t");
  }
  return null;
}

/**
 * Main loop of the game
 */
public void draw() {
  if (start) {
    background(200);
    startMenu.disp(mouseX, mouseY);
  }
  if (gameOver) {
    gameOver();
  } else if (running) {
    runGame();
    pauseBtn.disp(mouseX, mouseY);
  }
  if (paused) {
    pauseMenu.disp(mouseX, mouseY);
  }
}

/**
 * Draws all the particles in the list of particles
 */
public void drawParticles() {
  if (particles.isEmpty()) return;
  ArrayList<Particle> tempList = new ArrayList(particles);
  for (Particle p : particles) {
    p.move();
    p.disp();
    if (p.checkDead()) {
      tempList.remove(p);
    }
  }
  particles = tempList;
}

/**
 * Handles movements left and right
 */
public boolean handleLeftRight() {
  if (!(movingRight && movingLeft) && (movingRight || movingLeft)) {
    if (movingRight) {
      //Das determines how long after holding the input, before the piece auto-moves
      if (dasCharge < dasDelay) {
        if (dasCharge == 0) {
          //First frame after press will move the piece
          currentPiece.moveRight(gameBoard);
        }
        dasCharge++;
      } else {
        currentPiece.moveRight(gameBoard);
      }
    } else if (movingLeft) {
      //Das determines how long after holding the input, before the piece auto-moves
      if (dasCharge < dasDelay) {
        if (dasCharge == 0) {
          //First frame after press will move the piece
          currentPiece.moveLeft(gameBoard);
        }
        dasCharge++;
      } else {
        currentPiece.moveLeft(gameBoard);
      }
    }
    return true;
  }

  return false;
}

/**
 * Handles rotations
 */
public boolean handleRotations() {
  boolean successfulRotate = false;
  if (rotateClockwise && !rotatedClockwise) {
    currentPiece.rotateClockwise(gameBoard);
    rotateClockwise = false;
    rotatedClockwise = true;
    successfulRotate = true;
  }
  if (rotateCounterClockwise && !rotatedCounterClockwise) {
    currentPiece.rotateCounterClockwise(gameBoard);
    rotateCounterClockwise = false;
    rotatedCounterClockwise = true;
    successfulRotate = true;
  }
  return successfulRotate;
}

public boolean softDrop() {
  if (currentPiece.checkIfAtBottom() || currentPiece.checkIfOnStack(gameBoard)) return false;
  if (softDropping) {
    currentPiece.moveDown(gameBoard);
    return true;
  }
  return false;
}

/**
 * Handles all the user inputs
 */
public boolean handleInputs() {
  boolean successfulMovement = false;
  if (handleLeftRight()) {
    successfulMovement = true;
  }
  if (handleRotations()) {
    successfulMovement = true;
  }
  if (softDrop()) {
    successfulMovement = true;
  }
  return successfulMovement;
}

/**
 * Runs one frame of the game
 */
public void runGame() {
  background(200);
  stroke(0);
  drawGame(); //draws all the blocks in the stack, and the current piece

  //draws all the particles
  drawParticles();

  //does the line clear animation, which lasts 10 frames
  if (lineClearAnimation) {
    if (animationTimer >= 10) {
      animationTimer = 0;
      lineClearAnimation = false;
      //deletes all the cleared lines
      clearLines(linesToClear);

      held = false;
      currentPiece = nextPieceBag.poll();
      ;
      lastGravity = 0;
      lockTimer = 0;
      lockResets = 0;
      linesToClear.clear();

      lineClearAnimation();
    } else {
      lineClearAnimation();
      animationTimer++;
    }
    return;
  }

  if (checkGameEnd()) {
    running = false;
    gameOver = true;
    return;
  }

  //Moves the piece down according to what the gravity is
  while (lastGravity > gravity) {
    currentPiece.moveDown(gameBoard);
    lastGravity -= 1/gravity;
  }


  //Handles user inputs that haven't been processed yet
  if (currentPiece.checkIfAtBottom() || currentPiece.checkIfOnStack(gameBoard)) {
    if (handleInputs() && lockResets < maxLockResets) {
      lockTimer = 0;
      lockResets++;
      resetPieceOpacity();
    }
  } else {
    handleInputs();
  }

  if (nextPieceBag.size() < 7) {
    nextPieceBag.addAll(generateBag());
  }

  //currentPiece will be null if it had locked in
  if (currentPiece!= null) {
    //checks if the current piece is at the bottom of the board
    if (currentPiece.checkIfAtBottom() || currentPiece.checkIfOnStack(gameBoard)) {
      lockTimer++;
      decreasePieceOpacity();

      if (lockTimer > maxLockTime) {
        lockCurrentPiece();

        linesToClear = getLinesCleared();
        if (linesToClear.size() > 0) {
          totalLines += linesToClear.size();
          updateLevel();
          updateScore(linesToClear.size());
          println(score);

          lineClearAnimation = true;
          beginLineClearAnimation();
        } else {
          this.held = false;
          this.currentPiece = null;
          lockTimer = 0;
        }
      }
    }
  }

  //Generates new piece
  if (currentPiece == null) {
    lastGravity = 0;
    lockResets = 0;
    currentPiece = nextPieceBag.poll();
    if (checkTopOut()) {
      lockCurrentPiece();
      drawCurrentPiece();
      running = false;
      gameOver = true;
      toppedOut = true;

      return;
    }
  }
  gameTime++;
  currentPiece.incrementTimer();
  lastGravity++;
}

/**
 * Updates the level and gravity based on the total number of lines cleared
 */
public void updateLevel() {
  if (level >= MAX_LEVEL) return;
  int newLevel = (int) (Math.floor(totalLines / 10.0)+ 1);
  if (level < newLevel) {
    level = newLevel;
    //gravity = pow((0.8-((level-1)*0.007)),level-1) / 60;
    if (level < GRAVITY_LEVELS.length) {
      gravity = GRAVITY_LEVELS[level-1];
    }

    println("Level: " + level + ", Gravity: " + gravity);
  }
}

/**
 * Updates the user's score based on the number of lines that was just cleared
 */
public void updateScore(int linesCleared) {
  if (linesCleared == 1) {
    score += 100 * level;
  } else if (linesCleared == 2) {
    score += 300 * level;
  } else if (linesCleared == 3) {
    score += 500 * level;
  } else if (linesCleared == 4) {
    score += 800 * level;
  }
}

/**
 * Clears the given lines
 */
public void clearLines(HashSet<Integer> linesCleared) {
  ArrayList<Integer> linesClearedList= new ArrayList(linesCleared);
  Collections.sort(linesClearedList);
  for (int line : linesClearedList) { //line is the row number
    Block[] prevRow = gameBoard[line];
    //moves all the lines down one row
    for (int i = 0; i < line + 1; i++) {
      Block[] curRow = gameBoard[i];
      gameBoard[i] = prevRow;
      prevRow = curRow;
    }
    for (int j = 0; j < COLS; j++) {
      gameBoard[0][j] = new Block();
    }
  }
}

/**
 * Returns a set of all the rows that have been cleared
 */
public HashSet<Integer> getLinesCleared() {
  HashSet<Integer> clearedRows = new HashSet();

  Position[] piecePositions = currentPiece.getPositions();
  for (Position position : piecePositions) {
    if (position.row < 0) continue;

    //checks if any row the piece is occupying is filled
    boolean cleared = true;
    for (int j = 0; j < 10; j++) {
      if (!gameBoard[position.row][j].isLocked()) {
        cleared = false;
        break;
      }
    }
    if (cleared) {
      clearedRows.add(position.row);
    }
  }
  return clearedRows;
}

/**
 * Checks if a piece has spawned on top of the stack
 */
public boolean checkTopOut() {
  Position[] piecePositions = currentPiece.getPositions();
  for (Position position : piecePositions) {
    if (gameBoard[position.row][position.col].isLocked()) {
      println("Game Over: topped out");
      return true;
    }
  }
  return false;
}

/**
 * Checks if the game has ended according to the rules of the game mode
 */
public boolean checkGameEnd() {
  if (ultraMode) {
    //gameTime is measured in frames,
    return gameTime / 60.0 >= ULTRA_TIME;
  } else if (sprintMode) {
    return totalLines >= SPRINT_LINES;
  }
  return false;
}

/**
 * Ends the game by drawing the game over menu
 */
public void gameOver() {
  if (toppedOut) {
    if (animationTimer == 0) {
      delay(200);
    }
    if (animationTimer <= 25) {
      stroke(0);
      gameOverAnimation();

      animationTimer++;
      delay(30);
      return;
    }
  }

  gameOverMenu.disp(mouseX, mouseY);
  fill(255);
  if (endlessMode) {
    if (score > endlessHighScore) {
      endlessHighScore = score;
      outlineText("New High Score: " + score, MENU_BTN_LEFT+MENU_BTN_WIDTH/2, MENU_BTN_TOP);
    }
  } else if (ultraMode) {
    if (score > ultraHighScore) {
      ultraHighScore = score;
      outlineText("New High Score: " + score, MENU_BTN_LEFT+MENU_BTN_WIDTH/2, MENU_BTN_TOP);
    }
  } else if (sprintMode) {
    if (totalLines >= SPRINT_LINES) {
      if (gameTime <= sprintBestTime || sprintBestTime <= 0) {
        sprintBestTime = gameTime;
        outlineText("New Best Time: " + gameTime/60, MENU_BTN_LEFT+MENU_BTN_WIDTH/2, MENU_BTN_TOP);
      }
    }
  }
}

/**
 * Locks in the current piece where it is
 */
public void lockCurrentPiece() {
  Position[] piecePositions = currentPiece.getPositions();
  for (Position position : piecePositions) {
    if (position.row < 0) continue;
    gameBoard[position.row][position.col].setColor(currentPiece.getColor());
    gameBoard[position.row][position.col].setOpacity(255);
    gameBoard[position.row][position.col].lock();
  }
}

/**
 * Decreases the opacity of the current piece
 */
public void decreasePieceOpacity() {
  this.currentPiece.setOpacity(currentPiece.getOpacity() - 5);
}

/**
 * Resets the opacity of the current piece
 */
public void resetPieceOpacity() {
  this.currentPiece.setOpacity(255);
}

/**
 * Switches the current piece with the hold piece
 * If the hold piece is empty, generates a new piece instead
 */
public void holdPiece() {
  if (!held) {
    Piece tempHoldPiece = holdPiece;
    holdPiece = new Piece(currentPiece.getPieceType());
    if (tempHoldPiece == null) {
      currentPiece = nextPieceBag.poll();
    } else {
      currentPiece =  new Piece(tempHoldPiece.getPieceType());
    }
    lockTimer = 0;
    held = true;
  }
}

//Drawing methods to draw elements of the game

/**
 * Draws everything in the game
 */
public void drawGame() {
  this.drawGameField();
  this.drawGhostPiece();
  this.drawCurrentPiece();
  this.drawStack();

  this.drawHoldPiece();
  this.drawNextPiece();
  this.drawScores();
}

/**
 * Draws the pause menu with all the pause buttons
 */
public void drawScores() {
  textAlign(LEFT);
  textFont(font, scoreFontSize);

  rect(SCORE_BOX_LEFT, SCORE_BOX_TOP, SCORE_BOX_WIDTH, SCORE_BOX_HEIGHT);
  fill(0);
  text("Score: ", SCORE_BOX_LEFT+5, SCORE_BOX_TOP+scoreFontSize);
  text(score, SCORE_BOX_LEFT+5, SCORE_BOX_TOP+2*scoreFontSize);

  if (ultraMode || endlessMode) {
    text("High Score: ", SCORE_BOX_LEFT + 5, SCORE_BOX_TOP + 4 * scoreFontSize);
    if (endlessMode) {
      text("Time: " + gameTime / 60, SCORE_BOX_LEFT+5, SCORE_BOX_TOP+3*scoreFontSize);
      text(endlessHighScore, SCORE_BOX_LEFT+5, SCORE_BOX_TOP+5*scoreFontSize);
    } else {
      text("Time: " + (ULTRA_TIME - gameTime / 60), SCORE_BOX_LEFT+5, SCORE_BOX_TOP+3*scoreFontSize);
      text(ultraHighScore, SCORE_BOX_LEFT+5, SCORE_BOX_TOP+5*scoreFontSize);
    }
    text("Level: " + level, SCORE_BOX_LEFT+5, SCORE_BOX_TOP+6*scoreFontSize);
  } else if (sprintMode) {
    text("Time: " + gameTime / 60, SCORE_BOX_LEFT+5, SCORE_BOX_TOP+3*scoreFontSize);
    if (sprintBestTime > 0) {
      text("Best Time: ", SCORE_BOX_LEFT + 5, SCORE_BOX_TOP + 4 * scoreFontSize);
      text(sprintBestTime/60, SCORE_BOX_LEFT+5, SCORE_BOX_TOP+5*scoreFontSize);
    }
    text("Lines Left: ", SCORE_BOX_LEFT+5, SCORE_BOX_TOP+6*scoreFontSize);
    text((SPRINT_LINES - totalLines), SCORE_BOX_LEFT+5, SCORE_BOX_TOP+7*scoreFontSize);
  }
}

/**
 * Draws the background of the game field
 */
public void drawGameField() {
  fill(FIELD_COLOUR);
  rect(BOARD_LEFT, 0, FIELD_WIDTH, HEIGHT);
  strokeWeight((float)2);
  stroke(255);
  for (int i = 0; i <= ROWS; i++) {
    line(BOARD_LEFT, i * SIZE, BOARD_LEFT +FIELD_WIDTH, i*SIZE);
  }
  for (int j = 0; j <= COLS; j++) {
    line(BOARD_LEFT+j * SIZE, 0, BOARD_LEFT+j*SIZE, HEIGHT);
  }

  noFill();
  stroke(0);
  rect(BOARD_LEFT, 0, FIELD_WIDTH, HEIGHT);
}

/**
 * Draws all the blocks in the stack
 */
public void drawStack() {
  for (int i = 0; i < gameBoard.length; i++) {
    for (int j = 0; j < gameBoard[i].length; j++) {
      Block block = gameBoard[i][j];
      if (block.isLocked()) {
        float left = j * SIZE + BOARD_LEFT;
        block.disp(left, i * SIZE, SIZE);
      }
    }
  }
}

/**
 * Draws the upcoming pieces and its box
 */
public void drawNextPiece() {
  fill(0);
  textAlign(CENTER);
  textFont(font, btnFontSize);
  text("Next", NEXT_LEFT+NEXT_WIDTH/2, NEXT_TOP-HOLD_HEIGHT/4);

  noFill();
  rect(NEXT_LEFT, NEXT_TOP, NEXT_WIDTH, NEXT_HEIGHT);
  if (nextPieceBag.isEmpty()) return;

  int count = 0;
  for (Piece nPiece : nextPieceBag) {
    if (count >= visibleNextQueueSize) break;
    int colour = nPiece.getColor();
    Position[] positions = nPiece.getInitialPositions();

    for (Position position : positions) {
      int col = position.col - 3;
      float topGap = SIZE/2 + count*3*SIZE;
      float leftGap = SIZE/2;
      if (nPiece.getPieceType().equals("i")) {
        topGap = SIZE + count*3*SIZE;
        leftGap = 0;
      } else if (nPiece.getPieceType().equals("o")) {
        leftGap = 0;
      }
      float left = col * SIZE + NEXT_LEFT + leftGap;
      float top = position.row * SIZE + NEXT_TOP + topGap;

      nextBlocks[position.row+3*count][col].setColor(colour);
      nextBlocks[position.row+3*count][col].disp(left, top, SIZE);
    }
    count++;
  }
}

/**
 * Draws the current hold piece and its box
 */
public void drawHoldPiece() {
  fill(0);
  textAlign(CENTER);
  textFont(font, btnFontSize);
  text("Hold", HOLD_LEFT+HOLD_WIDTH/2, HOLD_TOP-HOLD_HEIGHT/4);

  noFill();
  rect(HOLD_LEFT, HOLD_TOP, HOLD_WIDTH, HOLD_HEIGHT);

  if (holdPiece == null) return;

  int colour = holdPiece.getColor();
  Position[] positions = holdPiece.getInitialPositions();

  for (Position position : positions) {
    int col = position.col - 3;
    float topGap = SIZE/2;
    float leftGap = SIZE/2;
    if (holdPiece.getPieceType().equals("i")) {
      topGap = SIZE;
      leftGap = 0;
    } else if (holdPiece.getPieceType().equals("o")) {
      leftGap = 0;
    }
    float left = col * SIZE + HOLD_LEFT + leftGap;
    float top = position.row * SIZE + HOLD_TOP + topGap;

    holdBlocks[position.row][col].setColor(colour);
    holdBlocks[position.row][col].disp(left, top, SIZE);
  }
}

/**
 * Draws the current piece at its position
 */
public void drawCurrentPiece() {
  if (currentPiece == null) return;
  Position[] piecePositions = currentPiece.getPositions();
  for (Position position : piecePositions) {
    if (position.row < 0) {
      continue;
    }
    int lastColor = gameBoard[position.row][position.col].getColor();

    float left = position.col * SIZE + BOARD_LEFT;

    gameBoard[position.row][position.col].setColor(currentPiece.getColor());
    gameBoard[position.row][position.col].setOpacity(currentPiece.getOpacity());
    gameBoard[position.row][position.col].disp(left, position.row * SIZE, SIZE);
    gameBoard[position.row][position.col].setColor(lastColor);
    gameBoard[position.row][position.col].setOpacity(255);
  }
}

/**
 * Draws the ghost piece below the current piece
 */
public void drawGhostPiece() {
  if (currentPiece == null) return;

  Piece ghostPiece = currentPiece.createGhost(gameBoard);

  Position[] piecePositions = ghostPiece.getPositions();
  for (Position position : piecePositions) {
    if (position.row < 0) {
      continue;
    }
    int lastColor = gameBoard[position.row][position.col].getColor();

    float left = position.col * SIZE + BOARD_LEFT;

    gameBoard[position.row][position.col].setColor(ghostPiece.getColor());
    gameBoard[position.row][position.col].disp(left, position.row * SIZE, SIZE);
    gameBoard[position.row][position.col].setColor(lastColor);
  }
}

/**
 * Detects key presses
 */
public void keyPressed() {
  if (!gameOver) {
    if (key == 'p' || key == 'P') {
      if (!paused) {
        this.pauseGame();
      } else {
        this.resumeGame();
      }
    } else if (key == 'r' || key == 'R') {
      this.reset();
    }
  }
  if (running) {
    if (key == CODED) {
      if (keyCode == UP) {
        rotateClockwise = true;
      } else if (keyCode == DOWN) {
        softDropping = true;
      } else if (keyCode == RIGHT) {
        movingRight = true;
      } else if (keyCode == LEFT) {
        movingLeft = true;
      } else if (keyCode == SHIFT) {
        holdPiece();
      }
    } else if (key == 'z' || key == 'Z') {
      rotateCounterClockwise = true;
    } else if (key == ' ') {
      currentPiece.hardDrop(gameBoard, particles);
      lockTimer = maxLockTime - 1;
    } else if (key == 'c') {
      holdPiece();
    }
  }
}

/**
 * Detects key releases
 */
public void keyReleased() {
  if (running) {
    if (key == CODED) {
      if (keyCode == UP) {
        rotateClockwise = false;
        rotatedClockwise = false;
        //currentPiece.rotateClockwise(gameBoard);
      } else if (keyCode == RIGHT) {
        dasCharge = 0;
        movingRight = false;
      } else if (keyCode == LEFT) {
        dasCharge = 0;
        movingLeft = false;
      } else if (keyCode == DOWN) {
        softDropping = false;
      }
    } else if (key == 'z' || key == 'Z') {
      rotateCounterClockwise = false;
      rotatedCounterClockwise = false;
    }
  }
}

/**
 * Detects mouse presses
 */
public void mousePressed() {
  if (running) {
    if (pauseBtn.over) {
      //pause button
      this.pauseGame();
    }
  } else if (paused) {
    //pause menu buttons
    Map<String, Button> pauseBtnMap = pauseMenu.getButtons();
    if (pauseBtnMap.get("Resume").over) {
      this.resumeGame();
    } else if (pauseBtnMap.get("Restart").over) {
      this.reset();
    } else if (pauseBtnMap.get("Quit").over) {
      this.quitToStart();
    }
  } else if (start) {
    //start menu buttons
    Map<String, Button> startBtnMap = startMenu.getButtons();
    if (startBtnMap.get("Endless").over) {
      endlessMode = true;
      sprintMode = false;
      ultraMode = false;
      reset();
    } else if (startBtnMap.get("Sprint").over) {
      endlessMode = false;
      sprintMode = true;
      ultraMode = false;
      reset();
    } else if (startBtnMap.get("Ultra").over) {
      endlessMode = false;
      sprintMode = false;
      ultraMode = true;
      reset();
    }
  } else if (gameOver) {
    //game over menu buttons
    Map<String, Button> gameOverBtnMap = gameOverMenu.getButtons();
    if (gameOverBtnMap.get("Restart").over) {
      this.reset();
    } else if (gameOverBtnMap.get("Quit").over) {
      this.quitToStart();
    }
  }
}
