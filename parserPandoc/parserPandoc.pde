/**
 
 Testing parsing of org-mode files from emacs json export.
 
 Not supported:
 
 - triggers (links) with style
 
 */

import java.util.*;

class areaData implements Cloneable {
  ArrayList <String> content;
  ArrayList <String> types;
  // triggers (i.e "links") and associated actions
  ArrayList <String> triggers;
  ArrayList <String> actions;
  int level = 0;
  String id = "noID";
  String position = "noPosition";
  String style = "noStyle";
  areaData parent = null;

  areaData() {
    content = new ArrayList();
    types = new ArrayList();
    triggers = new ArrayList();
    actions = new ArrayList();
  }

  // inheritate from this instance
  public areaData getHeir() {
    areaData clone = new areaData();
    clone.parent = this;
    clone.level = level+1;
    clone.position = position;
    clone.style = style;
    return clone;
  }

  // inheritate from a specific level
  public areaData getHeir(int level) {
    if (level == this.level) {
      return getHeir();
    }
    return parent.getHeir(level);
  }

  public void addContent(String str) {
    String curContent =  content.get(content.size() - 1);
    curContent += str;
    content.set(content.size() - 1, curContent);
  }

  // create new chunk of text
  public void newChunk(String type) {
    content.add("");
    types.add(type);
  }

  public void setID(String id) {
    this.id = id;
  }

  public void setPosition(String position) {
    this.position = position;
  }

  public void setStyle(String style) {
    this.style = style;
  }

  public String toString() {
    return "Header " + level + " ID: [" + id + "] -- position: [" + position + "] -- type: [" + style + "] -- content: {" + content + "}" + " -- types: {" + types + "} -- triggers: {" + triggers + "} actions: {" + actions + "}";
  }
}

ArrayList<areaData> areas;

// fith file, iterate over first raw
void loadData(String file) {

  JSONArray values = loadJSONArray(file);

  areaData dumb = new areaData();
  // the great grand mother came by herself
  dumb.parent = dumb;
  areas.add(dumb);
  loadArray(values, dumb);
  // process triggers / actions
  processTriggers();
}

// lastArea: current area held in areas
void loadArray(JSONArray values, areaData lastArea) {

  for (int i = 0; i < values.size(); i++) {
    // try to fetch object
    JSONObject object = values.getJSONObject(i, null);
    if (object != null) {
      lastArea = loadObject(object, lastArea);
    } 
    // then may be array
    else {
      JSONArray array = values.getJSONArray(i, null);
      if (array != null) {
        println("array");
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
          println("nothing??");
        }
        // could be a link residue
        // println("Got string ?? [", val, "]");
      }
    }
  }
}

// structure is like [["",["tag"],[["data-tag-name","@north"]]],[]]
String parseTag(JSONArray array) {
  return array.getJSONArray(0).getJSONArray(2).getJSONArray(0).getString(1);
}

// create new area, parse the array content
areaData loadObjectArea(JSONObject object, areaData lastArea) {
  areaData newArea; 
  JSONArray content = object.getJSONArray("c");
  int level = content.getInt(0);
  newArea = lastArea.getHeir(level-1);
  // ID is in array of 3rd element
  JSONArray contentID = content.getJSONArray(2);
  String id = "";
  for (int i = 0; i < contentID.size(); i++) {
    JSONObject objectID = contentID.getJSONObject(i);
    String type = objectID.getString("t", "");
    switch (type) {
    case "Str":
      id += objectID.getString("c", "");
      break;
    case "Space":
      id += " ";
      break;
      // holder for a tag
    case "Span":
      String tag = parseTag(objectID.getJSONArray("c"));
      // first char of tag set type, eg @direction or #style
      char tagType = tag.charAt(0);
      String tagContent = tag.substring(1);
      if (tag.charAt(0) == '#') {
        newArea.setStyle(tagContent);
      } else if (tagType == '@') {
        newArea.setPosition(tagContent);
      } else {
        println("Cannot process tag:", tag);
      }
      break;
    default:
      print("Unsupported format for header:", type);
    }
  }
  newArea.setID(id);
  return newArea;
}

// call correct methods depending on objects
// return the current area -- changes if new header occurs
areaData loadObject(JSONObject object, areaData lastArea) {
  areaData curArea = lastArea; 
  String type = object.getString("t", "");
  JSONArray contentArray;
  String contentString;
  switch(type) {
  case "Header":
    curArea = loadObjectArea(object, lastArea);
    areas.add(curArea);
    // TODO: grab title
    break;
  case "Space":
    lastArea.addContent(" ");
    break;
    // a paragraph is an array of text element
  case "Para":
    // TODO: new area
    lastArea.newChunk("regular");
    contentArray = object.getJSONArray("c");
    loadArray(contentArray, lastArea);
    break;
    // new chunk
  case "Emph":
    lastArea.newChunk("emph");
    contentArray = object.getJSONArray("c");
    loadArray(contentArray, lastArea);
    lastArea.newChunk("regular");
    break;
  case "Link":
    lastArea.newChunk("link");
    contentArray = object.getJSONArray("c");
    loadArray(contentArray, lastArea);
    lastArea.newChunk("regular");
    break;
  case "Str":
    contentString = object.getString("c");
    lastArea.addContent(contentString);
    break;
    // no type, likely first header

  case "":
    break;
  default:
    println("Header:", lastArea.toString());
    println("Unsupported:", type);
    break;
  }
  return curArea;
}

// run through areas, convert link type to triggers / actions
void processTriggers() {
  for (areaData area : areas) {
    // TODO: exception instead of log
    if (area.content.size() != area.types.size()) {
      println("Error, content/type mismatch for header: ", area);
      continue;
    }
    for (int i = 0; i < area.content.size();  i++) {
      switch(area.types.get(i)) {
      case "link":
        // colon as separator
        String[] link = area.content.get(i).split(":");
        if (link.length != 3) {
          println("Error, bad link:", area.content.get(i));
          continue;
        }
        area.triggers.add(link[0]);
        area.actions.add(link[1]);
        // replace content with actual text
        area.content.set(i,link[2]);
        break;
      default:
        area.triggers.add("");
        area.actions.add("");
        break;
      }
    }
  }
}

void setup() {
  size(800, 600);
  areas = new ArrayList();
  loadData("data.json");

  for (areaData area : areas) {
    println(area);
  }
}

void draw() {
}