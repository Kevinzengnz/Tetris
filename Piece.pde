/* Code for Tetris
 * By Kevin Zeng
 */

import processing.core.PApplet;

import java.util.*;

/**
 *  Class for a piece
 *  Each piece can be one of seven different ones
 */

class Piece {

  private final int GHOST_COLOUR = color(100); //colour of the ghost piece
  private String pieceType; //can be either i,j,l,o,s,z,t
  private int timer = 0;
  private int colour;
  private int opacity = 255;

  //describes which way the piece is oriented - 0 is default, 1 is 90 degrees clockwise
  //2 is 180 degrees around the default, and 3 is 90 degrees counterclockwise
  private int orientation = 0;

  private Position[] positions = new Position[4];

  //Offset data for J,L,S,T,Z pieces - see here https://tetris.wiki/Super_Rotation_System
  private final List<Position[]> offsetData =
    new ArrayList(Arrays.asList(
    new Position[]{new Position(0, 0), new Position(0, 0), new Position(0, 0), new Position(0, 0), new Position(0, 0)},
    new Position[]{new Position(0, 0), new Position(0, 1), new Position(1, 1), new Position(-2, 0), new Position(-2, 1)},
    new Position[]{new Position(0, 0), new Position(0, 0), new Position(0, 0), new Position(0, 0), new Position(0, 0)},
    new Position[]{new Position(0, 0), new Position(0, -1), new Position(1, -1), new Position(-2, 0), new Position(-2, -1)}));

  //Offset data for the I piece
  private final List<Position[]> offsetDataI =
    new ArrayList(Arrays.asList(
    new Position[]{new Position(0, 0), new Position(0, -1), new Position(0, 2), new Position(0, -1), new Position(0, 2)},
    new Position[]{new Position(0, -1), new Position(0, 0), new Position(0, 0), new Position(-1, 0), new Position(2, 0)},
    new Position[]{new Position(-1, -1), new Position(-1, 1), new Position(-1, -2), new Position(0, 1), new Position(0, -2)},
    new Position[]{new Position(-1, 0), new Position(-1, 0), new Position(-1, 0), new Position(1, 0), new Position(-2, 0)}));

  private final Position[] initialPositions;

  private final Position[] iStart = {new Position(0, 3),
    new Position(0, 4),
    new Position(0, 5),
    new Position(0, 6)};
  private final Position[] jStart = {new Position(0, 3),
    new Position(1, 4), //center block
    new Position(1, 3),
    new Position(1, 5)};
  private final Position[] lStart = {new Position(1, 3),
    new Position(1, 4), //center block
    new Position(1, 5),
    new Position(0, 5)};
  private final Position[] oStart = {new Position(0, 4),
    new Position(0, 5),
    new Position(1, 4),
    new Position(1, 5)};
  private final Position[] tStart = {new Position(1, 3),
    new Position(1, 4), //center block
    new Position(0, 4),
    new Position(1, 5)};
  private final Position[] sStart = {new Position(1, 3),
    new Position(1, 4),
    new Position(0, 4),
    new Position(0, 5)};
  private final Position[] zStart = {new Position(0, 3),
    new Position(1, 4),
    new Position(0, 4),
    new Position(1, 5)};

  /**
   * Constructor
   */
  public Piece(String type) {
    switch(type) {
    case "i":
      this.pieceType = type;
      this.colour = color(0, 255, 255);
      positions = iStart;
      break;
    case "j":
      this.pieceType = type;
      this.colour = color(0, 0, 255);
      positions = jStart;
      break;
    case "l":
      this.pieceType = type;
      this.colour = color(255, 127, 0);
      positions = lStart;
      break;
    case "o":
      this.pieceType = type;
      this.colour = color(255, 255, 0);
      positions = oStart;
      break;
    case "t":
      this.pieceType = type;
      this.colour = color(200, 0, 255);
      positions = tStart;
      break;
    case "s":
      this.pieceType = type;
      this.colour = color(0, 255, 0);
      positions = sStart;
      break;
    case "z":
      this.pieceType = type;
      this.colour = color(255, 0, 0);
      positions = zStart;
      break;
    }

    this.initialPositions = positions;
  }

  /**
   * Returns the positions of each block of this piece
   */
  public Position[] getPositions() {
    return positions;
  }

