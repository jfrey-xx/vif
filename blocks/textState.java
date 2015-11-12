/**
 
 Hold current variables / associations / corpus
 
 Static methods so that different universes could share values.
 
 All vars are integers, init automatically to 0.
 
 */

import java.util.*;

class textState {
  // holds reference to all variables
  static Map <String, Integer> vars = new LinkedHashMap<String, Integer>();
  // currently active areas
  //Map <String, textArea> vars;
  // set var to 0 and add to map if not already there
  static private void initVar(String var) {
    synchronized (vars) {
      if (!vars.containsKey(var)) {
        vars.put(var, 0);
      }
    }
  }

  // set to 0
  static void resetVar(String var) {
    synchronized (vars) {
      initVar(var);
      vars.put(var, 0);
    }
  }

  // incremente variable by 1
  static void incVar(String var) {
    synchronized (vars) {
      initVar(var);
      vars.put(var, vars.get(var) + 1);
    }
  }

  // decremente variable by 1
  static void decVar(String var) {
    synchronized (vars) {
      initVar(var);
      vars.put(var, vars.get(var) - 1);
    }
  }

  // getter
  static int getValue(String var) {
    synchronized (vars) {
      initVar(var);
      return vars.get(var);
    }
  }
}