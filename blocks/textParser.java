/* //<>// //<>//
 
 Create entities out of an org-mode file parsed by pandoc (version 1.15.1)
 
 **/

import java.util.ArrayList; 
import processing.core.*;
import processing.data.*;

class textParser {

  // separator for trigger type/param/style
  final static String TRIGGER_SEPARATOR = "-";
  // separator for trigger params, i.e. eq-heart.3 (escape regular expression)
  final static String TRIGGER_PARAM_SEPARATOR = "\\.";
  // the look for link to next paragraph.
  final static String NEW_PAR_SYMBOL = "§§§"; // "|→"

  private PApplet parent;
  private ArrayList<textAreaData> areas;
  // those activated on start
  private ArrayList<String> startAreas;

  // fetch area data
  public textParser(PApplet parent, String file) {
    this.parent = parent;
    areas = new ArrayList();
    startAreas = new ArrayList();
    JSONArray values = parent.loadJSONArray(file);
    textAreaData dumb = new textAreaData(parent);
    // the great grand mother came by herself
    dumb.ancestor = dumb;
    areas.add(dumb);
    loadArray(values, dumb);
    // meta info should at least hold starting area
    processMeta();
    // process triggers / actions
    processTriggers();
    // set animations
    processAnimations();

    for (textAreaData area : areas) {
      parent.println(area);
    }
  }

  // lastArea: current area held in areas
  // return the current area in case has changed recursively
  textAreaData loadArray(JSONArray values, textAreaData lastArea) {
    textAreaData curArea = lastArea;

    for (int i = 0; i < values.size (); i++) {
      // try to fetch object
      JSONObject object = values.getJSONObject(i, null);
      if (object != null) {
        // test if header info
        try {
          loadObjectMeta(object.getJSONObject("unMeta"));
        }
        catch (Exception e) {
          // no meta, usual stuff
          curArea = loadObject(object, curArea);
        }
      } 
      // then may be array
      else {
        JSONArray array = values.getJSONArray(i, null);
        if (array != null) {
          loadArray(array, lastArea);
        } 
        // it is a string then
        else {
          String val = "";
          try {
            val = values.getString(i);
          }
          catch (Exception e) {
            // ok, not really a string
            parent.println("nothing??");
          }
          // could be a link residue
          // println("Got string ?? [", val, "]");
        }
      }
    }
    return curArea;
  }

  // process meta info
  // eg: #+ACTIVATE: target area
  // TODO: handle several targets
  void loadObjectMeta(JSONObject meta) {
    // which area to activate on start
    try {
      JSONObject activate = meta.getJSONObject("activate");
      JSONArray content = activate.getJSONArray("c");

      String startArea = "";

      for (int i = 0; i < content.size (); i++) {
        JSONObject object = content.getJSONObject(i);
        String type = object.getString("t", "");
        if (type.equals("Str")) {
          startArea += object.getString("c", "");
        } else if (type.equals("Space")) {
          startArea += " ";
        }
      }

      parent.println("Starting area:", startArea);
      startAreas.add(startArea);
    }
    catch (Exception e) {
      parent.println("Error: did not found meta info for activation");
    }
  }

  // structure is like [["",["tag"],[["data-tag-name","@north"]]],[]]
  String parseTag(JSONArray array) {
    return array.getJSONArray(0).getJSONArray(2).getJSONArray(0).getString(1);
  }

  // create new area, parse the array content
  textAreaData loadObjectArea(JSONObject object, textAreaData lastArea) {
    textAreaData newArea; 
    JSONArray content = object.getJSONArray("c");
    int level = content.getInt(0);
    newArea = lastArea.getHeir(level-1);
    // ID is in array of 3rd element
    JSONArray contentID = content.getJSONArray(2);
    String id = "";
    for (int i = 0; i < contentID.size (); i++) {
      JSONObject objectID = contentID.getJSONObject(i);
      String type = objectID.getString("t", "");
      if (type.equals("Str")) {
        id += objectID.getString("c", "");
      } else if (type.equals("Space")) {
        id += " ";
      } else if (type.equals("Span")) {
        // holder for a tag
        String tag = parseTag(objectID.getJSONArray("c"));
        // first char of tag set type, eg @direction or #style
        char tagType = tag.charAt(0);
        String tagContent = tag.substring(1);
        if (tag.charAt(0) == '#') {
          newArea.setStyle(tagContent);
        } else if (tagType == '@') {
          newArea.setPosition(tagContent);
        } else if (tagType == '%') {
          newArea.setSize(tagContent);
        } else {
          parent.println("Cannot process tag:", tag);
        }
      } else {
        parent.print("Unsupported format for header:", type);
      }
    }
    newArea.setID(id);
    return newArea;
  }