  /**
   * Returns the initial positions of each block of this piece
   */
  public Position[] getInitialPositions() {
    return initialPositions;
  }

  /**
   * Returns the colour of this piece
   */
  public int getColor() {
    return this.colour;
  }

  /**
   * Returns the piece type
   */
  public String getPieceType() {
    return this.pieceType;
  }

  /**
   * Sets the opacity of this block
   * @param o opacity to change to
   */
  public void setOpacity(int o) {
    this.opacity = o;
  }

  /**
   * Gets the opacity of this block
   * @return block opacity
   */
  public int getOpacity() {
    return opacity;
  }

  /**
   * Returns the timer ie how long the piece has existed
   */
  public int getTimer() {
    return timer++;
  }

  /**
   * Increases the timer by 1
   */
  public void incrementTimer() {
    timer++;
  }

  /**
   * Moves this piece left one space if there is room
   */
  public void moveLeft(Block[][] currentBoard) {
    Position[] newPositions = new Position[4];
    for (int i = 0; i < 4; i++) {
      if (positions[i].col - 1 >= 0 && !checkLeftSide(currentBoard)) {
        newPositions[i] = new Position(positions[i].row, positions[i].col - 1);
      } else {
        return;
      }
    }
    positions = newPositions;
  }

  /**
   * Moves this piece right one space if there is room
   */
  public void moveRight(Block[][] currentBoard) {
    Position[] newPositions = new Position[4];
    for (int i = 0; i < 4; i++) {
      if (positions[i].col + 1 < Tetris.COLS && !checkRightSide(currentBoard)) {
        newPositions[i] = new Position(positions[i].row, positions[i].col + 1);
      } else {
        return;
      }
    }
    positions = newPositions;
  }

  /**
   * Moves this piece down one space if there is room
   */
  public void moveDown(Block[][] currentBoard) {
    Position[] newPositions = new Position[4];
    for (int i = 0; i < 4; i++) {
      if (!checkIfAtBottom() && !checkIfOnStack(currentBoard)) {
        newPositions[i] = new Position(positions[i].row+1, positions[i].col);
      } else {
        return;
      }
    }
    positions = newPositions;
  }

  /**
   * Instantly moves this piece as low as it can go
   */
  public void hardDrop(Block[][] currentBoard, ArrayList<Particle> particles) {
    while (!checkIfAtBottom() && !checkIfOnStack(currentBoard)) {
      moveDown(currentBoard);
    }
    if (particles != null) {
      //spawns three particles below this piece
      for (Position pos : positions) {
        if (pos.checkIfAtBottom() || pos.checkIfOnStack(currentBoard)) {
          particles.add(new Particle(Tetris.BOARD_LEFT + Tetris.SIZE * pos.col,
            Tetris.SIZE * (pos.row+1), -1, 1));
          particles.add(new Particle(Tetris.BOARD_LEFT + Tetris.SIZE * (float)(pos.col+0.5),
            Tetris.SIZE * (pos.row+1), 0, 1));
          particles.add(new Particle(Tetris.BOARD_LEFT + Tetris.SIZE * (pos.col+1),
            Tetris.SIZE * (pos.row+1), 1, 1));
        }
      }
    }
  }

  /**
   * Returns true if this piece is at the bottom of the board
   */
  public boolean checkIfAtBottom() {
    for (int i = 0; i < 4; i++) {
      if (positions[i].row + 1 >= Tetris.ROWS) {
        return true;
      }
    }
    return false;
  }

  /**
   * Returns true if there is a block below this piece
   */
  public boolean checkIfOnStack(Block[][] currentBoard) {
    for (int i = 0; i < 4; i++) {
      if (positions[i].row < 0) continue;
      if (currentBoard[positions[i].row + 1][positions[i].col].isLocked()) {
        return true;
      }
    }
    return false;
  }

  /**
   * Returns true if there is a block on the right side of this piece
   */
  public boolean checkRightSide(Block[][] currentBoard) {
    for (int i = 0; i < 4; i++) {
      if (positions[i].col + 1>= Tetris.COLS || positions[i].row < 0) continue;

      if (currentBoard[positions[i].row ][positions[i].col+1].isLocked()) {
        return true;
      }
    }
    return false;
  }

