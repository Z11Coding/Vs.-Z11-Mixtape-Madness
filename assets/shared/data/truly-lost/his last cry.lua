local activateHallucination = false
local activateHallucinationAlt = false
function onCreatePost()
    precacheImage("memory1")
    precacheImage("memory2")
    precacheImage("memory3")
    precacheImage("memory4")
    precacheImage("memory5")
    precacheImage("memory6")
    precacheImage("memory7")
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

    makeAnimatedLuaSprite("hallucinationZ11", "characters/Z11", getProperty("boyfriend.x") + 300, getProperty("boyfriend.y") + 300)
    addAnimationByPrefix("hallucinationZ11", "idle", "BF idle dance", 24, false)
    addOffset("hallucinationZ11", "idle", -5, 0)
    addAnimationByPrefix("hallucinationZ11", "singLEFT", "BF NOTE LEFT0", 24, false)
    addOffset("hallucinationZ11", "singLEFT", 5, -6)
    addAnimationByPrefix("hallucinationZ11", "singDOWN", "BF NOTE DOWN0", 24, false)
    addOffset("hallucinationZ11", "singDOWN", -20, -51)
    addAnimationByPrefix("hallucinationZ11", "singUP", "BF NOTE UP0", 24, false)
    addOffset("hallucinationZ11", "singUP", -46, 27)
    addAnimationByPrefix("hallucinationZ11", "singRIGHT", "BF NOTE RIGHT0", 24, false)
    addOffset("hallucinationZ11", "singRIGHT", -48, -7)
    --setObjectOrder("hallucinationBF", getObjectOrder("boyfriendGroup") - 7)
    addLuaSprite("hallucinationZ11", true)
    setProperty("hallucinationZ11.alpha", 0)

    makeAnimatedLuaSprite("rain", "rain", 0, 0)
    addAnimationByPrefix("rain", "idle", "rain tho", 60, true)
    screenCenter("rain", 'xy')
    addLuaSprite("rain", true)
    setProperty("rain.alpha", 0)

    makeAnimatedLuaSprite("static", "static", 0, 0)
    addAnimationByPrefix("static", "idle", "lestatic", 24, true)
    scaleObject("static", 8, 5)
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
    setProperty("theDarkAbyss.alpha", 0)
    didTheThing = true

    makeLuaSprite('memories', 'memory1', 100, 100)
    addLuaSprite("memories", true)
    setObjectCamera("memories", "xy")
    scaleObject("memories", 1.2, 1.2)
    --screenCenter("memories", 'xy')
    updateHitbox("memories", true)
    setProperty("memories.alpha", 0)
    playAnim("boyfriend", "scared", true)
    playAnim("dad", "scared", true)
    setTextString("botplayTxt", "Forever Empty...")
end

function onSongStart()
    for i = 0, 3 do
        setPropertyFromGroup("strumLineNotes", i, 'alpha', 0)
    end
    if getPropertyFromClass('backend.ClientPrefs', 'data.flashing') then
        cameraFlash("other", "be201c", 1, 'sineInOut')
    end
    setProperty("iconP2.alpha", 0)
    setProperty("dadGroup.alpha", 0)
    setProperty("camHUD.alpha", 0)
    setProperty("theDarkAbyss.alpha", 1)
    doTweenAlpha("liftTheAbyss", "theDarkAbyss", 0.8, 30, "sineInOut")
    doTweenAlpha("camHUDLIVE", "camHUD", 0.4, 30, "sineInOut")
    cameraShake("game", 0.1, 0.1)
    didTheThing = false
    setProperty("rain.alpha", 0.5)
    setProperty("static.alpha", 0.5)

end

function onCountdownTick(a)
    if a == 0 then
        playAnim("boyfriend", "scared", true)
        playAnim("dad", "scared", true)
        --setProperty("gf.specialAnim", true)
    end
    if a == 1 then
        playAnim("boyfriend", "scared", true)
        playAnim("dad", "scared", true)
        --setProperty("gf.specialAnim", true)
    end
    if a == 2 then
        playAnim("boyfriend", "scared", true)
        playAnim("dad", "scared", true)
        --setProperty("gf.specialAnim", true)
    end
    if a == 3 then
        playAnim("boyfriend", "hurt", true)
        playAnim("dad", "scared", true)
        --setProperty("gf.specialAnim", true)
    end
end

function goodNoteHit(a)
    if activateHallucination then
        setProperty("hallucinationBF.alpha", 0.5)
        doTweenAlpha("itsnotreal", "hallucinationBF", 0, 1, "sineInOut")
        playAnim("hallucinationBF", getProperty("boyfriend.animation.curAnim.name"), true)
    end
    if activateHallucinationAlt then
        setProperty("hallucinationZ11.alpha", 0.5)
        doTweenAlpha("itsnotreal", "hallucinationZ11", 0, 1, "sineInOut")
        playAnim("hallucinationZ11", getProperty("boyfriend.animation.curAnim.name"), true)
    end
end

