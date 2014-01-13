public class keywordIsRenamed {
  public static void main(String args[]) throws java.io.IOException { 
     new keywordIsRenamed().run(new java.util.Scanner(System.in), 
                    new java.io.PrintWriter(System.out));
  }
  
  private static final int if_ = 0;
  
  void run(java.util.Scanner input, java.io.Writer output) throws java.io.IOException {
    int state = if_;
    while (true) {
      String token = input.nextLine();
      switch (state) {
        
        case if_: {
          // Handle if
          
          
          break;
        }
        
      }
    }
  }
  
  private boolean while_(String token) {
    return token.equals("D1OP");
  }
  
  
}