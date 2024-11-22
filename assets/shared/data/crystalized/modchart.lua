local window_default = {}
local eT = 0 --elapsed time
local reach = {
    x = 200,
    y = 150
}
local speed = {
    x = 1.1,
    y = 2
}
local offset = {
    x = 0,
    y = -10000
}

function onDestroy()
    setPropertyFromClass('lime.app.Application','current.window.x', window_default[1])
    setPropertyFromClass('lime.app.Application','current.window.y', window_default[2])
    setPropertyFromClass('lime.app.Application','current.window.width', window_default[3])
    setPropertyFromClass('lime.app.Application','current.window.height', window_default[4])
    setPropertyFromClass('lime.app.Application','current.window.borderless', false)
end

function onCreatePost()
    makeLuaSprite("void")
    makeGraphic("void", screenWidth, screenHeight, '000000')
    setObjectCamera('void', 'camHUD')
    screenCenter("void")
    addLuaSprite("void", true)

    window_default[1] = getPropertyFromClass('lime.app.Application','current.window.x')
    window_default[2] = getPropertyFromClass('lime.app.Application','current.window.y')
    window_default[3] = getPropertyFromClass('lime.app.Application','current.window.width')
    window_default[4] = getPropertyFromClass('lime.app.Application','current.window.height')
    setProperty('camZooming', true)
    setProperty('camZoomingMult', 0)

    if getPropertyFromClass('backend.ClientPrefs', "data.modcharts") then
        makeLuaSprite("Window") --So that i can tween window stuff
        setProperty("Window.x", window_default[1])
        setProperty("Window.y", window_default[2])
        setProperty("Window.width", window_default[3])
        setProperty("Window.height", window_default[4])
        setProperty('camZoomingMult', 0)
        setPropertyFromClass('lime.app.Application','current.window.borderless', false)

        queueEase(2436, 2440, 'drunk', 1, 'quadOut')
        queueEase(2436, 2440, 'tornado', 1, 'quadOut')

        camWidth = getProperty("camGame.width")
        camHeight = getProperty("camGame.height")

        addBlankMod('screenSize', 1)
    end
end

function onUpdatePost(elapsed)
    if getPropertyFromClass('backend.ClientPrefs', "data.modcharts") then
        setWindowOppacity(getProperty("Window.alpha"))
        if songStarted then
            setPropertyFromClass('lime.app.Application','current.window.x', getProperty("Window.x"))
            setPropertyFromClass('lime.app.Application','current.window.y', getProperty("Window.y"))
            setPropertyFromClass('lime.app.Application','current.window.width', getProperty("Window.width") * getValue("screenSize"))
            setPropertyFromClass('lime.app.Application','current.window.height', getProperty("Window.height") * getValue("screenSize"))
        end
        if levetate then
            eT = eT + elapsed
            setProperty('Window.x', window_default[1] + math.sin((eT * speed.x) + offset.x) * reach.x)
            setProperty('Window.y', window_default[2] + math.cos((eT * speed.y) + offset.y) * reach.y)
        end
        if getProperty("Window.width") > window_default[3] then setProperty("Window.width", getProperty("Window.width")-0.5) end
        if getProperty("Window.height") > window_default[4] then setProperty("Window.height", getProperty("Window.height")-0.5) end
    end
end

function onSkipIntro()
    if getPropertyFromClass('backend.ClientPrefs', "data.modcharts") then
        cancelTween('WindowAlpha')
        cancelTween('WindowY')
        setWindowPos(window_default[1], window_default[2])
        setProperty('Window.alpha', 1)
    end
    setProperty('void.alpha', 0)
    cancelTween('voidAlpha')
end

function onSongStart()
    songStarted = true
    if getPropertyFromClass('backend.ClientPrefs', "data.modcharts") then
        if curStep == 0 then
            doTweenAlpha('WindowAlpha', "Window", 0, stepCrochet*0.001*8, 'sineInOut')
        else    
            doTweenAlpha('voidAlpha', "void", 0, stepCrochet*0.001*8, 'sineInOut')
        end
    else
        doTweenAlpha('voidAlpha', "void", 0, stepCrochet*0.001*8, 'sineInOut')
    end
