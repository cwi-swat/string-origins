public class renameKnowsSourceNames {
  public static void main(String args[]) throws java.io.IOException { 
     new renameKnowsSourceNames().run(new java.util.Scanner(System.in), 
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
          
          
          if (run______(token)) {
             state = token_;
          }
          
          if (run_(token)) {
             state = token_;
          }
          
          if (run__(token)) {
             state = token_;
          }
          
          if (run___(token)) {
             state = token_;
          }
          
          if (run____(token)) {
             state = token_;
          }
          
          if (run_____(token)) {
             state = token_;
          }
          
          break;
        }
        
      }
    }
  }
  
  private boolean run______(String token) {
    return token.equals("D1OP");
  }
  
  private boolean run_(String token) {
    return token.equals("D1OP");
  }
  
  private boolean run__(String token) {
    return token.equals("D1OP");
  }
  
  private boolean run___(String token) {
    return token.equals("D1OP");
  }
  
  private boolean run____(String token) {
    return token.equals("D1OP");
  }
  
  private boolean run_____(String token) {
    return token.equals("D1OP");
  }
  
  
}