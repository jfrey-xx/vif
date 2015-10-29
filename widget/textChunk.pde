
import geomerative.*;

class textChunk {
  public RGroup group;
  private textRenderer txtrdr;
  private textType type;
  // warning, actual text in group may differ -- textHolder discard whitespaces
  private String text;

  textChunk(textRenderer txtrdr, String text, textType type) {
    this.txtrdr = txtrdr;
    this.text = text;
    this.type = type;
  }

  // textHolder compute group depending on wrapping
  public void setGroup(RGroup group) {
    this.group = group;
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