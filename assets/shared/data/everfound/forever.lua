local activateHallucination = false
function onCreate()
    setProperty('skipCountdown', true)
end
function onCreatePost()
    setProperty('camHUD.alpha', 0)
    makeAnimatedLuaSprite("rain", "rain", 0, 0)
    addAnimationByPrefix("rain", "idle", "rain tho", 60, true)
    screenCenter("rain", 'xy')
    addLuaSprite("rain", true)
    setProperty("rain.alpha", 0.5)

    makeAnimatedLuaSprite("static", "static", 0, 0)
    addAnimationByPrefix("static", "idle", "lestatic", 24, true)
    scaleObject("static", 8, 7)
    screenCenter("static", 'xy')
    addLuaSprite("static", true)
    setProperty("static.alpha", 0.5)
    setProperty("static.x", getProperty("static.x") + 300)
    setProperty("static.y", getProperty("static.y") + 100)

    makeLuaSprite('theDarkAbyssBG', nil, 0, 0)
    makeGraphic("theDarkAbyssBG", screenWidth*2, screenHeight*2, "ffffff")
    addLuaSprite("theDarkAbyssBG")
    screenCenter("theDarkAbyssBG", 'xy')
    updateHitbox("theDarkAbyssBG", true)
    setProperty('theDarkAbyssBG.alpha', 0)

    makeLuaSprite('theDarkAbyss', nil, 0, 0)
    makeGraphic("theDarkAbyss", screenWidth*2, screenHeight*2, "000000")
    addLuaSprite("theDarkAbyss", true)
    screenCenter("theDarkAbyss", 'xy')
    updateHitbox("theDarkAbyss", true)
    setProperty("gfGroup.alpha", 0)
    setProperty("theDarkAbyss.alpha", 1)
    playAnim("boyfriend", "sineUP-miss", true)
    setTextString("botplayTxt", "Forever Empty...")
end

function onCountdownTick(a)
    if a == 0 then
        playAnim("boyfriend", "singUPmiss", true)
        --setProperty("gf.specialAnim", true)
    end
    if a == 1 then
        playAnim("boyfriend", "singUPmiss", true)
        --setProperty("gf.specialAnim", true)
    end
    if a == 2 then
        playAnim("boyfriend", "singUPmiss", true)
        --setProperty("gf.specialAnim", true)
    end
    if a == 3 then
        playAnim("boyfriend", "idle", true)
        --setProperty("gf.specialAnim", true)
    end
end

function onSongStart()
    setProperty('theDarkAbyssBG.alpha', 0)
    setProperty("timeBar.visible", false)
    setProperty("timeTxt.visible", false)
    setProperty("healthBar.alpha", 0)
    setProperty("healthBerBG.alpha", 0)
    setProperty("iconP1.alpha", 0)
    setProperty("iconP2.alpha", 0)
    setProperty("scoreTxt.alpha", 0)
    didTheThing = false
    for i = 0, 3 do
        setPropertyFromGroup("strumLineNotes", i, 'alpha', 1)
    end
end

function onUpdatePost()
    if permaHey then
        playAnim('boyfriend', 'hey', true)
        playAnim('gf', 'cheer', true)
    end
end

