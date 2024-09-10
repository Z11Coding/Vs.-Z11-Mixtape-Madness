local amountLeft = 1
local safeForNow = false
local safeCheck = false
function onCreatePost()
    luaDebugMode = true
    setProperty("boyfriend.y", getProperty("boyfriend.y") - 10)
    setProperty("dad.y", getProperty("dad.y") + 70)

    makeLuaSprite("redFlash", "effects/RedVG", 0, 0)
    setObjectCamera("redFlash", "hud")
    screenCenter("redFlash", 'xy')
    addLuaSprite("redFlash", true)
    setProperty("redFlash.alpha", 0)

    makeLuaSprite("sign", "mechanics/resist/Sign", 0, 0)
    setObjectCamera("sign", "hud")
    scaleObject("sign", 0.5, 0.5)
    updateHitbox("sign")
    screenCenter("sign", 'xy')
    addLuaSprite("sign", true)
    setProperty("sign.alpha", 0)

    makeLuaSprite("x", "mechanics/resist/twitter", 0, 0)
    setObjectCamera("x", "hud")
    scaleObject("x", 0.5, 0.5)
    updateHitbox("x")
    screenCenter("x", 'xy')
    addLuaSprite("x", true)
    setProperty("x.alpha", 0)

    makeLuaText("warnem", "WAIT...", 700, 0, 500)
    setObjectCamera("warnem", "hud")
    setTextSize('warnem', 50)
    screenCenter('warnem', 'X')
    addLuaText("warnem")
    setProperty("warnem.alpha", 0)
    setProperty("warnem.x", getProperty("warnem.x") + 30)

    setProperty('gfGroup.x', getProperty('gfGroup.x') + 500)
    setProperty('gfGroup.alpha', 0)
end

function onEvent(name, value1, value2)
    if name == 'doAttackMech' then
        setTextColor("warnem", "YELLOW")
        setTextString("warnem", "WAIT...")
        if difficultyName == 'Nightmare' then
            if keyboardPressed("SPACE") then
                setProperty("health", 0)
                setProperty("dad.x", getProperty("dad.x") + 400)
            end
            setProperty("redFlash.alpha", 1)
            doTweenAlpha("redAl", "redFlash", 0, 0.2, "sineInOut")
            setProperty("warnem.alpha", 1)
            doTweenAlpha("warnemAl", "warnem", 0, 0.2, "sineInOut")
        elseif difficultyName == 'Hard' then
            setProperty("x.alpha", 1)
            doTweenAlpha("xAl", "x", 0, 0.2, "sineInOut")
            setProperty("warnem.alpha", 1)
            doTweenAlpha("warnemAl", "warnem", 0, 0.2, "sineInOut")
            setProperty("redFlash.alpha", 1)
            doTweenAlpha("redAl", "redFlash", 0, 0.2, "sineInOut")
        elseif difficultyName == 'Unreal' then
            if keyboardPressed("SPACE") then
                setProperty("health", 0)
                setProperty("dad.x", getProperty("dad.x") + 400)
            end
            setProperty("warnem.alpha", 1)
            doTweenAlpha("warnemAl", "warnem", 0, 0.2, "sineInOut")
        end
        runTimer("doWarn", (crochet/1000)/playbackRate)
        if (difficultyName == 'Nightmare' or difficultyName == 'Unreal') and not (curStep >= 1024 and curStep <= 1536) or (curStep <= 2048 and curStep >= 2034) then setProperty("dad.x", getProperty("dad.x") + 100) end
        amountLeft = value1-2
        if value1 == 3 then
            amountMoved = 400
        end
        --debugPrint('WAIT...')
    end
end

