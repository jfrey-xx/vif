/* //<>//

 Create entities out of text. Dumb class at the moment.
 **/

import java.util.ArrayList; 
import processing.core.*;

class textParser {
  // WIP: awful way to get various results
  static int nbText = 0;
  static int nbType = 0;
  static int nbTrigger = 0;
  static int nbAction = 0;

  // return string content of chunks
  public static String[] getChunksText(String src) {
    String[] texts;
    switch (nbText) {
    case 0:
      texts = new String[] {"one", "second", " et un et deux", "nst nstnstnst aw "};
      break;
    case 1:
      texts = new String[] {"new kind", " of string", " it's top"};
      break;
    default:
      texts = new String[] {"over"};
      break;
    }
    nbText++;
    return texts;
  }

  public static textType[] getChunksType(String scr) {
    textType[] types;
    switch (nbType) {
    case 0:
      types = new textType[] {textType.REGULAR, textType.BEAT, textType.EMPHASIS, textType.SHAKE};
      break;
    case 1:
      types = new textType[] {textType.EMPHASIS, textType.REGULAR, textType.SHAKE};
      break;
    default:
      types = new textType[] {textType.REGULAR};
      break;
    }
    nbType++;
    return types;
  }

  public static textTrigger[] getChunksTrigger(String scr, textPicking pick) {
    ArrayList<textTrigger> triggers = new ArrayList();

    switch (nbTrigger) {
    case 0:
      triggers.add(pick.getNewPicker());
      triggers.add(pick.getNewPicker());
      triggers.add(pick.getNewPicker());
      triggers.add(pick.getNewPicker());
      break;
    case 1:
      triggers.add(null);
      triggers.add(pick.getNewPicker());
      triggers.add(null);
      break;
    default:
      triggers.add(null);
      break;
    }
    nbTrigger++;

    // workaround for cast
    textTrigger[] trig = new textTrigger[triggers.size()];
    triggers.toArray(trig);

    return trig;
  }

  public static textAction[] getChunksAction(String scr, String areaID) {
    ArrayList<textAction> actions = new ArrayList();

    switch (nbAction) {
    case 0:
      actions.add(null);
      actions.add(new textTAGoto(areaID, "toto"));
      actions.add(null);
      actions.add(null);
      break;
    case 1:
      actions.add(null);
      actions.add(new textTAGoto(areaID, "a1"));
      actions.add(null);
      break;
    default:
      actions.add(null);
      break;
    }
    nbAction++;

    // workaround for cast
    textAction[] act = new textAction[actions.size()];
    actions.toArray(act);

    return act;
  }

  public static textAreaData[] getAreasData(String src) {
    ArrayList<textAreaData> datas = new ArrayList();

    textAreaData data;

    data = new textAreaData();
    data.size = new PVector (40, 30);
    data.position = new PVector (0, 0, -5);
    data.id = "a1";
    data.atStart = true;
    datas.add(data);

    data = new textAreaData();
    data.size = new PVector (40, 30);
    data.position = new PVector (-100, 0, 50);
    data.id = "a2";
    data.atStart = true;
    datas.add(data);
    
    data = new textAreaData();
    data.size = new PVector (40, 30);
    data.position = new PVector (-100, 100, 50);
    data.id = "toto";
    datas.add(data);
    

    // workaround for cast
    textAreaData[] dat = new textAreaData[datas.size()];
    datas.toArray(dat);

    return dat;
  }
}

// holder for data associated to text areas
class textAreaData {
  PVector size;
  PVector position;
  String id = "none";
  String content = "";
  boolean atStart = false;
}