  // call correct methods depending on objects
  // return the current area -- changes if new header or new paragraph occurs
  textAreaData loadObject(JSONObject object, textAreaData lastArea) {   
    textAreaData curArea = lastArea; 
    String type = object.getString("t", "");
    JSONArray contentArray;
    String contentString;
    if (type.equals("Header")) {
      curArea = loadObjectArea(object, curArea );
      areas.add(curArea);
    } else if (type.equals("Space")) {
      lastArea.addContent(" ");
    } 
    // create a new textarea if already had content
    else if (type.equals("Para")) {

      if (curArea.hasContent()) {
        // creating new area
        textAreaData newArea = curArea.getNewPar();
        // adding link to previous
        curArea.newChunk(textType.LINK);
        // create by hand a "pick" button
        curArea.addContent("pick:goto-" + newArea.getId() + ": " + textParser.NEW_PAR_SYMBOL);
        // switching to new
        areas.add(newArea);
        curArea = newArea;
      }

      curArea.newChunk(textType.REGULAR);
      // a paragraph is an array of text element
      contentArray = object.getJSONArray("c");
      curArea = loadArray(contentArray, curArea);
    } else if (type.equals("Emph")) {
      // new chunk
      curArea.newChunk(textType.EMPHASIS);
      contentArray = object.getJSONArray("c");
      curArea = loadArray(contentArray, curArea);
      curArea.newChunk(textType.REGULAR);
    } else if (type.equals("Strong")) {
      curArea.newChunk(textType.STRONG);
      contentArray = object.getJSONArray("c");
      curArea  = loadArray(contentArray, curArea);
      curArea.newChunk(textType.REGULAR);
    } else if (type.equals("Link")) {
      curArea.newChunk(textType.LINK);
      contentArray = object.getJSONArray("c");
      curArea = loadArray(contentArray, curArea);
      curArea.newChunk(textType.REGULAR);
    } else if (type.equals("Str")) {
      contentString = object.getString("c");
      curArea.addContent(contentString);
    } else if (type.equals("")) {
      // no type, likely first header
    } else {
      parent.println("Header:", curArea.toString());
      parent.println("Unsupported:", type);
    }
    return curArea;
  }

  void processMeta() {
    boolean gotStart = false;
    // set activation flag
    for (textAreaData area : areas) {
      for (String target : startAreas) {
        if (area.getId().equals(target)) {
          area.atStart = true;
          gotStart = true;
        }
      }
    }

    // TODO exception
    if (!gotStart) {
      parent.println("Error: no area set for start");
    }
  }

  // run through areas, convert link type to triggers / actions
  void processTriggers() {
    for (textAreaData area : areas) {
      // TODO: exception instead of log
      if (area.content.size() != area.types.size()) {
        parent.println("Error, content/type mismatch for header: ", area);
        continue;
      }
      for (int i = 0; i < area.content.size (); i++) {
        switch(area.types.get(i)) {
        case LINK:
          // colon as separator
          String[] link = area.content.get(i).split(":");
          if (link.length < 2 || link.length > 3) {
            parent.println("Error, bad link:", area.content.get(i));
            continue;
          }
          area.triggers.add(link[0]);
          area.actions.add(link[1]);
          // adds nothing to text if only here for trigger
          if (link.length > 2) {
            area.content.set(i, link[2]);
          } else {
            area.content.set(i, "");
          }
          break;
        default:
          area.triggers.add("");
          area.actions.add("");
          break;
        }
      }
    }
  }

  // split and return type trig
  static String getTriggerType(String trig) {
    // trigger format: type, [parameter, animation]
    String[] split = trig.split(TRIGGER_SEPARATOR);
    return split[0];
  }