end

function resetWindowPos(time, size)
    if getPropertyFromClass('backend.ClientPrefs', "data.modcharts") then
        doTweenX('WindowX', "Window", window_default[1], stepCrochet*0.001*time, 'sineInOut')
        doTweenY('WindowY', "Window", window_default[2], stepCrochet*0.001*time, 'sineInOut')
        if size == true then
            setProperty("Window.width", window_default[3])
            setProperty("Window.height", window_default[4])
        end
    end
end

function setWindowPos(x, y)
    setProperty("Window.x", x)
    setProperty("Window.y", y)
end

function tweenWindowPos(x, y, time)
    doTweenX('WindowX', "Window", x, stepCrochet*0.001*time, 'circOut')
    doTweenY('WindowY', "Window", y, stepCrochet*0.001*time, 'circOut')

end

function onStepHit()
    if getPropertyFromClass('backend.ClientPrefs', "data.modcharts") then
        if curStep == 8 then
            setWindowPos(window_default[1], window_default[2] - 1000)
            doTweenY('WindowY', 'Window', window_default[2], stepCrochet*0.001*(128*2), 'sineInOut')
            doTweenAlpha('WindowAlpha', "Window", 1, stepCrochet*0.001*(128*2), 'sineInOut')
            doTweenAlpha('voidAlpha', "void", 0, stepCrochet*0.001*(128*2), 'sineInOut')
        end
        if curStep == 263 then
            preDrop = true 
            levetate = true
        end
        if curStep == 520 then
            part2 = true
        end
        if curStep == 775 then
            part2 = false
            preDrop = false
            levetate = false
            resetWindowPos(4, true)
        end
        if curStep == 776 then
            queueEase(curStep, curStep+3, 'centerrotateZ', 0, 'quadOut', 0)
            queueEase(curStep, curStep+3, 'centerrotateZ', 0, 'quadOut', 1)
            queueEase(curStep, curStep+3, 'centered', 1, 'quadOut')
            queueEase(curStep, curStep+3, 'centerrotateY', 90, 'quadOut')
        end
        if curStep == 792 then
            queueEase(curStep, curStep+15, 'centerrotateZ', 0, 'quadOut', 0)
            queueEase(curStep, curStep+15, 'centerrotateZ', 0, 'quadOut', 1)
            queueEase(curStep, curStep+15, 'flaccid', 0, 'quadOut', 0)
            queueEase(curStep, curStep+15, 'flaccid', 0, 'quadOut', 1)
            queueEase(curStep, curStep+15, 'reverse', 0, 'quadOut', 0)
            queueEase(curStep, curStep+15, 'reverse', 0, 'quadOut', 1)
            queueEase(curStep, curStep+15, 'centered', 0, 'quadOut')
            queueEase(curStep, curStep+15, 'centerrotateY', 360, 'quadOut')
            queueEase(curStep, curStep+15, 'noteAngle', 360, 'quadOut')
            queueEase(curStep, curStep+15, 'receptorAngle', 360, 'quadOut')
        end
        if curStep == 808 then
            setValue('centerrotateY', 0)
            setValue('noteAngle', 0)
            setValue('receptorAngle', 0)
            drop1 = true
            spin1 = true
        end
        if curStep == 1315 then
            drop1 = false
            spin1 = false
        end
        
        if curStep == 1380 then
            if not middlescroll then
                setValue('transformX', 325, 1)
                setValue('transformX', -325, 0)
                setValue('alpha', 1, 1)
                setValue('noteAlpha', 1, 1)
            end
        end

        if curStep >= 1384 and curStep <= 1891 then
            if (curStep-4) % 16 == 0 then
                setValue('cross', 0)
                setProperty('camGame.zoom', getProperty('camGame.zoom')+ 0.05)
                setProperty('camHUD.zoom', getProperty('camHUD.zoom')+ 0.05)
            end
            if (curStep-4) % 16 == 4 then
                setValue('split', 1)
                setProperty('camGame.zoom', getProperty('camGame.zoom')+ 0.05)
                setProperty('camHUD.zoom', getProperty('camHUD.zoom')+ 0.05)
            end
            if (curStep-4) % 16 == 8 then
                setValue('split', 0)
                setValue('alternate', 1)
                setProperty('camGame.zoom', getProperty('camGame.zoom')+ 0.05)
                setProperty('camHUD.zoom', getProperty('camHUD.zoom')+ 0.05)
            end
            if (curStep-4) % 16 == 12 then
                setValue('alternate', 0)
                setValue('cross', 1)
                setProperty('camGame.zoom', getProperty('camGame.zoom')+ 0.05)
                setProperty('camHUD.zoom', getProperty('camHUD.zoom')+ 0.05)
            end
            if (curStep-4) % 32 == 0 then
                setValue('reverse', 1)
            end
            if (curStep-4) % 32 == 16 then
                setValue('reverse', 0)
            end

            if (curStep-4) % 64 == 0 then
                setValue('centered', 0)
            end
            if (curStep-4) % 64 == 32 then
                setValue('centered', 1)
            end
        end

        if curStep == 1892 then
            setValue('centered', 0)
            setValue('reverse', 0)
            setValue('alternate', 0)
            setValue('split', 0)
            setValue('cross', 0)
            if not middlescroll then
                setValue('transformX', 0, 1)
                setValue('transformX', 0, 0)
                setValue('alpha', 0, 1)
                setValue('noteAlpha', 0, 1)
            end
            resetWindowPos(4, true)
        end

        if curStep == 1896 then
            preDrop2 = true
            levetate = true
        end
        if curStep == 2152 then
            part2 = true
        end

        if curStep == 2408 then
            queueEase(curStep, curStep+15, 'centerrotateZ', 0, 'quadOut', 0)
            queueEase(curStep, curStep+15, 'centerrotateZ', 0, 'quadOut', 1)
            queueEase(curStep, curStep+15, 'flaccid', 0, 'quadOut', 0)
            queueEase(curStep, curStep+15, 'flaccid', 0, 'quadOut', 1)
            queueEase(curStep, curStep+15, 'reverse', 0, 'quadOut', 0)
            queueEase(curStep, curStep+15, 'reverse', 0, 'quadOut', 1)
            queueEase(curStep, curStep+15, 'centered', 0, 'quadOut')
            queueEase(curStep, curStep+15, 'centerrotateY', 360, 'quadOut')
            queueEase(curStep, curStep+15, 'noteAngle', 360, 'quadOut')
            queueEase(curStep, curStep+15, 'receptorAngle', 360, 'quadOut')
            part2 = false
            preDrop2 = false
            levetate = false
            resetWindowPos(4, true)
        end

        if curStep == 2952 then
            levetate = true
            setValue("dizzy", 1)
        end

        if curStep == 3464 then
            levetate = false
            resetWindowPos(16, true)
            setValue("dizzy", 0)
            setValue("drunk", 0)
            cameraFlash('camGame', '000000', stepCrochet*0.001*16)
        end

        if curStep == 3496 then
            levetate = true
            preDrop2 = true
            cameraFlash('camGame', 'FFFFFF', 1, true)
        end

        if curStep == 3752 then
            part2 = true
        end

        if curStep == 4007 then
            part2 = false
            preDrop = false
            levetate = false
            resetWindowPos(4, true)
        end
        if curStep == 4008 then
            queueEase(curStep, curStep+3, 'centerrotateZ', 0, 'quadOut', 0)
            queueEase(curStep, curStep+3, 'centerrotateZ', 0, 'quadOut', 1)
            queueEase(curStep, curStep+3, 'centered', 1, 'quadOut')
            queueEase(curStep, curStep+3, 'centerrotateY', 90, 'quadOut')
        end
        if curStep == 4024 then
            queueEase(curStep, curStep+15, 'flaccid', 0, 'quadOut', 0)
            queueEase(curStep, curStep+15, 'flaccid', 0, 'quadOut', 1)
            queueEase(curStep, curStep+15, 'reverse', 0, 'quadOut', 0)
            queueEase(curStep, curStep+15, 'reverse', 0, 'quadOut', 1)
            queueEase(curStep, curStep+15, 'centered', 0, 'quadOut')
            queueEase(curStep, curStep+15, 'centerrotateY', 360, 'quadOut')
            queueEase(curStep, curStep+15, 'noteAngle', 360, 'quadOut')
            queueEase(curStep, curStep+15, 'receptorAngle', 360, 'quadOut')
        end
        if curStep == 4040 then
            setValue('centerrotateY', 0)
            setValue('noteAngle', 0)
            setValue('receptorAngle', 0)
            drop1 = true
            spin1 = true
        end

        if curStep == 4548 then
            drop1 = false
            spin1 = false
        end

        if curStep == 4552 then
            setProperty("Window.width", 0)
            setProperty("Window.height", 0)
            regrow = true
        end

        if drop1 then
            if curStep % 4 == 0 then
                setValue('tinyY', 0.5)
                queueEase(curStep, curStep+3, 'tinyY', 0, 'quadOut')
                if curStep % 8 == 0 then
                    setValue('drunk', -1)
                    queueEase(curStep, curStep+3, 'drunk', 0, 'quadOut')
                    queueEase(curStep, curStep+1, 'transform0Y', -50, 'circOut')
                    queueEase(curStep+2, curStep+3, 'transform0Y', 0, 'circIn')
                    queueEase(curStep, curStep+1, 'transform2Y', -50, 'sineInOut')
                    queueEase(curStep+2, curStep+3, 'transform2Y', 0, 'sineInOut')
                    setValue('rotateZ', -25)
                    queueEase(curStep, curStep+3, 'rotateZ', 0, 'quadOut')
                    setValue('note0Angle', -50)
                    queueEase(curStep, curStep+3, 'note0Angle', 0, 'quadOut')
                    setValue('receptor0Angle', -50)
                    queueEase(curStep, curStep+3, 'receptor0Angle', 0, 'quadOut')
                    setValue('note2Angle', -50)
                    queueEase(curStep, curStep+3, 'note2Angle', 0, 'quadOut')
                    setValue('receptor2Angle', -50)
                    queueEase(curStep, curStep+3, 'receptor2Angle', 0, 'quadOut')
                    setProperty('Window.x', getProperty('Window.x')+50)
                    doTweenX('WindowX', "Window", window_default[1], stepCrochet*0.001*4, 'quadOut')
                end
                if curStep % 8 == 4 then
                    setValue('drunk', 1)
                    queueEase(curStep, curStep+3, 'drunk', 0, 'quadOut')
                    queueEase(curStep, curStep+1, 'transform3Y', -50, 'circOut')
                    queueEase(curStep+2, curStep+3, 'transform3Y', 0, 'circIn')
                    queueEase(curStep, curStep+1, 'transform1Y', -50, 'sineInOut')
                    queueEase(curStep+2, curStep+3, 'transform1Y', 0, 'sineInOut')
                    setValue('rotateZ', 25)
                    queueEase(curStep, curStep+3, 'rotateZ', 0, 'quadOut')
                    setValue('note3Angle', 50)
                    queueEase(curStep, curStep+3, 'note3Angle', 0, 'quadOut')
                    setValue('receptor3Angle', 50)
                    queueEase(curStep, curStep+3, 'receptor3Angle', 0, 'quadOut')
                    setValue('note1Angle', 50)
                    queueEase(curStep, curStep+3, 'note1Angle', 0, 'quadOut')
                    setValue('receptor1Angle', 50)
                    queueEase(curStep, curStep+3, 'receptor1Angle', 0, 'quadOut')
                    setProperty('Window.x', getProperty('Window.x')-50)
                    doTweenX('WindowX', "Window", window_default[1], stepCrochet*0.001*4, 'quadOut')
                end
            end
        end

        if preDrop then
            if (curStep-8) % (16*4) == 0 then
                setProperty('camGame.zoom', getProperty('camGame.zoom')+ 0.05)
                setProperty('camHUD.zoom', getProperty('camHUD.zoom')+ 0.05)
                if part2 and ((curStep-8) % (16*8) == 0 or (curStep-8) % (16*8) == 62) then 
                    queueEase(curStep, curStep+3, 'centerrotateY', 180, 'quadOut')
                elseif not part2 then
                    queueEase(curStep, curStep+3, 'centerrotateY', 180, 'quadOut')
                end
                if part2 then 
                    queueEase(curStep, curStep+3, 'centerrotateZ', 15, 'quadOut', 0)
                    queueEase(curStep, curStep+3, 'centerrotateZ', -15, 'quadOut', 1)
                    queueEase(curStep, curStep+3, 'flaccid', 0.4, 'quadOut', 0)
                    queueEase(curStep, curStep+3, 'flaccid', -0.4, 'quadOut', 1)
                    queueEase(curStep, curStep+3, 'reverse', 1, 'quadOut', 0)
                    queueEase(curStep, curStep+3, 'reverse', 0, 'quadOut', 1)
                end
            end
            if (curStep-8) % (16*4) == 8 then
                queueEase(curStep, curStep+1, 'invert', 0.95, 'quadOut')
            end
            if (curStep-8) % (16*4) == 12 then
                setProperty('camGame.zoom', getProperty('camGame.zoom')+ 0.05)
                setProperty('camHUD.zoom', getProperty('camHUD.zoom')+ 0.05)
                queueEase(curStep, curStep+1, 'invert', 0, 'quadOut')
            end
            if (curStep-8) % (16*4) == 16 then
                queueEase(curStep, curStep+1, 'invert', 0.95, 'quadOut')
            end
            if (curStep-8) % (16*4) == 20 then
                setProperty('camGame.zoom', getProperty('camGame.zoom')+ 0.05)
                setProperty('camHUD.zoom', getProperty('camHUD.zoom')+ 0.05)
                
                queueEase(curStep, curStep+1, 'invert', 0, 'quadOut')
            end
            if (curStep-8) % (16*4) == 24 then
                queueEase(curStep, curStep+7, 'opponentSwap', 1, 'quadOut')
                queueEase(curStep, curStep+7, 'noteAngle', -360, 'sineOut')
                queueEase(curStep, curStep+7, 'receptorAngle', -360, 'sineOut')
            end

            if (curStep-8) % (16*4) == 32 then
                setProperty('camGame.zoom', getProperty('camGame.zoom')+ 0.05)
                setProperty('camHUD.zoom', getProperty('camHUD.zoom')+ 0.05)
                
                if part2 and ((curStep-8) % (16*8) == 32 or (curStep-8) % (16*8) == (32*4)) then 
                    queueEase(curStep, curStep+3, 'centerrotateY', 0, 'quadOut')
                elseif not part2 then
                    queueEase(curStep, curStep+3, 'centerrotateY', 0, 'quadOut')
                end
                if part2 then 
                    queueEase(curStep, curStep+3, 'centerrotateZ', -15, 'quadOut', 0)
                    queueEase(curStep, curStep+3, 'centerrotateZ', 15, 'quadOut', 1)
                    queueEase(curStep, curStep+3, 'flaccid', 0.4, 'quadOut', 0)
                    queueEase(curStep, curStep+3, 'flaccid', -0.4, 'quadOut', 1)
                    queueEase(curStep, curStep+3, 'reverse', 0, 'quadOut', 0)
                    queueEase(curStep, curStep+3, 'reverse', 1, 'quadOut', 1)
                end
            end
            if (curStep-8) % (16*4) == 40 then
                queueEase(curStep, curStep+1, 'invert', 0.95, 'quadOut')
            end
            if (curStep-8) % (16*4) == 44 then
                setProperty('camGame.zoom', getProperty('camGame.zoom')+ 0.05)
                setProperty('camHUD.zoom', getProperty('camHUD.zoom')+ 0.05)
                
                queueEase(curStep, curStep+1, 'invert', 0, 'quadOut')
            end
            if (curStep-8) % (16*4) == 48 then
                queueEase(curStep, curStep+1, 'invert', 0.95, 'quadOut')
            end
            if (curStep-8) % (16*4) == 52 then
                setProperty('camGame.zoom', getProperty('camGame.zoom')+ 0.05)
                setProperty('camHUD.zoom', getProperty('camHUD.zoom')+ 0.05)
                
                queueEase(curStep, curStep+1, 'invert', 0, 'quadOut')
            end
            if (curStep-8) % (16*4) == 56 then
                setProperty('camGame.zoom', getProperty('camGame.zoom')+ 0.02)
                setProperty('camHUD.zoom', getProperty('camHUD.zoom')+ 0.02)
                
                queueEase(curStep, curStep+7, 'opponentSwap', 0, 'quadOut')
                queueEase(curStep, curStep+7, 'noteAngle', 0, 'sineOut')
                queueEase(curStep, curStep+7, 'receptorAngle', 0, 'sineOut')
                setValue('centerrotateX', 50)
                queueEase(curStep, curStep+3, 'centerrotateX', 0, 'sineOut')
            end
            if (curStep-8) % (16*4) == 60 then
                setProperty('camGame.zoom', getProperty('camGame.zoom')- 0.02)
                setProperty('camHUD.zoom', getProperty('camHUD.zoom')- 0.02)
                
                setValue('centerrotateX', -50)
                queueEase(curStep, curStep+3, 'centerrotateX', 0, 'sineOut')
            end
        end

        if preDrop2 then
            if (curStep-40) % (16*4) == 0 then
                setProperty('camGame.zoom', getProperty('camGame.zoom')+ 0.05)
                setProperty('camHUD.zoom', getProperty('camHUD.zoom')+ 0.05)
                if part2 and ((curStep-40) % (16*8) == 0 or (curStep-40) % (16*8) == 62) then 
                    queueEase(curStep, curStep+3, 'centerrotateY', 180, 'quadOut')
                elseif not part2 then
                    queueEase(curStep, curStep+3, 'centerrotateY', 180, 'quadOut')
                end
                if part2 then 
                    queueEase(curStep, curStep+3, 'reverse', 1, 'quadOut', 0)
                    queueEase(curStep, curStep+3, 'reverse', 0, 'quadOut', 1)
                end
            end
            if (curStep-40) % (16*4) == 8 then
                queueEase(curStep, curStep+1, 'invert', 0.95, 'quadOut')
            end
            if (curStep-40) % (16*4) == 12 then
                setProperty('camGame.zoom', getProperty('camGame.zoom')+ 0.05)
                setProperty('camHUD.zoom', getProperty('camHUD.zoom')+ 0.05)
                queueEase(curStep, curStep+1, 'invert', 0, 'quadOut')
            end
            if (curStep-40) % (16*4) == 16 then
                queueEase(curStep, curStep+1, 'invert', 0.95, 'quadOut')
            end
            if (curStep-40) % (16*4) == 20 then
                setProperty('camGame.zoom', getProperty('camGame.zoom')+ 0.05)
                setProperty('camHUD.zoom', getProperty('camHUD.zoom')+ 0.05)
                queueEase(curStep, curStep+1, 'invert', 0, 'quadOut')
            end
            if (curStep-40) % (16*4) == 24 then
                queueEase(curStep, curStep+7, 'opponentSwap', 1, 'quadOut')
                queueEase(curStep, curStep+7, 'noteAngle', -360, 'sineOut')
                queueEase(curStep, curStep+7, 'receptorAngle', -360, 'sineOut')
            end

            if (curStep-40) % (16*4) == 32 then
                setProperty('camGame.zoom', getProperty('camGame.zoom')+ 0.05)
                setProperty('camHUD.zoom', getProperty('camHUD.zoom')+ 0.05)
                if part2 and ((curStep-40) % (16*8) == 32 or (curStep-40) % (16*8) == (32*4)) then 
                    queueEase(curStep, curStep+3, 'centerrotateY', 0, 'quadOut')
                elseif not part2 then
                    queueEase(curStep, curStep+3, 'centerrotateY', 0, 'quadOut')
                end
                if part2 then 
                    queueEase(curStep, curStep+3, 'reverse', 0, 'quadOut', 0)
                    queueEase(curStep, curStep+3, 'reverse', 1, 'quadOut', 1)
                end
            end
            if (curStep-40) % (16*4) == 40 then
                queueEase(curStep, curStep+1, 'invert', 0.95, 'quadOut')
            end
            if (curStep-40) % (16*4) == 44 then
                setProperty('camGame.zoom', getProperty('camGame.zoom')+ 0.05)
                setProperty('camHUD.zoom', getProperty('camHUD.zoom')+ 0.05)
                queueEase(curStep, curStep+1, 'invert', 0, 'quadOut')
            end
            if (curStep-40) % (16*4) == 48 then
                queueEase(curStep, curStep+1, 'invert', 0.95, 'quadOut')
            end
            if (curStep-40) % (16*4) == 52 then
                setProperty('camGame.zoom', getProperty('camGame.zoom')+ 0.05)
                setProperty('camHUD.zoom', getProperty('camHUD.zoom')+ 0.05)
                queueEase(curStep, curStep+1, 'invert', 0, 'quadOut')
            end
            if (curStep-40) % (16*4) == 56 then
                setProperty('camGame.zoom', getProperty('camGame.zoom')+ 0.02)
                setProperty('camHUD.zoom', getProperty('camHUD.zoom')+ 0.02)
                queueEase(curStep, curStep+7, 'opponentSwap', 0, 'quadOut')
                queueEase(curStep, curStep+7, 'noteAngle', 0, 'sineOut')
                queueEase(curStep, curStep+7, 'receptorAngle', 0, 'sineOut')
                setValue('centerrotateX', 50)
                queueEase(curStep, curStep+3, 'centerrotateX', 0, 'sineOut')
            end
            if (curStep-40) % (16*4) == 60 then
                setProperty('camGame.zoom', getProperty('camGame.zoom')- 0.02)
                setProperty('camHUD.zoom', getProperty('camHUD.zoom')- 0.02)
                setValue('centerrotateX', -50)
                queueEase(curStep, curStep+3, 'centerrotateX', 0, 'sineOut')
            end
        end
    else
        if curStep == 8 then
            doTweenAlpha('voidAlpha', "void", 0, stepCrochet*0.001*(128*2), 'sineInOut')
        end
        if curStep == 263 then
            preDrop = true 
        end
        if curStep == 775 then
            preDrop = false
        end
        if curStep == 808 then
            drop1 = true
        end
        if curStep == 1315 then
            drop1 = false
        end

        if curStep >= 1384 and curStep <= 1891 then
            if (curStep-4) % 4 == 0 then
                setProperty('camGame.zoom', getProperty('camGame.zoom')+ 0.05)
                setProperty('camHUD.zoom', getProperty('camHUD.zoom')+ 0.05)
            end
        end

        if curStep == 1896 then
            preDrop2 = true
        end

        if curStep == 2408 then
            preDrop2 = false
        end

        if curStep == 3464 then
            cameraFlash('camGame', '000000', stepCrochet*0.001*16)
        end

        if curStep == 3496 then
            preDrop2 = true
            cameraFlash('camGame', 'FFFFFF', 1, true)
        end

        if curStep == 4007 then
            preDrop = false
        end

        if curStep == 4040 then
            drop1 = true
        end

        if curStep == 4548 then
            drop1 = false
        end

        if drop1 then
            if curStep % 4 == 0 then
                if curStep % 8 == 0 then
                    setProperty('camGame.zoom', getProperty('camGame.zoom')+ 0.05)
                setProperty('camHUD.zoom', getProperty('camHUD.zoom')+ 0.05)
                end
                if curStep % 8 == 4 then
                    setProperty('camGame.zoom', getProperty('camGame.zoom')+ 0.05)
                setProperty('camHUD.zoom', getProperty('camHUD.zoom')+ 0.05)
                end
            end
        end

        if preDrop then
            if (curStep-8) % (16*4) == 0 then
                setProperty('camGame.zoom', getProperty('camGame.zoom')+ 0.05)
                setProperty('camHUD.zoom', getProperty('camHUD.zoom')+ 0.05)
            end
            if (curStep-8) % (16*4) == 12 then
                setProperty('camGame.zoom', getProperty('camGame.zoom')+ 0.05)
                setProperty('camHUD.zoom', getProperty('camHUD.zoom')+ 0.05)
            end
            if (curStep-8) % (16*4) == 20 then
                setProperty('camGame.zoom', getProperty('camGame.zoom')+ 0.05)
                setProperty('camHUD.zoom', getProperty('camHUD.zoom')+ 0.05)
            end

            if (curStep-8) % (16*4) == 32 then
                setProperty('camGame.zoom', getProperty('camGame.zoom')+ 0.05)
                setProperty('camHUD.zoom', getProperty('camHUD.zoom')+ 0.05)
            end
            if (curStep-8) % (16*4) == 44 then
                setProperty('camGame.zoom', getProperty('camGame.zoom')+ 0.05)
                setProperty('camHUD.zoom', getProperty('camHUD.zoom')+ 0.05)
            end
            if (curStep-8) % (16*4) == 52 then
                setProperty('camGame.zoom', getProperty('camGame.zoom')+ 0.05)
                setProperty('camHUD.zoom', getProperty('camHUD.zoom')+ 0.05)
            end
            if (curStep-8) % (16*4) == 56 then
                setProperty('camGame.zoom', getProperty('camGame.zoom')+ 0.02)
                setProperty('camHUD.zoom', getProperty('camHUD.zoom')+ 0.02)
            end
            if (curStep-8) % (16*4) == 60 then
                setProperty('camGame.zoom', getProperty('camGame.zoom')- 0.02)
                setProperty('camHUD.zoom', getProperty('camHUD.zoom')- 0.02)
            end
        end

        if preDrop2 then
            if (curStep-40) % (16*4) == 0 then
                setProperty('camGame.zoom', getProperty('camGame.zoom')+ 0.05)
                setProperty('camHUD.zoom', getProperty('camHUD.zoom')+ 0.05)
            end
            if (curStep-40) % (16*4) == 12 then
                setProperty('camGame.zoom', getProperty('camGame.zoom')+ 0.05)
                setProperty('camHUD.zoom', getProperty('camHUD.zoom')+ 0.05)
            end
            if (curStep-40) % (16*4) == 20 then
                setProperty('camGame.zoom', getProperty('camGame.zoom')+ 0.05)
                setProperty('camHUD.zoom', getProperty('camHUD.zoom')+ 0.05)
            end
            if (curStep-40) % (16*4) == 32 then
                setProperty('camGame.zoom', getProperty('camGame.zoom')+ 0.05)
                setProperty('camHUD.zoom', getProperty('camHUD.zoom')+ 0.05)
            end
            if (curStep-40) % (16*4) == 44 then
                setProperty('camGame.zoom', getProperty('camGame.zoom')+ 0.05)
                setProperty('camHUD.zoom', getProperty('camHUD.zoom')+ 0.05)
            end
            if (curStep-40) % (16*4) == 52 then
                setProperty('camGame.zoom', getProperty('camGame.zoom')+ 0.05)
                setProperty('camHUD.zoom', getProperty('camHUD.zoom')+ 0.05)
            end
            if (curStep-40) % (16*4) == 56 then
                setProperty('camGame.zoom', getProperty('camGame.zoom')+ 0.02)
                setProperty('camHUD.zoom', getProperty('camHUD.zoom')+ 0.02)
            end
            if (curStep-40) % (16*4) == 60 then
                setProperty('camGame.zoom', getProperty('camGame.zoom')- 0.02)
                setProperty('camHUD.zoom', getProperty('camHUD.zoom')- 0.02)
            end
        end
    end
end