curRainAmount = 0
smoothRain = 0
nextRainAmount = 0
function onCreate() 
    if shadersEnabled then  
        local ShaderName = 'rain'
        initLuaShader(ShaderName)
        makeLuaSprite('camShader', nil)
        makeGraphic('camShader', screenWidth, screenHeight)
        scaleObject("camShader", 20.0, 20.0)
        setSpriteShader('camShader', ShaderName)
        

        runHaxeCode([[
            trace(game.getLuaObject('camShader').shader + ' Has Been Loaded!');                      
            //FlxG.game.setFilters([new ShaderFilter(game.getLuaObject('camShader').shader)]);
            game.camGame.setFilters([new ShaderFilter(game.getLuaObject('camShader').shader)]);
            game.camHUD.setFilters([new ShaderFilter(game.getLuaObject('camShader').shader)]);
        ]])

        function onUpdate(elapsed)
            smoothRain = lerp(curRainAmount, nextRainAmount, ((curRainAmount / smoothRain) * (elapsed * 10)) * playbackRate)
            setShaderFloat('camShader', 'iTime', os.clock())
            setShaderFloat('camShader', 'iTimescale', 0.7)
            setShaderFloat('camShader', 'iIntensity', smoothRain)
        end
    end
end

function onEvent(eventName, value1, value2)
    if eventName == 'Thunderstorm Trigger' then
        if value1 == '0' then --Light Rain
            nextRainAmount = 0.05
        elseif value1 == '1' then --Heavy Rain
            nextRainAmount = 0.33
        elseif value1 == '2' then --Thunderstorm
            nextRainAmount = 10
        elseif value1 == '3' then --No Rain
            nextRainAmount = 0
        end
    end
end

function lerp(s, e, t)
    return s + (e - s) * math.min(t, 1)
end

function onDestroy()
    if shadersEnabled then
        runHaxeCode([[
            FlxG.game.setFilters([]);
        ]])
    end
end