function onCreate()
    makeLuaSprite("starfield")
    makeGraphic("starfield", screenWidth, screenHeight)
    initLuaShader('starfield')
    setSpriteShader("starfield", "starfield")

    addHaxeLibrary('ShaderFilter', 'openfl.filters');
    runHaxeCode([[
        //game.camHUD.setFilters([new ShaderFilter(game.getLuaObject('starfield').shader)]);
        //game.camGame.setFilters([new ShaderFilter(game.getLuaObject('starfield').shader)]);
        //game.camGame.setFilters([new ShaderFilter(game.getLuaObject('starfield').shader)]);
    ]])
end

function onCreatePost()
    
end

function onUpdate(elapsed)
    setShaderFloat("boyfriend", "iTime", os.clock())
end