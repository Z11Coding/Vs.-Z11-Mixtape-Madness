function onCreatePost()
    makeLuaSprite("void")
    makeGraphic("void", screenWidth*2, screenHeight*2, '000000')
    setObjectCamera('void', 'hud')
    screenCenter("void")
    addLuaSprite('void', true)
    setProperty('void.alpha', 1)
    setProperty('dad.alpha', 0)
    setProperty('iconP2.alpha', 0)
    setProperty('healthBar.leftBar.alpha', 0)
end

function onStartCountdown()
    setProperty('camZoomingMult', 0)
end

local continuous = {}
local function queueContFunc(startStep, endStep, callback)
    table.insert(continuous, { startStep, endStep, callback })
end

function onCountdownStarted()
    addBlankMod("haloRadiusX", 0)
    addBlankMod("haloRadiusZ", 0)
    addBlankMod("haloSpeed", 0)
    if modcharts then
        setValue('drunk', 1, 0)
        setValue('tipZ', 1, 0)
        setValue('opponentSwap', 0.5, 0)
        setValue('fieldX', 400, 1)
        setValue('fieldZ', 800, 1)
        setValue('fieldY', 600, 1)
        setValue('fieldYaw', -30, 1)
        setValue('fieldRoll', 30, 1)
        setValue('fieldPitch', -20, 1)
        setValue('drawDistance', 300, 1)
        setValue('disableDrawDistMult', 1, 1)
    end
end

