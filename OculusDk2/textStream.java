/**
 
 Abstraction and implementation for data streamed from the outside
 
 WARNING: should get values between 0 and 1.
 
 Here will be defined fallback depending on stream types.
 
 NB: using System.out.println to avoid use of PApplet with static textState
 
 TODO:
 
 - stream could be resolved after disconnect, implement timeout before fallback
 - several users
 
 FIXME:
 
 - reachedSinceLastUpdate() and probably whole stream not working if the stream is read at several place at the same time (value fetched on-demand). should use at least framecount.
 - the fallback equivalent of reachedSinceLastUpdate() is just a threshold on value, also should use framecount and timestamp
 
 */

// for stream
import edu.ucsd.sccn.LSL;
// for fallback
import AULib.*;

// handling only one channel
// NB: streams will not be updated in the background, hence implementations should return last value in pipe
abstract class textStream {
  // stream type, will also determin fallback
  private String stream;

  // will we use fallback values or not?
  private boolean fallback;

  // fallback animation
  private textStreamFallback fallbackValue;

  // value considered as trigger for stream
  final protected float threshold = 1; 

  // trigger for fallback -- we dot not have history in here
  final protected float fallbackThreshold = (float)0.75; 

  // child class should call this constructor
  textStream(String stream) {
    this.stream = stream;

    fallbackValue = textStreamFallback.fromString(stream);
    if (fallbackValue == null) {
      System.out.println("Error: no fallback for stream of type " + stream + ", will be using default animation if needed.");
      fallbackValue = textStreamFallback.DEFAULT;
    }

    fallback = !init();
  }

  // should return true if stremm successfully resolved, false if we will use fallback
  abstract protected boolean init();

  // should return last value from stream
  abstract protected float fetchValue();

  // in case framerate goes down, need to make sure that we did not miss a threshold. Childs should have a way to know what happenned between calls.
  abstract protected boolean reachedSinceLastUpdate();

  // if stream reached a threshold value since last update
  final boolean reachedTreshold() {
    if (fallback) {
      return getValue() >= fallbackThreshold;
    }
    return reachedSinceLastUpdate();
  }

  // the stream encountered a probrem, child should call this method so that fallback takes it from here
  final void disableStream() {
    this.fallback = true;
  }

  final float getValue() {
    if (fallback) {
      return fallbackValue.fetchValue();
    }
    return fetchValue();
  }

  // one should know what we are after
  final protected String streamType() {
    return stream;
  }
}

// fallback implemented depending on stream type
enum textStreamFallback {

  // name, freq of singal, type of wave, wave parameter
  HEART("HEART", 1, AULib.WAVE_SYM_VAR_BLOB, 1), 
    BREATH("BREATH", (float) 0.3, AULib.WAVE_SYM_GAIN, (float) 0.2), 
    DEFAULT("DEFAULT", (float)0.5, AULib.WAVE_SYM_BLOB, 0);

  private String text;
  private float freq;
  private int waveType;
  private float waveParam;

  // by default, absolute position
  textStreamFallback(String text, float freq, int waveType, float waveParam) {
    this.text = text;
    this.freq = freq;
    this.waveType = waveType;
    this.waveParam = waveParam;
  }

  // value using clock as input for wave
  public float fetchValue() {
    // feed AULib with values between 0 and 1
    float input = System.currentTimeMillis() % (int) (1000 / freq) / (float) (1000 / freq);
    return AULib.wave(waveType, input, waveParam);
  }

  // return enum from string, insensitive to case
  // idea from: http://stackoverflow.com/a/2965252
  public static textStreamFallback fromString(String text) {
    if (text != null) {
      for (textStreamFallback fal : textStreamFallback.values()) {
        if (text.equalsIgnoreCase(fal.text)) {
          return fal;
        }
      }
    }
    return null;
  }
}

// will only based retrieval on stream type, fetching the first resolved stream. Non blocking call, stream has 1s to respond upon init, it'll be too late.
class textStreamLSL extends textStream {

  // the actual stream
  private LSL.StreamInlet inlet;
  // buffer holding data
  private float[] sample;
  // had hit 1 value since last call
  private boolean hitThreshold = false;


  textStreamLSL(String stream) {
    super(stream);
  }

  @Override
    protected boolean init() {
    
    LSL.StreamInfo[] results;

    System.out.println("Resolving a LSL stream of type [" + streamType() + "]");
    // try to find at least one stream, 0.1s timeout
    results = LSL.resolve_stream("type", streamType(), 1, 0.1);

    if (results.length < 1) {
      System.out.println("Error: no stream found.");
      return false;
    }

    System.out.println("Number of streams found: " + results.length + ", opening stream 1");

    // open an inlet
    inlet = new LSL.StreamInlet(results[0]);

    try {
      sample = new float[inlet.info().channel_count()];
    }
    catch(Exception e) {
      System.out.println("Error: Can't open a stream!");
      return false;
    }

    if (sample.length < 1) {
      System.out.println("Error: did not even one channel");
      return false;
    }

    if (sample.length > 1) {
      System.out.println("Warning, " + sample.length + " channels detected, only first one used");
    }

    System.out.println("Got first value: " + sample[0]);
    return true;
  }

  @Override
    protected float fetchValue() {

    hitThreshold = false;

    try {
      // Pulling everithing in queue -- failback at 1000 values just to avoid blocking forever
      int safe = 1000;
      while (inlet.pull_sample(sample, 0) != 0 && safe > 0) {
        if (sample[0] >= threshold) {
          hitThreshold = true;
        }
        safe--;
      }
      if (safe == 0) {
        System.out.println("Warning, did not had time to fetch last value in stream " +   streamType());
      }
    }
    catch(Exception e) {
      System.out.println("Error: Can't get a sample for stream " + streamType() + ", disabling stream.");
      disableStream();
    }
    return sample[0];
  }

  @Override
    protected boolean reachedSinceLastUpdate() {
    return  hitThreshold;
  }
}