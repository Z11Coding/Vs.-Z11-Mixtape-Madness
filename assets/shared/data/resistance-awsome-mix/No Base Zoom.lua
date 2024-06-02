function onUpdate()
    setProperty("camZoomingMult", 0)
end

function onBeatHit()
    --[[if curBeat % 4 == 0 then
        doTweenZoom('camResetGame', 'camGame', getProperty('defaultCamZoom'), 1, 'sineOut')
        doTweenZoom('camResetHUD', 'camHUD', 1, 1, 'sineOut')
    end]]
end