missgrant = (function () {
  var missgrant = {};
  
  missgrant.state$idle = 0;
  
  missgrant.state$active = 1;
  
  missgrant.state$waitingForLight = 2;
  
  missgrant.state$waitingForDrawer = 3;
  
  missgrant.state$unlockedPanel = 4;
  
  missgrant.run = function(input) {
    var state = this.state$idle;
    for (var i = 0; i < input.length; i++) {
      var token = input[i];
      switch (state) {
        
        case this.state$idle: {
          
             this.unlockDoor();
          
             this.lockPanel();
          
          
          if (this.doorClosed(token)) {
             state = this.state$active;
          }
          
          if (this.doorOpened(token)) {
             state = this.state$idle;
          }
          
          break;
        }
        
        case this.state$active: {
          
          
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
  
  missgrant.doorClosed = function(token) {
    return token === "D1CL";
  };
  
  missgrant.drawerOpened = function(token) {
    return token === "D2OP";
  };
  
  missgrant.lightOn = function(token) {
    return token === "L1ON";
  };
  
  missgrant.doorOpened = function(token) {
    return token === "D1OP";
  };
  
  missgrant.panelClosed = function(token) {
    return token === "PNCL";
  };
  
  
  missgrant.unlockPanel = function() {
    console.log("PNUL");
  };
  
  missgrant.lockPanel = function() {
    console.log("PNLK");
  };
  
  missgrant.lockDoor = function() {
    console.log("D1LK");
  };
  
  missgrant.unlockDoor = function() {
    console.log("D1UL");
  };
  
  return missgrant;
})();

//@ sourceMappingURL=missgrant.js.map
