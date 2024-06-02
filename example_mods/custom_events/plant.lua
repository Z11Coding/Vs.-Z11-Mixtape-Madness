local marHealth = 3
local plantDir = 0
local flashCount = 0

function onEvent(n,v1,v2)
	if n == 'plant' then
		if v1 == 'bottom' then
			doTweenY('botPlantUp','plant',getProperty('plant.y')-320,0.5)
		elseif v1 == 'top' then
			doTweenY('topPlantDown','plant2',990,0.5)
		end
		plantDir = v1
	end
end

function onTweenCompleted(t)
	if t == 'botPlantUp' or t == 'topPlantDown' then
		if marHealth > 1 then
			playSound('pipe',0.9)
			changeMar()
		else
			if plantDir == 'bottom' then
				doTweenY('botPlantDown','plant',getProperty('pipe.y')+790,0.5)
			elseif plantDir == 'top' then
				doTweenY('topPlantUp','plant2',getProperty('pipe2.y')+1450,0.5)
			end
		end
	end
end

function changeMar()
	flashCount = 3

	setProperty('dad.visible',false)
	runTimer('marFlash',0.15)
end

function onTimerCompleted(t)
	if t == 'marFlash' then
		if not getProperty('dad.visible') then
			setProperty('dad.visible',true)
			if flashCount == 1 then
				if marHealth == 3 then
					triggerEvent('Change Character','dad','mario')
					setProperty('dad.y',getProperty('pipe.y')+614)
				elseif marHealth == 2 then
					triggerEvent('Change Character','dad','lil-mario')
					setProperty('dad.y',getProperty('pipe.y')+614)
				end
				marHealth = marHealth - 1
			end
		else
			setProperty('dad.visible',false)
		end
		flashCount = flashCount - 1

		if flashCount > 0 then 
			runTimer('marFlash',0.2) 
		else
			if plantDir == 'bottom' then
				doTweenY('botPlantDown','plant',getProperty('pipe.y')+790,0.5)
			elseif plantDir == 'top' then
				doTweenY('topPlantUp','plant2',getProperty('pipe2.y')+1450,0.5)
			end
		end
	end
end