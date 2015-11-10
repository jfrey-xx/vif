/**
 
 Testing parsing of org-mode files from emacs json export.
 
 */

import java.util.*;

class areaData implements Cloneable {
  ArrayList <String> content;
  ArrayList <String> types;
  int level = 0;
  String position = "noPosition";
  String style = "noStyle";
  areaData parent = null;
  
  areaData() {
    content = new ArrayList();
    types = new ArrayList();
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

  public String toString() {
    return "Header level " + level + "  -- content: {" + content + "}" + " -- types: {" + types + "}";
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
        println("Got string ?? [", val, "]");
      }
    }
  }
}

// create new area, parse the array content
areaData loadObjectArea(JSONObject object, areaData lastArea) {
  areaData newArea; 
  JSONArray content = object.getJSONArray("c");
  int level = content.getInt(0);
  newArea = lastArea.getHeir(level-1);
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



void setup() {
  size(800, 600);
  areas = new ArrayList();
  loadData("data.json");

for(areaData area : areas) {
  println(area);
}
   
   
}

void draw() {
}