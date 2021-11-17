/* Code for Tetris
 * By Kevin Zeng
 */

/**
 * Does the game over animation, where all the blocks fall and disappear beneath the screen
 */
private void gameOverAnimation() {
  drawGameField();
  for (int i = 0; i < gameBoard.length; i++) {
    for (int j = 0; j < gameBoard[i].length; j++) {
      Block block = gameBoard[i][j];
      if (block.isLocked()) {
        block.setRotation(block.getRotation() + PI/8);
        block.setOpacity(block.getOpacity() -20);
        float left = j * SIZE + BOARD_LEFT+SIZE/2;
        block.disp(left, i * SIZE + animationTimer*SIZE, SIZE);
      }
    }
  }
}

/**
 * Begins the animation of the lines being cleared
 */
private void beginLineClearAnimation() {
  for (int row : linesToClear) {
    for (int j = 0; j < gameBoard[row].length; j++) {
      Block block = gameBoard[row][j];
      block.setColor(255);
      currentPiece.setOpacity(0);
    }
  }
}

/**
 * Performs the animation of the lines being cleared
 */
private void lineClearAnimation() {
  for (int row : linesToClear) {
    for (int j = 0; j < gameBoard[row].length; j++) {
      Block block = gameBoard[row][animationTimer];
      block.unlock();
    }
  }
}

/**
* Draws text with a dark outline
*/
public void outlineText(String text, float x, float y) {
  pushMatrix();
  translate(x, y);

  fill(0);
  for (int i = -1; i < 2; i++) {
    text(text, i, 0);
    text(text, 0, i);
  }
  fill(255);
  text(text, 0, 0);

  popMatrix();
}