  // split and return param trig
  // (null if nothing)
  static String getTriggerParam(String trig) {
    // trigger format: type, [parameter, animation]
    String[] split = trig.split(TRIGGER_SEPARATOR);
    if (split.length < 2) {
      return null;
    }
    return split[1];
  }

  // split and return style trig (will be type if no given)
  static String getTriggerStyle(String trig) {
    // trigger format: type, [parameter, animation]
    String[] split = trig.split(TRIGGER_SEPARATOR);
    if (split.length > 2) {
      return split[2];
    } 
    return split[0];
  }

  // split and return type action
  static String getActionType(String action) {
    // action format: type, parameter
    // "-" is also separator for actions options
    String[] split = action.split(TRIGGER_SEPARATOR);
    return split[0];
  }

  // split and return param action
  // return null if finds nothing
  static String getActionParam(String action) {
    String[] split = action.split(TRIGGER_SEPARATOR);
    if (split.length < 2) {
      return null;
    }
    return split[1];
  }

  // match trigger style with animation
  // FIXME: kind of duplication with getChunksTrigger, quick'n dirty, use enum string for auto match
  void processAnimations() {
    for (textAreaData area : areas) {
      for (String trig : area.triggers) {
        String trigStyle = getTriggerStyle(trig);
        // default for trig
        if (trigStyle.equals("pick")) {
          area.anim.add(textAnim.SHADOW);
        } else if (trigStyle.equals("heartstyle")) {
          area.anim.add(textAnim.HEART);
        } else {
          area.anim.add(textAnim.NONE);
        }
      }
    }
  }

  // get an array copy of textAreaData
  public textAreaData[] getAreasData() {
    textAreaData[] dat = new textAreaData[areas.size()];
    areas.toArray(dat);
    return dat;
  }
}

// holder for data associated to text areas
class textAreaData {
  PApplet parent;

  PVector size;
  // do not hold PVector since could vary upon init
  private textPosition position;
  boolean atStart = false;

  ArrayList <String> content;
  ArrayList <textType> types;
  // triggers (i.e "links") and associated actions / animations
  ArrayList <String> triggers;
  ArrayList <String> actions;
  ArrayList <textAnim> anim;
  int level = 0;
  private String id = "noID";
  // new paragraphs create other areas
  private String mainID = "noID";
  private int parNumber = 0;
  String style = "noStyle";
  textAreaData ancestor = null;

  // so as not to create new paragraph if no text truely added
  boolean hasContent = false;

  textAreaData(PApplet parent) {
    this.parent = parent;
    content = new ArrayList();
    types = new ArrayList();
    triggers = new ArrayList();
    actions = new ArrayList();
    anim = new ArrayList();

    // put a default size and position just to avoid null pointer
    size = textSize.MEDIUM.getSize();
    position = textPosition.NORTH;
  }

  public textAreaData getNewPar() {
    textAreaData clone = new textAreaData(parent);
    clone.ancestor = this.ancestor;
    clone.level = level;
    clone.position = position;
    clone.size = new PVector (size.x, size.y);
    clone.style = style;
    clone.parNumber = parNumber + 1;
    clone.mainID = mainID;
    clone.id = mainID + "_" + Integer.toString(clone.parNumber);
    return clone;
  }

  // inheritate from this instance
  public textAreaData getHeir() {
    textAreaData clone = new textAreaData(parent);
    clone.ancestor = this;
    clone.level = level+1;
    clone.position = position;
    clone.size = new PVector (size.x, size.y);
    clone.style = style;
    return clone;
  }

  // inheritate from a specific level
  public textAreaData getHeir(int level) {
    if (level == this.level) {
      return getHeir();
    }
    return ancestor.getHeir(level);
  }

  // sensitive data, protect it against external modification
  public String getId() {
    return id;
  }

  public void addContent(String str) {
    // WARNING: this content may be a temporary link that'll be modified later, so do not 
    if (!str.equals("")) {
      hasContent = true;
    }
    String curContent =  content.get(content.size() - 1);
    curContent += str;
    content.set(content.size() - 1, curContent);
  }

  public boolean hasContent() {
    return hasContent;
  }

  // create new chunk of text
  public void newChunk(textType type) {
    content.add("");
    types.add(type);
  }

  public void setID(String id) {
    this.mainID = id;
    this.id = id;
  }

