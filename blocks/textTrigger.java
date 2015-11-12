/**
 
 Handles events / actions
 
 */

import processing.core.*;

abstract class textTrigger {

  protected PApplet parent;
  // optionnal action
  textAction action;

  // how long for selection (ms). Immediate action if 0 or less
  private int selectionDelay = 0;

  // flag for pick and timer (in ms) since picked
  private boolean picked = false;
  int startPicked = -1;
  int timePicked = -1;

  // in activity upon further notice
  private boolean active = true;

  textTrigger(PApplet parent) {
    this.parent = parent;
  }

  protected final void setDelay(int selectionDelay) {
    this.selectionDelay = selectionDelay;
  }

  public final void setAction(textAction action) {
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

  public final boolean isActive() {
    return active;
  }

  // should be called by universe upon de-registsration
  public final void disable() {
    active = false;
  }
}

// what will be done
abstract class textAction {
  // the actual action, give access to the whole universe (simplicity > safety)
  abstract void fire(textUniverse universe);
  // raised when finished
  abstract boolean done();
}

class textTAGoto extends textAction {
  // ID of textArea source and target
  private String src;
  private String target;
  private boolean done = false;

  textTAGoto(String src, String target) {
    this.src = src;
    this.target = target;
  }

  void fire(textUniverse universe) {
    universe.parent.println("fire!");
    universe.disableArea(src);
    universe.enableArea(target);
    done = true;
  }

  boolean done() {
    return done;
  }
}

// incremente variable
class textTAInc extends textAction {
  private String var;
  private boolean done = false;

  textTAInc(String var) {
    this.var = var;
  }

  void fire(textUniverse universe) {
    textState.incVar(var);
    universe.parent.println("increments:", textState.getValue(var));
    done = true;
  }

  boolean done() {
    return done;
  }
}