public class keywordIsRenamedButNotToSourceName {
  public static void main(String args[]) throws java.io.IOException { 
     new keywordIsRenamedButNotToSourceName().run(new java.util.Scanner(System.in), 
                    new java.io.PrintWriter(System.out));
  }
  
  private static final int if__ = 0;
  
  void run(java.util.Scanner input, java.io.Writer output) throws java.io.IOException {
    int state = if__;
    while (true) {
      String token = input.nextLine();
      switch (state) {
        
        case if__: {
          // Handle if
          
          
          if (if_(token)) {
             state = if__;
          }
          
          break;
        }
        
      }
    }
  }
  
  private boolean if_(String token) {
    return token.equals("D1OP");
  }
  
  
}