
/** 
 Hold one sequence of text, handles multiple lines
 
 groups -> chunk of text -> words
 */

import geomerative.*;

import java.util.Arrays;

class textHolder {

  final String SEPARATOR = " ";

  private RFont font;
  private int fontSize;
  private float fontLineHeight;
  private float fontLineSpacing; // will be height of one char * 1.25
  private float fontWordSpacing;

  // main holder
  private RGroup group;
  // logical groups
  private ArrayList<RGroup> groups;
  private ArrayList<String> texts;
  private ArrayList<textType> types;

  // width limit, will wrap if go beyond
  private float maxWidth = -1;

  textHolder(String fontFile, int fontSize) {
    this.fontSize = fontSize;
    font = new RFont(fontFile, fontSize, LEFT); // left align by default

    // Height: takes on the tallest char (?)
    fontLineHeight = font.toGroup("(").getHeight();
    println("Font line height: ", fontLineHeight);
    // space between lines: height * 1.25
    fontLineSpacing =fontLineHeight * 1.25;
    println("Font line spacing: ", fontLineSpacing);
    // cannot get just a space apparently..
    fontWordSpacing = font.toGroup("a w").getWidth() - font.toGroup("aw").getWidth();
    println("Font word spacing: ", fontWordSpacing);

    texts = new ArrayList();
    types = new ArrayList();
  }

  public void setWidth(float maxWidth) {
    this.maxWidth = maxWidth;
    rebuildGroup();
  }

  public void addText(String newText) {
    addText(newText, textType.REGULAR);
  }
  // append text to right
  // each call to this function create new group
  public void addText(String newText, textType type) {
    if (newText.length() < 1) {
      println("Empty new text, abort");
      return;
    } else {
      println("Adding [", newText, "] of type", type.toString(), "to the stack.");
    }

    // append to previous
    texts.add(newText);
    types.add(type);
    // update inner state
    rebuildGroup();
  }

  // recomptue position, wrap to max width, split by words
  private void rebuildGroup() {
    println("Rebuilding groups...");
    groups = new ArrayList();
    group = new RGroup();
    // for positionning, need a temporary group by lines
    float curWidth = 0;
    float curHeight = 0;

    int n = 0;
    for (String text : texts) {
      // holder for each chunk of text
      RGroup textGroup = new RGroup();
      // fetch corresponding string
      println("Dealing with group ", n, ":[", text, "]");


      // check if the group before ended with white space, retrieve last char if exists
      boolean newWord = false;
      String lastChar = "";
      if (n > 0 && texts.get(n-1).length() > 0) {
        String lastString = texts.get(n-1);
        lastChar = texts.get(n-1).substring(texts.get(n-1).length() - 1);
        if (lastChar.equals(SEPARATOR)) {
          newWord = true;
        }
      }

      if (newWord) {
        println("Begin with new word");
      } else {
        println("Append to last");
      }

      String[] words = text.split(SEPARATOR);
      println("Nb words: ", words.length);

      for (int i=0; i < words.length; i++) {
        // one subgroup per word
        RGroup wGroup = font.toGroup(words[i]);

        println("Adding: [", words[i], "] -- size: ", words[i].length(), " -- width: ", wGroup.getWidth());

        // 0 char -- or group of size lesser than 0 to prevent bug -- means a separator, will just make sure that we have new word, nothing to append otherwise
        if (SEPARATOR.equals(words[i]) || wGroup.getWidth() < 0) {
          newWord = true;
          println("Skip separator");
          continue;
        }
        // since we split with separator, from second and up it's a new word
        if (i > 0) {
          newWord = true;
        }

        if (curWidth == 0 && curHeight == 0) {
          println("First word of line");
          // shift even firt line to have 0,0 at top left
          curHeight = fontLineHeight;
        } else if (
          // won't create a line unless there is a new word and at least something on current line
          newWord &&  curWidth>0  &&
          //  check if overflow
          curWidth + fontWordSpacing + wGroup.getWidth() > maxWidth
          ) {
          println("New line");
          curWidth = 0;
          curHeight += fontLineSpacing;
        } else {
          println("Append to curWidth: ", curWidth);
          if (newWord) {
            curWidth += fontWordSpacing;
          } else {
            // we obviously have something before, get the right spacing
            String firstChar = words[i].substring(0, 1);
            float fontCharSpacing = font.toGroup(lastChar + firstChar).getWidth() - font.toGroup(firstChar).getWidth() -  font.toGroup(lastChar).getWidth();
            println("Font char spacing between [", lastChar , "] / [", firstChar, "]:", fontCharSpacing);
            curWidth += fontCharSpacing;
          }
        }

        wGroup.translate(curWidth, curHeight);
        curWidth+=wGroup.getWidth();

        textGroup.addGroup(wGroup);
      }

      groups.add(textGroup);
      group.addGroup(textGroup);

      n++;
    }
  }

  // bounding box
  public void drawDebug() {
    if (group.countElements() > 0) {
      pushStyle();
      stroke(0);
      noFill();
      rect(group.getTopLeft().x, group.getTopLeft().y, group.getWidth(), group.getHeight());
      popStyle();
    }

    // width limit
    if (maxWidth > 0) {
      pushStyle();
      fill(255, 0, 0);
      rect(0, 0, maxWidth, 2);
      popStyle();
    }
  }

  public void draw() {
    for (int i = 0; i < groups.size(); i++) {
      textDraw(groups.get(i), types.get(i));
    }
  }
}