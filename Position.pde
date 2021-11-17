/* Code for Tetris
 * By Kevin Zeng
 */

class Position {

  /**
   * Fields containing a row and a column
   */
  public final int row;
  public final int col;

  /**
   * Constructor
   */
  Position (int row, int col) {
    this.row = row;
    this.col = col;
  }

  public String toString() {
    return "Row: " + this.row + ", Col: " + this.col;
  }


  /**
   * Returns true if this position is at the bottom of the board
   */
  public boolean checkIfAtBottom() {
    if (row + 1 >= Tetris.ROWS) {
      return true;
    }
    return false;
  }

  /**
   * Returns true if there is a block below this position
   */
  public boolean checkIfOnStack(Block[][] currentBoard) {
    if (row < 0) return false;
    if (currentBoard[row + 1][col].isLocked()) {
      return true;
    }
    return false;
  }

  /**
   * Returns true if the position is a valid one inside the play field(or above) 
   * and also isn't occupied already
   */
  public boolean checkValidPosition(Block[][] currentBoard) {
    if (row >= Tetris.ROWS
      || col >= Tetris.COLS || col < 0) {
      return false;
    }
    if (row < 0) {
      return true;
    } else return !currentBoard[row][col].isLocked();
  }
}
