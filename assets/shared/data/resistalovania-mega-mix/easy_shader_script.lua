--by _ipe_
--pls credit me if u use this that would be cool :DD

function onCreatePost()
    --[[
        YOUR SHADERS HERE <------------
        YOUR SHADERS HERE <------------
        YOUR SHADERS HERE <------------
        YOUR SHADERS HERE <------------
        pls read the wiki

        setControl('BarrelBlurEffect','barrel',0.0)
        setControl('BarrelBlurEffect','effect',0.0)
        setControl('BarrelBlurEffect','zoom',1.0)
        setControl('BarrelBlurEffect', 'doChroma', false)

        setControl('BloomEffect','strength',0.0)
        setControl('BloomEffect','effect',0.0)
        setControl('BloomEffect','contrast',0.0)
        setControl('BloomEffect','brightness',0.0)

        setControl('ChromAbEffect','strength',0)

        setControl('GreyscaleEffect','strength',0)

        setControl('MirrorRepeatEffect','x',0.0)
        setControl('MirrorRepeatEffect','y',0.0)
        setControl('MirrorRepeatEffect','angle',0.0)
        setControl('MirrorRepeatEffect','zoom', 1.0)

        setControl('MosaicEffect','strength',0)

        setControl('ScanlineEffect','strength',0.0)
        setControl('ScanlineEffect','pixelsBetweenEachLine',10)
        setControl('ScanlineEffect','lineHeight',0.6)

        setControl('VignetteEffect','size',0)
        setControl('VignetteEffect','stretch',0)
        setControl('VignetteEffect','red',0)
        setControl('VignetteEffect','green',0)
        setControl('VignetteEffect','blue',0)
    ]]
    makeShader('bilinear_aa', {'game', 'hud'})
    makeShader('pixel2', {'game', 'hud'})

    makeControl("bilinear_aa", "iTime", 0);
    makeControl('pixel2', 'pxSize', 0.1)

    reloadShaders()
end

function onUpdate()
    updateControllers()
end

function onUpdatePost(elapsed)
    setControl('bilinear_aa', 'iTime', elapsed)
end

function onEvent(n,v1,v2)
    if n == "ess_Tween Controller" then
        val1 = splitter(v1, ',')
        val2 = splitter(v2, ',')

        tweenControl(val1[1]..'_'..val1[2]..'_control_tween', val1[1], val1[2], val2[1] or 0, 1 / ((bpm) / val2[2]) or 1, val2[3])
    end
    if n == "ess_Bump Controller" then
        val1 = splitter(v1, ',')
        val2 = splitter(v2, ',')

        setControl(val1[1], val1[2], val2[1])
        tweenControl(val1[1]..'_'..val1[2]..'_control_bump', val1[1], val1[2], val2[2], 1 / ((bpm) / 120), 'QuintOut')
    end
    if n == "ess_Set Controller Value" then
        val1 = splitter(v1, ',')
        setControl(val1[1], val1[2], v2)
    end
end

--stolen hehehehehehehe
function splitter(inputstr, sep)
    if sep == nil then
        sep = "%s"
    end
    local t = {}
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
            table.insert(t, str)
    end
    return t
end




----------------------------------
----------------------------------
--        SHADERS CODE          --
--      DONT TOUCH !!!!!!       --
----------------------------------
----------------------------------

function makeShader(shader, cams)
    for i = 1, #cams do
        table.insert(shaderTable[cams[i]], shader)
    end

    initLuaShader(shader); 
    makeLuaSprite(shader) 
    makeGraphic(shader, screenWidth, screenHeight); 
    setSpriteShader(shader, shader)
end

function makeControl(shader, var, value)
    table.insert(controllerTable, {shader, var, value})

    if value ~= 'os.clock' then
        makeLuaSprite(shader..'_'..var..'_control', '', value, -10000)
        addLuaSprite(shader..'_'..var..'_control')
    end
end

--I hate how i made this so i just renamed functions so it doesnt look so ugly lol
function getControl(shader, control)
    return getProperty(shader..'_'..control..'_control.x')
end

function setControl(shader, control, value)
    return setProperty(shader..'_'..control..'_control.x', value)
end

function tweenControl(tag, shader, control, value, time, ease)
    return doTweenX(tag, shader..'_'..control..'_control', value, time, ease)
end

--------------------------------------------------------
--------------------------------------------------------
--------------------------------------------------------

shaderTable = {
    ['game'] = {},
    ['hud'] = {},
    ['other'] = {}
}
controllerTable = {}

function reloadShaders()
    runHaxeCode([[
        game.camGame.setFilters([
            ]]..shaderString(getShaders('game'))..[[
        ]);

        game.camHUD.setFilters([
            ]]..shaderString(getShaders('hud'))..[[
        ]); 

        game.camOther.setFilters([
            ]]..shaderString(getShaders('other'))..[[
        ]); 
    ]])
end

function updateControllers()
    for i = 1, #controllerTable do
        if controllerTable[i][3] ~= 'os.clock' then 
            setShaderFloat(controllerTable[i][1], controllerTable[i][2], getControl(controllerTable[i][1], controllerTable[i][2]))
        else
            setShaderFloat(controllerTable[i][1], controllerTable[i][2], os.clock())
        end
    end
end

function getShaders(cam)
    local shaders = {}
    for i = 1, #shaderTable[cam] do
        table.insert(shaders, shaderTable[cam][i])
    end

    return shaders
end

function shaderString(shaders)
    local string = ''
    for i = 1, #shaders do
        string = string .. 'new ShaderFilter(game.getLuaObject("' .. shaders[i] .. '").shader),'
    end
    return string
end