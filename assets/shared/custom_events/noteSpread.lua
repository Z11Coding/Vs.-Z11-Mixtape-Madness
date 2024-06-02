function onEvent(eventName)
    if eventName == 'noteSpread' then
	    for i = 1, 4 do
            setProperty("PLnote"..i..".x", getProperty("PLnote"..i..".x") - getRandomInt(-50, screenWidth / 7))
            setProperty("PLnote"..i..".y", getProperty("PLnote"..i..".y") - getRandomInt(5, screenHeight / 11))

            setProperty("OPnote"..i..".x", getProperty("OPnote"..i..".x") + getRandomInt(-50, screenWidth / 7))
            setProperty("OPnote"..i..".y", getProperty("OPnote"..i..".y") - getRandomInt(5, screenHeight / 11))

            setProperty("PLnote"..i..".angle", getRandomInt(-180, 180))
            setProperty("OPnote"..i..".angle", getRandomInt(-180, 180))

	    	doTweenX('PLnote'..i, 'PLnote'..i, 0, (crochet/1000), 'circOut')
            doTweenY('PLnote'..i, 'PLnote'..i, 0, (crochet/1000), 'circOut')
		
            doTweenX('OPnote'..i, 'OPnote'..i, 0, (crochet/1000), 'circOut')
            doTweenY('OPnote'..i, 'OPnote'..i, 0, (crochet/1000), 'circOut')

            doTweenAngle('PLnote'..i, 'PLnote'..i, 0, (crochet/1000), 'circOut')
            doTweenAngle('OPnote'..i, 'OPnote'..i, 0, (crochet/1000), 'circOut')
	    end
    end
end