function onStepHit()
    liveStep = curStep

    if curStep == 128 then
        doTweenAlpha('bringthegamein', 'void', 0, stepCrochet*0.001*364, 'sineOut')
    end
    if curStep == 496 then
        doTweenAlpha('herehecomes', 'dad', 1, stepCrochet*0.001*16, 'sineOut')
        doTweenAlpha('awman', 'iconP2', 1, stepCrochet*0.001*16, 'sineOut')
        doTweenAlpha('yourdonefornow', 'healthBar.leftBar', 1, stepCrochet*0.001*16, 'sineOut')
    end
    if curStep == 1535 then setProperty('dad.alpha', 0.5) setProperty('iconP2.alpha', 0.5) setProperty('healthBar.leftBar.alpha', 0.5) end
    if curStep == 2032 then
        doTweenAlpha('herehecomes', 'dad', 1, stepCrochet*0.001*16, 'sineOut')
        doTweenAlpha('awman', 'iconP2', 1, stepCrochet*0.001*16, 'sineOut')
        doTweenAlpha('yourdonefornow', 'healthBar.leftBar', 1, stepCrochet*0.001*16, 'sineOut')
    end
    if modcharts then
        if curStep == 511 then
            rave1 = true
            setValue('drunk', 0, 0)
            setValue('tipZ', 0, 0)
        end
        if curStep == 760 then
            rave1 = false
            quake = true
            queueEase(curStep, curStep+8, 'reverse', 1, 'cubeInOut', 0)
        end
        if curStep == 766 then
            rave1 = true
            quake = false
        end
        if curStep == 1016 then
            rave1 = false
            quake = true
            queueEase(curStep, curStep+8, 'reverse', 0, 'cubeInOut', 0)
            queueEase(curStep, curStep+8, 'centered', 1, 'cubeInOut', 0)
        end
        if curStep == 1023 then
            flipflop = true
            quake = false
        end
        if curStep == 1144 then
            queueEase(curStep, curStep+8, 'centered', 0, 'cubeInOut', 0)
            queueEase(curStep, curStep+8, 'split', 1, 'cubeInOut', 0)
            rave2 = true
        end
        if curStep == 1278 then
            flipflop = false
        end
        if curStep == 1279 then
            flipflop = false
            queueEase(curStep, curStep+3, 'split', 0, 'cubeOut', 0)
            queueEase(curStep, curStep+3, 'fieldPitch', 120, 'cubeOut', 0)
            queueEase(curStep, curStep+3, 'fieldYaw', 180, 'cubeOut', 0)
        end
        if curStep == 1407 then
            queueEase(curStep, curStep+3, 'fieldPitch', 60, 'cubeOut', 0)
        end
        if curStep == 1412 then
            queueEase(curStep, curStep+3, 'fieldYaw', 60, 'cubeOut', 0)
        end
        if curStep == 1416 then
            queueEase(curStep, curStep+3, 'fieldYaw', 160, 'cubeOut', 0)
        end
        if curStep == 1419 then
            queueEase(curStep, curStep+3, 'fieldPitch', 180, 'cubeOut', 0)
        end
        if curStep == 1422 then
            queueEase(curStep, curStep+3, 'fieldPitch', 0, 'cubeOut', 0)
            queueEase(curStep, curStep+3, 'fieldYaw', 180, 'cubeOut', 0)
        end
        if curStep == 1439 then
            queueEase(curStep, curStep+3, 'fieldYaw', 60, 'cubeOut', 0)
        end
        if curStep == 1444 then
            queueEase(curStep, curStep+3, 'fieldPitch', 60, 'cubeOut', 0)
        end
        if curStep == 1448 then
            queueEase(curStep, curStep+3, 'fieldPitch', 160, 'cubeOut', 0)
        end
        if curStep == 1451 then
            queueEase(curStep, curStep+3, 'fieldYaw', 180, 'cubeOut', 0)
        end
        if curStep == 1454 then
            queueEase(curStep, curStep+3, 'fieldYaw', 0, 'cubeOut', 0)
            queueEase(curStep, curStep+3, 'fieldPitch', 0, 'cubeOut', 0)
        end
        if curStep == 1534 then
            rave2 = false
        end
        if curStep == 1535 then
            setValue('dizzy', 1, 0)
            setValue('drunk', 1, 0)
            setValue('tipZ', 1, 0)
            setValue('boost', 1, 0)
            setValue('brake', 1, 1)
        end
        if curStep == 1727 then
            queueEase(curStep, 1791, 'tipZ', 0, 'cubeOut', 0)
            queueEase(curStep, 1791, 'drunk', 0, 'cubeOut', 0)
            queueEase(curStep, 1791, 'tornado', 1, 'cubeOut', 0)
            queueEase(curStep, 1791, 'zigzag', 1, 'cubeOut', 0)
            queueEase(curStep, 1791, 'bounce', 1, 'cubeOut', 0)
            queueEase(curStep, 1791, 'haloRadiusX', 150, 'quartOut', 0)
            queueEase(curStep, 1791, 'haloRadiusZ', 50, 'quartOut', 0)
            queueEase(curStep, 1791, 'haloSpeed', 3, 'quartOut', 0)
        end
        if curStep == 2032 then
            setValue('dizzy', 0, 0)
            setValue('boost', 0, 0)
            setValue('brake', 0, 1)
            setValue('tornado', 0, 0)
            setValue('zigzag', 0, 0)
            setValue('bounce', 0, 0)
            queueEase(curStep, curStep+15, 'cross', 1, 'cubeOut', 0)
            queueEase(curStep, curStep+15, 'haloRadiusX', 0, 'cubeOut', 0)
            queueEase(curStep, curStep+15, 'haloRadiusZ', 0, 'cubeOut', 0)
            queueEase(curStep, curStep+15, 'haloSpeed', 0, 'cubeOut', 0)
        end
        if curStep == 2047 then
            rave3 = true
        end
        if curStep == 2176 then
            queueEase(curStep, curStep+3, 'reverse', 1, 'cubeOut', 0)
        end
        if curStep == 2295 then
            rave3 = false
        end
        if curStep == 2176 then
            queueEase(curStep, curStep+7, 'cross', 0, 'cubeOut', 0)
            queueEase(curStep, curStep+7, 'reverse', 0, 'cubeOut', 0)
            queueEase(curStep, curStep+7, 'alternate', 1, 'cubeOut', 0)
        end
        if curStep == 2303 then
            rave2 = true
            flipflop = true
            flipflop2 = true
        end
        if curStep == 2432 then
            queueEase(curStep, curStep+3, 'fieldPitch', 60, 'cubeOut', 0)
        end
        if curStep == 2436 then
            queueEase(curStep, curStep+3, 'fieldYaw', 60, 'cubeOut', 0)
        end
        if curStep == 2440 then
            queueEase(curStep, curStep+3, 'fieldYaw', 160, 'cubeOut', 0)
        end
        if curStep == 2443 then
            queueEase(curStep, curStep+3, 'fieldPitch', 180, 'cubeOut', 0)
        end
        if curStep == 2446 then
            queueEase(curStep, curStep+3, 'fieldPitch', 0, 'cubeOut', 0)
            queueEase(curStep, curStep+3, 'fieldYaw', 180, 'cubeOut', 0)
        end
        if curStep == 2464 then
            queueEase(curStep, curStep+3, 'fieldYaw', 60, 'cubeOut', 0)
        end
        if curStep == 2468 then
            queueEase(curStep, curStep+3, 'fieldPitch', 60, 'cubeOut', 0)
        end
        if curStep == 2472 then
            queueEase(curStep, curStep+3, 'fieldPitch', 160, 'cubeOut', 0)
        end
        if curStep == 2475 then
            queueEase(curStep, curStep+3, 'fieldYaw', 180, 'cubeOut', 0)
        end
        if curStep == 2477 then
            queueEase(curStep, curStep+3, 'fieldYaw', 0, 'cubeOut', 0)
            queueEase(curStep, curStep+3, 'fieldPitch', 0, 'cubeOut', 0)
        end
        if curStep == 2495 then
            rave2 = false
            flipflop = false
            flipflop2 = false
        end
        if curStep == 2511 then
            rave2 = true
            flipflop = true
            flipflop2 = true
        end
        if curStep == 2552 then
            rave2 = false
            flipflop = false
            flipflop2 = false
            queueEase(curStep, curStep+3, 'alternate', 0, 'cubeOut', 0)
            queueEase(curStep, curStep+3, 'reverse', 0, 'cubeOut', 0)
            queueEase(curStep, curStep+3, 'invert', 0, 'cubeOut', 0)
            queueEase(curStep, curStep+3, 'flip', 0, 'cubeOut', 0)
        end
    end
    if cameraZoomOnBeat then
        if curStep == 512 then
            cameraFlash('game', 'ffffff', 1)
            jerseyCam = true
        end
        if curStep == 767 then
            cameraFlash('game', 'ffffff', 1)
            jerseyCam = false
            jerseyCamTilt = true
        end
        if curStep == 1023 then
            cameraFlash('game', 'ffffff', 1)
            jerseyCamTilt = false
        end
        if curStep == 1279 then
            cameraFlash('game', 'ffffff', 1)
            jerseyCamTilt = true
        end
        if curStep == 1406 then
            jerseyCamTilt = false
        end
        if curStep == 1407 then
            setValue('gameAngle', 5)
            setValue('hudAngle', -5)
        end
        if curStep == 1412 then
            setValue('gameAngle', -5)
            setValue('hudAngle',   5)
        end
        if curStep == 1416 then
            setValue('gameAngle', 5)
            setValue('hudAngle', -5)
        end
        if curStep == 1419 then
            setValue('gameAngle', -5)
            setValue('hudAngle',   5)
        end
        if curStep == 1422 then
            setValue('gameAngle', 5)
            setValue('hudAngle', -5)
            jerseyCamTilt = true
        end
        if curStep == 1438 then
            jerseyCamTilt = false
        end
        if curStep == 1439 then
            setValue('gameAngle', 5)
            setValue('hudAngle', -5)
        end
        if curStep == 1444 then
            setValue('gameAngle', -5)
            setValue('hudAngle',   5)
        end
        if curStep == 1448 then
            setValue('gameAngle', 5)
            setValue('hudAngle', -5)
        end
        if curStep == 1451 then
            setValue('gameAngle', -5)
            setValue('hudAngle',   5)
        end
        if curStep == 1454 then
            setValue('gameAngle', 5)
            setValue('hudAngle', -5)
            jerseyCamTilt = true
        end 
        if curStep == 1470 then jerseyCamTilt = true end
        if curStep == 1471 then
            setValue('gameAngle', 5)
            setValue('hudAngle', -5)
        end 
        if curStep == 1480 then
            setValue('gameAngle', -5)
            setValue('hudAngle', 5)
        end 
        if curStep == 1486 then jerseyCamTilt = true end
        if curStep == 1530 then jerseyCamTilt = false end
        if curStep == 1535 then cameraFlash('game', 'ffffff', 1) end
        if curStep >= 1791 and curStep <= 2031 then
            setProperty('defaultCamZoom', getProperty('defaultCamZoom')+0.001)
        end
        if curStep == 2048 then jerseyCam = true end
        if curStep == 2295 then jerseyCam = false end
        if curStep == 2304 then jerseyCamTilt = true end
        if curStep == 2431 then jerseyCamTilt = false end
        if curStep == 2432 then
            setValue('gameAngle', 5)
            setValue('hudAngle', -5)
        end
        if curStep == 2436 then
            setValue('gameAngle', -5)
            setValue('hudAngle',   5)
        end
        if curStep == 2440 then
            setValue('gameAngle', 5)
            setValue('hudAngle', -5)
        end
        if curStep == 2443 then
            setValue('gameAngle', -5)
            setValue('hudAngle',   5)
        end
        if curStep == 2446 then
            setValue('gameAngle', 5)
            setValue('hudAngle', -5)
            jerseyCamTilt = true
        end
        if curStep == 2463 then jerseyCamTilt = false end
        if curStep == 2464 then
            setValue('gameAngle', 5)
            setValue('hudAngle', -5)
        end
        if curStep == 2468 then
            setValue('gameAngle', -5)
            setValue('hudAngle',   5)
        end
        if curStep == 2472 then
            setValue('gameAngle', 5)
            setValue('hudAngle', -5)
        end
        if curStep == 2475 then
            setValue('gameAngle', -5)
            setValue('hudAngle',   5)
        end
        if curStep == 2478 then
            setValue('gameAngle', 5)
            setValue('hudAngle', -5)
            jerseyCamTilt = true
        end
        if curStep == 2495 then jerseyCamTilt = false end
        if curStep == 2496 then
            setValue('gameAngle', 5)
            setValue('hudAngle', -5)
        end 
        if curStep == 2504 then
            setValue('gameAngle', -5)
            setValue('hudAngle', 5)
        end 
        if curStep == 2512 then jerseyCamTilt = true end
        if curStep == 2552 then jerseyCamTilt = false end
        if curStep == 2560 then cameraFlash('other', 'ffffff', 5) setObjectCamera('void', 'other') setProperty('void.alpha', 1) end
    end


    if jerseyCam then
        if curStep % 16 == 0 then
            setProperty('camGame.zoom', getProperty('camGame.zoom')+0.2)
        end
        if curStep % 16 == 4 then
            setProperty('camGame.zoom', getProperty('camGame.zoom')+0.2)
        end
        if curStep % 16 == 8 then
            setProperty('camGame.zoom', getProperty('camGame.zoom')+0.2)
        end
        if curStep % 16 == 11 then
            setProperty('camGame.zoom', getProperty('camGame.zoom')+0.2)
        end
        if curStep % 16 == 15 then
            setProperty('camGame.zoom', getProperty('camGame.zoom')+0.2)
        end
    end
    if jerseyCamTilt then
        if curStep % 16 == 0 then
            setProperty('camGame.zoom', getProperty('camGame.zoom')+0.2)
            setValue('gameAngle', 5)
            setValue('hudAngle', -5)
            queueEase(curStep, curStep+3, 'gameAngle', 0)
            queueEase(curStep, curStep+3, 'hudAngle', 0)
        end
        if curStep % 16 == 4 then
            setProperty('camGame.zoom', getProperty('camGame.zoom')+0.2)
            setValue('gameAngle', -5)
            setValue('hudAngle', 5)
            queueEase(curStep, curStep+3, 'gameAngle', 0)
            queueEase(curStep, curStep+3, 'hudAngle', 0)
        end
        if curStep % 16 == 8 then
            setProperty('camGame.zoom', getProperty('camGame.zoom')+0.2)
        end
        if curStep % 16 == 11 then
            setProperty('camGame.zoom', getProperty('camGame.zoom')+0.2)
        end
        if curStep % 16 == 14 then
            setProperty('camGame.zoom', getProperty('camGame.zoom')+0.2)
        end
    end
