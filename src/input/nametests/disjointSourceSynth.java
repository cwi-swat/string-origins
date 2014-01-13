public class disjointSourceSynth {
  private static String if_ = "disjointSourceSynth";
  public static void main(String args[]) throws java.io.IOException { 
     new disjointSourceSynth().run(new java.util.Scanner(System.in), 
                    new java.io.PrintWriter(System.out));
  }
  
  private static final int token_ = 0;
  
  void run(java.util.Scanner input, java.io.Writer output) throws java.io.IOException {
    int state = token_;
    while (true) {
      String token = input.nextLine();
      switch (state) {
        
        case token_: {
          // Handle token
          
          
          if (run_(token)) {
             state = token_;
          }
          
          break;
        }
        
      }
    }
  }
  
  private boolean run_(String token) {
    return token.equals("D1OP");
  }
  
  
}