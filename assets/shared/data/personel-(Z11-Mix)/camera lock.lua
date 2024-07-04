function onUpdate(elapsed)
	if focusA == "dad" then
		lockx = getProperty("dad.getMidpoint().x")
		locky = getProperty("dad.getMidpoint().y")
	end
	if focusA == "gf" then
		lockx = getProperty("gf.getMidpoint().x")
		locky = getProperty("gf.getMidpoint().y")
	end
	if focusA == "boyfriend" then
		lockx = getProperty("boyfriend.getMidpoint().x")-- - 100 - getProperty("boyfriend.cameraPosition[0]") + getProperty("boyfriendCameraOffset[0]")
		locky = getProperty("boyfriend.getMidpoint().y")-- - 100 + getProperty("boyfriend.cameraPosition[1]") + getProperty("boyfriendCameraOffset[1]")
	end
	setProperty('cameraSpeed', 9999999)
	triggerEvent('Camera Follow Pos', lockx, locky)
end

lastFocus = 'gf'
function onMoveCamera(focus)
	focusA = focus
	if lastFocus ~= focus then
		lastFocus = focus
		setProperty("camGame.zoom", getProperty("camGame.zoom")-0.2)
		doTweenZoom('zoomies', 'camGame', getProperty("camGame.zoom")+0.2, stepCrochet*0.001*4, 'sineOut')
		--setProperty("camHUD.zoom", getProperty("camHUD.zoom")-0.2)
		--doTweenZoom('zoomies', 'camHUD', getProperty("camHUD.zoom")+0.2, stepCrochet*0.001*4, 'sineOut')
	end
end