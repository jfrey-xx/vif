/* //<>//
 
 Create entities out of an org-mode file parsed by pandoc (version 1.15.1)
 
 **/

import java.util.ArrayList; 
import processing.core.*;
import processing.data.*;

class textParser {

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
  void loadArray(JSONArray values, textAreaData lastArea) {

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
          lastArea = loadObject(object, lastArea);
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
  // return the current area -- changes if new header occurs
  textAreaData loadObject(JSONObject object, textAreaData lastArea) {   
    textAreaData curArea = lastArea; 
    String type = object.getString("t", "");
    JSONArray contentArray;
    String contentString;
    if (type.equals("Header")) {
      curArea = loadObjectArea(object, lastArea);
      areas.add(curArea);
    } else if (type.equals("Space")) {
      lastArea.addContent(" ");
    } else if (type.equals("Para")) {
      // a paragraph is an array of text element

      // TODO: new area
      lastArea.newChunk(textType.REGULAR);
      // a white space separator between paragraphs, waiting for line return
      lastArea.addContent(" ");
      contentArray = object.getJSONArray("c");
      loadArray(contentArray, lastArea);
    } else if (type.equals("Emph")) {
      // new chunk
      lastArea.newChunk(textType.EMPHASIS);
      contentArray = object.getJSONArray("c");
      loadArray(contentArray, lastArea);
      lastArea.newChunk(textType.REGULAR);
    } else if (type.equals("Strong")) {
      lastArea.newChunk(textType.STRONG);
      contentArray = object.getJSONArray("c");
      loadArray(contentArray, lastArea);
      lastArea.newChunk(textType.REGULAR);
    } else if (type.equals("Link")) {
      lastArea.newChunk(textType.LINK);
      contentArray = object.getJSONArray("c");
      loadArray(contentArray, lastArea);
      lastArea.newChunk(textType.REGULAR);
    } else if (type.equals("Str")) {
      contentString = object.getString("c");
      lastArea.addContent(contentString);
    } else if (type.equals("")) {
      // no type, likely first header
    } else {
      parent.println("Header:", lastArea.toString());
      parent.println("Unsupported:", type);
    }
    return curArea;
  }

  void processMeta() {
    boolean gotStart = false;
    // set activation flag
    for (textAreaData area : areas) {
      for (String target : startAreas) {
        if (area.id.equals(target)) {
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
          if (link.length != 3) {
            parent.println("Error, bad link:", area.content.get(i));
            continue;
          }
          area.triggers.add(link[0]);
          area.actions.add(link[1]);
          // replace content with actual text
          area.content.set(i, link[2]);
          break;
        default:
          area.triggers.add("");
          area.actions.add("");
          break;
        }
      }
    }
  }

  // 
  // FIXME: kind of duplication with getChunksTrigger, quick'n dirty, use enum string for auto match
  void processAnimations() {
    for (textAreaData area : areas) {
      for (String trig : area.triggers) {
        // trigger format: type, [parameter, animation]
        String[] split = trig.split("-");
        // default for trig
        if (split[0].equals("pick")) {
          area.anim.add(textAnim.SHADOW);
        } else if (split.length > 2 && split[2].equals("heartstyle")) {
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
  PVector position;
  boolean atStart = false;

  ArrayList <String> content;
  ArrayList <textType> types;
  // triggers (i.e "links") and associated actions / animations
  ArrayList <String> triggers;
  ArrayList <String> actions;
  ArrayList <textAnim> anim;
  int level = 0;
  String id = "noID";
  String style = "noStyle";
  textAreaData ancestor = null;

  textAreaData(PApplet parent) {
    this.parent = parent;
    content = new ArrayList();
    types = new ArrayList();
    triggers = new ArrayList();
    actions = new ArrayList();
    anim = new ArrayList();

    // put a default size and position just to avoid null pointer
    size = new PVector(10, 10);
    position = new PVector(0, 0, 0);
  }

  // inheritate from this instance
  public textAreaData getHeir() {
    textAreaData clone = new textAreaData(parent);
    clone.ancestor = this;
    clone.level = level+1;
    clone.position = new PVector(position.x, position.y, position.z);
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

  public void addContent(String str) {
    String curContent =  content.get(content.size() - 1);
    curContent += str;
    content.set(content.size() - 1, curContent);
  }

  // create new chunk of text
  public void newChunk(textType type) {
    content.add("");
    types.add(type);
  }

  public void setID(String id) {
    this.id = id;
  }

  // convert string code to actual position
  public void setPosition(String position) {
    textPosition pos = textPosition.fromString(position);
    if (pos == null) {
      parent.println("Error, no position for keyword:", position);
    } else {
      this.position = pos.getPosition();
    }
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
      String triggerType = triggers.get(i);
      if (triggerType.equals("pick")) {
        tTriggers.add(pick.getNewPicker());
      } else if (triggerType.equals("")) {
        // no trigger associated to current chunk
        tTriggers.add(null);
      } else {
        parent.println("Trigger not supported:", triggers.get(i));
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
      // "-" is separator for actions options
      String[] split = actions.get(i).split("-");
      // first substring is code
      String actionType = split[0];
      if (actionType.equals ("goto")) {
        if (split.length != 2) {
          parent.println("Bad format for GOTO action:", split);
          tActions.add(null);
          continue;
        }
        String targetID = split[1];
        tActions.add(new textTAGoto(areaID, targetID));
      } else if (actionType.equals("")) {
        // no action associated to current chunk
        tActions.add(null);
      } else {
        parent.println("Action not supported: [", split[0], "] from", actions.get(i));
        tActions.add(null);
      }
    }

    // workaround for cast
    textAction[] act = new textAction[tActions.size()];
    tActions.toArray(act);
    return act;
  }
}