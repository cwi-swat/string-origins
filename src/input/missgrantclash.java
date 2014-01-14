public class missgrantclash {
  public static void main(String args[]) throws java.io.IOException { 
     new missgrantclash().run(new java.util.Scanner(System.in), 
                    new java.io.PrintWriter(System.out));
  }
  
  private static final int if__ = 0;
  
  private static final int active = 1;
  
  private static final int waitingForLight = 2;
  
  private static final int waitingForDrawer = 3;
  
  private static final int unlockedPanel = 4;
  
  void run(java.util.Scanner input, java.io.Writer output) throws java.io.IOException {
    int state = if__;
    while (true) {
      String token = input.nextLine();
      switch (state) {
        
        case if__: {
          // Handle if
          
             token_(output);
          
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
          
          if (run__(token)) {
             state = waitingForDrawer;
          }
          
          break;
        }
        
        case waitingForLight: {
          // Handle waitingForLight
          
          
          if (run__(token)) {
             state = unlockedPanel;
          }
          
          break;
        }
        
        case waitingForDrawer: {
          // Handle waitingForDrawer
          
          
          if (if_(token)) {
             state = unlockedPanel;
          }
          
          if (while__(token)) {
             state = waitingForLight;
          }
          
          break;
        }
        
        case unlockedPanel: {
          // Handle unlockedPanel
          
             class_(output);
          
             lockDoor(output);
          
          
          if (while_(token)) {
             state = if__;
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
  
  private boolean run__(String token) {
    return token.equals("L1ON");
  }
  
  private boolean while__(String token) {
    return token.equals("D1OP");
  }
  
  private boolean while_(String token) {
    return token.equals("BLA");
  }
  
  
  private void class_(java.io.Writer output) throws java.io.IOException {
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
  
  private void token_(java.io.Writer output) throws java.io.IOException {
    System.err.println("Executing token");
    int token_var;
    output.write("D1UL\n");
    output.flush();
    // Add more code here
  }
  
}