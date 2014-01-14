missgrantclash = (function () {
  var missgrantclash = {};
  
  missgrantclash.state$if = 0;
  
  missgrantclash.state$active = 1;
  
  missgrantclash.state$waitingForLight = 2;
  
  missgrantclash.state$waitingForDrawer = 3;
  
  missgrantclash.state$unlockedPanel = 4;
  
  missgrantclash.run = function(input) {
    var state = this.state$if;
    for (var i = 0; i < input.length; i++) {
      var token = input[i];
      switch (state) {
        
        case this.state$if: {
          
             this.token();
          
             this.lockPanel();
          
          
          if (this.run_(token)) {
             state = this.state$active;
          }
          
          break;
        }
        
        case this.state$active: {
          
          
          if (this.if_(token)) {
             state = this.state$waitingForLight;
          }
          
          if (this.run(token)) {
             state = this.state$waitingForDrawer;
          }
          
          break;
        }
        
        case this.state$waitingForLight: {
          
          
          if (this.run(token)) {
             state = this.state$unlockedPanel;
          }
          
          break;
        }
        
        case this.state$waitingForDrawer: {
          
          
          if (this.if_(token)) {
             state = this.state$unlockedPanel;
          }
          
          if (this.while(token)) {
             state = this.state$waitingForLight;
          }
          
          break;
        }
        
        case this.state$unlockedPanel: {
          
             this.class();
          
             this.lockDoor();
          
          
          if (this.while_(token)) {
             state = this.state$if;
          }
          
          break;
        }
        
      }
    }
  };
  
  missgrantclash.run_ = function(token) {
    return token === "D1CL";
  };
  
  missgrantclash.if_ = function(token) {
    return token === "D2OP";
  };
  
  missgrantclash.run = function(token) {
    return token === "L1ON";
  };
  
  missgrantclash.while = function(token) {
    return token === "D1OP";
  };
  
  missgrantclash.while_ = function(token) {
    return token === "BLA";
  };
  
  
  missgrantclash.class = function() {
    console.log("PNUL");
  };
  
  missgrantclash.lockPanel = function() {
    console.log("PNLK");
  };
  
  missgrantclash.lockDoor = function() {
    console.log("D1LK");
  };
  
  missgrantclash.token = function() {
    console.log("D1UL");
  };
  
  return missgrantclash;
})();

//# sourceMappingURL=missgrantclash.js.map
