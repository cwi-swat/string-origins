public class keywordIsRenamedButNotToGenName {
  private static String if_ = "keywordIsRenamedButNotToGenName";
  public static void main(String args[]) throws java.io.IOException { 
     new keywordIsRenamedButNotToGenName().run(new java.util.Scanner(System.in), 
                    new java.io.PrintWriter(System.out));
  }
  
  private static final int foo = 0;
  
  void run(java.util.Scanner input, java.io.Writer output) throws java.io.IOException {
    int state = foo;
    while (true) {
      String token = input.nextLine();
      switch (state) {
        
        case foo: {
          // Handle foo
          
          
          if (if__(token)) {
             state = foo;
          }
          
          break;
        }
        
      }
    }
  }
  
  private boolean if__(String token) {
    return token.equals("D1OP");
  }
  
  
}