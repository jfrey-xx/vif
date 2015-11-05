/**
 
 Testing parsing of org-mode files from emacs json export.
 
 */

import java.util.*;

class areaData implements Cloneable {
  String content = "";
  int level = 0;
  String position = "noPosition";
  String style = "noStyle";

  public areaData clone() {
    areaData clone = new areaData();
    clone.content = content;
    clone.level = level;
    clone.position = position;
    clone.style = style;
    return clone;
  }
}

// fith file, iterate over first raw
void loadData(String file) {

  ArrayList<areaData> areas = new ArrayList();

  JSONArray values = loadJSONArray(file);
  println("values:", values.size());

  areaData dumb = new areaData();

  areas.addAll(loadArray(values, dumb));
}

// lastArea: parent area to create some kind of inheritance
ArrayList<areaData> loadArray(JSONArray values, areaData lastArea) {
  areaData newArea = lastArea.clone();
  newArea.level += 1;
  // 1 heading, get object
  // 2 heading, get id
  int nextStep = 0;
  ArrayList<areaData> areas = new ArrayList();

  for (int i = 0; i <  newArea.level; i++) {
    print(newArea.level);
  }

  print(" values:", values.size(), " -- ");

  for (int i = 0; i < values.size(); i++) {
    // try to fetch object
    JSONObject object = values.getJSONObject(i, null);
    if (object != null) {
      switch(nextStep) {
      case 1:
        println("got heading params");
        nextStep = 2;
        break;
      default:
        println("object");
        break;
      }
    } 
    // then may be array
    else {
      JSONArray array = values.getJSONArray(i, null);
      if (array != null) {
        println("array");
        areas.addAll(loadArray(array, newArea));
      } 
      // it is a string then
      else {
        String val = "";
        try {
          val = values.getString(i);
        }
        catch (Exception e) {
          // ok, not really a string
          //println("nothing");
        }
        switch(nextStep) {
        case 1:
          println("wrong!");
          nextStep = 0;
          break;
        case 2:
          println("heading title:", val);
          nextStep = 0;
          break;
        default:
          if (val.equals("headline")) {
            println("Heading!");
            nextStep = 1;
          }
          break;
        }
      }
    }
  }

  return areas;
}

void setup() {
  size(800, 600);
  loadData("data.json");
  /*int id = animal.getInt("id");
   String species = animal.getString("species");
   String name = animal.getString("name");
   println(id + ", " + species + ", " + name);*/
}

void draw() {
}