function onStepHit()
    if curStep == 1 then
        doTweenAlpha("liftTheAbyss", "theDarkAbyss", 0.8, 5, "sineInOut")
        doTweenAlpha("freedom", "camHUD", 0.2, 2, "sineInOut")
        for i = 0, 3 do
            noteTweenAlpha("cmeredadnotes"..i, i, 0.6, 5, "sineInOut")
        end
        doTweenAlpha("cmeredad", "dad", 0.6, 5, "sineInOut")
    end
    if curStep == 32 then
        if getPropertyFromClass('backend.ClientPrefs', 'data.flashing') then
            cameraFlash("other", "ffffff", 1, 'sineInOut')
        end
    end
    if curStep == 288 then
        if getPropertyFromClass('backend.ClientPrefs', 'data.flashing') then
            cameraFlash("other", "ffffff", 1, 'sineInOut')
        end
        setProperty('theDarkAbyssBG.alpha', 0.3)
        if getPropertyFromClass('backend.ClientPrefs', 'data.shaders') then
            setSpriteShader("boyfriend", "starfield")
        end
        setProperty("theDarkAbyss.alpha", 0.2)
        setProperty("camHUD.alpha", 1)
        setTextColor("ready", '7a507a')
        setProperty("ready.alpha", 1)
        setProperty('ready.visible', true)
        setTextString("ready", "[THE POWER OF THE VOID FILLS YOU!]")
        doTweenAlpha("textfade", "ready", 0, 5, "sineInOut")
        setProperty("timeBar.visible", true)
        setProperty("timeTxt.visible", true)
        setProperty("healthBar.alpha", 1)
        setProperty("healthBerBG.alpha", 1)
        setProperty("iconP1.alpha", 1)
        setProperty("iconP2.alpha", 1)
        setProperty("scoreTxt.alpha", 1)
        setProperty("dad.alpha", 1)
        for i = 0, 3 do
            noteTweenAlpha("cmeredadnotes"..i, i, 1, 0.1, "sineInOut")
        end
    end
    if curStep == 800 then
        if getPropertyFromClass('backend.ClientPrefs', 'data.flashing') then
            cameraFlash("other", "ffffff", 1, 'sineInOut')
        end
        setProperty("theDarkAbyss.alpha", 1)
        setProperty("theDarkAbyssBG.alpha", 0)
        doTweenAlpha("reliftTheAbyss", "theDarkAbyss", 0.8, 7, "sineInOut")
    end
    if curStep == 1055 then
        if getPropertyFromClass('backend.ClientPrefs', 'data.flashing') then
            cameraFlash("other", "ffffff", 1, 'sineInOut')
        end
        setProperty("theDarkAbyss.alpha", 0.2)
        setProperty("theDarkAbyssBG.alpha", 0.5)
    end
    if curStep == 1071 then
        setTextColor("ready", '8a0303')
        setProperty("ready.alpha", 1)
        setProperty('ready.visible', true)
        setTextString("ready", "[WHY]")
    end
    if curStep == 1076 then
        setTextString("ready", "[WHY WONT]")
    end
    if curStep == 1080 then
        setTextString("ready", "[WHY WONT YOU]")
    end
    if curStep == 1082 then
        setTextString("ready", "[WHY WONT YOU GIVE]")
    end
    if curStep == 1084 then
        setTextString("ready", "[WHY WONT YOU GIVE UP???]")
    end
    if curStep == 1086 then
        doTweenAlpha("textfade", "ready", 0, 1, "sineInOut")
    end
    if curStep == 1103 then
        setTextColor("ready", '8a0303')
        setProperty("ready.alpha", 1)
        setProperty('ready.visible', true)
        setTextString("ready", "[YOU]")
    end
    if curStep == 1107 then
        setTextString("ready", "[YOU WONT]")
    end
    if curStep == 1112 then
        setTextString("ready", "[YOU WONT ESCAPE]")
    end
    if curStep == 1116 then
        setTextString("ready", "[YOU WONT ESCAPE ME!]")
    end
    if curStep == 1118 then
        doTweenAlpha("textfade", "ready", 0, 1, "sineInOut")
    end
    if curStep == 1199 then
        setTextColor("ready", '8a0303')
        setProperty("ready.alpha", 1)
        setProperty('ready.visible', true)
        setTextString("ready", "[YOU]")
    end
    if curStep == 1204 then
        setTextString("ready", "[YOU WILL]")
    end
    if curStep == 1208 then
        setTextString("ready", "[YOU WILL NOT]")
    end
    if curStep == 1210 then
        setTextString("ready", "[YOU WILL NOT DEFEAT]")
    end
    if curStep == 1212 then
        setTextString("ready", "[YOU WILL NOT DEFEAT ME,]")
    end
    if curStep == 1214 then
        setTextString("ready", "[YOU WILL NOT DEFEAT ME, BOYFRIEND!]")
    end
    if curStep == 1216 then
        doTweenAlpha("textfade", "ready", 0, 1, "sineInOut")
    end
    if curStep == 1231 then
        setTextColor("ready", '8a0303')
        setProperty("ready.alpha", 1)
        setProperty('ready.visible', true)
        setTextString("ready", "[STOP]")
    end
    if curStep == 1236 then
        setTextString("ready", "[STOP FIGHTING]")
    end
    if curStep == 1239 then
        setTextString("ready", "[STOP FIGHTING BACK!]")
    end
    if curStep == 1242 then
        doTweenAlpha("textfade", "ready", 0, 1, "sineInOut")
    end
    if curStep == 1327 then
        doTweenAlpha("byeopp", "dad", 0, 5, "sineInOut")
        doTweenAlpha("byeoppicon", "iconP2", 0, 5, "sineInOut")
        for i = 0, 3 do
            noteTweenAlpha("byebyenow"..i, i, 0, 5, "sineInOut")
        end
    end
    if curStep == 1327 then
        setTextColor("ready", '8a0303')
        setProperty("ready.alpha", 1)
        setProperty('ready.visible', true)
        setTextString("ready", "[NO]")
    end
    if curStep == 1332 then
        setTextString("ready", "[NO NO]")
    end
    if curStep == 1336 then
        setTextString("ready", "[NO NO NO]")
    end
    if curStep == 1338 then
        setTextString("ready", "[NO NO NO NO]")
    end
    if curStep == 1340 then
        setTextString("ready", "[NO NO NO NO NO!]")
    end
    if curStep == 1342 then
        doTweenAlpha("textfade", "ready", 0, 1, "sineInOut")
    end
    if curStep == 1439 then
        if getPropertyFromClass('backend.ClientPrefs', 'data.flashing') then
            cameraFlash("other", "ffffff", 1, 'sineInOut')
        end
        setProperty('gfGroup.alpha', 1)
        setProperty('iconP2.alpha', 1)
        setTextString("botplayTxt", "BOTPLAY")
        setProperty("theDarkAbyss.alpha", 0)
        setProperty("rain.alpha", 0)
        setProperty("static.alpha", 0)
        doTweenAlpha("hudFade", "camHUD", 0, 3, "sineInOut")
        setProperty('camZoomingMult', 0)
    end
    if curStep >= 1455 then
        permaHey = true
    end
end