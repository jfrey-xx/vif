
/**
 
 Holds one type of text
 */

import geomerative.*;

class textChunk {
  // renderer and scene are created outside
  private textRenderer txtrdr;
  private Scene scene;
  private textPicker picker;
  // main holder
  public RGroup group;
  // sub words to split interaction
  public ArrayList<textWord> words;
  private textType type;
  // warning, actual text in group may differ -- textHolder discard whitespaces
  private String text;

  textChunk(textPicking pick, textRenderer txtrdr, String text, textType type) {
    this.picker = pick.getNewPicker();
    this.txtrdr = txtrdr;
    this.text = text;
    this.type = type;
    group = new RGroup();
    words = new ArrayList();
  }

  // textHolder compute group depending on wrapping
  public RGroup getGroup() {
    return group;
  }

  // textHolder compute group depending on wrapping
  public void addWord(RGroup wGroup, String wText) {
    textWord word = new textWord(wGroup, wText);
    words.add(word);
    group.addGroup(wGroup);
  }

  public String getText() {
    return text;
  }

  public void draw() {

    println(picker.getPosition());
    picker.update();

    pushStyle();
    pushMatrix();
    translate(0, 0, 1);
    if (picker.isPicked()) {
      fill(255, 0, 0);
      println("Gotya!");
    } else
      fill(0, 0, 255);
    rect(0, 0, 100, 100);
    popMatrix();
    popStyle();
    if (group != null) {
      txtrdr.textDraw(group, type);
    }
  }
}