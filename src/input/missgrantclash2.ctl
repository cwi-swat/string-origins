events
 open D1CL
 close D2OP
 lock L1ON
 unlock D1OP
end 

resetEvents 
end 

commands
end
  
state opened
 close => closed 
end


state current0
 open => opened
 lock => current 
end 


state current 
 unlock => current0 
end  
