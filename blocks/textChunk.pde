
/**
 
 Holds one type of text
 */

import geomerative.*;
import java.util.Arrays;
import remixlab.proscene.*;
import java.util.ArrayList;

class textChunk {
  // renderer and scene are created outside
  private textRenderer txtrdr;
  private Scene scene;
  // main holder
  public RGroup group;
  // sub words to split interaction
  public ArrayList<textWord> words;
  textType type;
  // warning, actual text in group may differ -- textHolder discard whitespaces
  private String text;
  private textTrigger trig;

  textChunk(textRenderer txtrdr, String text, textType type) {
    this(txtrdr, text, type, null);
  }

  textChunk(textRenderer txtrdr, String text, textType type, textTrigger trig) {
    this.txtrdr = txtrdr;
    this.text = text;
    this.type = type;
    this.trig = trig;
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
    if (trig != null) {
      trig.setBoundaries(group.getTopLeft().x, group.getTopLeft().y, group.getBottomRight().x, group.getBottomRight().y);
    }
  }

  public String getText() {
    return text;
  }

  public void draw() {
    if (group != null) {
      txtrdr.textDraw(this);
    }
  }

  // for textRenderer
  // FIXME: better archi
  public float pickedRatio() {
    if (trig != null) {
      return trig.pickedRatio();
    } else {
      return -1;
    }
  }
}