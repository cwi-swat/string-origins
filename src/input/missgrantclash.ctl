// a comment

events
 run_ D1CL
 if_ D2OP
 run L1ON
 while D1OP
 while_ BLA
end 


resetEvents 
end 

commands
 class PNUL
 lockPanel PNLK
 lockDoor D1LK
 
 unlockDoor D1UL
end
  
state if
 actions {unlockDoor lockPanel}
 run_ => active 
end


state active
 if_ => waitingForLight
 run => waitingForDrawer 
end 


state waitingForLight 
 run => unlockedPanel 
end  


state waitingForDrawer
 if_ => unlockedPanel
 while => waitingForLight
end 

 
state unlockedPanel
 actions {class lockDoor}
 while_ => if 
end

