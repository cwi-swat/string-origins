// a comment

events
 run_ D1CL
 token D2OP
 run L1ON
 doorOpened D1OP
 panelClosed PNCL
end 


resetEvents 
 doorOpened
end 

commands
 unlockPanel PNUL
 lockPanel PNLK
 lockDoor D1LK
 
 unlockDoor D1UL
end
  
state idle
 actions {unlockDoor lockPanel}
 run_ => active 
end


state active
 token => waitingForLight
 run => waitingForDrawer 
end 


state waitingForLight 
 run => unlockedPanel 
end  


state waitingForDrawer
 token => unlockedPanel
end 

 
state unlockedPanel
 actions {unlockPanel lockDoor}
 panelClosed => idle 
end

