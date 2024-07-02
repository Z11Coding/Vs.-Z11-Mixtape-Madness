local colorVal = '000000'
function onCreate()
    setProperty('skipArrowStartTween', true)
end
function onCreatePost()
    makeLuaSprite('theDarkAbyssBG', nil, 0, 0)
    makeGraphic("theDarkAbyssBG", screenWidth*2, screenHeight*2, "ffffff")
    addLuaSprite("theDarkAbyssBG")
    screenCenter("theDarkAbyssBG", 'xy')
    updateHitbox("theDarkAbyssBG", true)
    setProperty('theDarkAbyssBG.alpha', 0)

    makeAnimatedLuaSprite("rain", "rain", 0, 0)
    addAnimationByPrefix("rain", "idle", "rain tho", 60, true)
    screenCenter("rain", 'xy')
    addLuaSprite("rain", true)
    setProperty("rain.alpha", 0)

    makeAnimatedLuaSprite("static", "static", 0, 0)
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
    setProperty("theDarkAbyss.alpha", 1)

    makeLuaSprite('TopBar', nil, 0, -350)
	makeGraphic('TopBar', 1280, 350, '000000')
	setObjectCamera('TopBar', 'camHUD')
	addLuaSprite('TopBar', true)

    makeLuaSprite('BottomBar', nil, 0, 720)
	makeGraphic('BottomBar', 1280, 350, '000000')
	setObjectCamera('BottomBar', 'camHUD')
	addLuaSprite('BottomBar', true)

    if getPropertyFromClass('backend.ClientPrefs', 'data.shaders') then
        initLuaShader("glitch")
        makeLuaSprite("underwater")
        makeGraphic("underwater", screenWidth, screenHeight)
        setSpriteShader("underwater", "glitch")

        addHaxeLibrary("ShaderFilter", "openfl.filters")
        runHaxeCode([[
            game.camGame.setFilters([new ShaderFilter(game.getLuaObject("underwater").shader)]);
            //game.camHUD.setFilters([new ShaderFilter(game.getLuaObject("underwater").shader)]);
        ]])
    end
    setProperty("gfGroup.alpha", 0)
    setProperty("camHUD.alpha", 0)
    didTheThing = true
    setTextString("botplayTxt", "Forever Empty...")
    for i = 0,3 do
        setPropertyFromGroup('strumLineNotes', i, 'alpha', 0)
    end
end

function onSongStart()
    setProperty("iconP2.alpha", 0)
    setProperty("dadGroup.alpha", 0)
    setProperty("camHUD.alpha", 0)
    doTweenAlpha("liftTheAbyss", "theDarkAbyss", 0.3, 30, "sineInOut")
    doTweenAlpha("camHUDLIVE", "camHUD", 1, 30, "sineInOut")
    cameraShake("game", 0.1, 0.1)
    didTheThing = false
    setProperty("rain.alpha", 0)
    setProperty("static.alpha", 0)
end

