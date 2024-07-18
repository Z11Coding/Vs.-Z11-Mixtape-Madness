local pixel = 30
local pixel2 = 0.1
local rePixel = false
local dePixel = false
function onCreatePost()
    if getPropertyFromClass('backend.ClientPrefs', 'data.shaders') then
        makeLuaSprite('a')
        makeGraphic("a", screenWidth, screenHeight)
        initLuaShader('pixel')
        setSpriteShader("a", "pixel")
        setShaderFloat('a', 'mult', 0)
        setShaderFloatArray('a', 'r', {0, 0, 0})
        setShaderFloatArray('a', 'g', {0, 0, 0})
        setShaderFloatArray('a', 'b', {0, 0, 0})
        setShaderFloatArray('a', 'uBlocksize', {pixel, pixel})
        addHaxeLibrary('ShaderFilter', 'openfl.filters');
        runHaxeCode([[
            game.camHUD.setFilters([new ShaderFilter(game.getLuaObject('a').shader)]);
            //game.camGame.setFilters([new ShaderFilter(game.getLuaObject('a').shader)]);
            //game.camGame.setFilters([new ShaderFilter(game.getLuaObject('starfield').shader)]);
        ]])
    end
end

function onUpdate()
    if dePixel then
        if pixel > 0 then
            pixel = pixel - 0.1
        else
            dePixel = false
        end
    end
    if rePixel then
        if pixel < 30 then
            pixel = pixel + 0.09
        else
            rePixel = false
        end
    end
    setShaderFloatArray('a', 'uBlocksize', {pixel, pixel})
end

function onStepHit()
    if curStep == 1 then
        dePixel = true
    end
end