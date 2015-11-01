
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
    initGroups();
  }

  // return overall group
  public RGroup getGroup() {
    return group;
  }

  // to be called if groups are recomputed by holder before addWord is called again
  public void initGroups() {
    group = new RGroup();
    words = new ArrayList();
  }

  // wold group given by textHolder, that computes group depending on wrapping
  // update interactive frame reference
  public void addWord(RGroup wGroup, String wText) {
    textWord word = new textWord(wGroup, wText);
    words.add(word);
    group.addGroup(wGroup);
    picker.setBoundaries( group.getTopLeft().x, group.getTopLeft().y, group.getBottomRight().x, group.getBottomRight().y);
  }

  public String getText() {
    return text;
  }

  public void draw() {
    picker.draw();
    if (group != null) {
      txtrdr.textDraw(this);
    }
  }

  // wrapers around picker
  public boolean isPicked() {
    return picker.isPicked();
  }

  public float pickedRatio() {
    return picker.pickedRatio();
  }
}