end

cur = 0
curOpp = 0
function opponentNoteHit(index, noteDir, noteType, isSustainNote)
    if modcharts then 
        if liveStep >= 1023 and liveStep <= 1276 then
            setProperty('camGame.zoom', getProperty('camGame.zoom')+0.2)
        end
    end
    setHealth(getHealth() - 0.02)
end

function goodNoteHit(index, noteDir, noteType, isSustainNote)
    if modcharts then
        if liveStep >= 1023 and liveStep <= 1276 then
            setProperty('camGame.zoom', getProperty('camGame.zoom')+0.2)
        end
    end
end

function onModifierRegisterPost()
    addBlankMod('gameAngle', 0)
    addBlankMod('hudAngle', 0)
end

function onUpdate(elapsed)
    setProperty('camGame.angle', getValue('gameAngle'))
    setProperty('camHUD.angle', getValue('hudAngle'))
    if keyboardJustPressed('SPACE') then
        setProperty("void.alpha", 0)
    end
    for i = #continuous, 1, -1 do
        local data = continuous[i];
        if(curStep >= data[1])then
            if(curStep > data[2])then
                table.remove(continuous, i)
            else
                data[3](getProperty("curDecStep"));
            end
        end
    end
    if quake then
        for i = 0, 3 do
            setValue('transform'..i..'X', getRandomFloat(-10, 10))
            setValue('transform'..i..'Y', getRandomFloat(-10, 10))
        end
    end
