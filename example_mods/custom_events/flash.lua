color = FFFFFF
time = 1

function onEvent(name, value1, value2)
	if name == 'flash' then

		if value1 == '' then
			color = 'FFFFFF'
		elseif value2 == '' then
			time = 1
		else
			color = value1
			time = value2
		end

		cameraFlash('hud', color, time, true)
	end
end