
/** 
 Hold one sequence of text, handles multiple lines
 
 groups -> chunk of text -> words
 */

import processing.core.*;
import geomerative.*;
import java.util.ArrayList;

class textHolder {
  private PApplet parent;
  // where we will draw into
  private PGraphics pg;

  // actual font size in pixel and correspondce ratio for real-world unit
  private int fontSize;
  private float worldRatio;
  textRenderer txtrdr;

  final String SEPARATOR = " ";

  private RFont font;
  private float fontLineHeight;
  private float fontLineSpacing; // will be height of one char * 1.25
  private float fontWordSpacing;

  // main holder
  private RGroup group;
  // logical groups
  private ArrayList<textChunk> chunks;

  // width limit, will wrap if go beyond
  // NB: inner variable in pixels
  private float maxWidth = -1;

  // hacky flag for spamming stdout
  public boolean debug = false;

  textHolder(PApplet parent, PGraphics pg, String fontFile, int fontSize) {
    this(parent, pg, fontFile, fontSize, 1);
  }

  // fontSize: in pixels the higher
  // worldRatio: world unit to pixels ratio. Eg. use fontSize 100 and worldRatio 0.01 for good-looking 1 meter font size
  textHolder(PApplet parent, PGraphics pg, String fontFile, int fontSize, float worldRatio) {
    this.parent = parent;
    this.pg = pg;
    this.fontSize = fontSize;
    this.worldRatio = worldRatio;

    txtrdr = new textRenderer(parent, pg, fontSize);

    font = new RFont(fontFile, fontSize, parent.LEFT); // left align by default

    // Height: takes on the tallest char (?)
    fontLineHeight = font.toGroup("(").getHeight();
    debugln("Font line height: " + fontLineHeight);
    // space between lines: height * 1.25
    fontLineSpacing = fontLineHeight * (float) 1.25;
    debugln("Font line spacing: " + fontLineSpacing);
    // cannot get just a space apparently..
    fontWordSpacing = font.toGroup("a w").getWidth() - font.toGroup("aw").getWidth();
    debugln("Font word spacing: " + fontWordSpacing);

    chunks = new ArrayList();
  }

  // set width boundaries (in world unit)
  public void setWidth(float maxWidth) {
    this.maxWidth = maxWidth/worldRatio;
    rebuildGroup();
  }

  public void addText(String newText) {
    addText(newText, textType.REGULAR);
  }

  // no trigger by default
  public void addText(String newText, textType type) {
    addText(newText, textType.REGULAR, null);
  }

  // append text to right
  // each call to this function create new group
  public void addText(String newText, textType type, textTrigger trig) {
    if (newText.length() < 1) {
      debugln("Empty new text, abort");
      return;
    } else {
      debugln("Adding [", newText, "] of type", type.toString(), "to the stack.");
    }

    chunks.add(new textChunk(txtrdr, newText, type, trig));
    // update inner state
    rebuildGroup();
  }

  // recomptue position, wrap to max width, split by words
  private void rebuildGroup() {
    debugln("Rebuilding groups...");
    group = new RGroup();
    // for positionning, need a temporary group by lines
    float curWidth = 0;
    float curHeight = 0;

    // for transition between chunk
    textChunk prevChunk = null;

    for (textChunk chunk : chunks) {
      // going to recompute groups, clean before
      chunk.initGroups();
      String text = chunk.getText();
      // holder for each chunk of text
      RGroup textGroup = new RGroup();
      // fetch corresponding string
      debugln("Dealing with group:[", text, "]");


      // check if the group before ended with white space, retrieve last char if exists
      boolean newWord = false;
      String lastChar = "";
      if ( prevChunk != null &&  prevChunk.getText().length() > 0) {
        String lastString = prevChunk.getText();
        lastChar = prevChunk.getText().substring(prevChunk.getText().length() - 1);
        if (lastChar.equals(SEPARATOR)) {
          newWord = true;
        }
      }

      if (newWord) {
        debugln("Begin with new word");
      } else {
        debugln("Append to last");
      }

      String[] words = text.split(SEPARATOR);
      debugln("Nb words: " + words.length);

      for (int i=0; i < words.length; i++) {
        // one subgroup per word
        RGroup wGroup = font.toGroup(words[i]);

        debugln("Adding: [", words[i], "] -- size: " + words[i].length() + " -- width: " + wGroup.getWidth());

        // 0 char -- or group of size lesser than 0 to prevent bug -- means a separator, will just make sure that we have new word, nothing to append otherwise
        if (SEPARATOR.equals(words[i]) || wGroup.getWidth() < 0) {
          newWord = true;
          debugln("Skip separator");
          continue;
        }
        // since we split with separator, from second and up it's a new word
        if (i > 0) {
          newWord = true;
        }

        if (curWidth == 0 && curHeight == 0) {
          debugln("First word of line");
          // shift even firt line to have 0,0 at top left
          curHeight = fontLineHeight;
        } else if (
          // won't create a line unless there is a new word and at least something on current line
          newWord &&  curWidth>0  &&
          //  check if overflow
          curWidth + fontWordSpacing + wGroup.getWidth() > maxWidth
          ) {
          debugln("New line");
          curWidth = 0;
          curHeight += fontLineSpacing;
        } else {
          debugln("Append to curWidth: " + curWidth);
          if (newWord) {
            curWidth += fontWordSpacing;
          } else {
            // we obviously have something before, get the right spacing
            String firstChar = words[i].substring(0, 1);
            float fontCharSpacing = font.toGroup(lastChar + firstChar).getWidth() - font.toGroup(firstChar).getWidth() -  font.toGroup(lastChar).getWidth();
            debugln("Font char spacing between [", lastChar, "] / [", firstChar, "]:" + fontCharSpacing);
            curWidth += fontCharSpacing;
          }
        }

        wGroup.translate(curWidth, curHeight);
        curWidth+=wGroup.getWidth();
        chunk.addWord(wGroup, words[i]);
      }
      group.addGroup(chunk.getGroup());

      prevChunk = chunk;
    }
  }

  // bounding box
  public void drawDebug() {
    pg.pushMatrix();
    pg.scale(worldRatio);
    if (group.countElements() > 0) {
      pg.pushStyle();
      pg.strokeWeight(fontSize * worldRatio*2);
      pg.stroke(0);
      pg.noFill();
      pg.rect(group.getTopLeft().x, group.getTopLeft().y, group.getWidth(), group.getHeight());
      pg.popStyle();
    }

    // width limit
    if (maxWidth > 0) {
      pg.pushStyle();
      pg.strokeWeight(fontSize * worldRatio*2);
      pg.fill(255, 0, 0);
      pg.rect(0, 0, maxWidth, 2);
      pg.popStyle();
    }
    pg.popMatrix();
  }

  public void draw() {
    pg.pushMatrix();
    pg.scale(worldRatio);
    for (int i = 0; i < chunks.size (); i++) {
      chunks.get(i).draw();
    }
    pg.popMatrix();
  }

  // we don't want to *always* spam stdout
  private void debugln(String... mes) {
    if (debug) {
      parent.println(mes);
    }
  }
}