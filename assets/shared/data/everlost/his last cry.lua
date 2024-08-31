local activateHallucination = true
function onCreate()
    setProperty('skipArrowStartTween', true)
    setProperty('skipCountdown', true)
end
function onCreatePost()
    makeAnimatedLuaSprite("hallucinationBF", "characters/BOYFRIEND", getProperty("boyfriend.x") + 300, getProperty("boyfriend.y") + 10)
    addAnimationByPrefix("hallucinationBF", "idle", "BF idle dance", 24, false)
    addOffset("hallucinationBF", "idle", -5, 0)
    addAnimationByPrefix("hallucinationBF", "singLEFT", "BF NOTE LEFT0", 24, false)
    addOffset("hallucinationBF", "singLEFT", 5, -6)
    addAnimationByPrefix("hallucinationBF", "singDOWN", "BF NOTE DOWN0", 24, false)
    addOffset("hallucinationBF", "singDOWN", -20, -51)
    addAnimationByPrefix("hallucinationBF", "singUP", "BF NOTE UP0", 24, false)
    addOffset("hallucinationBF", "singUP", -46, 27)
    addAnimationByPrefix("hallucinationBF", "singRIGHT", "BF NOTE RIGHT0", 24, false)
    addOffset("hallucinationBF", "singRIGHT", -48, -7)
    --setObjectOrder("hallucinationBF", getObjectOrder("boyfriendGroup") - 7)
    addLuaSprite("hallucinationBF", true)
    setProperty("hallucinationBF.alpha", 0)

    makeAnimatedLuaSprite("rain", "effects/rain", 0, 0)
    addAnimationByPrefix("rain", "idle", "rain tho", 60, true)
    screenCenter("rain", 'xy')
    addLuaSprite("rain", true)
    setProperty("rain.alpha", 0)

    makeAnimatedLuaSprite("static", "effects/static", 0, 0)
    addAnimationByPrefix("static", "idle", "lestatic", 24, true)
    scaleObject("static", 8, 8)
    screenCenter("static", 'xy')
    addLuaSprite("static", true)
    setProperty("static.alpha", 0)
    setProperty("static.x", getProperty("static.x") + 300)
    setProperty("static.y", getProperty("static.y") + 200)

    makeLuaSprite('theDarkAbyss', nil, 0, 0)
    makeGraphic("theDarkAbyss", screenWidth*2, screenHeight*2, "000000")
    addLuaSprite("theDarkAbyss", true)
    screenCenter("theDarkAbyss", 'xy')
    updateHitbox("theDarkAbyss", true)
    setProperty("gfGroup.alpha", 0)
    setProperty("dad.alpha", 0)
    setProperty("camHUD.alpha", 0)
    setProperty("theDarkAbyss.alpha", 1)
    didTheThing = true
    setTextString("botplayTxt", "Forever Empty...")
    setValue('alpha', 1, 1)
    setValue('noteAlpha', 1, 1)
    makeLuaText('toolongago', '3 YEARS LATER...', 900, 0, 0)
    setTextSize('toolongago', 50)
    setObjectCamera('toolongago', 'other')
    screenCenter('toolongago')
    setTextFont("toolongago", "pixel")
    setProperty('toolongago.alpha', 0)
    addLuaText("toolongago", true)
end

function onSongStart()
    doTweenAlpha("theStartoftheEnd", "toolongago", 1, 1, "sineInOut")
    setProperty("iconP2.alpha", 0)
    doTweenAlpha("liftTheAbyss", "theDarkAbyss", 0.8, 30, "sineInOut")
    doTweenAlpha("camHUDLIVE", "camHUD", 0.4, 20, "sineInOut")
    didTheThing = false
    setProperty("rain.alpha", 0.5)
    setProperty("static.alpha", 0.5)
    setHealthBarColors("000000", rgbToHex(getProperty("boyfriend.healthColorArray")))
end

function goodNoteHit(a)
    if activateHallucination then
        setProperty("hallucinationBF.alpha", 0.5)
        doTweenAlpha("itsnotreal", "hallucinationBF", 0, 1, "sineInOut")
        playAnim("hallucinationBF", getProperty("boyfriend.animation.curAnim.name"), true)
    end
end

function onStepHit()
    if curStep == 8 then
        doTweenAlpha("3yearstoolate", "toolongago", 0, 10, "sineInOut")
    end
    if curStep == 319 then
        doTweenAlpha("liftTheAbyss", "theDarkAbyss", 1, 6, "sineInOut")
        doTweenAlpha("camHUDLIVE", "camHUD", 0, 6, "sineInOut")
    end
    if curStep == 353 then
        doTweenAlpha("liftTheAbyss", "theDarkAbyss", 0.5, 9, "sineInOut")
        doTweenAlpha("camHUDLIVE", "camHUD", 0.6, 9, "sineInOut")
        setHealthBarColors(rgbToHex(getProperty("dad.healthColorArray")), rgbToHex(getProperty("boyfriend.healthColorArray")))
        queueEase(curStep, curStep+15, 'alpha', 0.4, 'sineInOut', 1)
        queueEase(curStep, curStep+15, 'noteAlpha', 0.4, 'sineInOut', 1)
        doTweenAlpha("cmeredad", "dad", 0.6, 9, "sineInOut")
        doTweenAlpha("cmeredadicon", "iconP2", 0.6, 9, "sineInOut")
    end
    if curStep == 1439 then
        if getPropertyFromClass('backend.ClientPrefs', 'data.flashing') then
            cameraFlash("other", "ffffff", 1, 'sineInOut')
        end
        setProperty("theDarkAbyss.alpha", 1)
        doTweenAlpha("liftTheAbyss", "theDarkAbyss", 0.8, 9, "sineInOut")
        setProperty("camHUD.alpha", 0)
        doTweenAlpha("camHUDLIVE", "camHUD", 0.4, 9, "sineInOut")
    end
    if curStep == 1952 then
        if getPropertyFromClass('backend.ClientPrefs', 'data.flashing') then
            cameraFlash("other", "ffffff", 1, 'sineInOut')
        end
        setProperty("theDarkAbyss.alpha", 0.5)
    end
    if curStep == 2688 then
        doTweenAlpha("camHUDLIVE", "camHUD", 0, 3, "sineInOut")
        doTweenAlpha("hehasgivinin", "boyfriend", 0, 3, "sineInOut")
        doTweenAlpha("gameover", "camGame", 0, 3, "sineInOut")
    end
end

function onBeatHit()
    if curBeat % 2 == 0 then
        if getProperty("hallucinationBF.animation.curAnim.name") == 'idle' then
            playAnim("hallucinationBF", "idle", true)
        end
    end
end

function rgbToHex(array)
	return string.format('%.2x%.2x%.2x', math.min(array[1]+50,255), math.min(array[2]+50,255), math.min(array[3]+50,255))
end

function onUpdate()
    if not didTheThing then
        setHealthBarColors("000000", rgbToHex(getProperty("boyfriend.healthColorArray")))
        didTheThing = true
    end
end