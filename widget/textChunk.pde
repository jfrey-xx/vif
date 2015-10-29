
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

  // return overall group
  public RGroup getGroup() {
    return group;
  }

  // wold group given by textHolder, that computes group depending on wrapping
  // update interactive frame reference
  public void addWord(RGroup wGroup, String wText) {
    textWord word = new textWord(wGroup, wText);
    words.add(word);
    group.addGroup(wGroup);
    picker.setPosition(new PVector(group.getCenter().x, group.getCenter().y));
  }

  public String getText() {
    return text;
  }

  public void draw() {

    println(picker.getPosition());
    
    pushStyle();
    pushMatrix();
    translate(group.getCenter().x, group.getCenter().y, 1);
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