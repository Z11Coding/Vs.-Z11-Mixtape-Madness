function onEvent(name, value1, value2)
   if name == 'tweenStando' then
     if value1 == 'dad' then
	  if value2 == 'T' then
	   doTweenX('dadLeft', 'dad', getProperty('dad.x')- 300, 1, 'cubeOut')
	  end 
	  if value2 == 'F' then
	   doTweenX('dadRight', 'dad', getProperty('dad.x')+ 300, 1, 'cubeOut')
	  end 	  
	 end
     if value1 == 'bf' then
	  if value2 == 'T' then
	   doTweenX('boyfriendRight', 'boyfriend', getProperty('boyfriend.x')+ 340, 1, 'cubeOut')
	  end 
	  if value2 == 'F' then
	   doTweenX('boyfriendLeft', 'boyfriend', getProperty('boyfriend.x')- 340, 1, 'cubeOut')
	  end 	  
	 end	 
   end
end