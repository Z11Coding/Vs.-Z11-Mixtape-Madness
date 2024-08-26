local pxSize = 0.1
local curFPS = 60
function onCreatePost()
    curFPS = getPropertyFromClass('backend.ClientPrefs', 'data.framerate')
    setProperty('dad.y', getProperty('dad.y') - 60)
    setProperty('gfGroup.visible', false)

    initLuaShader("pixel2")
    makeLuaSprite("pix")
    makeGraphic("pix", screenWidth, screenHeight)
    setSpriteShader('pix', "pixel2") 

    runHaxeCode([[
        game.camGame.setFilters([new ShaderFilter(game.getLuaObject("pix").shader)]);
        game.camHUD.setFilters([new ShaderFilter(game.getLuaObject("pix").shader)]);
    ]]) 
end

function onStepHit()
    if curStep >= 1007 and curStep <= 1020 then
        doPixel = true
    else
        doPixel = false
    end
    if curStep >= 1519 and curStep <= 1533 then
        unDoPixel = true
    else
        unDoPixel = false
    end
    if curStep <= 1534 then
        pxSize = 0
    end
end

function onUpdatePost()
    if doPixel then
	    pxSize = pxSize + 0.1/(curFPS/60)
    end
    if unDoPixel then
	    pxSize = pxSize - 0.1/(curFPS/60)
    end
	setShaderFloat("pix", "pxSize", pxSize)
end