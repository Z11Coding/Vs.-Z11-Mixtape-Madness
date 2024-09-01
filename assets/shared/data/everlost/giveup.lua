local optionCur = 0
function onStepHit()
    if curStep == 351 then
        openCustomSubstate("GiveUp", true)
        setProperty('camHUD.alpha', 0)
    end
end

function onCustomSubstateCreatePost(name)
    if name == "GiveUp" then
        makeLuaSprite("giveup", 'lost/giveup', 0, 0)
        insertToCustomSubstate('giveup')
        makeLuaText('ye', '>Yes', 400, -300, 0)
        screenCenter("ye", 'y')
        scaleObject('ye', 3, 3, true)
        setTextFont("ye", "pixel.otf")
        addLuaText('ye')
        insertToCustomSubstate('ye')
        makeLuaText('no', 'No', 400, 350, 0)
        screenCenter("no", 'y')
        scaleObject('no', 3, 3, true)
        setTextFont("no", "pixel.otf")
        addLuaText('no')
        insertToCustomSubstate('no')
        setObjectCamera('ye', 'other')
        setObjectCamera('no', 'other')
    end
end

function onCustomSubstateUpdate()
    if keyboardJustPressed('LEFT') or keyboardJustPressed('A') then
        optionCur = optionCur + 1
    end
    if keyboardJustPressed('RIGHT') or keyboardJustPressed('D') then
        optionCur = optionCur - 1
    end
    if optionCur > 1 then
        optionCur = 0
    end
    if optionCur < 0 then
        optionCur = 1
    end
    if optionCur == 0 then
        setTextString("ye", ">Yes")
        setTextString("no", "No")
    else
        setTextString("ye", "Yes")
        setTextString("no", ">No")
    end
    if keyboardJustPressed('ENTER') then
        if optionCur == 0 then
            removeLuaText('ye', true)
            removeLuaText('no', true)
            closeCustomSubstate('GiveUp')
        else
            removeLuaText('ye', true)
            removeLuaText('no', true)
            closeCustomSubstate('GiveUp')
            loadSong('EverFound', -1)
        end
    end
end