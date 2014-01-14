events
  
 drawerOpened D2OP
 Bla BLA
 lightOn L1ON
 doorOpenedRenamed D1OP
 panelClosed PNCL
 newEvent NEW
end 

resetEvents 
 doorOpened
end 

commands
 unlockPanel PNUL
 lockPanel PNLK
 lockDoor D1LK
 unlockDoor D1UL
 COM COMMAND
end
  
state idle
 actions {unlockDoor lockPanel}
 doorClosed => ACTIVE 
end


state ACTIVE
 drawerOpened => waitingForLight
 lightOn => waitingForDrawer 
end 


state waitingForLight 
 lightOn => unlockedPanel 
end  

state someLoneState
end

state unlockedPanel
 actions {unlockPanel lockDoor}
 panelClosed => idle 
end

state waitingForDrawer
 actions {bla}
 drawerOpened => unlockedPanel
end 

 