function onTimerCompleted(a,b,c)
    --debugPrint(safeForNow)
    if a == 'doWarn' then
        if amountLeft == 0 then
            setTextColor("warnem", "RED")
            if difficultyName == 'Nightmare' then
                if keyboardPressed("SPACE") then
                    setProperty("health", 0)
                    setProperty("dad.x", getProperty("dad.x") + 400)
                end
                setProperty("redFlash.alpha", 1)
                doTweenAlpha("redAl", "redFlash", 0, 0.2, "sineInOut")
                setProperty("warnem.alpha", 1)
                doTweenAlpha("warnemAl", "warnem", 0, 0.2, "sineInOut")
            else if difficultyName == 'Hard' then
                setProperty("sign.alpha", 1)
                doTweenAlpha("signAl", "sign", 0, 0.2, "sineInOut")
                setProperty("redFlash.alpha", 1)
                doTweenAlpha("redAl", "redFlash", 0, 0.2, "sineInOut")
                setProperty("warnem.alpha", 1)
                doTweenAlpha("warnemAl", "warnem", 0, 0.2, "sineInOut")
            else if difficultyName == 'Unreal' then
                if keyboardPressed("SPACE") then
                    setProperty("health", 0)
                    setProperty("dad.x", getProperty("dad.x") + 400)
                end
            end
            end
            end
            runTimer("doAttackMech", (crochet/1000)/playbackRate)
            if (difficultyName == 'Nightmare' or difficultyName == 'Unreal') and not (curStep >= 1024 and curStep <= 1536) or (curStep <= 2048 and curStep >= 2034) then setProperty("dad.x", getProperty("dad.x") + 100) end
            setTextString("warnem", "PRESS SPACE!")
            safeCheck = true
            --debugPrint('PRESS NOW!')
        else
            setTextColor("warnem", "YELLOW")
            if difficultyName == 'Nightmare' then
                if keyboardPressed("SPACE") then
                    setProperty("health", 0)
                    setProperty("dad.x", getProperty("dad.x") + 400)
                end
                setProperty("redFlash.alpha", 1)
                doTweenAlpha("redAl", "redFlash", 0, 0.2, "sineInOut")
                setProperty("warnem.alpha", 1)
                doTweenAlpha("warnemAl", "warnem", 0, 0.2, "sineInOut")
            else if difficultyName == 'Hard' then
                setProperty("x.alpha", 1)
                doTweenAlpha("xAl", "x", 0, 0.2, "sineInOut")
                setProperty("redFlash.alpha", 1)
                doTweenAlpha("redAl", "redFlash", 0, 0.2, "sineInOut")
                setProperty("warnem.alpha", 1)
                doTweenAlpha("warnemAl", "warnem", 0, 0.2, "sineInOut")
            else if difficultyName == 'Unreal' then
                if keyboardPressed("SPACE") then
                    setProperty("health", 0)
                    setProperty("dad.x", getProperty("dad.x") + 400)
                end
            end
            end
            end
            amountLeft = amountLeft - 1
            runTimer("doWarn", (crochet/1000)/playbackRate)
            if (difficultyName == 'Nightmare' or difficultyName == 'Unreal') and not (curStep >= 1024 and curStep <= 1536) or (curStep <= 2048 and curStep >= 2034) then setProperty("dad.x", getProperty("dad.x") + 100) end
            setTextString("warnem", "WAIT...")
            --debugPrint('WAIT...')
        end
    end
    if a == 'doAttackMech' then
        if difficultyName == 'Mega Nightmare' then
            runTimer("doCheck", 0.01)
            if keyboardJustPressed("SPACE") then
                safeForNow = true
            end
            if safeForNow then
                --debugPrint('SAFE!')
            else
                --debugPrint('LAST CHANCE!')
            end
        else if difficultyName == 'Mega Unreal' then
            runTimer("doCheck", 0.001)
            if safeForNow then
                --debugPrint('SAFE!')
            else
                --debugPrint('GAME OVER!')
                safeCheck = false
            end
        else
            runTimer("doCheck", 0.4)
            if safeForNow then
                --debugPrint('SAFE!')
            else
               -- debugPrint('LAST CHANCE!')
            end
        end
        end
    end
    if a == 'doCheck' then
        cancelTimer("doAttackMech")
        cancelTimer("doWarn")
        amountLeft = 1
        if not botPlay then
            if not safeForNow then
                --debugPrint('GAME OVER!')
                setProperty("health", 0)
            else
                --debugPrint('SAFE!')
                playAnim("boyfriend", "idle-alt", true)
                setProperty("boyfriend.specialAnim", true)
                setProperty("dad.x", getProperty("dad.x") + 200)
                doTweenX("goBAck", "dad", 0, 1, "sineInOut")
                safeForNow = false
                safeCheck = false
            end
        else
            playAnim("boyfriend", "idle-alt", true)
            setProperty("boyfriend.specialAnim", true)
            setProperty("dad.x", getProperty("dad.x") + 200)
            doTweenX("goBAck", "dad", 0, 1, "sineInOut")
            cancelTimer("doCheck")
            safeForNow = false
        end
    end
end

function onUpdate(w)
    if safeCheck then
        if keyboardPressed("SPACE") then
            safeForNow = true
            setTextString("warnem", "SAFE!")
            setTextColor("warnem", "GREEN")
            if difficultyName == 'Mega Unreal' then
                setProperty("warnem.alpha", 1)
                doTweenAlpha("warnemAl", "warnem", 0, 0.2, "sineInOut")
            end
        end
    end
end