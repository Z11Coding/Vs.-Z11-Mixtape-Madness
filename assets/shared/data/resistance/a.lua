local pxSize = 0.1
local curFPS = 60
function onCreatePost()
	muteVoices = getModSetting('oldvoices')
    precacheSound('VoicesOld')
    setProperty('gf.x', getProperty('gf.x')-1300)
    setProperty('gf.y', getProperty('gf.y')-100)
    curFPS = getPropertyFromClass("backend.ClientPrefs", "data.framerate")
end

function onSongStart()
    if muteVoices then
        playSound('VoicesOld', 1, 'Voices')
        runTimer('resync', 3)
    end
end

function onTimerCompleted(a)
    if a == 'resync' then
        setSoundTime('Voices', getProperty('vocals.time'))
        runTimer('resync', 3)
    end
end

--I love basic functions

function onPause()
    pauseSound('Voices')
end

function onResume()
    resumeSound('Voices')
end

function noteMiss()
    setSoundVolume('Voices', 0)
end

function goodNoteHit()
    setSoundVolume('Voices', 1)
end

function opponentNoteHit()
    setSoundVolume('Voices', 1)
end

function onStepHit()
    if curStep >= 1775 and curStep <= 1783 then
            doPixel = true
       else
            doPixel = false
     end
     if curStep >= 2800 and curStep <= 2808 then
            unDoPixel = true
     else
            unDoPixel = false
     end
    if curStep == 1263 then
        doTweenX("z11", "gf", 400, 1, "sineOut")
    end
    if curStep == 1535 then
        doTweenY("z11", "gf", -2000, 12, "sineOut")
        doTweenAngle("z11a", "gf", 360, 6, "sineOut")
        doTweenAlpha("z11al", "gf", 0, 2, "sineOut")
    end
end

function onUpdate()
    if muteVoices then
        setProperty('vocals.volume', 0)
    end
end


function onUpdatePost()
    if keyboardJustPressed('SPACE') then
        setSoundTime('Voices', getProperty('vocals.time'))
    end
    if muteVoices then
        setProperty('vocals.volume', 0)
    end
    if doPixel then
	--setShaderFloat('die2','pxSize', setShaderFloat('die2','pxSize') + 0.1 / (curFPS/60))
        --runHaxeCode('shader0.setFloat(\'pxSize\', shader0.getFloat(\'pxSize\') + 0.1/(ClientPrefs.framerate/60));')
        pxSize = pxSize + 0.1/(curFPS/60)
       -- debugPrint(pxSize)
    end
    if unDoPixel then
	--setShaderFloat('die2','pxSize', getShaderFloat('pxSize') - 0.1 / (curFPS/60))
        --runHaxeCode('shader0.setFloat(\'pxSize\', shader0.getFloat(\'pxSize\') - 0.1/(ClientPrefs.framerate/60));')
        pxSize = pxSize - 0.1/(curFPS/60)
        --debugPrint(pxSize)
    end
	triggerEvent("ess_Set Controller Value", 'pixel2,pxSize', pxSize)
end

