/*

 Create entities out of text. Dumb class at the moment.
 **/

/*
    holder.addText("one");
 holder.addText("second", textType.BEAT);
 holder.addText(" et un et deux", textType.EMPHASIS);
 holder.addText("nst nstnstnst aw ", textType.SHAKE);
 */

class textParser {
  // WIP: awful way to get various results
  static int nbText = 0;
  static int nbType = 0;

  // return string content of chunks
  public static String[] getChunksText(String src) {
    String[] texts;
    switch (nbText) {
    case 0:
      texts = new String[] {"one", "second", " et un et deux", "nst nstnstnst aw "};
      break;
    case 1:
      texts = new String[] {"new kind", " of string", " it's top"};
      break;
    default:
      texts = new String[] {"over"};
      break;
    }
    nbText++;
    return texts;
  }

  public static textType[] getChunksType(String scr) {
    textType[] types;
    switch (nbType) {
    case 0:
      types = new textType[] {textType.REGULAR, textType.BEAT, textType.EMPHASIS, textType.SHAKE};
      break;
    case 1:
      types = new textType[] {textType.EMPHASIS, textType.REGULAR, textType.SHAKE};
      break;
    default:
      types = new textType[] {textType.REGULAR};
      break;
    }
    nbType++;
    return types;
  }
}