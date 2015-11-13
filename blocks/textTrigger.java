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
  // if has already fired since ratio >= 1
  private boolean waitingFire = true;

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
  void setBoundariesChunk(float topLeftX, float topLeftY, float bottomRightX, float bottomRightY) {
    return;
  }

  // to be overriden for visible, by default does nothing
  void setBoundariesArea(float topLeftX, float topLeftY, float bottomRightX, float bottomRightY) {
    return;
  }

  // if currently picked
  public final boolean isPicked() {
    return picked;
  }

  // -1: not picked
  // between 0 and 1: ratio before timesUp
  // update waitingFire flag -- once per "1" reached
  public final float pickedRatio() {
    if (!isPicked()) {
      waitingFire = true;
      return -1;
    }
    if (timePicked >= selectionDelay || selectionDelay <= 0) {
      return 1;
    }
    waitingFire = true;
    return ( (float)timePicked / selectionDelay);
  }

  // if this trigger should still be updated (may be disabled depending on action)
  public final boolean isActive() {
    return active;
  }

  // picked reached one and still no action taken. usefull to ensure that there is no two actions in a row
  // NB: state reset after each call
  public final boolean waitingFire() {
    if ((waitingFire) &&  pickedRatio() >=1) {
      waitingFire = false;
      return true;
    }
    return false;
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

// check if a value reaches a threshold
// NB: immediate fire
class textTrigEq extends textTrigger {
  private String var;
  private int value;
  // set to true in constructors if parameters ok
  private boolean init = false;

  textTrigEq(PApplet parent, String param) {
    super(parent);
    setDelay(0);

    String [] split = param.split(textParser.TRIGGER_PARAM_SEPARATOR);

    if (split.length != 2) {
      parent.println("Wrong parameter for eq trigger [" + param + "] of length", split.length);
    } else {
      var = split[0];
      value = Integer.parseInt(split[1]);
      parent.println("new eq with var", var, "and value", value);
      init = true;
    }
  }

  @Override
    protected boolean update() {
    return textState.getValue(var) == value;
  }
}

/****** Actions ******/

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
    universe.parent.println("go from [" + src + "] to [" + target + "]");
    universe.disableArea(src);
    universe.enableArea(target);
    done = true;
  }

  boolean done() {
    return done;
  }
}

// increments variable
class textTAInc extends textAction {
  private String var;

  textTAInc(String var) {
    this.var = var;
  }

  void fire(textUniverse universe) {
    textState.incVar(var);
    universe.parent.println("increments:", textState.getValue(var));
  }

  // can procude the effect several times
  boolean done() {
    return false;
  }
}