/**
 
 Hold current variables / associations / corpus
 
 Static methods so that different universes could share values.
 
 All vars are integers, init automatically to 0.
 
 TODO: implement other protocol for streaming, let user choose.
 
 */

import java.util.*;

class textState {
  // holds reference to all variables
  static Map <String, Integer> vars = new LinkedHashMap<String, Integer>();
  // also for streams
  static Map <String, textStream> streams = new LinkedHashMap<String, textStream>();


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

  /** Streaming **/

  // bind to new stream if manage to, or will attemps to use fallback based on stream type
  static private void initStream(String stream) {
    synchronized (streams) {
      if (!streams.containsKey(stream)) {
        streams.put(stream, new textStreamLSL(stream));
      }
    }
  }

  static float getStreamValue(String stream) {
    synchronized (streams) {
      initStream(stream);
      return streams.get(stream).getValue();
    }
  }
}