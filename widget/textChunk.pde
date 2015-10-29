
/**
 
 Holds one type of text
 */

import geomerative.*;

class textChunk {
  // main holder
  public RGroup group;
  // sub words to split interaction
  public ArrayList<textWord> words;
  private textRenderer txtrdr;
  private textType type;
  // warning, actual text in group may differ -- textHolder discard whitespaces
  private String text;

  textChunk(textRenderer txtrdr, String text, textType type) {
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
    if (group != null) {
      txtrdr.textDraw(group, type);
    }
  }
}