function onStepHit()
    if difficultyName == 'Hard' then
        if curStep == 256 then
            setProperty("memories.alpha", 0.3)
            doTweenAlpha("memoriesfade", "memories", 0, 3, "sineInOut")
        end
        if curStep == 288 then
            removeLuaSprite("memories", true)
            makeLuaSprite('memories', 'memory2', 100, 100)
            addLuaSprite("memories", true)
            setObjectCamera("memories", "xy")
            scaleObject("memories", 1.2, 1.2)
            --screenCenter("memories", 'xy')
            updateHitbox("memories", true)
            setProperty("memories.alpha", 0.3)
            doTweenAlpha("memoriesfade", "memories", 0, 3, "sineInOut")
        end
        if curStep == 320 then
            removeLuaSprite("memories", true)
            makeLuaSprite('memories', 'memory3', 100, 100)
            addLuaSprite("memories", true)
            setObjectCamera("memories", "xy")
            scaleObject("memories", 1.2, 1.2)
            --screenCenter("memories", 'xy')
            updateHitbox("memories", true)
            setProperty("memories.alpha", 0.3)
            doTweenAlpha("memoriesfade", "memories", 0, 3, "sineInOut")
        end
        if curStep == 352 then
            removeLuaSprite("memories", true)
            makeLuaSprite('memories', 'memory4', 100, 100)
            addLuaSprite("memories", true)
            setObjectCamera("memories", "xy")
            scaleObject("memories", 1.2, 1.2)
            --screenCenter("memories", 'xy')
            updateHitbox("memories", true)
            setProperty("memories.alpha", 0.3)
            doTweenAlpha("memoriesfade", "memories", 0, 3, "sineInOut")
        end
        if curStep == 384 then
            removeLuaSprite("memories", true)
            makeLuaSprite('memories', 'memory5', 100, 100)
            addLuaSprite("memories", true)
            setObjectCamera("memories", "xy")
            scaleObject("memories", 1.2, 1.2)
            --screenCenter("memories", 'xy')
            updateHitbox("memories", true)
            setProperty("memories.alpha", 0.3)
            doTweenAlpha("memoriesfade", "memories", 0, 3, "sineInOut")
        end
        if curStep == 416 then
            removeLuaSprite("memories", true)
            makeLuaSprite('memories', 'memory6', 100, 100)
            addLuaSprite("memories", true)
            setObjectCamera("memories", "xy")
            --screenCenter("memories", 'xy')
            scaleObject("memories", 1.2, 1.2)
            updateHitbox("memories", true)
            setProperty("memories.alpha", 0.3)
            doTweenAlpha("memoriesfade", "memories", 0, 3, "sineInOut")
        end
        if curStep == 448 then
            removeLuaSprite("memories", true)
            makeLuaSprite('memories', 'memory7', 100, 100)
            addLuaSprite("memories", true)
            setObjectCamera("memories", "xy")
            scaleObject("memories", 1.2, 1.2)
            --screenCenter("memories", 'xy')
            updateHitbox("memories", true)
            setProperty("memories.alpha", 0.3)
            doTweenAlpha("memoriesfade", "memories", 0, 3, "sineInOut")
        end
        if curStep == 480 then
            removeLuaSprite("memories", true)
            makeLuaSprite('memories', 'memory8', 100, 100)
            addLuaSprite("memories", true)
            setObjectCamera("memories", "xy")
            scaleObject("memories", 1.2, 1.2)
            --screenCenter("memories", 'xy')
            updateHitbox("memories", true)
            setProperty("memories.alpha", 0.3)
            doTweenAlpha("memoriesfade", "memories", 0, 3, "sineInOut")
        end
    end
    if curStep == 512 then
        if getPropertyFromClass('backend.ClientPrefs', 'data.flashing') then
            cameraFlash("other", "000000", 1, 'sineInOut')
        end
    end
    if curStep == 560 then
        setHealthBarColors(rgbToHex(getProperty("dad.healthColorArray")), rgbToHex(getProperty("boyfriend.healthColorArray")))
        activateHallucination = true
        doTweenAlpha("cmeredad", "dad", 0.5, 5, "sineInOut")
        doTweenAlpha("cmeredadicon", "iconP2", 0.5, 5, "sineInOut")
        for i = 0, 3 do
            noteTweenAlpha("cmeredadnotes"..i, i, 0.5, 5, "sineInOut")
        end
    end
    if curStep == 1215 then
        setHealthBarColors("000000", rgbToHex(getProperty("boyfriend.healthColorArray")))
        if getPropertyFromClass('backend.ClientPrefs', 'data.flashing') then
            cameraFlash("other", "000000", 1, 'sineInOut')
        end
        doTweenAlpha("cmeredad", "dad", 0, 0.1, "sineInOut")
        doTweenAlpha("cmeredadicon", "iconP2", 0, 0.1, "sineInOut")
        for i = 0, 3 do
            noteTweenAlpha("cmeredadnotes"..i, i, 0, 0.1, "sineInOut")
        end
    end
    if curStep == 1310 then
        setHealthBarColors(rgbToHex(getProperty("dad.healthColorArray")), rgbToHex(getProperty("boyfriend.healthColorArray")))
        doTweenAlpha("cmeredad", "dad", 0.1, 5, "sineInOut")
        doTweenAlpha("cmeredadicon", "iconP2", 0.1, 5, "sineInOut")
        for i = 0, 3 do
            noteTweenAlpha("cmeredadnotes"..i, i, 0.1, 5, "sineInOut")
        end
    end
    if curStep == 1715 then
        setHealthBarColors("000000", rgbToHex(getProperty("boyfriend.healthColorArray")))
        doTweenAlpha("hereComesTheAbyss", "theDarkAbyss", 1, 1, "sineInOut")
        doTweenAlpha("byebye", "camHUD", 0, 5, "sineInOut")
    end
end

function onBeatHit()
    if curBeat % 2 == 0 then
        if getProperty("hallucinationBF.animation.curAnim.name") == 'idle' then
            playAnim("hallucinationBF", "idle", true)
        end
    end
    if curBeat % 2 == 0 then
        if getProperty("hallucinationZ11.animation.curAnim.name") == 'idle' then
            playAnim("hallucinationZ11", "idle", true)
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