function boundTo(value, min, max)
	return math.max(min, math.min(max, value))
end

function math.lerp(from,to,i) return from+(to-from)*i end

function setChrome(chromeOffset)
	triggerEvent("ess_Set Controller Value", 'vcr,rOffset', chromeOffset)
	triggerEvent("ess_Set Controller Value", 'vcr,gOffset', 0)
	triggerEvent("ess_Set Controller Value", 'vcr,bOffset', chromeOffset * -1)
end

function onEvent(n,v1,v2)
	if n == 'Chromatic Aberration' then
		local Chromacrap = 0;
		Chromacrap = Chromacrap + v1; -- edit this
		function onUpdate(elapsed)
			if (shadersEnabled) then
				Chromacrap = math.lerp(Chromacrap, 0, boundTo(elapsed * v2, 0, 1));
				setChrome(Chromacrap);
			end
		end
	end
end