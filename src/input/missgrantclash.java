public class missgrantclash {
  public static void main(String args[]) throws java.io.IOException { 
     new missgrantclash().run(new java.util.Scanner(System.in), 
                    new java.io.PrintWriter(System.out));
  }
  
  private static final int state$idle = 0;
  
  private static final int state$active = 1;
  
  private static final int state$waitingForLight = 2;
  
  private static final int state$waitingForDrawer = 3;
  
  private static final int state$unlockedPanel = 4;
  
  void run(java.util.Scanner input, java.io.Writer output) throws java.io.IOException {
    int state = state$idle;
    while (true) {
      String token = input.nextLine();
      switch (state) {
        
        case state$idle: {
          
             unlockDoor(output);
          
             lockPanel(output);
          
          
          if (run_(token)) {
             state = state$active;
          }
          
          break;
        }
        
        case state$active: {
          
          
          if (token_(token)) {
             state = state$waitingForLight;
          }
          
          if (run__(token)) {
             state = state$waitingForDrawer;
          }
          
          break;
        }
        
        case state$waitingForLight: {
          
          
          if (run__(token)) {
             state = state$unlockedPanel;
          }
          
          break;
        }
        
        case state$waitingForDrawer: {
          
          
          if (token_(token)) {
             state = state$unlockedPanel;
          }
          
          if (while_(token)) {
             state = state$waitingForLight;
          }
          
          break;
        }
        
        case state$unlockedPanel: {
          
             unlockPanel(output);
          
             lockDoor(output);
          
          
          if (while__(token)) {
             state = state$idle;
          }
          
          break;
        }
        
      }
    }
  }
  
  private boolean run_(String token) {
    return token.equals("D1CL");
  }
  
  private boolean token_(String token) {
    return token.equals("D2OP");
  }
  
  private boolean run__(String token) {
    return token.equals("L1ON");
  }
  
  private boolean while_(String token) {
    return token.equals("D1OP");
  }
  
  private boolean while__(String token) {
    return token.equals("SHOULDBECOMEWHILE__");
  }
  
  
  private void unlockPanel(java.io.Writer output) throws java.io.IOException {
    output.write("PNUL\n");
    output.flush();
    // Add more code here
  }
  
  private void lockPanel(java.io.Writer output) throws java.io.IOException {
    output.write("PNLK\n");
    output.flush();
    // Add more code here
  }
  
  private void lockDoor(java.io.Writer output) throws java.io.IOException {
    output.write("D1LK\n");
    output.flush();
    // Add more code here
  }
  
  private void unlockDoor(java.io.Writer output) throws java.io.IOException {
    output.write("D1UL\n");
    output.flush();
    // Add more code here
  }
  
}