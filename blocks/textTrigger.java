/**
 
 Handles events / actions
 
 */

import processing.core.*;

abstract class textTrigger {

  protected PApplet parent;
  // optionnal action
  private textTriggerAction action;

  // how long for selection (ms). Immediate action if 0 or less
  private int selectionDelay = 0;

  // flag for pick and timer (in ms) since picked
  private boolean picked = false;
  int startPicked = -1;
  int timePicked = -1;

  textTrigger(PApplet parent) {
    this.parent = parent;
  }

  protected final void setDelay(int selectionDelay) {
    this.selectionDelay = selectionDelay;
  }

  public final void setAction(textTriggerAction action) {
    this.action = action;
  }

  // wrapper for update, compute timer, trigger action if needed
  final void draw() {
    picked = update();
    // reset timer if nothing
    if (!picked) {
      startPicked = -1;
      timePicked = -1;
    } 
    // start or update timer otherwise
    else { 
      if ( timePicked < 0) {
        startPicked = parent.millis();
        timePicked = 0;
      } else {
        timePicked = parent.millis() - startPicked;
      }
    }
  }

  // should compute and return current trigger
  abstract protected boolean update();

  // to be overriden for picking, by default does nothing
  void setBoundaries(float topLeftX, float topLeftY, float bottomRightX, float bottomRightY) {
    return;
  }

  // if currently picked
  public final boolean isPicked() {
    return picked;
  }

  // -1: not picked
  // between 0 and 1: ratio before timesUp
  public final float pickedRatio() {
    if (!isPicked()) {
      return -1;
    }
    if (timePicked >= selectionDelay || selectionDelay <= 0) {
      return 1;
    }
    return ( (float)timePicked / selectionDelay);
  }
}

// what will be done
class textTriggerAction {
}