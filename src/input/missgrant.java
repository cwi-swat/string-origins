public class missgrant {
  private static String if_ = "missgrant";
  public static void main(String args[]) throws java.io.IOException { 
     new missgrant().run(new java.util.Scanner(System.in), 
                    new java.io.PrintWriter(System.out));
  }
  
  private static final int idle = 0;
  
  private static final int active = 1;
  
  private static final int waitingForLight = 2;
  
  private static final int waitingForDrawer = 3;
  
  private static final int unlockedPanel = 4;
  
  void run(java.util.Scanner input, java.io.Writer output) throws java.io.IOException {
    int state = idle;
    while (true) {
      String token = input.nextLine();
      switch (state) {
        
        case idle: {
          // Handle idle
          
             unlockDoor(output);
          
             lockPanel(output);
          
          
          if (doorClosed(token)) {
             state = active;
          }
          
          if (doorOpened(token)) {
             state = idle;
          }
          
          break;
        }
        
        case active: {
          // Handle active
          
          
          if (drawerOpened(token)) {
             state = waitingForLight;
          }
          
          if (lightOn(token)) {
             state = waitingForDrawer;
          }
          
          if (doorOpened(token)) {
             state = idle;
          }
          
          break;
        }
        
        case waitingForLight: {
          // Handle waitingForLight
          
          
          if (lightOn(token)) {
             state = unlockedPanel;
          }
          
          if (doorOpened(token)) {
             state = idle;
          }
          
          break;
        }
        
        case waitingForDrawer: {
          // Handle waitingForDrawer
          
          
          if (drawerOpened(token)) {
             state = unlockedPanel;
          }
          
          if (doorOpened(token)) {
             state = idle;
          }
          
          break;
        }
        
        case unlockedPanel: {
          // Handle unlockedPanel
          
             unlockPanel(output);
          
             lockDoor(output);
          
          
          if (panelClosed(token)) {
             state = idle;
          }
          
          if (doorOpened(token)) {
             state = idle;
          }
          
          break;
        }
        
      }
    }
  }
  
  private boolean doorClosed(String token) {
    return token.equals("D1CL");
  }
  
  private boolean drawerOpened(String token) {
    return token.equals("D2OP");
  }
  
  private boolean lightOn(String token) {
    return token.equals("L1ON");
  }
  
  private boolean doorOpened(String token) {
    return token.equals("D1OP");
  }
  
  private boolean panelClosed(String token) {
    return token.equals("PNCL");
  }
  
  
  private void unlockPanel(java.io.Writer output) throws java.io.IOException {
    System.err.println("Executing unlockPanel");
    int unlockPanel_var;
    output.write("PNUL\n");
    output.flush();
    // Add more asdsadsdaYES and YES code here
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
    // 
  }
  
  private void unlockDoor(java.io.Writer output) throws java.io.IOException {
    System.err.println("Executing unlockDoor");
    int unlockDoor_var;
    output.write("D1UL\n");
    output.flush();
    // Addsdjkfhfsdjkfhksdjhjksfdhkjhsfdk more code here
  }
  
}