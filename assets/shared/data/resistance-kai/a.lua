local pxSize = 0.1
local curFPS = 60
function onCreatePost()
    curFPS = getPropertyFromClass("backend.ClientPrefs", "data.framerate")
    addCharacterToList('mio', 'dad')
    setProperty('gf.x', getProperty('gf.x')-1300)
    setProperty('gf.y', getProperty('gf.y')-100)
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
    if curStep == 3872 then
        doTweenColor('shape', 'dadGroup', 'black', 1, 'sineOut')
    end
    if curStep == 3968 then
        triggerEvent("Change Character", "dad", "mio")
        doTweenColor('shift', 'dadGroup', 'white', 1, 'sineOut')
        cameraFlash("camGame", "FFFFFF", 1, false)
    end
end


function onUpdatePost()
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

