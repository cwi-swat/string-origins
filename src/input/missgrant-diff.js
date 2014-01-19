missgrant-diff = (function () {
  var missgrant-diff = {};
  
  missgrant-diff.state$idle = 0;
  
  missgrant-diff.state$ACTIVE = 1;
  
  missgrant-diff.state$waitingForLight = 2;
  
  missgrant-diff.state$waitingForDrawer = 3;
  
  missgrant-diff.state$unlockedPanel = 4;
  
  missgrant-diff.run = function(input) {
    var state = this.state$idle;
    for (var i = 0; i < input.length; i++) {
      var token = input[i];
      switch (state) {
        
        case this.state$idle: {
          
             this.unlockDoor();
          
             this.lockPanel();
          
          
          if (this.doorClosed(token)) {
             state = this.state$ACTIVE;
          }
          
          if (this.doorOpened(token)) {
             state = this.state$idle;
          }
          
          break;
        }
        
        case this.state$ACTIVE: {
          
          
          if (this.drawerOpened(token)) {
             state = this.state$waitingForLight;
          }
          
          if (this.lightOn(token)) {
             state = this.state$waitingForDrawer;
          }
          
          if (this.doorOpened(token)) {
             state = this.state$idle;
          }
          
          break;
        }
        
        case this.state$waitingForLight: {
          
          
          if (this.lightOn(token)) {
             state = this.state$unlockedPanel;
          }
          
          if (this.doorOpened(token)) {
             state = this.state$idle;
          }
          
          break;
        }
        
        case this.state$waitingForDrawer: {
          
          
          if (this.drawerOpened(token)) {
             state = this.state$unlockedPanel;
          }
          
          if (this.doorOpened(token)) {
             state = this.state$idle;
          }
          
          break;
        }
        
        case this.state$unlockedPanel: {
          
             this.unlockPanel();
          
             this.lockDoor();
          
          
          if (this.panelClosed(token)) {
             state = this.state$idle;
          }
          
          if (this.doorOpened(token)) {
             state = this.state$idle;
          }
          
          break;
        }
        
      }
    }
  };
  
  missgrant-diff.drawerOpened = function(token) {
    return token === "D2OP";
  };
  
  missgrant-diff.Bla = function(token) {
    return token === "BLA";
  };
  
  missgrant-diff.lightOn = function(token) {
    return token === "L1ON";
  };
  
  missgrant-diff.doorOpened = function(token) {
    return token === "D1OP";
  };
  
  missgrant-diff.panelClosed = function(token) {
    return token === "PNCL";
  };
  
  missgrant-diff.newEvent = function(token) {
    return token === "NEW";
  };
  
  
  missgrant-diff.unlockPanel = function() {
    console.log("PNUL");
  };
  
  missgrant-diff.lockPanel = function() {
    console.log("PNLK");
  };
  
  missgrant-diff.lockDoor = function() {
    console.log("D1LK");
  };
  
  missgrant-diff.unlockDoor = function() {
    console.log("D1UL");
  };
  
  return missgrant-diff;
})();

//@ sourceMappingURL=missgrant-diff.js.map
