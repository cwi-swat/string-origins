public class missgrantclash {
  private static String if_ = "missgrantclash";
  public static void main(String args[]) throws java.io.IOException { 
     new missgrantclash().run(new java.util.Scanner(System.in), 
                    new java.io.PrintWriter(System.out));
  }
  
  private static final int if = 0;
  
  private static final int active = 1;
  
  private static final int waitingForLight = 2;
  
  private static final int waitingForDrawer = 3;
  
  private static final int unlockedPanel = 4;
  
  void run(java.util.Scanner input, java.io.Writer output) throws java.io.IOException {
    int state = if;
    while (true) {
      String token = input.nextLine();
      switch (state) {
        
        case if: {
          // Handle if
          
             token(output);
          
             lockPanel(output);
          
          
          if (run_(token)) {
             state = active;
          }
          
          break;
        }
        
        case active: {
          // Handle active
          
          
          if (if_(token)) {
             state = waitingForLight;
          }
          
          if (run(token)) {
             state = waitingForDrawer;
          }
          
          break;
        }
        
        case waitingForLight: {
          // Handle waitingForLight
          
          
          if (run(token)) {
             state = unlockedPanel;
          }
          
          break;
        }
        
        case waitingForDrawer: {
          // Handle waitingForDrawer
          
          
          if (if_(token)) {
             state = unlockedPanel;
          }
          
          if (while(token)) {
             state = waitingForLight;
          }
          
          break;
        }
        
        case unlockedPanel: {
          // Handle unlockedPanel
          
             class(output);
          
             lockDoor(output);
          
          
          if (while_(token)) {
             state = if;
          }
          
          break;
        }
        
      }
    }
  }
  
  private boolean run_(String token) {
    return token.equals("D1CL");
  }
  
  private boolean if_(String token) {
    return token.equals("D2OP");
  }
  
  private boolean run(String token) {
    return token.equals("L1ON");
  }
  
  private boolean while(String token) {
    return token.equals("D1OP");
  }
  
  private boolean while_(String token) {
    return token.equals("BLA");
  }
  
  
  private void class(java.io.Writer output) throws java.io.IOException {
    System.err.println("Executing class");
    int class_var;
    output.write("PNUL\n");
    output.flush();
    // Add more code here
  }
  
  private void lockPanel(java.io.Writer output) throws java.io.IOException {
    System.err.println("Executing lockPanel");
    int lockPanel_var;
    output.write("PNLK\n");
    output.flush();
    // Add more code here
  }
  
  private void lockDoor(java.io.Writer output) throws java.io.IOException {
    System.err.println("Executing lockDoor");
    int lockDoor_var;
    output.write("D1LK\n");
    output.flush();
    // Add more code here
  }
  
  private void token(java.io.Writer output) throws java.io.IOException {
    System.err.println("Executing token");
    int token_var;
    output.write("D1UL\n");
    output.flush();
    // Add more code here
  }
  
}