/**
 
 Abstraction and implementation for data streamed from the outside
 
 WARNING: should get values between 0 and 1.
 
 Here will be defined fallback depending on stream types.
 
 NB: using System.out.println to avoid use of PApplet with static textState
 
 TODO:
 
 - stream could be resolved after disconnect, implement timeout before fallback
 - several users
 
 */

import edu.ucsd.sccn.LSL;

// handling only one channel
// NB: streams will not be updated in the background, hence implementations should return last value in pipe
abstract class textStream {
  // stream type, will also determin fallback
  private String stream;

  // will we use fallback values or not?
  private boolean fallback;

  // stub for fallback object
  private float fallbackValue = (float)0.666;

  // child class should call this constructor
  textStream(String stream) {
    this.stream = stream;
    fallback = !init();
  }

  // should return true if stremm successfully resolved, false if we will use fallback
  abstract protected boolean init();

  // should return last value from stream
  abstract protected float fetchValue();

  // the stream encountered a probrem, child should call this method so that fallback takes it from here
  final void disableStream() {
    this.fallback = true;
  }

  final float getValue() {
    if (fallback) {
      return fallbackValue;
    }
    return fetchValue();
  }

  // one should know what we are after
  final protected String streamType() {
    return stream;
  }
}

// will only based retrieval on stream type, fetching the first resolved stream. Non blocking call, stream has 1s to respond upon init, it'll be too late.
class textStreamLSL extends textStream {

  // the actual stream
  private LSL.StreamInlet inlet;
  // buffer holding data
  float[] sample;

  textStreamLSL(String stream) {
    super(stream);
  }

  @Override
    protected boolean init() {

    LSL.StreamInfo[] results;

    System.out.println("Resolving a LSL stream of type [" + streamType() + "]");
    // try to find at least one stream, 1s timeout
    results = LSL.resolve_stream("type", streamType(), 1, 1);

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
    try {
      // Pulling everithing in queue -- failback at 1000 values just to avoid blocking forever
      int safe = 1000;
      while (inlet.pull_sample(sample, 0) != 0 && safe > 0) {
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
}