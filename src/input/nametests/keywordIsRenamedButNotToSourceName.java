public class keywordIsRenamedButNotToSourceName {
  private static String if_ = "keywordIsRenamedButNotToSourceName";
  public static void main(String args[]) throws java.io.IOException { 
     new keywordIsRenamedButNotToSourceName().run(new java.util.Scanner(System.in), 
                    new java.io.PrintWriter(System.out));
  }
  
  private static final int while__ = 0;
  
  void run(java.util.Scanner input, java.io.Writer output) throws java.io.IOException {
    int state = while__;
    while (true) {
      String token = input.nextLine();
      switch (state) {
        
        case while__: {
          // Handle while
          
          
          if (while_(token)) {
             state = while__;
          }
          
          break;
        }
        
      }
    }
  }
  
  private boolean while_(String token) {
    return token.equals("D1OP");
  }
  
  
}