  // convert string code to actual position
  public void setPosition(String position) {
    textPosition pos = textPosition.fromString(position);
    if (pos == null) {
      parent.println("Error, no position for keyword:", position);
    } else {
      this.position = pos;
    }
  }

  public textPosition getPosition() {
    return position;
  }

  public void setSize(String size) {
    textSize siz = textSize.fromString(size);
    if (siz == null) {
      parent.println("Error, no size for keyword:", size);
    } else {
      this.size = siz.getSize();
    }
  }

  public void setStyle(String style) {
    this.style = style;
  }

  public String toString() {
    return "Header " + level + " ID: [" + id + "] -- position: [" + position + "] -- size: [" + 
      size + "] -- type: [" + style + "] -- content: {" + content + "}" + " -- types: {" + 
      types + "} -- triggers: {" + triggers + "} actions: {" + actions + "} -- anim: {" + anim + "}";
  }

  //// giving to textArea

  // return string content of chunks
  public String[] getChunksText() {
    String[] dat = new String[content.size()];
    content.toArray(dat);
    return dat;
  }

  public textType[] getChunksType() {
    textType[] dat = new textType[types.size()];
    types.toArray(dat);
    return dat;
  }

  public textAnim[] getChunksAnim() {
    textAnim[] dat = new textAnim[anim.size()];
    anim.toArray(dat);
    return dat;
  }

  // convert triggers coded with strings to actual triggers
  public textTrigger[] getChunksTrigger(textPicking pick) {
    ArrayList<textTrigger> tTriggers = new ArrayList();

    for (int i = 0; i < triggers.size (); i++) {
      String triggerType = textParser.getTriggerType(triggers.get(i));
      if (triggerType.equals("pick")) {
        tTriggers.add(pick.getNewPicker());
      } else if (triggerType.equals("visible")) {
        tTriggers.add(pick.getNewVisible(true));
      } else if (triggerType.equals("invisible")) {
        tTriggers.add(pick.getNewVisible(false));
      } else if (triggerType.equals("bind")) {
        // WIP: bind as pick for debug
        tTriggers.add(pick.getNewPicker());
      } else if (triggerType.equals("eq")) {
        tTriggers.add(new textTrigEq(parent, textParser.getTriggerParam(triggers.get(i))));
      } else if (triggerType.equals("timer")) {
        tTriggers.add(new textTrigTimer(parent, textParser.getTriggerParam(triggers.get(i))));
      } else if (triggerType.equals("")) {
        // no trigger associated to current chunk
        tTriggers.add(null);
      } else {
        parent.println("Trigger not supported:", triggerType);
        tTriggers.add(null);
      }
    }

    // workaround for cast
    textTrigger[] trig = new textTrigger[tTriggers.size()];
    tTriggers.toArray(trig);

    return trig;
  }

  // convert actions coded with strings to actual actions
  public textAction[] getChunksAction(String areaID) {
    ArrayList<textAction> tActions = new ArrayList();

    for (int i = 0; i < actions.size (); i++) {
      // first substrings codes
      String actionType = textParser.getActionType(actions.get(i));
      String actionParam = textParser.getActionParam(actions.get(i)); 
      if (actionType.equals ("goto")) {
        if (actionParam == null) {
          parent.println("Bad format for GOTO action:", actions.get(i));
          tActions.add(null);
          continue;
        }
        tActions.add(new textTAGoto(areaID, actionParam));
      } else if (actionType.equals("inc")) {
        if (actionParam == null) {
          parent.println("Bad format for INC action:", actions.get(i));
          tActions.add(null);
          continue;
        }
        // will increment said value
        tActions.add(new textTAInc(actionParam));
      } else if (actionType.equals("")) {
        // no action associated to current chunk
        tActions.add(null);
      } else {
        parent.println("Action not supported: [", actionType, "] from", actions.get(i));
        tActions.add(null);
      }
    }

    // workaround for cast
    textAction[] act = new textAction[tActions.size()];
    tActions.toArray(act);
    return act;
  }

  public textStyle getStyle() {
    textStyle tStyle =  textStyle.fromString(style);
    if (tStyle == null) {
      parent.println("Warning: cannot find style corresponding to [" + style + "].");
    }
    return tStyle;
  }
}