  /**
   * Returns true if there is a block on the left side of this piece
   */
  public boolean checkLeftSide(Block[][] currentBoard) {
    for (int i = 0; i < 4; i++) {
      if (positions[i].col-1 < 0 || positions[i].row < 0) continue;
      if (currentBoard[positions[i].row][positions[i].col-1].isLocked()) {
        return true;
      }
    }
    return false;
  }

  /**
   * Rotates the piece clockwise 90 degrees
   * @param currentBoard the state of the current board
   */
  public void rotateClockwise(Block[][] currentBoard) {
    if (!pieceType.equals("o")) {
      int newOrientation = orientation + 1;
      if (newOrientation > 3) newOrientation = 0;

      Position[] newPositions = new Position[4];

      Position centerPos = this.positions[1]; //pivot

      //gets the rotated positions of the piece
      for (int i = 0; i < 4; i++) {
        newPositions[i] = new Position(positions[i].row - centerPos.row, positions[i].col - centerPos.col);
        newPositions[i] = new Position(newPositions[i].col, -newPositions[i].row);
        newPositions[i] = new Position(newPositions[i].row + centerPos.row, newPositions[i].col + centerPos.col);
      }
      Position[] kickedPositions = testPositions(currentBoard, newPositions, newOrientation);
      if (kickedPositions == null) {
        return; //no kicked position found
      } else {
        newPositions = kickedPositions;
      }
      positions = newPositions;
      orientation = newOrientation;
    }
  }

  /**
   * Rotates the piece anti-clockwise 90 degrees
   * @param currentBoard the state of the current board
   */
  public void rotateCounterClockwise(Block[][] currentBoard) {
    if (!pieceType.equals("o")) {
      int newOrientation = orientation - 1;
      if (newOrientation < 0) newOrientation = 3;

      Position[] newPositions = new Position[4];

      Position centerPos = this.positions[1]; //pivot

      for (int i = 0; i < 4; i++) {
        newPositions[i] = new Position(positions[i].row - centerPos.row, positions[i].col - centerPos.col);
        newPositions[i] = new Position(-newPositions[i].col, newPositions[i].row);
        newPositions[i] = new Position(newPositions[i].row + centerPos.row, newPositions[i].col + centerPos.col);
      }
      Position[] kickedPositions = testPositions(currentBoard, newPositions, newOrientation);
      if (kickedPositions == null) {
        return; //no kicked position found
      } else {
        newPositions = kickedPositions;
      }

      positions = newPositions;
      orientation = newOrientation;
    }
  }

  /**
   * Tests 5 different positions around the current piece to find a valid one. If none are found, then returns null
   * Offset data found here https://tetris.wiki/Super_Rotation_System
   * @param currentBoard the state of the current board
   * @param newPositions positions before trying the kick
   * @return a new set of positions that has been kicked
   */
  private Position[] testPositions(Block[][] currentBoard, Position[] newPositions, int newOrientation) {
    List<Position[]> offsets = offsetData;
    if (pieceType.equals("i")) {
      offsets = offsetDataI;
    }

    for (int i = 0; i < 5; i++) {
      Position offset = new Position(offsets.get(orientation)[i].row - offsets.get(newOrientation)[i].row,
        offsets.get(orientation)[i].col - offsets.get(newOrientation)[i].col);

      Position[] kickedPositions = new Position[4];
      boolean valid = true;
      for (int ii = 0; ii < 4; ii++) {
        kickedPositions[ii] = new Position(newPositions[ii].row + offset.row, newPositions[ii].col + offset.col);
        if (!kickedPositions[ii].checkValidPosition(currentBoard)) {
          valid = false;
          break;
        }
      }
      if (valid) {
        return kickedPositions;
      }
    }
    return null;
  }

  /**
   * Returns a 'ghost piece', ie a piece that is in the same position as this piece, but dropped to the bottom,
   * and colored lightly
   * @param currentBoard state of the current board
   * @return a ghost piece with same orientation, hard dropped
   */
  public Piece createGhost(Block[][] currentBoard) {
    Piece ghost = new Piece(this.pieceType);
    ghost.positions = this.positions;
    ghost.colour = GHOST_COLOUR;
    ghost.hardDrop(currentBoard, null);
    return ghost;
  }
}
