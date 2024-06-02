rateLimitLow =  0.89
rateLimitHigh = 0.9
allowMech = false
function onCreatePost()
	if getModSetting("allowAccMech") then
		if difficultyName == 'Hard' and getModSetting("ultimaMode") then
			allowMech = true
			rateLimitLow =  0.89
			rateLimitHigh = 0.9
		elseif difficultyName == 'Dave' and not getModSetting("ultimaMode") then
			allowMech = true
			rateLimitLow =  0.94
			rateLimitHigh = 0.95
		elseif difficultyName == 'Dave' and getModSetting("ultimaMode") then
			allowMech = true
			rateLimitLow =  0.98
			rateLimitHigh = 0.99
		end
	else
		allowMech = false
	end
end

function onRecalculateRating()
	if allowMech and rating ~= 0 then
		if rating <= rateLimitLow then
			triggerEvent('Camera Follow Pos', '-210', '330')
			triggerEvent('Set Cam Zoom', '1.5', '')
			runTimer('death', 2.5, 0)
		end
		if rating >= rateLimitHigh then
			cancelTimer('death')
			triggerEvent('Camera Follow Pos', '', '')
			triggerEvent('Set Cam Zoom', '0.8', '')
		end
	end
end

function onTimerCompleted(tag)
	if tag == 'death' then
		setProperty('health', -500)
	end
end