function onStepHit()
    if curStep == 304 then
        for i = 0, 3 do
            noteTweenAlpha("cmeredadnotes"..i, i, 1, 1, "sineInOut")
        end
        doTweenAlpha('bfAlph', 'dadGroup', 1, 1, 'sineInOut')
        doTweenAlpha('bficonAlph', 'iconP2', 1, 1, 'sineInOut')
        colorVal = rgbToHex(getProperty("dad.healthColorArray"))
    end
    if curStep == 640 then
        if getPropertyFromClass('backend.ClientPrefs', 'data.flashing') then
            cameraFlash("other", "be201c", 1, 'sineInOut')
        end
    end
    if curStep == 1148 then
        if getPropertyFromClass('backend.ClientPrefs', 'data.flashing') then
            setProperty('theDarkAbyssBG.alpha', 1)
            setProperty('camHUD.alpha', 0)
        end
    end
    if curStep == 1152 then
        setProperty('theDarkAbyss.alpha', 1)
        setProperty('theDarkGlitch.alpha', 1)
        doTweenAlpha("liftTheAbyss", "theDarkAbyss", 0.3, 12, "sineInOut")
        doTweenAlpha("liftTheAbyss2", "theDarkGlitch", 0.3, 12, "sineInOut")
        doTweenAlpha("camHUDLIVE", "camHUD", 1, 10, "sineInOut")
        setProperty('theDarkAbyssBG.alpha', 0.3)
        setProperty("rain.alpha", 0.5)
        setProperty("static.alpha", 0.5)
    end
    if curStep == 1472 then
        if getPropertyFromClass('backend.ClientPrefs', 'data.flashing') then
            cameraFlash("other", "000000", 1, 'sineInOut')
            setProperty('theDarkGlitch.alpha', 1)
            setProperty('theDarkAbyss.alpha', 1)
        end 
    end
    if curStep == 1568 then
        if getPropertyFromClass('backend.ClientPrefs', 'data.flashing') then
            doTweenAlpha("liftTheAbyss2", "theDarkGlitch", 0.3, 3, "sineInOut")
            doTweenAlpha("liftTheAbyss", "theDarkAbyss", 0.3, 3, "sineInOut")
            doTweenZoom('camZoom', 'camGame', 2.2, 1, 'sineInOut')
            startTween("doDefTween", "defaultCamZoom", 2.2, 1)
        end 
    end
    if curStep == 1600 then
        hardBounce = true
    end
    if curStep == 1726 then
        hardBounce = false
    end
    if curStep == 1752 then
        hardBounce = true
    end
    if curStep == 1769 then
        hardBounce = false
    end
    if curStep == 1774 then
        hardBounce = true
    end
    if curStep == 1787 then
        hardBounce = false
    end
    if curStep == 1814 then
        hardBounce = true
    end
    if curStep == 1834 then
        hardBounce = false
    end
    if curStep == 1838 then
        hardBounce = true
    end
    if curStep == 1850 then
        hardBounce = false
    end
    if curStep == 1980 then
        doTweenZoom('camZoom', 'camGame', 2.2, 1, 'sineInOut')
        startTween("doDefTween", "defaultCamZoom", 2.2, 1)
    end
    if curStep == 2240 then
        doTweenZoom('camZoom', 'camGame', 2.2, 12, 'sineInOut')
        startTween("doDefTween", "defaultCamZoom", 2.2, 12)
    end
    if curStep == 2367 then
        hardBounce = true
    end
    if curStep == 2510 then
        hardBounce = false
    end
    if curStep == 2515 then
        hardBounce = true
    end
    if curStep == 2522 then
        hardBounce = false
    end
    if curStep == 2526 then
        hardBounce = true
    end
    if curStep == 2587 then
        hardBounce = false
    end
    if curStep == 2590 then
        hardBounce = true
    end
    if curStep == 2623 then
        hardBounce = false
    end
    if curStep == 2784 then
        setProperty('theDarkGlitch.alpha', 1)
        setProperty('theDarkAbyss.alpha', 1)
        setProperty('camHUD.alpha', 0)
    end
end

function rgbToHex(array)
	return string.format('%.2x%.2x%.2x', math.min(array[1]+50,255), math.min(array[2]+50,255), math.min(array[3]+50,255))
end

function onUpdate()
    if keyboardJustPressed('E') then
        --colorVal = rgbToHex(getProperty("dad.healthColorArray"))
    end
    --runHaxeCode('setVar(colorVal, '..colorVal..')')
    if not didTheThing then
        setHealthBarColors("000000", rgbToHex(getProperty("boyfriend.healthColorArray")))
        didTheThing = true
    end
    setHealthBarColors(colorVal, rgbToHex(getProperty("boyfriend.healthColorArray")))
end

function onUpdatePost()
    setShaderFloat("underwater", "time", os.clock())
    if keyboardJustPressed('E') then
        colorVal = rgbToHex(getProperty("dad.healthColorArray"))
    end
end

function onBeatHit()
    if hardBounce then
        triggerEvent("Add Camera Zoom", 0.1, 0.1)
    end
end

function onTweenCompleted(a)
    if a == 'doDefTween' then
        setProperty('defaultCamZoom', 1.05)
    end
end

function opponentNoteHit()
    if curBeat >= 336 and curBeat <= 368 then
        if getProperty('theDarkAbyss.alpha') == 1 then
            setProperty('theDarkAbyss.alpha', 0)
        else
            setProperty('theDarkAbyss.alpha', 1)
        end
    end
end