end

function onBeatHit()
    if rave1 then
        if curBeat % 2 == 0 then
            queueEase(liveStep, liveStep, 'centerrotateY', 50, 'sineOut', 0)
            queueEase(liveStep+1, liveStep+7, 'centerrotateY', 0, 'cubeOut', 0)
        else
            queueEase(liveStep, liveStep, 'centerrotateY', -50, 'sineOut', 0)
            queueEase(liveStep+1, liveStep+7, 'centerrotateY', 0, 'cubeOut', 0)
        end
    end
    if rave2 then
        if curBeat % 2 == 0 then
            queueEase(liveStep, liveStep, 'centerrotateY', 50, 'sineOut', 0)
            queueEase(liveStep+1, liveStep+7, 'centerrotateY', 0, 'cubeOut', 0)

            queueEase(liveStep, liveStep, 'centerrotateZ', 50, 'sineOut', 0)
            queueEase(liveStep+1, liveStep+7, 'centerrotateZ', 0, 'cubeOut', 0)
        else
            queueEase(liveStep, liveStep, 'centerrotateY', -50, 'sineOut', 0)
            queueEase(liveStep+1, liveStep+7, 'centerrotateY', 0, 'cubeOut', 0)

            queueEase(liveStep, liveStep, 'centerrotateZ', -50, 'sineOut', 0)
            queueEase(liveStep+1, liveStep+7, 'centerrotateZ', 0, 'cubeOut', 0)
        end
    end
    if rave3 then
        queueEase(liveStep, liveStep, 'mini', 1, 'sineOut', 0)
        queueEase(liveStep+1, liveStep+3, 'mini', 0, 'cubeOut', 0)

        queueEase(liveStep, liveStep, 'confusion', 0.1, 'sineOut', 0)
        queueEase(liveStep+1, liveStep+4, 'confusion', 0, 'cubeOut', 0)

        if curBeat % 2 == 0 then
            queueEase(liveStep, liveStep, 'centerrotateY', 50, 'sineOut', 0)
            queueEase(liveStep+1, liveStep+7, 'centerrotateY', 0, 'cubeOut', 0)

            queueEase(liveStep, liveStep, 'centerrotateZ', 50, 'sineOut', 0)
            queueEase(liveStep+1, liveStep+7, 'centerrotateZ', 0, 'cubeOut', 0)
        else
            queueEase(liveStep, liveStep, 'centerrotateY', -50, 'sineOut', 0)
            queueEase(liveStep+1, liveStep+7, 'centerrotateY', 0, 'cubeOut', 0)

            queueEase(liveStep, liveStep, 'centerrotateZ', -50, 'sineOut', 0)
            queueEase(liveStep+1, liveStep+7, 'centerrotateZ', 0, 'cubeOut', 0)
        end
    end
    if flipflop then
        if curBeat % 2 == 0 then
            setValue('reverse', 1, 0)
            setValue('transform0Y', 150, 0)
            setValue('transform2Y', 150, 0)
            setValue('transform1Y', -150, 0)
            setValue('transform3Y', -150, 0)
            queueEase(liveStep, liveStep+3, 'transform0Y', 0, 'cubeOut', 0)
            queueEase(liveStep, liveStep+3, 'transform1Y', 0, 'cubeOut', 0)
            queueEase(liveStep, liveStep+3, 'transform2Y', 0, 'cubeOut', 0)
            queueEase(liveStep, liveStep+3, 'transform3Y', 0, 'cubeOut', 0)
        end
        if curBeat % 2 == 1 then
            setValue('reverse', 0, 0)
            setValue('transform0Y', -150, 0)
            setValue('transform2Y', -150, 0)
            setValue('transform1Y', 150, 0)
            setValue('transform3Y', 150, 0)
            queueEase(liveStep, liveStep+3, 'transform0Y', 0, 'cubeOut', 0)
            queueEase(liveStep, liveStep+3, 'transform1Y', 0, 'cubeOut', 0)
            queueEase(liveStep, liveStep+3, 'transform2Y', 0, 'cubeOut', 0)
            queueEase(liveStep, liveStep+3, 'transform3Y', 0, 'cubeOut', 0)
        end
    end
    if flipflop2 then
        if curBeat % 4 == 0 then
            queueEase(liveStep, liveStep+3, 'invert', 1, 'cubeOut', 0)
        end
        if curBeat % 4 == 1 then
            queueEase(liveStep, liveStep+3, 'invert', 0, 'cubeOut', 0)
        end
        if curBeat % 4 == 2 then
            queueEase(liveStep, liveStep+3, 'flip', 1, 'cubeOut', 0)
        end
        if curBeat % 4 == 3 then
            queueEase(liveStep, liveStep+3, 'flip', 0, 'cubeOut', 0)
        end
    end
end

queueContFunc(0, 999999999999999999, function(step)
    local beat = step / 4;
    for col = 0, 3 do
        local speed = getValue("haloSpeed", 0)
        local input = (col + 1 + beat) * math.rad(360 / 4)
        local radiusX = getValue("haloRadiusX", 0)
        local radiusZ = getValue("haloRadiusZ", 0)
        setValue("transform" .. col .. "X", radiusX * math.sin(input) * speed, 0)
        setValue("transform" .. col .. "Z", radiusZ * math.cos(input) * speed, 0)
    end
end)