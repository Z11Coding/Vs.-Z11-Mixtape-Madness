local active = false
local shaderList = {
    [0] = 'starfield',
    [1] = 'vcr_with_no_glitch',
    [2] = 'Glitched',
    [3] = 'static',
    [4] = 'vcr_with_glitch',
    [5] = 'underwater',
    [6] = 'analog_tv',
    [7] = 'bloom',
}
guh = 0
local window_default = {}
function onCreate()
    window_default[1] = getPropertyFromClass("openfl.Lib", "application.window.x")
	window_default[2] = getPropertyFromClass("openfl.Lib", "application.window.y")
    makeLuaSprite('theDarkAbyssBG', nil, 0, 0)
    makeGraphic("theDarkAbyssBG", screenWidth*2, screenHeight*2, "ffffff")
    addLuaSprite("theDarkAbyssBG")
    screenCenter("theDarkAbyssBG", 'xy')
    updateHitbox("theDarkAbyssBG", true)
    setProperty('theDarkAbyssBG.alpha', 0.5)
	--setPropertyFromClass("openfl.Lib", "application.window.borderless",true)
end
function onCreatePost()
    luaDebugMode = false
    if getPropertyFromClass('ClientPrefs', 'shaders') then
        initLuaShader("vcr_with_no_glitch")
        makeLuaSprite("underwater")
        makeGraphic("underwater", screenWidth, screenHeight)
        setSpriteShader("underwater", "vcr_with_no_glitch")

        addHaxeLibrary("ShaderFilter", "openfl.filters")
        runHaxeCode([[
            //game.camGame.setFilters([new ShaderFilter(game.getLuaObject("underwater").shader)]);
            //game.camHUD.setFilters([new ShaderFilter(game.getLuaObject("underwater").shader)]);
        ]])
    end
end

function onStepHit()
    daStep = curStep
    if curStep == 192 then 
        cameraFlash('camOther', 'FFFFFF', 1)
        setSpriteShader("theDarkAbyssBG", 'starfield')
    end
end

function onUpdate(elapsed)
    if active then
        setPropertyFromClass("openfl.Lib", "application.window.x",getPropertyFromClass("openfl.Lib", "application.window.x") + math.random(-10, 10))
        setPropertyFromClass("openfl.Lib", "application.window.y",getPropertyFromClass("openfl.Lib", "application.window.y") + math.random(-10, 10))
    end
    if getPropertyFromClass('ClientPrefs', 'shaders') then
        if active then
            if getPropertyFromClass('ClientPrefs', 'flashing') then
                setSpriteShader("dad", shaderList[math.random(0, 7)])
                setSpriteShader("theDarkAbyssBG", shaderList[math.random(0, 7)])
                setSpriteShader("rain", shaderList[math.random(0, 7)])
                setSpriteShader("underwater", shaderList[math.random(0, 7)])
                for i = 0, 3 do
                    setSpriteShader('strumLineNotes.members['..i..']', shaderList[math.random(0, 7)])
                end
                for i = 0, getProperty("notes.length") do
                    if not getPropertyFromGroup('notes', i, 'mustPress') then
                        setSpriteShader('notes.members['..i..']', shaderList[math.random(0, 7)])
                    end
                end
            end
        end
    end
    guh = guh + elapsed
	setProperty('dad.y',150 - 150 * math.sin((guh * 0.3) * math.pi))
    if not mustHitSection then
        cameraSetTarget('dad')
    end
end 
local time = 0
function onUpdatePost(elapsed)
    for i = 0, getProperty("notes.length") - 1 do
        if getPropertyFromGroup('notes', i, 'noteType') == 'Void Note' then
            setPropertyFromGroup('notes', i, 'rgbShader.r', '0xFF000000')
            setPropertyFromGroup('notes', i, 'rgbShader.g', '0xFF000000')
            setPropertyFromGroup('notes', i, 'rgbShader.b', '0xFF000000')
        end
    end
    time = time + elapsed
    setShaderFloat("dad", "iTime", os.clock())
    setShaderFloat("theDarkAbyssBG", "iTime", os.clock())
    --setShaderFloat("underwater", "iTime", time)
    setShaderFloat("boyfriend", "iTime", os.clock())
    for i = 0, 3 do
        setShaderFloat("strumLineNotes.members["..i.."]", "iTime", os.clock())
        if getPropertyFromGroup("strumLineNotes", i, 'angle') > 0 then
            setPropertyFromGroup("strumLineNotes", i, 'angle', getPropertyFromGroup("strumLineNotes", i, 'angle') - 1)
        end
        if getPropertyFromGroup("strumLineNotes", i, 'direction') < 90 then
            setPropertyFromGroup("strumLineNotes", i, 'direction', getPropertyFromGroup("strumLineNotes", i, 'direction') + 1)
        end
    end
end

function opponentNoteHit(a,b,c,d)
    if getProperty("health") > 0.1 then
        setProperty('health', getProperty("health") - 0.007)
    end
    if (daStep >= 2880 and daStep <= 3083) or (daStep >= 3263 and daStep <= 3455) or (daStep >= 4997 and daStep <= 5189) then
        active = true
        runTimer('reset', 0.1)
        if getProperty("health") > 0.1 then
            setProperty('health', getProperty("health") - 0.03)
        end
        for i = 0, 3 do
            setPropertyFromGroup("strumLineNotes", i, 'angle', math.random(0, 360))
            setPropertyFromGroup("strumLineNotes", i, 'direction', math.random(0, 90))
        end
        setPropertyFromClass("openfl.Lib", "application.window.x", window_default[1])
        setPropertyFromClass("openfl.Lib", "application.window.y", window_default[2])
    end
end

function onTimerCompleted(tag)
    if tag == 'reset' then
        active = false
        setSpriteShader("dad", "starfield")
        setSpriteShader("theDarkAbyssBG", 'starfield')
        setSpriteShader("rain", 'starfield')
        setSpriteShader("underwater", "RGBPalette")
        for i = 0, 3 do
            setSpriteShader('strumLineNotes.members['..i..']', 'RGBPalette')
        end
        for i = 0, getProperty("notes.length") do
            if not getPropertyFromGroup('notes', i, 'mustPress') then
                setSpriteShader('notes.members['..i..']', 'RGBPalette')
            end
        end
        if getPropertyFromClass("openfl.Lib", "application.window.x") > window_default[1] then
            setPropertyFromClass("openfl.Lib", "application.window.x",getPropertyFromClass("openfl.Lib", "application.window.x") - 1)
        else if getPropertyFromClass("openfl.Lib", "application.window.x") < window_default[1] then
            setPropertyFromClass("openfl.Lib", "application.window.x",getPropertyFromClass("openfl.Lib", "application.window.x") + 1)
        end
        end
        if getPropertyFromClass("openfl.Lib", "application.window.y") > window_default[2] then
            setPropertyFromClass("openfl.Lib", "application.window.y",getPropertyFromClass("openfl.Lib", "application.window.y") - 1)
        else if getPropertyFromClass("openfl.Lib", "application.window.y") < window_default[2] then
            setPropertyFromClass("openfl.Lib", "application.window.y",getPropertyFromClass("openfl.Lib", "application.window.y") + 1)
        end
        end
    end
end

function onDestroy()
    --setPropertyFromClass("openfl.Lib", "application.window.borderless",false)
    setPropertyFromClass("openfl.Lib", "application.window.x",window_default[1])
    setPropertyFromClass("openfl.Lib", "application.window.y",window_default[2])
end

function boundTo(value, min, max)
    return math.max(min, math.min(max, value))
end
function math.lerp(from,to,i)return from+(to-from)*i end