local active = false
local shaderList = {
    [0] = 'galaxy',
    [1] = 'mess'
}
guh = 0
local window_default = {}
function onCreate()
    makeLuaSprite('theDarkAbyssBG', nil, 0, 0)
    makeGraphic("theDarkAbyssBG", screenWidth*5, screenHeight*5, "ffffff")
    addLuaSprite("theDarkAbyssBG")
    screenCenter("theDarkAbyssBG", 'xy')
    updateHitbox("theDarkAbyssBG", true)
    setProperty('theDarkAbyssBG.alpha', 1)
	--setPropertyFromClass("openfl.Lib", "application.window.borderless",true)
end

function onCreatePost()
    luaDebugMode = true
    initLuaShader("galaxy")
    initLuaShader("distortion")
    initLuaShader("starfield")
    setSpriteShader("theDarkAbyssBG", 'galaxy')
end

function onStepHit()
    daStep = curStep
    if curStep == 1023 then 
        setSpriteShader("theDarkAbyssBG", shaderList[1])
    end
    if curStep == 1279 then 
        setSpriteShader("theDarkAbyssBG", shaderList[0])
    end
end

function onUpdatePost(elapsed)
    setShaderFloat("theDarkAbyssBG", "iTime", os.clock())
end

function opponentNoteHit(a,b,c,d)
    if getProperty("health") > 0.1 then
        setProperty('health', getProperty("health") - 0.007)
    end
end

function boundTo(value, min, max)
    return math.max(min, math.min(max, value))
end

function math.lerp(from,to,i)return from+(to-from)*i end