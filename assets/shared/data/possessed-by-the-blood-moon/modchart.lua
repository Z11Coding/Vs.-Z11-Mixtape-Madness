local localStep = 0
local textFlash = true
function callShader(func,vars)
    callScript('data/possessed-by-the-blood-moon/shader',func,vars)
end
function onCreatePost()
    if difficultyName == "NITG" or difficultyName == "POSSESSED" then
        makeLuaSprite("bg", nil, 0, 0)
        makeGraphic("bg", screenWidth*2, screenHeight*2, "000000")
        screenCenter("bg", 'xy')
        addLuaSprite('bg')
        setObjectOrder("bg", getObjectOrder('boyfriendGroup')+1)

        makeLuaSprite("actualbg", 'stages/pbtbm/bg', 0, 0)
        setObjectCamera("actualbg", "hud")
        scaleObject("actualbg", 2, 1.5)
        screenCenter("actualbg", 'xy')
        addLuaSprite('actualbg')

        makeLuaSprite("moonMask", 'stages/pbtbm/moon_glow', 0, -20)
        setObjectCamera("moonMask", "hud")
        scaleObject("moonMask", 0.3, 0.3)
        screenCenter("moonMask", 'x')
        addLuaSprite('moonMask')
        setBlendMode('moonMask', 'lighten')

        makeLuaSprite("moon", 'stages/pbtbm/moon', 0, 60)
        setObjectCamera("moon", "hud")
        scaleObject("moon", 0.3, 0.3)
        screenCenter("moon", 'x')
        addLuaSprite('moon')

        makeLuaSprite("atmos", 'stages/pbtbm/atmos', 0, 0)
        setObjectCamera("atmos", "hud")
        scaleObject("atmos", 2.5, 1.5)
        screenCenter("atmos", 'xy')
        addLuaSprite('atmos')

        makeLuaSprite("radial", 'stages/pbtbm/radial', 0, 0)
        setObjectCamera("radial", "other")
        scaleObject("radial", 2.5, 1.5)
        screenCenter("radial", 'xy')
        addLuaSprite('radial')
        setProperty("radial.color", '0xFFFF0000')

        makeLuaSprite("redFlash", nil, 0, 0)
        makeGraphic("redFlash", screenWidth*2, screenHeight*2, "FF0000")
        setObjectCamera("redFlash", 'hud')
        screenCenter("redFlash")
        addLuaSprite('redFlash')
        setProperty("redFlash.alpha", 0)

        makeLuaSprite("moonP", 'stages/pbtbm/pixel/moon', 0, 60)
        scaleObject("moonP", 4, 4)
        screenCenter("moonP", 'x')
        addLuaSprite('moonP')
        setProperty("moonP.alpha", 0)

        makeLuaText('poss', "POSSESSEDBY", 30, 150, 50)
        scaleObject('poss', 2, 2)
        setTextFont("poss", "pixel.otf")
        addLuaText('poss')

        makeLuaText('themoon', "THEBLOODMOON", 30, 450, 50)
        scaleObject('themoon', 2, 2)
        setTextFont("themoon", "pixel.otf")
        addLuaText('themoon')

        makeLuaSprite("dust", 'stages/pbtbm/dust', 0, 60)
        setObjectCamera("dust", "other")
        scaleObject("dust", 2, 1)
        screenCenter("dust", 'xy')
        addLuaSprite('dust')
        setBlendMode('dust', 'add')
        setProperty("dust.alpha", 0.1)

        --[[makeLuaSprite("pixel", nil, 0, 0)
        --setObjectCamera("dust", "other")
        scaleObject("pixel", 2, 1)
        screenCenter("pixel", 'xy')
        addLuaSprite('pixel')
        initLuaShader("pixel")
        setSpriteShader("pixel", "pixel")
        setShaderSampler2D("pixel", "mult", 1)]]

        setProperty("boyfriend.visible", false)
        setProperty("gf.visible", false)
        setProperty("dad.visible", false)

        makeLuaText("Big Ol Words", '', 1000, 0, 0)
        setObjectCamera("Big Ol Words", "other")
        setTextSize("Big Ol Words", 300)
        setTextFont("Big Ol Words", "Bonechiller Free.ttf")
        screenCenter("Big Ol Words")
        setProperty("Big Ol Words.y", getProperty("Big Ol Words.y")-200)
        addLuaText("Big Ol Words")
        setTextBorder("Big Ol Words", 5, 'FFFFFF')

        setProperty("iconP1.visible", false)
        setProperty("iconP2.visible", false)

        callShader('createShader',{'ca','ChromAbEffect'})
        callShader('createShader',{'greyscale','GreyscaleEffect'})
        callShader('createShader',{'mirror','BarrelBlurEffectWithMirror'})


        callShader('createShader',{'scanline','ScanlineEffect'})
        callShader('createShader',{'vignette','VignetteEffect'})
        shaderVar('vignette', 'strength', 15)
        shaderVar('vignette', 'size', 0.5)

        callShader('createShader',{'blur', 'BlurEffect'})
        callShader('createShader',{'mirrorHUD','BarrelBlurEffectWithMirror'})

        callShader('createShader',{'bloom2','BloomEffect'})

        callShader('createShader',{'blood','ColorOverrideEffect'})
        
        callShader('createShader',{'bar','BarrelBlurEffectWithMirror'})

        callShader('runShader',{'camHUD',{'greyscale','scanline','blur','ca','bloom2','vignette','blood'}})
        callShader('runShader',{'camHUD','mirrorHUD'})
        callShader('runShader',{'camVisual',{'greyscale','scanline','blur','ca','bloom2', 'bar'}})
        callShader('runShader',{'camOther',{'greyscale','scanline','blur','ca','bloom2', 'bar'}})
        
        queueEase(0, 30, 'fieldPitch', -40, 'sineOut')
        queueEase(0, 32, 'reverse', 1, 'sineOut')
        queueEase(0, 32, 'mini', 1, 'sineOut')
        queueEase(0, 32, 'tornado', 2, 'sineOut')
        queueEase(0, 32, 'hudShake', 25, 'sineOut')
        queueEase(0, 32, 'sudden', 1, 'sineOut')

        queueEase(144, 160, 'mini', 0, 'sineInOut')
        queueEase(144, 160, 'sudden', 0, 'sineInOut')
        queueEase(144, 160, 'stealthPastReceptors', 1, 'sineInOut')
        queueEase(144, 160, 'vanish', 1, 'sineInOut')
        
        queueEase(160, 272, 'fieldYaw', 360, 'sineInOut')
        queueEase(160, 272, 'vanish', 0, 'sineInOut')

        queueEase(280, 287, 'fieldYaw', 0, 'sineInOut')
        queueEase(280, 287, 'fieldPitch', 0, 'sineInOut')
        queueEase(280, 287, 'reverse', 0, 'sineInOut')
        queueEase(286, 287, 'drunk', 1, 'sineInOut')
        queueEase(286, 287, 'tornado', 0, 'sineInOut')

        queueEase(320, 350, 'grey', 0, 'sineOut')
        queueEase(320, 350, 'hudShake', 0, 'sineOut')
        queueEase(320, 350, 'vig', 0, 'sineOut')
        queueEase(320, 350, 'blur', 0, 'sineOut')
        queueEase(320, 349, 'mirrorZoom', 5, 'sineInOut')

        queueEase(335, 349, 'scale', 2, 'sineIn')
        queueEase(350, 352, 'scale', 1, 'sineOut')
        queueEase(350, 352, 'rotateX', 360, 'sineOut')
        queueEase(350, 352, 'drunk', 0, 'sineOut')

        queueEase(350, 350, 'mirrorZoom', 0.5, 'cubeOut')
        queueEase(351, 352, 'mirrorZoom', 1, 'cubeOut')

        queueEase(352, 354, 'flip', 1, 'cubeOut')

        queueEase(378, 380, 'flip', 0, 'cubeOut')
        queueEase(378, 380, 'reverse', 1, 'cubeOut')

        queueEase(384, 388, 'invert', 1, 'cubeOut')

        queueEase(410, 414, 'centered', 1, 'cubeOut')
        queueEase(410, 414, 'reverse', 0, 'cubeOut')

        queueEase(416, 420, 'invert', 0, 'cubeOut')
        queueEase(410, 414, 'centered', 0, 'cubeOut')
        queueEase(416, 420, 'split', 1, 'cubeOut')

        queueEase(442, 446, 'split', 0, 'cubeOut')
        queueEase(442, 446, 'centered', 1, 'cubeOut')

        queueEase(448, 452, 'centered', 0, 'cubeOut')
        queueEase(448, 452, 'cross', 1, 'cubeOut')

        queueEase(474, 478, 'cross', 0, 'cubeOut')

        queueEase(480, 484, 'centered', 1, 'cubeOut')

        queueEase(506, 510, 'invert', 1, 'cubeOut')

        queueEase(512, 516, 'invert', 0, 'cubeOut')
        queueEase(512, 516, 'split', 1, 'cubeOut')

        queueEase(538, 542, 'invert', 1, 'cubeOut')
        queueEase(538, 542, 'split', 0, 'cubeOut')

        queueEase(544, 548, 'invert', 0, 'cubeOut')
        queueEase(544, 548, 'alternate', 1, 'cubeOut')

        queueEase(570, 574, 'invert', 1, 'cubeOut')
        queueEase(570, 574, 'alternate', 0, 'cubeOut')

        queueEase(576, 580, 'invert', 0, 'cubeOut')
        queueEase(576, 580, 'centered', 0, 'cubeOut')

        shake1(580)

        shake1(588)

        bumpy(596, true)

        bumpy(600, false)

        queueEase(604, 608, 'centerrotateY', 180, 'sineOut')

        queueEase(608, 672, 'centerrotateY', 0, 'sineOut')

        queueEase(672, 719, 'scale', 2, 'sineInOut')

        queueEase(720, 720, 'scale', 1, 'sineOut')

        queueEase(720, 736, 'zigzag', 1, 'sineOut')

        queueEase(860, 863, 'mirrorZoom', 3, 'cubeOut')

        queueEase(1184, 1239, 'scale', 2, 'cubeOut')

        queueEase(1240, 1240, 'scale', 1, 'cubeOut')
        queueEase(1240, 1248, 'mirrorAngle', 180, 'cubeOut')
        queueEase(1240, 1248, 'unboundedReverse', 1, 'cubeOut')

        queueEase(1440, 1464, 'centerrotateX', 0, 'cubeOut')

        queueEase(1472, 1487, 'centerrotateX', 360*16, 'cubeInOut')

        queueEase(1520, 1536, 'centerrotateY', 360*16, 'cubeIn')

        queueEase(1600, 1660, 'alpha', 1, 'cubeIn', 1)
        queueEase(1600, 1660, 'alpha', 0, 'cubeIn', 0)

        queueEase(1840, 1847, 'scale', 2, 'cubeOut')

        queueEase(1848, 1854, 'scale', 1, 'cubeOut')

        queueEase(1968, 1976, 'mirrorZoom', 1, 'cubeOut')
        queueEase(1976, 1978, 'mirrorZoom', 6, 'cubeOut')
        queueEase(1979, 1981, 'mirrorZoom', 8, 'cubeOut')
        queueEase(1982, 1982, 'mirrorZoom', 10, 'cubeOut')

        
        queueEase(1984, 1984, 'mirrorAngle', 90, 'cubeOut')
        queueEase(1984, 1984, 'mirrorZoom', 15, 'cubeOut')

        queueEase(1986, 1986, 'mirrorAngle', -90, 'cubeOut')
        queueEase(1986, 1986, 'mirrorZoom', 20, 'cubeOut')

        queueEase(2224, 2239, 'mirrorZoom', 1, 'cubeOut')
        queueEase(2224, 2239, 'mirrorAngle', 0, 'cubeOut')
        queueEase(2224, 2224, 'mirrorX', 0, 'cubeOut')
        queueEase(2224, 2224, 'mirrorY', 0, 'cubeOut')
        queueEase(2224, 2239, 'grace', 0, 'cubeOut')

        queueEase(2239, 2288, 'mirrorZoom', 2, 'cubeInOut')
        queueEase(2239, 2288, 'mirrorAngle', 15, 'cubeInOut')

        queueEase(2288, 2294, 'mirrorZoom', 1, 'cubeInOut')
        queueEase(2288, 2294, 'mirrorAngle', 0, 'cubeInOut')

        queueEase(2303, 2335, 'scale', 2, 'cubeIn')
        queueEase(2336, 2351, 'scale', 1, 'cubeInOut')

        queueEase(2364, 2365, 'centerrotateY', 360, 'cubeOut', 0)
        queueEase(2364, 2365, 'reverse', 1, 'cubeOut', 0)
        queueEase(2366, 2367, 'centerrotateY', -360, 'cubeOut', 0)
        queueEase(2366, 2367, 'reverse', 0, 'cubeOut', 0)

        queueEase(2607, 2624, 'grace', 0, 'cubeOut')

        queueEase(2728, 2736, 'drunk', 0, 'cubeOut')
        queueEase(2728, 2736, 'tipsy', 0, 'cubeOut')
        queueEase(2728, 2736, 'tipZ', 0, 'cubeOut')
        queueEase(2736, 2736, 'cmod', 10, 'cubeOut')

        queueEase(2752, 2768, 'transformY', 1500, 'cubeInOut', -1, getValue('transformY'))
        queueEase(2752, 2768, 'centerrotateZ', 1500, 'cubeInOut', -1, getValue('centerrotateZ'))
        queueEase(2752, 2768, 'centerrotateY', 1500, 'cubeInOut', -1, getValue('centerrotateY'))
        queueEase(2752, 2768, 'centerrotateX', 1500, 'cubeInOut', -1, getValue('centerrotateX'))
        queueEase(2767, 2776, 'transformX', 9000, 'cubeOut', -1, getValue('transformY'))

        runHaxeCode([[
            var pixelCam:FlxCamera;
            pixelCam = new FlxCamera();
            pixelCam.width = 700;
            pixelCam.height = 500;
            pixelCam.x = 300;
            pixelCam.y = -900;
            FlxG.cameras.remove(game.camOther, false);
            FlxG.cameras.add(pixelCam, false);
            FlxG.cameras.add(game.camOther, false);
            game.variables.set("pixelCam", pixelCam);
            pixelCam.scroll.x = 300;
            pixelCam.scroll.y = 50;
            pixelCam.zoom = 0.8;
            pixelCam.alpha = 0.1;

            var flash = game.getLuaObject('redFlash');
            var moon = game.getLuaObject('moonP');
            var txt1 = game.getLuaObject('poss');
            var txt2 = game.getLuaObject('themoon');
            flash.cameras = [pixelCam];
            moon.cameras = [pixelCam];
            game.dadField.cameras = [pixelCam];
            txt1.cameras = [pixelCam];
            txt2.cameras = [pixelCam];
        ]])
    else
        makeLuaSprite("redFlash", nil, 0, 0)
        makeGraphic("redFlash", screenWidth*2, screenHeight*2, "FF0000")
        setObjectCamera("redFlash", 'game')
        screenCenter("redFlash")
        addLuaSprite('redFlash')
        setProperty("redFlash.alpha", 0)

        makeLuaText("Big Ol Words", '', 1000, 0, 0)
        setObjectCamera("Big Ol Words", "other")
        setTextSize("Big Ol Words", 300)
        setTextFont("Big Ol Words", "Bonechiller Free.ttf")
        screenCenter("Big Ol Words")
        setProperty("Big Ol Words.y", getProperty("Big Ol Words.y")-200)
        addLuaText("Big Ol Words")
        setTextBorder("Big Ol Words", 5, 'FFFFFF')

        makeAnimatedLuaSprite("pixelBF", 'characters/bfPixel', getProperty("boyfriend.x")-30, getProperty("boyfriend.y")-90)
        addAnimationByPrefix("pixelBF", "singLEFT", "BF LEFT NOTE", 24, false)
        addAnimationByPrefix("pixelBF", "singDOWN", "BF DOWN NOTE", 24, false)
        addAnimationByPrefix("pixelBF", "singUP", "BF UP NOTE", 24, false)
        addAnimationByPrefix("pixelBF", "singRIGHT", "BF RIGHT NOTE", 24, false)
        addAnimationByPrefix("pixelBF", "idle", "BF IDLE", 24, false)
        --addOffset("pixelBF", "idle", 7, 0)
        addLuaSprite("pixelBF", true)
        scaleObject("pixelBF", 7, 7)
        setProperty("pixelBF.alpha", 0)

        makeAnimatedLuaSprite("pixelGF", 'characters/gfPixel', getProperty("gf.x")-70, getProperty("gf.y")-75)
        addAnimationByIndices("pixelGF", "danceLeft", "GF IDLE", "30,0,1,2,3,4,5,6,7,8,9,10,11,12,13,14", 24, false)
        addAnimationByIndices("pixelGF", "danceRight", "GF IDLE", "15,16,17,18,19,20,21,22,23,24,25,26,27,28,29", 24, false)
        addLuaSprite("pixelGF", true)
        scaleObject("pixelGF", 7, 7)
        setProperty("pixelGF.alpha", 0)
        setObjectOrder("pixelGF", getObjectOrder("gfGroup")+4)

        callShader('createShader',{'ca','ChromAbEffect'})
        callShader('createShader',{'greyscale','GreyscaleEffect'})
        callShader('createShader',{'mirror','BarrelBlurEffectWithMirror'})
        callShader('createShader',{'scanline','ScanlineEffect'})
        callShader('createShader',{'vignette','VignetteEffect'})
        shaderVar('vignette', 'strength', 15)
        shaderVar('vignette', 'size', 0.5)

        callShader('createShader',{'blur', 'BlurEffect'})
        callShader('createShader',{'mirrorHUD','BarrelBlurEffectWithMirror'})
        callShader('createShader',{'bloom2','BloomEffect'})

        callShader('createShader',{'blood','ColorOverrideEffect'})
        callShader('createShader',{'bar','BarrelBlurEffectWithMirror'})
        
        callShader('runShader',{'camHUD',{'greyscale','scanline','blur','ca','bloom2','vignette','blood', 'mirrorHUD'}})
        callShader('runShader',{'camGame',{'greyscale','scanline','blur','ca','bloom2','vignette','blood', 'mirrorHUD'}})

        queueEase(320, 350, 'grey', 0, 'sineOut')
        queueEase(320, 350, 'hudShake', 0, 'sineOut')
        queueEase(320, 350, 'vig', 0, 'sineOut')
        queueEase(320, 350, 'blur', 0, 'sineOut')

        queueEase(1600, 1660, 'alpha', 1, 'cubeIn', 1)
        queueEase(1600, 1660, 'alpha', 0, 'cubeIn', 0)
    end
end

function shaderTween(shader,var,value,time,easing)
    callShader('tweenShaderValue',{shader,var,value,time,easing})
end
function shaderVar(shader,var,value,type)
    callShader('setShaderVar',{shader,var,value,type})
end

function doZoomOnStep(s)
    if curStep == s-1 then
        shaderTween('mirror', 'zoom', 0.85, stepCrochet*0.001*1, 'cubeIn')
        shaderTween('mirrorHUD', 'zoom', 0.85, stepCrochet*0.001*1, 'cubeIn')

        shaderTween('bar', 'zoom', 0.85, stepCrochet*0.001*1, 'cubeIn')
        shaderTween('bar', 'zoom', 0.85, stepCrochet*0.001*1, 'cubeIn')
    elseif curStep == s then 
        shaderTween('mirror', 'zoom', getValue("mirrorZoom"), stepCrochet*0.001*3, 'cubeOut')
        shaderTween('mirrorHUD', 'zoom', getValue("mirrorZoom"), stepCrochet*0.001*3, 'cubeOut')

        shaderTween('bar', 'zoom', 1, stepCrochet*0.001*3, 'cubeOut')
        shaderTween('bar', 'zoom', 1, stepCrochet*0.001*3, 'cubeOut')
        
        if getValue("hudShake") > 0 then
            --Do Nothing
        else
            setValue('hudShake', 500)
            queueEase(localStep, localStep+1, 'hudShake', 0, 'cubeOut')
        end
    end
end
function doTiltOnStep(s, ang)
    if curStep == s then
        tilt(ang*2)
    end
end
function doBurstOnStep(s)
    if curStep == s then
        bloomBurst()
    end
end
function bloomBurst()
    shaderVar('ca', 'strength', 0.005)
    shaderVar('bloom2', 'effect', 0.25)
    shaderVar('bloom2', 'strength', 3)
    shaderTween('ca', 'strength', 0, stepCrochet*0.001*16, 'cubeOut')
    shaderTween('bloom2', 'effect', 0, stepCrochet*0.001*16, 'cubeOut')
    shaderTween('bloom2', 'strength', 0, stepCrochet*0.001*16, 'cubeOut')
    if getValue("grey") > 0 then
        shaderVar('greyscale', 'strength', 0)
        shaderTween('greyscale', 'strength', 1, stepCrochet*0.001*16, 'cubeOut')
    else
        shaderVar('greyscale', 'strength', 1)
        shaderTween('greyscale', 'strength', 0, stepCrochet*0.001*16, 'cubeOut')
    end
    if getValue("vig") > 0 then
        shaderVar('vig', 'strength', 0)
        shaderTween('vig', 'strength', 15, stepCrochet*0.001*16, 'cubeOut')
    else
        shaderVar('vig', 'strength', 15)
        shaderTween('vig', 'strength', 0, stepCrochet*0.001*16, 'cubeOut')
    end
    if getValue("hudShake") > 0 then
        --Do Nothing
    else
        setValue('hudShake', 500)
        queueEase(localStep, localStep+1, 'hudShake', 0, 'cubeOut')
    end
end

function tilt(ang)
    ang = ang/2
    shaderVar('mirror', 'angle', ang)
    shaderTween('mirror', 'angle', 0, stepCrochet*0.001*4, 'cubeOut')
    shaderVar('mirrorHUD', 'angle', ang)
    shaderTween('mirrorHUD', 'angle', 0, stepCrochet*0.001*4, 'cubeOut')
    shaderVar('mirror', 'barrel', ang)
    shaderTween('mirror', 'barrel', 0, stepCrochet*0.001*4, 'cubeOut')
    shaderVar('mirrorHUD', 'barrel', ang)
    shaderTween('mirrorHUD', 'barrel', 0, stepCrochet*0.001*4, 'cubeOut')
end

function shake1(curSteps)
    queueEase(curSteps, curSteps, 'transform0Y', 50, 'cubeOut')
    queueEase(curSteps, curSteps, 'transform1Y', -50, 'cubeOut')
    queueEase(curSteps, curSteps, 'transform2Y', 50, 'cubeOut')
    queueEase(curSteps, curSteps, 'transform3Y', -50, 'cubeOut')

    queueEase(curSteps+1, curSteps+1, 'transform0Y', -50, 'cubeOut')
    queueEase(curSteps+1, curSteps+1, 'transform1Y', 50, 'cubeOut')
    queueEase(curSteps+1, curSteps+1, 'transform2Y', -50, 'cubeOut')
    queueEase(curSteps+1, curSteps+1, 'transform3Y', 50, 'cubeOut')
    
    queueEase(curSteps+2, curSteps+2, 'transform0Y', 50, 'cubeOut')
    queueEase(curSteps+2, curSteps+2, 'transform1Y', -50, 'cubeOut')
    queueEase(curSteps+2, curSteps+2, 'transform2Y', 50, 'cubeOut')
    queueEase(curSteps+2, curSteps+2, 'transform3Y', -50, 'cubeOut')

    queueEase(curSteps+3, curSteps+3, 'transform0Y', -50, 'cubeOut')
    queueEase(curSteps+3, curSteps+3, 'transform1Y', 50, 'cubeOut')
    queueEase(curSteps+3, curSteps+3, 'transform2Y', -50, 'cubeOut')
    queueEase(curSteps+3, curSteps+3, 'transform3Y', 50, 'cubeOut')

    queueEase(curSteps+4, curSteps+8, 'transform0Y', 0, 'cubeOut')
    queueEase(curSteps+4, curSteps+8, 'transform1Y', 0, 'cubeOut')
    queueEase(curSteps+4, curSteps+8, 'transform2Y', 0, 'cubeOut')
    queueEase(curSteps+4, curSteps+8, 'transform3Y', 0, 'cubeOut')
end

function bumpy(curSteps, leftright)
    if leftright then
        queueEase(curSteps, curSteps+1, 'transform0Y', 50, 'cubeOut')
        queueEase(curSteps, curSteps+1, 'transform1Y', -50, 'cubeOut')
        queueEase(curSteps, curSteps+1, 'transform2Y', 50, 'cubeOut')
        queueEase(curSteps, curSteps+1, 'transform3Y', -50, 'cubeOut')
        
        queueEase(curSteps+2, curSteps+3, 'transform0Y', 0, 'cubeOut')
        queueEase(curSteps+2, curSteps+3, 'transform1Y', 0, 'cubeOut')
        queueEase(curSteps+2, curSteps+3, 'transform2Y', 0, 'cubeOut')
        queueEase(curSteps+2, curSteps+3, 'transform3Y', 0, 'cubeOut')
    else
        queueEase(curSteps, curSteps+1, 'transform0Y', -50, 'cubeOut')
        queueEase(curSteps, curSteps+1, 'transform1Y', 50, 'cubeOut')
        queueEase(curSteps, curSteps+1, 'transform2Y', -50, 'cubeOut')
        queueEase(curSteps, curSteps+1, 'transform3Y', 50, 'cubeOut')

        queueEase(curSteps+2, curSteps+3, 'transform0Y', 0, 'cubeOut')
        queueEase(curSteps+2, curSteps+3, 'transform1Y', 0, 'cubeOut')
        queueEase(curSteps+2, curSteps+3, 'transform2Y', 0, 'cubeOut')
        queueEase(curSteps+2, curSteps+3, 'transform3Y', 0, 'cubeOut')
    end
end

hudZoom = 1
function onUpdatePost()
    setProperty("camZooming", false)
    setProperty("camZoomingMult", 0)
    hudZoom = getProperty("camHUD.zoom")
    for i = 0, getProperty("notes.length")-1 do
        if not getPropertyFromGroup("notes", i, 'mustPress') then
            setPropertyFromGroup("notes", i, 'texture', 'PIXEL')
        end
    end
    for i = 0, getProperty('dadField.strumNotes.length') - 1 do
        setPropertyFromGroup('dadField.strumNotes', i, 'texture', 'PIXEL')
    end
    setProperty("camHUD.x", (((screenWidth - getProperty("camHUD.width")) / 2) + math.random(-getValue("hudShake")*hudZoom, getValue("hudShake") * hudZoom)/10000) * getProperty("camHUD.width") )
    setProperty("camHUD.y", (((screenHeight - getProperty("camHUD.height")) / 2) + math.random(-getValue("hudShake")*hudZoom, getValue("hudShake") * hudZoom) / 10000) * getProperty("camHUD.height"))

    setProperty("camGame.x", (((screenWidth - getProperty("camGame.width")) / 2) + math.random(-getValue("hudShake")*hudZoom, getValue("hudShake") * hudZoom)/10000) * getProperty("camGame.width") )
    setProperty("camGame.y", (((screenHeight - getProperty("camGame.height")) / 2) + math.random(-getValue("hudShake") * hudZoom, getValue("hudShake") * hudZoom) / 10000) * getProperty("camGame.height"))
end

function postReceptorGeneration()
    if not middlescroll and difficultyName == "NITG" or difficultyName == "POSSESSED" then
        setValue('transformX', 325, 1)
        setValue('transformX', -325, 0)
    elseif not middlescroll and difficultyName == "FNF" then
        setValue('transformX', 325, 1)
        setValue('transformX', -325, 0)
        setValue('alpha', 1, 1)
    end
    setProperty('dadField.inControl', true)
    setProperty('dadField.isPlayer', true)
    setProperty('dadField.autoPlayed', botPlay)
    runHaxeCode([[
        dadField.noteHitCallback = game.goodNoteHit;

        var savingGrace:ProxyField;
        savingGrace = new ProxyField(game.playerField.noteField);
        savingGrace.cameras = [game.camVisual];
        savingGrace.scrollFactor.set(1,1);
        savingGrace.alpha = 0;
        game.add(savingGrace);
        game.variables.set("savingGrace", savingGrace);

        var savingGrace2:ProxyField;
        savingGrace2 = new ProxyField(game.dadField.noteField);
        savingGrace2.cameras = [game.camVisual];
        savingGrace2.scrollFactor.set(1,1);
        savingGrace2.alpha = 0;
        game.add(savingGrace2);
        game.variables.set("savingGrace2", savingGrace2);
    ]])
end

function onModifierRegisterPost()
    addBlankMod("haloRadiusX", 0)
    addBlankMod("haloRadiusZ", 0)
    addBlankMod("haloSpeed", 0)
    addBlankMod("camAngle", 0)

    addBlankMod('grey', 1)
    addBlankMod('mirrorZoom', 1)
    addBlankMod('mirrorAngle', 0)
    addBlankMod('mirrorX', 0)
    addBlankMod('mirrorY', 0)
    addBlankMod('blur', 1)
    addBlankMod('vig', 15)
    addBlankMod("hudShake", 0)

    addBlankMod("grace", 0)
    addBlankMod("grace2", 0)
end

local continuous = {}
local function queueContFunc(startStep, endStep, callback)
    table.insert(continuous, { startStep, endStep, callback })
end

freakOut = false
sCroch = 0
function onUpdate(elapsed)
    for i = #continuous, 1, -1 do
        local data = continuous[i];
        if(curStep >= data[1])then
            if(curStep > data[2])then
                table.remove(continuous, i)
            else
                data[3](getProperty("curDecStep"));
            end
        end
    end
    setProperty("camZooming", false)
    setProperty("camZoomingMult", 0)
    if difficultyName == "NITG" or difficultyName == "POSSESSED" then
        setProperty('radial.alpha', getValue("greyscale", 0))
        shaderVar("greyscale", 'strength', getValue("grey", 0))
        shaderVar("mirrorHUD", 'zoom', getValue("mirrorZoom", 0))
        shaderVar("mirrorHUD", 'barrel', getValue("mirrorZoom", 0)-1)
        shaderVar("mirrorHUD", 'angle', getValue("mirrorAngle", 0))
        shaderVar("mirrorHUD", 'x', getValue("mirrorX", 0))
        shaderVar("mirrorHUD", 'y', getValue("mirrorY", 0))
        shaderVar("blur", 'strength', getValue("blur", 0))
        shaderVar('vignette', 'size', getValue("vig", 0)/20)
        setProperty('savingGrace.alpha', getValue("grace", 0))
        setProperty('savingGrace2.alpha', getValue("grace2", 0))
        shaderVar("bar", 'barrel', getValue("mirrorZoom", 0)-1)
    else
        shaderVar("greyscale", 'strength', getValue("grey", 0))
        shaderVar("mirrorHUD", 'angle', getValue("mirrorAngle", 0))
        shaderVar("mirrorHUD", 'x', getValue("mirrorX", 0))
        shaderVar("mirrorHUD", 'y', getValue("mirrorY", 0))
        shaderVar("blur", 'strength', getValue("blur", 0))
        shaderVar('vignette', 'strength', getValue("vig", 0))
        setProperty('savingGrace.alpha', getValue("grace", 0))
        shaderVar("bar", 'angle', getValue("mirrorAngle", 0))
    end
    if localStep >= 1344 and localStep <= 1359 then
        shaderVar('ca', 'strength', getRandomFloat(0.001, 0.09))
    end
    if keyboardJustPressed("TAB") then
        setProperty("camHUD.alpha", 1)
    end
    if flipOrama3 then
        mirXPos = mirXPos+0.3
        setValue('mirrorX', mirXPos)
    end
end

function onStepHit()
    if difficultyName == "NITG" or difficultyName == "POSSESSED" then
        localStep = curStep
        sCroch = stepCrochet

        if textFlash then
            if curStep % 2 == 0 then
                setTextColor("Big Ol Words", "ff0000")
            else
                setTextColor("Big Ol Words", "ffffff")
            end
        end

        if discombobulate then
            if curStep % 16 == 0 then
                queueEase(localStep, localStep+1, 'mirrorZoom', 2, 'cubeOut')
                bloomBurst()
            end
    
            if curStep % 16 == 3 then
                queueEase(localStep, localStep+1, 'mirrorZoom', 3, 'cubeOut')
                bloomBurst()
            end

            if curStep % 16 == 6 then
                queueEase(localStep, localStep+1, 'mirrorZoom', 4, 'cubeOut')
                bloomBurst()
            end

            if curStep % 16 == 9 then
                queueEase(localStep, localStep+1, 'mirrorZoom', 5, 'cubeOut')
                bloomBurst()
            end

            if curStep % 16 == 12 then
                queueEase(localStep, localStep+1, 'mirrorZoom', 6, 'cubeOut')
                bloomBurst()
            end

            if curStep % 16 == 14 then
                queueEase(localStep, localStep+1, 'mirrorZoom', 12, 'cubeOut')
                bloomBurst()
            end
        end

        doBurstOnStep(32)
        doZoomOnStep(32)

        doBurstOnStep(160)
        doZoomOnStep(160)

        doBurstOnStep(288)
        doZoomOnStep(288)

        doBurstOnStep(352)
        doZoomOnStep(352)

        doBurstOnStep(378)
        doZoomOnStep(378)
        doTiltOnStep(378, 15)

        doBurstOnStep(383)
        doZoomOnStep(383)
        doTiltOnStep(383, -15)

        doBurstOnStep(410)
        doZoomOnStep(410)
        doTiltOnStep(410, 15)

        doBurstOnStep(416)
        doZoomOnStep(416)
        doTiltOnStep(416, -15)

        doBurstOnStep(442)
        doZoomOnStep(442)
        doTiltOnStep(442, 15)

        doBurstOnStep(448)
        doZoomOnStep(448)
        doTiltOnStep(448, -15)

        doBurstOnStep(474)
        doZoomOnStep(474)
        doTiltOnStep(474, 15)

        doBurstOnStep(480)
        doZoomOnStep(480)
        doTiltOnStep(480, -15)

        doBurstOnStep(506)
        doZoomOnStep(506)
        doTiltOnStep(506, 15)

        doBurstOnStep(512)
        doZoomOnStep(512)
        doTiltOnStep(512, -15)

        doBurstOnStep(538)
        doZoomOnStep(538)
        doTiltOnStep(538, 15)

        doBurstOnStep(544)
        doZoomOnStep(544)
        doTiltOnStep(544, -15)

        doBurstOnStep(570)
        doZoomOnStep(570)
        doTiltOnStep(570, 15)

        doBurstOnStep(576)
        doZoomOnStep(576)
        doTiltOnStep(576, -15)

        doZoomOnStep(580)
        doZoomOnStep(581)
        doZoomOnStep(582)
        doZoomOnStep(583)
        doZoomOnStep(584)

        doZoomOnStep(588)
        doZoomOnStep(589)
        doZoomOnStep(590)
        doZoomOnStep(591)
        doZoomOnStep(592)

        doZoomOnStep(596)

        doZoomOnStep(600)

        doTiltOnStep(604, 360)


        if curStep == 607 then
            jumpy = true
        end
        if curStep == 719 then
            jumpy = false
        end

        if curStep == 720 then
            shaderVar('ca', 'strength', 0.005)
            setTextString("Big Ol Words", "KILLER")
            setValue("hudShake", 1000)
            setValue('mirrorZoom', 3)
        end

        if curStep == 728 then
            setTextString("Big Ol Words", "KILLER MOON")
        end

        if curStep == 735 then
            setValue("hudShake", 0)
            setTextString("Big Ol Words", "")
            rave1 = true
            flipOrama = true
        end

        if curStep == 791 then
            flipOrama = false
            rave1 = false
        end
        
        if curStep == 792 then
            queueEase(localStep, localStep+1, 'flip', 1, 'cubeOut')
            setValue("mirrorX", 0)
            setValue("mirrorZoom", 1)
            mirXPos = 0
        end
        if curStep == 793 then
            queueEase(localStep, localStep+1, 'flip', 0, 'cubeOut')
        end
        if curStep == 794 then
            queueEase(localStep, localStep+1, 'flip', 1, 'cubeOut')
        end
        if curStep == 795 then
            queueEase(localStep, localStep+1, 'flip', 0, 'cubeOut')
        end
        if curStep == 796 then
            queueEase(localStep, localStep+3, 'centered', 1, 'cubeOut')
        end
        doTiltOnStep(796, 360)

        if curStep == 799 then
            flipOrama = true
            rave1 = true
        end

        if curStep == 829 then
            flipOrama = false
            rave1 = false
        end

        doTiltOnStep(860, 360)
        if curStep == 861 then
            flipOrama2 = true
            rave2 = true
        end
        doTiltOnStep(920, 360)
        if curStep == 916 then
            flipOrama2 = false
            rave2 = false
        end

        if curStep == 922 then
            queueEase(localStep, localStep+1, 'flip', 1, 'sineOut')
            setValue("mirrorX", 0)
            setValue("mirrorZoom", 1)
            setValue("mirrorAngle", 0)
            mirXPos = 0
            mirAnPos = 0
        end
        if curStep == 923 then
            queueEase(localStep, localStep+1, 'flip', 0, 'sineOut')
        end
        if curStep == 924 then
            queueEase(localStep, localStep+1, 'flip', 1, 'sineOut')
        end
        if curStep == 925 then
            queueEase(localStep, localStep+1, 'flip', 0, 'sineOut')
        end
        if curStep == 926 then
            queueEase(localStep, localStep+1, 'flip', 1, 'sineOut')
        end
        if curStep == 927 then
            queueEase(localStep, localStep+1, 'flip', 0, 'sineOut')
        end
        if curStep == 928 then
            queueEase(localStep, localStep+3, 'centered', 0, 'cubeOut')
            setValue('centerrotateY', 0)
        end
        if curStep == 927 then
            flipOrama2 = true
            rave2 = true
            spinGod = true
        end
        if curStep == 959 then
            flipOrama2 = false
            rave2 = false
            spinGod = false
        end
        if curStep == 960 then
            queueEase(localStep, localStep+31, 'mirrorX', 0, 'elasticOut')
        end

        doBurstOnStep(992)
        doZoomOnStep(992)
        if curStep == 992 then
            setValue("zigzag", 0)
            setValue("tipsy", 1)
            setValue("tipZ", 1)
            setValue("mirrorZoom", 1)
        end

        doBurstOnStep(1020)
        doZoomOnStep(1020)

        doBurstOnStep(1024)
        doZoomOnStep(1024)

        doBurstOnStep(1052)
        doZoomOnStep(1052)

        doBurstOnStep(1056)
        doZoomOnStep(1056)

        doBurstOnStep(1084)
        doZoomOnStep(1084)

        doBurstOnStep(1088)
        doZoomOnStep(1088)

        if curStep >= 1104 and curStep <= 1119 then
            doZoomOnStep(curStep)
            setValue("tipsy", 0)
            setValue("tipZ", 0)
        end

        doTiltOnStep(1176, 15)

        doTiltOnStep(1180, -15)
        doTiltOnStep(1181, -15)
        doTiltOnStep(1182, -15)
        doTiltOnStep(1183, -15)

        if curStep == 1248 then
            revModSwap = true
            setValue("mirrorZoom", 3)
            setValue("zigzag", 0)
        end
    
        if curStep == 1295 then
            revModSwap = false
            queueEase(localStep, localStep, 'split', 0, 'cubeOut')
            queueEase(localStep, localStep, 'alternate', 0, 'cubeOut')
            queueEase(localStep, localStep, 'cross', 0, 'cubeOut')
            setValue("mirrorZoom", 6)
            setValue("mirrorAngle", 15)
        end
        if curStep == 1300 then
            queueEase(localStep, localStep+7, 'reverse', 1, 'cubeOut')
            queueEase(localStep, localStep+7, 'centerrotateY', 360, 'cubeOut')
            queueEase(localStep, localStep+3, 'mirrorZoom', 1, 'cubeOut')
            queueEase(localStep, localStep+3, 'mirrorAngle', 0, 'cubeOut')
        end

        if curStep == 1304 then
            setValue("mirrorZoom", 6)
            setValue("mirrorAngle", -15)
        end

        if curStep == 1306 then
            queueEase(localStep, localStep+7, 'reverse', 0, 'cubeOut')
            queueEase(localStep, localStep+7, 'centerrotateY', 0, 'cubeOut')
            queueEase(localStep, localStep+4, 'mirrorZoom', 1, 'cubeOut')
            queueEase(localStep, localStep+3, 'mirrorAngle', 180, 'cubeOut')
        end

        if curStep == 1311 then
            revModSwap = true
            setValue("mirrorZoom", 3)
        end

        if curStep == 1343 then
            revModSwap = false
            setValue("mirrorZoom", 1)
            queueEase(localStep, localStep, 'split', 0, 'cubeOut')
            queueEase(localStep, localStep, 'alternate', 0, 'cubeOut')
            queueEase(localStep, localStep, 'cross', 0, 'cubeOut')
        end

        if curStep >= 1344 and curStep <= 1359 then
            shaderVar('vignette', 'strength', 50)
            shaderVar('scanline', 'strength', 1)
            setValue("blur", 1)
            setValue("grey", 1)
            setValue("hudShake", 5)
            setValue("zigzag", 10)
        end
        if curStep == 1360 then
            setValue("hudShake", 0)
            shaderVar('ca', 'strength', 0)
            shaderVar('vignette', 'strength', 0)
            shaderVar('scanline', 'strength', 0)
            setValue("blur", 0)
            setValue("grey", 0)
            setValue("mirrorY", -0.8)
            setValue("zigzag", 0)
        end
        if curStep == 1363 then
            setValue("mirrorY", -0.6)
        end
        if curStep == 1366 then
            setValue("mirrorY", -0.4)
        end
        if curStep == 1370 then
            setValue("mirrorY", -1)
            setValue("mirrorAngle", -90)
        end
        if curStep == 1372 then
            queueEase(localStep, localStep+3, 'mirrorY', 0, 'cubeOut')
            queueEase(localStep, localStep+3, 'mirrorAngle', 0, 'cubeOut')
            queueEase(localStep, localStep+3, 'mirrorZoom', 6, 'cubeOut')
        end
        if curStep == 1376 then
            setValue("mirrorZoom", 5)
        end
        if curStep == 1378 then
            setValue("mirrorZoom", 4)
        end
        if curStep == 1380 then
            revModSwap = true
            setValue("mirrorZoom", 3)
        end
        if curStep == 1431 then
            revModSwap = false
            setValue("mirrorZoom", 1)
            queueEase(localStep, localStep+3, 'mirrorX', 0, 'cubeOut')
            queueEase(localStep, localStep, 'split', 0, 'cubeOut')
            queueEase(localStep, localStep, 'alternate', 0, 'cubeOut')
            queueEase(localStep, localStep, 'cross', 0, 'cubeOut')  
        end
        if curStep == 1432 then
            queueEase(localStep, localStep+14, 'mirrorAngle', 360*16, 'cubeOut')
        end
        if curStep == 1504 then
            setValue("hudShake", 200)
            queueEase(localStep, localStep+23, 'hudShake', 0, 'cubeOut')
            queueEase(localStep, localStep+7, 'mirrorZoom', 20, 'cubeOut')
            queueEase(localStep, localStep+7, 'grace', 1, 'cubeOut')
        end
        if curStep == 1520 then
            queueEase(localStep, localStep+15, 'transformX', 325, 'cubeIn', 1)
            queueEase(localStep, localStep+15, 'hudShake', 2000, 'cubeIn')
            queueEase(localStep, localStep+7, 'grace2', 0.5, 'cubeIn')
            queueEase(localStep, localStep+7, 'grace', 0, 'cubeIn')
            queueEase(localStep, localStep+15, 'mirrorAngle', 0, 'cubeIn')
            queueEase(localStep, localStep+15, 'mirrorZoom', 1, 'cubeIn')
            doTweenAlpha("pixTrans", "redFlash", 0.4, 2.1, "cubeIn")
            doTweenAlpha("pixTrans2", "moonP", 0.4, 2.1, "cubeIn")
            doTweenY("pixTrans3", "pixelCam", 100, 2.6, "cubeOut")
            doTweenAlpha("pixTrans4", "pixelCam", 0.2, 2.1, "cubeIn")
        end
        if curStep == 1536 then
            cameraFlash("other", "FFFFFF", 0.5, true)
            setProperty("redFlash.alpha", 1)
            setProperty("pixelCam.alpha", 1)
            setProperty("moonP.alpha", 1)
            setValue('mirrorZoom', 1)
            setValue('mirrorAngle', 0)
            setValue('mirrorX', 0)
            setValue('mirrorY', 0)
            setValue('alpha', 1, 0)
            setValue('transformX', 375)
            setValue('transformX', -260, 0)
            setValue('alternate', 1)
            setValue('centered', 1)
            setValue('boost', 2)
            setValue('localrotateZ', 90)
            setValue('transformZ', -325)
            setValue('cmod', 5)
            setValue('zigzag', 0)
            setValue('hudShake', 0)
            shaderVar('ca', 'strength', 0.005)
            setValue('receptor0Angle', 90)
            setValue('receptor1Angle', 180)
            setValue('receptor2Angle', 0)
            setValue('receptor3Angle', 270)
            setValue('note0Angle', 90)
            setValue('note1Angle', 180)
            setValue('note2Angle', 0)
            setValue('note3Angle', 270)
            setProperty("healthBar.alpha", 0)
            setProperty("healthBar2.alpha", 0)
            setProperty("timeBar.alpha", 0)
            setProperty("showRating", false)
            setProperty("showComboNum", false)
        end

        if curStep == 1600 then
            doTweenAlpha("pixTrans", "redFlash", 0, 10, "cubeInOut")
            doTweenAlpha("pixTrans1", "healthBar", 1, 10, "cubeInOut")
            doTweenAlpha("pixTrans2", "healthBar2", 1, 10, "cubeInOut")
            doTweenAlpha("pixTrans3", "timeBar", 1, 10, "cubeInOut")
            doTweenAlpha("pixTrans6", "moonP", 0, 10, "cubeInOut")
            doTweenAlpha("pixTrans8", "pixelCam", 0, 10, "cubeInOut")
            queueEase(localStep, localStep+63, 'transformZ', 0, 'cubeOut')

            queueEase(localStep, localStep+63, 'note0Angle', 0, 'cubeOut')
            queueEase(localStep, localStep+63, 'note1Angle', 0, 'cubeOut')
            queueEase(localStep, localStep+63, 'note3Angle', 0, 'cubeOut')
            queueEase(localStep, localStep+63, 'receptor0Angle', 0, 'cubeOut')
            queueEase(localStep, localStep+63, 'receptor1Angle', 0, 'cubeOut')
            queueEase(localStep, localStep+63, 'receptor3Angle', 0, 'cubeOut')

            queueEase(localStep, localStep+63, 'drawDistance', 100000, 'cubeOut')
        end

        doBurstOnStep(1660)
        doZoomOnStep(1660)
        if curStep == 1664 then
            queueEase(curStep, curStep+3, 'mini', 1, 'cubeOut')
        end

        doBurstOnStep(1664)
        doZoomOnStep(1664)
        if curStep == 1664 then
            queueEase(curStep, curStep+3, 'tipZ', 5, 'cubeOut')
            queueEase(curStep, curStep+3, 'drunk', 5, 'cubeOut')
            queueEase(curStep, curStep+3, 'cmod', 1, 'cubeOut')
            setProperty("showRating", true)
            setProperty("showComboNum", true)
        end

        doBurstOnStep(1680)
        doZoomOnStep(1680)

        doBurstOnStep(1696)
        doZoomOnStep(1696)

        doBurstOnStep(1712)
        doZoomOnStep(1712)
        
        doBurstOnStep(1720)
        doZoomOnStep(1720)

        doBurstOnStep(1723)
        doZoomOnStep(1723)
        doBurstOnStep(1724)
        doZoomOnStep(1724)
        doBurstOnStep(1725)
        doZoomOnStep(1725)

        doBurstOnStep(1728)
        doZoomOnStep(1728)

        doBurstOnStep(1744)
        doZoomOnStep(1744)

        doBurstOnStep(1760)
        doZoomOnStep(1760)

        doBurstOnStep(1776)
        doZoomOnStep(1776)

        if curStep == 1848 then
            queueEase(curStep, curStep+3, 'mini', 0, 'cubeOut')
            queueEase(curStep, curStep+3, 'tipZ', 0, 'cubeOut')
            queueEase(curStep, curStep+3, 'drunk', 0, 'cubeOut')
            queueEase(curStep, curStep+3, 'alternate', 0, 'cubeOut')
            queueEase(curStep, curStep+3, 'centered', 0, 'cubeOut')
            queueEase(curStep, curStep+3, 'boost', 0, 'cubeOut')
            queueEase(curStep, curStep+3, 'centerrotateY', 0, 'cubeOut')
            queueEase(curStep, curStep+3, 'localrotateZ', 0, 'cubeOut')
            queueEase(curStep, curStep+3, 'transformX', -325, 'cubeOut', 0)
            setValue('zigzag', 0)
            setValue('cmod', 0)
            queueEase(curStep, curStep+3, 'cmod', 2, 'cubeOut')
            shaderVar('ca', 'strength', 0.005)
            textFlash = false
            setTextColor("Big Ol Words", "000000")
            setTextString("Big Ol Words", "BLACK")
            setValue("hudShake", 100)
            queueEase(curStep, curStep+8, 'grace', 0.8, 'sineOut')
            queueEase(curStep, curStep+8, 'mirrorZoom', 5, 'sineOut')
            queueEase(curStep, curStep+8, 'tornado', 2, 'sineOut')
        end

        if curStep == 1852 then
            --queueEase(curStep, curStep+3, 'cmod', 4, 'cubeOut')
            setTextString("Big Ol Words", "BLACK MAGIC")
        end

        if curStep == 1854 then
            setValue("hudShake", 0)
            setTextString("Big Ol Words", "")
            rave3 = true
        end
        if curStep == 1857 then
            flipOrama3 = true
        end

        if curStep == 1967 then
            rave3 = false
        end
        if curStep == 1968 then
            flipOrama3 = false
        end

        if curStep == 1987 then
            rave3 = true
        end
        if curStep == 1988 then
            flipOrama3 = true
            cameraFlash('camVisual', 'FF0000', 1)
        end

        if curStep == 2039 then
            rave3 = false
        end
        if curStep == 2040 then
            flipOrama3 = false
            textFlash = true
            setTextString("Big Ol Words", "WHAT")
        end
        if curStep == 2042 then
            setTextString("Big Ol Words", "WHAT THE")
        end
        if curStep == 2047 then
            setTextString("Big Ol Words", "")
            rave3 = true
        end
        if curStep == 2048 then
            flipOrama3 = true
            cameraFlash('camVisual', 'FF0000', 1)
        end
        if curStep == 2079 then
            rave3 = false
        end
        if curStep == 2080 then
            flipOrama3 = true
            cameraFlash('camVisual', 'FF0000', 0.5, true)
            setValue("mirrorZoom", 10)
        end
        if curStep == 2081 then
            flipOrama3 = false
        end
        if curStep == 2088 then
            flipOrama3 = true
            cameraFlash('camVisual', 'FF0000', 0.5, true)
            setValue("mirrorZoom", 8)
        end
        if curStep == 2089 then
            flipOrama3 = false
        end
        if curStep == 2096 then
            flipOrama3 = true
            cameraFlash('camVisual', 'FF0000', 0.5, true)
            setValue("mirrorZoom", 6)
        end
        if curStep == 2097 then
            flipOrama3 = false
        end
        if curStep == 2100 then
            flipOrama3 = true
            cameraFlash('camVisual', 'FF0000', 0.5, true)
            setValue("mirrorZoom", 4)
        end
        if curStep == 2101 then
            flipOrama3 = false
        end
        if curStep == 2104 then
            flipOrama3 = true
            cameraFlash('camVisual', 'FF0000', 0.5, true)
            setValue("mirrorZoom", 2)
        end
        if curStep == 2105 then
            flipOrama3 = false
        end
        if curStep == 2111 then
            rave3 = true
        end
        if curStep == 2112 then
            flipOrama3 = true
            cameraFlash('camVisual', 'FF0000', 1)
            setValue("mirrorZoom", 10)
        end
        if curStep == 2223 then
            rave3 = false
        end
        if curStep == 2224 then
            flipOrama3 = false
            queueEase(curStep, curStep+3, 'tornado', 0, 'sineOut')
            setValue('cmod', 5)
            setValue('boost', 3)
            setValue('drawDistance', 200)
            setValue('zigzag', 0)
        end
        if curStep == 2239 then
            rave1 = true
        end
        if curStep == 2286 then
            rave1 = false
        end
        if curStep == 2288 then
            setTextString("Big Ol Words", "I-")
            screenCenter("Big Ol Words")
        end
        if curStep == 2290 then
            setTextString("Big Ol Words", "I")
        end
        if curStep == 2292 then
            setTextString("Big Ol Words", "AINT'")
        end
        if curStep == 2296 then
            setTextString("Big Ol Words", "DONE")
        end
        if curStep == 2300 then
            setTextString("Big Ol Words", "YET")
        end
        if curStep == 2304 then
            setTextString("Big Ol Words", "")
        end
        if curStep == 2367 then
            discombobulate = true
            queueEase(curStep, curStep+3, 'grace', 0.4, 'sineOut')
            queueEase(curStep, curStep+3, 'grey', 1, 'sineOut')
            setValue('drawDistance', 1500)
            setValue("boost", 0)
            setValue("cmod", 5)
            --setValue("grey", 1)
            shaderVar('ca', 'strength', 0.005)
        end
        if curStep == 2427 then
            discombobulate = false
        end
        doTiltOnStep(2428, 360)
        doZoomOnStep(2428)
        if curStep == 2428 then
            queueEase(curStep, curStep+3, 'mirrorZoom', 1, 'sineOut')
            setValue("cmod", 2)
        end

        if curStep == 2431 then
            discombobulate = true
        end

        if curStep == 2432 then
            setValue("cmod", 5)
            queueEase(curStep, curStep+3, 'mirrorZoom', 5, 'sineOut')
        end

        if curStep == 2463 then
            discombobulate = false
        end

        if curStep == 2492 then
            setValue("cmod", 2)
            queueEase(curStep, curStep+3, 'mirrorAngle', 25, 'elasticOut')
            queueEase(curStep, curStep+1, 'mirrorZoom', 0.5, 'elasticOut')
            queueEase(curStep, curStep+3, 'centered', 1, 'cubeOut')
            setValue("hudShake", 100)
            queueEase(curStep, curStep+3, 'hudShake', 0, 'cubeOut')
            queueEase(curStep, curStep+3, 'grey', 0, 'cubeOut')
        end

        if curStep == 2495 then
            discombobulate = true
        end

        if curStep == 2496 then
            queueEase(curStep, curStep+3, 'grey', 1, 'cubeOut')
            queueEase(curStep, curStep+3, 'mirrorAngle', 0, 'elasticOut')
            queueEase(curStep, curStep+1, 'mirrorZoom', 5, 'elasticOut')
            queueEase(curStep, curStep+3, 'centered', 0, 'cubeOut')
            setValue("cmod", 5)
        end

        if curStep == 2551 then
            discombobulate = false
        end

        if curStep == 2552 then
            queueEase(curStep, curStep+15, 'centerrotateY', 360*8, 'cubeOut')
            queueEase(curStep, curStep+15, 'mirrorAngle', 360*8, 'cubeOut')
            setValue("mirrorZoom", 1)
            queueEase(curStep, curStep+15, 'mirrorZoom', 5, 'cubeOut')
            setValue("cmod", 0)
            queueEase(curStep, curStep+15, 'cmod', 5, 'cubeOut')
        end

        if curStep == 2559 then
            discombobulate = true
        end

        if curStep == 2592 then
            queueEase(curStep, curStep+31, 'centerrotateY', 360*16, 'cubeIn')
            queueEase(curStep, curStep+31, 'mirrorAngle', 360*16, 'cubeOut')
            queueEase(curStep, curStep+31, 'mirrorZoom', 1, 'cubeOut')
            queueEase(curStep, curStep+31, 'mirrorX', 0, 'cubeOut')
        end
        
        if curStep == 2607 then
            discombobulate = false
        end
        
        if curStep == 2623 then
            cameraFlash('other', 'FF0000', 2, true)
            setValue("cmod", 0.5)
            setValue("drunk", 2)
            setValue("tipsy", 2)
            setValue("tipZ", 2)
            setValue("grey", 0)
            setValue("flip", 0)
            setValue("invert", 0)
        end
        doZoomOnStep(2624)
        doBurstOnStep(2624)
        --KILLER MOON
    else
        localStep = curStep
        sCroch = stepCrochet

        if textFlash then
            if curStep % 2 == 0 then
                setTextColor("Big Ol Words", "ff0000")
            else
                setTextColor("Big Ol Words", "ffffff")
            end
        end

        doBurstOnStep(32)
        doZoomOnStep(32)

        doBurstOnStep(160)
        doZoomOnStep(160)

        doBurstOnStep(288)
        doZoomOnStep(288)

        doBurstOnStep(352)
        doZoomOnStep(352)

        doBurstOnStep(378)
        doZoomOnStep(378)
        doTiltOnStep(378, 15)

        doBurstOnStep(383)
        doZoomOnStep(383)
        doTiltOnStep(383, -15)

        doBurstOnStep(410)
        doZoomOnStep(410)
        doTiltOnStep(410, 15)

        doBurstOnStep(416)
        doZoomOnStep(416)
        doTiltOnStep(416, -15)

        doBurstOnStep(442)
        doZoomOnStep(442)
        doTiltOnStep(442, 15)

        doBurstOnStep(448)
        doZoomOnStep(448)
        doTiltOnStep(448, -15)

        doBurstOnStep(474)
        doZoomOnStep(474)
        doTiltOnStep(474, 15)

        doBurstOnStep(480)
        doZoomOnStep(480)
        doTiltOnStep(480, -15)

        doBurstOnStep(506)
        doZoomOnStep(506)
        doTiltOnStep(506, 15)

        doBurstOnStep(512)
        doZoomOnStep(512)
        doTiltOnStep(512, -15)

        doBurstOnStep(538)
        doZoomOnStep(538)
        doTiltOnStep(538, 15)

        doBurstOnStep(544)
        doZoomOnStep(544)
        doTiltOnStep(544, -15)

        doBurstOnStep(570)
        doZoomOnStep(570)
        doTiltOnStep(570, 15)

        doBurstOnStep(576)
        doZoomOnStep(576)
        doTiltOnStep(576, -15)

        doZoomOnStep(580)
        doZoomOnStep(581)
        doZoomOnStep(582)
        doZoomOnStep(583)
        doZoomOnStep(584)

        doZoomOnStep(588)
        doZoomOnStep(589)
        doZoomOnStep(590)
        doZoomOnStep(591)
        doZoomOnStep(592)

        doZoomOnStep(596)

        doZoomOnStep(600)

        doTiltOnStep(604, 360)

        if curStep == 720 then
            shaderVar('ca', 'strength', 0.005)
            setTextString("Big Ol Words", "KILLER")
            setValue("hudShake", 1000)
        end
        if curStep == 728 then
            setTextString("Big Ol Words", "KILLER MOON")
        end
        if curStep == 735 then
            setValue("hudShake", 0)
            setTextString("Big Ol Words", "")
            rave1 = true
        end
        if curStep == 791 then
            rave1 = false
        end
        doTiltOnStep(796, 360)
        if curStep == 799 then
            rave1 = true
        end
        if curStep == 829 then
            rave1 = false
        end
        doTiltOnStep(860, 360)
        if curStep == 861 then
            rave2 = true
        end
        doTiltOnStep(920, 360)
        if curStep == 916 then
            rave2 = false
        end
        if curStep == 927 then
            rave2 = true
        end
        if curStep == 959 then
            rave2 = false
            setValue("mirrorZoom", 1)
        end
        doBurstOnStep(992)
        doZoomOnStep(992)
        if curStep == 992 then
            setValue("mirrorZoom", 1)
        end
        doBurstOnStep(1020)
        doZoomOnStep(1020)

        doBurstOnStep(1024)
        doZoomOnStep(1024)

        doBurstOnStep(1052)
        doZoomOnStep(1052)

        doBurstOnStep(1056)
        doZoomOnStep(1056)

        doBurstOnStep(1084)
        doZoomOnStep(1084)

        doBurstOnStep(1088)
        doZoomOnStep(1088)
        if curStep >= 1104 and curStep <= 1119 then
            doZoomOnStep(curStep)
        end
        doTiltOnStep(1176, 15)

        doTiltOnStep(1180, -15)
        doTiltOnStep(1181, -15)
        doTiltOnStep(1182, -15)
        doTiltOnStep(1183, -15)
        if curStep == 1295 then
            setValue("mirrorAngle", 15)
        end
        if curStep == 1300 then
            queueEase(localStep, localStep+3, 'mirrorAngle', 0, 'cubeOut')
        end
        if curStep == 1304 then
            setValue("mirrorAngle", -15)
        end
        if curStep == 1306 then
            queueEase(localStep, localStep+3, 'mirrorAngle', 0, 'cubeOut')
        end
        if curStep >= 1344 and curStep <= 1359 then
            shaderVar('vignette', 'strength', 50)
            shaderVar('scanline', 'strength', 1)
            setValue("blur", 1)
            setValue("grey", 1)
            setValue("hudShake", 5)
        end
        if curStep == 1360 then
            setValue("hudShake", 0)
            shaderVar('ca', 'strength', 0)
            shaderVar('vignette', 'strength', 0)
            shaderVar('scanline', 'strength', 0)
            setValue("blur", 0)
            setValue("grey", 0)
        end
        if curStep == 1370 then
            setValue("mirrorAngle", -90)
        end
        if curStep == 1372 then
            queueEase(localStep, localStep+3, 'mirrorAngle', 0, 'cubeOut')
        end
        if curStep == 1432 then
            queueEase(localStep, localStep+14, 'mirrorAngle', 360*8, 'cubeOut')
        end
        if curStep == 1504 then
            setValue("hudShake", 200)
            queueEase(localStep, localStep+23, 'hudShake', 0, 'cubeOut')
        end
        if curStep == 1520 then
            queueEase(localStep, localStep+15, 'hudShake', 2000, 'cubeIn')
        end
        if curStep == 1536 then
            cameraFlash("hud", "FFFFFF", 0.5, true)
            setProperty("redFlash.alpha", 1)
            setValue('alpha', 1, 0)
            setValue('alpha', 0, 1)
            setProperty("boyfriend.alpha", 0)
            setProperty("dad.alpha", 0)
            setProperty("pixelBF.alpha", 1)
            setProperty("pixelGF.alpha", 1)
            setValue('hudShake', 0)
            shaderVar('ca', 'strength', 0.005)
            setProperty("healthBar.alpha", 0)
            setProperty("healthBar2.alpha", 0)
            setProperty("timeBar.alpha", 0)
            setProperty("showRating", false)
            setProperty("showComboNum", false)
        end
        if curStep == 1600 then
            doTweenAlpha("pixTrans", "redFlash", 0, 10, "cubeInOut")
            doTweenAlpha("pixTrans1", "healthBar", 1, 10, "cubeInOut")
            doTweenAlpha("pixTrans2", "healthBar2", 1, 10, "cubeInOut")
            doTweenAlpha("pixTrans3", "timeBar", 1, 10, "cubeInOut")
            doTweenAlpha("pixTrans4", "boyfriend", 1, 10, "cubeInOut")
            doTweenAlpha("pixTrans4.5", "dad", 1, 10, "cubeInOut")
            doTweenAlpha("pixTrans5", "pixelBF", 0, 10, "cubeInOut")
            doTweenAlpha("pixTrans5.5", "pixelGF", 0, 10, "cubeInOut")
        end
        doBurstOnStep(1660)
        doZoomOnStep(1660)
        
        doBurstOnStep(1664)
        doZoomOnStep(1664)
        if curStep == 1664 then
            setProperty("showRating", true)
            setProperty("showComboNum", true)
        end
        doBurstOnStep(1680)
        doZoomOnStep(1680)

        doBurstOnStep(1696)
        doZoomOnStep(1696)

        doBurstOnStep(1712)
        doZoomOnStep(1712)
        
        doBurstOnStep(1720)
        doZoomOnStep(1720)

        doBurstOnStep(1723)
        doZoomOnStep(1723)
        doBurstOnStep(1724)
        doZoomOnStep(1724)
        doBurstOnStep(1725)
        doZoomOnStep(1725)

        doBurstOnStep(1728)
        doZoomOnStep(1728)

        doBurstOnStep(1744)
        doZoomOnStep(1744)

        doBurstOnStep(1760)
        doZoomOnStep(1760)

        doBurstOnStep(1776)
        doZoomOnStep(1776)

        if curStep == 1848 then
            shaderVar('ca', 'strength', 0.005)
            textFlash = false
            setTextColor("Big Ol Words", "000000")
            setTextString("Big Ol Words", "BLACK")
            setValue("hudShake", 100)
        end
        if curStep == 1852 then
            --queueEase(curStep, curStep+3, 'cmod', 4, 'cubeOut')
            setTextString("Big Ol Words", "BLACK MAGIC")
        end
        if curStep == 1854 then
            setValue("hudShake", 0)
            setTextString("Big Ol Words", "")
            rave3 = true
        end
        if curStep == 1967 then
            rave3 = false
        end
        if curStep == 1987 then
            rave3 = true
        end
        if curStep == 1988 then
            cameraFlash('camVisual', 'FF0000', 1)
        end
        if curStep == 2039 then
            rave3 = false
        end
        if curStep == 2040 then
            textFlash = true
            setTextString("Big Ol Words", "WHAT")
        end
        if curStep == 2042 then
            setTextString("Big Ol Words", "WHAT THE")
        end
        if curStep == 2047 then
            setTextString("Big Ol Words", "")
            rave3 = true
        end
        if curStep == 2048 then
            cameraFlash('camVisual', 'FF0000', 1)
        end
        if curStep == 2079 then
            rave3 = false
        end
        if curStep == 2080 then
            cameraFlash('camVisual', 'FF0000', 0.5, true)
        end
        if curStep == 2088 then
            cameraFlash('camVisual', 'FF0000', 0.5, true)
        end
        if curStep == 2096 then
            cameraFlash('camVisual', 'FF0000', 0.5, true)
        end
        if curStep == 2100 then
            cameraFlash('camVisual', 'FF0000', 0.5, true)
        end
        if curStep == 2104 then
            cameraFlash('camVisual', 'FF0000', 0.5, true)
        end
        if curStep == 2111 then
            rave3 = true
        end
        if curStep == 2112 then
            cameraFlash('camVisual', 'FF0000', 1)
        end
        if curStep == 2223 then
            rave3 = false
        end
        if curStep == 2224 then
            queueEase(curStep, curStep+3, 'tornado', 0, 'sineOut')
        end
        if curStep == 2239 then
            rave1 = true
        end
        if curStep == 2286 then
            rave1 = false
        end
        if curStep == 2288 then
            setTextString("Big Ol Words", "I-")
            screenCenter("Big Ol Words")
        end
        if curStep == 2290 then
            setTextString("Big Ol Words", "I")
        end
        if curStep == 2292 then
            setTextString("Big Ol Words", "AINT'")
        end
        if curStep == 2296 then
            setTextString("Big Ol Words", "DONE")
        end
        if curStep == 2300 then
            setTextString("Big Ol Words", "YET")
        end
        if curStep == 2304 then
            setTextString("Big Ol Words", "")
        end

        if curStep == 2367 then
            discombobulate = true
            queueEase(curStep, curStep+3, 'grace', 0.4, 'sineOut')
            queueEase(curStep, curStep+3, 'grey', 1, 'sineOut')
            setValue('drawDistance', 1500)
            setValue("boost", 0)
            setValue("cmod", 5)
            --setValue("grey", 1)
            shaderVar('ca', 'strength', 0.005)
        end
        if curStep == 2427 then
            discombobulate = false
        end
        doTiltOnStep(2428, 360)
        doZoomOnStep(2428)
        if curStep == 2492 then
            queueEase(curStep, curStep+3, 'mirrorAngle', 25, 'elasticOut')
            setValue("hudShake", 100)
            queueEase(curStep, curStep+3, 'hudShake', 0, 'cubeOut')
            queueEase(curStep, curStep+3, 'grey', 0, 'cubeOut')
        end

        if curStep == 2496 then
            queueEase(curStep, curStep+3, 'grey', 1, 'cubeOut')
            queueEase(curStep, curStep+3, 'mirrorAngle', 0, 'elasticOut')
        end
        if curStep == 2552 then
            queueEase(curStep, curStep+15, 'mirrorAngle', 360*8, 'cubeOut')
        end
        if curStep == 2592 then
            queueEase(curStep, curStep+31, 'mirrorAngle', 360*16, 'cubeOut')
        end

        if curStep == 2623 then
            cameraFlash('other', 'FF0000', 2, true)
            setValue("grey", 0)
        end
        doZoomOnStep(2624)
        doBurstOnStep(2624)
    end
end
updownfunk = false
local singDir = {"singLEFT", "singDOWN", "singUP", "singRIGHT"}
function goodNoteHit(a, b, c, d)
    setProperty("camZooming", false)
    if difficultyName == "NITG" or difficultyName == "POSSESSED" then
        if localStep >= 832 and localStep <= 859 or localStep >= 1184 and localStep <= 1240 or localStep >= 1488 and localStep <= 1504 or localStep >= 1792 and localStep <= 1848 or localStep >= 2368 and localStep <= 2427 or localStep >= 2432 and localStep <= 2488 or localStep >= 2496 and localStep <= 2551 or localStep >= 2560 and localStep <= 2592 then
            updownfunk = not updownfunk
            if updownfunk then
                queueEase(localStep, localStep+1, 'transform0Y', 25, 'cubeOut')
                queueEase(localStep, localStep+1, 'transform1Y', -25, 'cubeOut')
                queueEase(localStep, localStep+1, 'transform2Y', 25, 'cubeOut')
                queueEase(localStep, localStep+1, 'transform3Y', -25, 'cubeOut')
                
                queueEase(localStep+2, localStep+3, 'transform0Y', 0, 'cubeOut')
                queueEase(localStep+2, localStep+3, 'transform1Y', 0, 'cubeOut')
                queueEase(localStep+2, localStep+3, 'transform2Y', 0, 'cubeOut')
                queueEase(localStep+2, localStep+3, 'transform3Y', 0, 'cubeOut')

                if localStep >= 2368 and localStep <= 2427 or localStep >= 2432 and localStep <= 2488 or localStep >= 2496 and localStep <= 2551 or localStep >= 2560 and localStep <= 2592 then
                    queueEase(localStep, localStep+1, 'mirrorX', 1, 'cubeOut')
                    queueEase(localStep, localStep+1, 'mirrorAngle', 15, 'cubeOut')
                    queueEase(localStep, localStep+1, 'flip', 1, 'cubeOut')
                end
                    
            else
                queueEase(localStep, localStep+1, 'transform0Y', -25, 'cubeOut')
                queueEase(localStep, localStep+1, 'transform1Y', 25, 'cubeOut')
                queueEase(localStep, localStep+1, 'transform2Y', -25, 'cubeOut')
                queueEase(localStep, localStep+1, 'transform3Y', 25, 'cubeOut')
        
                queueEase(localStep+2, localStep+3, 'transform0Y', 0, 'cubeOut')
                queueEase(localStep+2, localStep+3, 'transform1Y', 0, 'cubeOut')
                queueEase(localStep+2, localStep+3, 'transform2Y', 0, 'cubeOut')
                queueEase(localStep+2, localStep+3, 'transform3Y', 0, 'cubeOut')

                if localStep >= 2368 and localStep <= 2427 or localStep >= 2432 and localStep <= 2488 or localStep >= 2496 and localStep <= 2551 or localStep >= 2560 and localStep <= 2592 then
                    queueEase(localStep, localStep+1, 'mirrorX', -1, 'cubeOut')
                    queueEase(localStep, localStep+1, 'mirrorAngle', -15, 'cubeOut')
                    queueEase(localStep, localStep+1, 'flip', 0, 'cubeOut')
                end
            end
            if localStep >= 1184 and localStep <= 1240 then
                doZoomOnStep(localStep)
                doBurstOnStep(localStep)
            end
            
            if localStep >= 1792 and localStep <= 1847 then
                doBurstOnStep(localStep)
            end
        end
        if localStep >= 860 and localStep <= 864 or localStep >= 2427 and localStep <= 2429 then
            queueEase(localStep, localStep+1, 'transform0Y', 50, 'cubeOut')
            queueEase(localStep, localStep+1, 'transform1Y', -50, 'cubeOut')
            queueEase(localStep, localStep+1, 'transform2Y', 50, 'cubeOut')
            queueEase(localStep, localStep+1, 'transform3Y', -50, 'cubeOut')
            
            queueEase(localStep+2, localStep+3, 'transform0Y', 0, 'cubeOut')
            queueEase(localStep+2, localStep+3, 'transform1Y', 0, 'cubeOut')
            queueEase(localStep+2, localStep+3, 'transform2Y', 0, 'cubeOut')
            queueEase(localStep+2, localStep+3, 'transform3Y', 0, 'cubeOut')
        end
        if localStep >= 1120 and localStep <= 1135 or localStep >= 1152 and localStep <= 1167 or localStep >= 2030 and localStep <= 2351 then
            doBurstOnStep(localStep)
            doZoomOnStep(localStep)
        end
        if localStep >= 2044 and localStep <= 2046 then
            if freakOut then
                freakOut = false
                setTextString("Big Ol Words", "WHAT THE FU-")
            else
                freakOut = true
                setTextString("Big Ol Words", "ERROR")
            end
        end
    elseif difficultyName == "FNF" then
        playAnim("pixelBF", singDir[b+1], true)
        if localStep >= 1184 and localStep <= 1240 then
            doZoomOnStep(localStep)
            doBurstOnStep(localStep)
        end
        
        if localStep >= 1792 and localStep <= 1847 then
            doBurstOnStep(localStep)
        end
        if localStep >= 1120 and localStep <= 1135 or localStep >= 1152 and localStep <= 1167 or localStep >= 2030 and localStep <= 2351 then
            doBurstOnStep(localStep)
            doZoomOnStep(localStep)
        end
        if localStep >= 2044 and localStep <= 2046 then
            if freakOut then
                freakOut = false
                setTextString("Big Ol Words", "WHAT THE FU-")
            else
                freakOut = true
                setTextString("Big Ol Words", "ERROR")
            end
        end
    end
end

lastFlip = 0

function onBeatHit()
    if difficultyName == "NITG" or difficultyName == "POSSESSED" then
        if jumpy then
            if curBeat % 2 == 0 then 
                queueEase(localStep, localStep+1, 'transformY', -50, 'sineOut')
                queueEase(localStep+2, localStep+3, 'transformY', 0, 'sineOut')

                queueEase(localStep, localStep+1, 'mirrorZoom', 1.3, 'sineOut')
                queueEase(localStep+2, localStep+3, 'mirrorZoom', 1, 'sineOut')
            else
                queueEase(localStep, localStep+1, 'mirrorZoom', 1.3, 'sineOut')
                queueEase(localStep+2, localStep+3, 'mirrorZoom', 1, 'sineOut')

                queueEase(localStep, localStep+1, 'transformY', 50, 'sineOut')
                queueEase(localStep+2, localStep+3, 'transformY', 0, 'sineOut')
            end
        end

        if rave1 then
            queueEase(localStep, localStep, 'mini', 1, 'sineOut')
            queueEase(localStep+1, localStep+3, 'mini', 0, 'cubeut')

            queueEase(localStep, localStep, 'cmod', 4, 'sineOut')
            queueEase(localStep+1, localStep+3, 'cmod', 2, 'cubeut')
            doBurstOnStep(localStep)
            doZoomOnStep(localStep)
        end

        if rave3 then
            queueEase(localStep, localStep, 'mini', 1, 'sineOut')
            queueEase(localStep+1, localStep+3, 'mini', 0, 'cubeut')

            queueEase(localStep, localStep, 'confusion', 0.1, 'sineOut')
            queueEase(localStep+1, localStep+4, 'confusion', 0, 'cubeut')

            queueEase(localStep, localStep, 'cmod', 8, 'sineOut')
            queueEase(localStep+1, localStep+3, 'cmod', 2, 'cubeut')
            doZoomOnStep(localStep)
            doBurstOnStep(localStep)
            cameraFlash('camVisual', 'FF0000', 1, true)
            if curBeat % 2 == 0 then
                doTiltOnStep(localStep, -15)
                queueEase(localStep, localStep, 'centerrotateY', 50, 'sineOut')
                queueEase(localStep+1, localStep+7, 'centerrotateY', 0, 'cubeut')

                queueEase(localStep, localStep, 'centerrotateZ', 50, 'sineOut')
                queueEase(localStep+1, localStep+7, 'centerrotateZ', 0, 'cubeut')
            else
                doTiltOnStep(localStep, 15)
                queueEase(localStep, localStep, 'centerrotateY', -50, 'sineOut')
                queueEase(localStep+1, localStep+7, 'centerrotateY', 0, 'cubeut')

                queueEase(localStep, localStep, 'centerrotateZ', -50, 'sineOut')
                queueEase(localStep+1, localStep+7, 'centerrotateZ', 0, 'cubeut')
            end
        end

        if rave2 then
            queueEase(localStep, localStep, 'noteAlpha', 1, 'sineOut')
            queueEase(localStep+1, localStep+3, 'noteAlpha', 0, 'cubeut')

            queueEase(localStep, localStep, 'mini', 1, 'sineOut')
            queueEase(localStep+1, localStep+3, 'mini', 0, 'cubeut')
            doBurstOnStep(localStep)
            doZoomOnStep(localStep)
        end

        if flipOrama then
            mirXPos = mirXPos+1
            queueEase(localStep, localStep+3, 'mirrorX', mirXPos, 'cubeOut')
            if lastFlip == 0 then
                queueEase(localStep, localStep+3, 'flip', 1, 'cubeOut')
                lastFlip = 1
            elseif lastFlip == 1 then
                queueEase(localStep, localStep+3, 'flip', 0, 'cubeOut')
                lastFlip = 0
            end
        end
        
        if flipOrama2 then
            mirXPos = mirXPos-1
            mirAnPos = mirAnPos-90
            queueEase(localStep, localStep+3, 'mirrorX', mirXPos, 'cubeOut')
            queueEase(localStep, localStep+3, 'mirrorAngle', mirAnPos, 'cubeOut')
            if lastFlip == 0 then
                queueEase(localStep, localStep+3, 'flip', 1, 'cubeOut')
                lastFlip = 1
            elseif lastFlip == 1 then
                queueEase(localStep, localStep+3, 'flip', 0, 'cubeOut')
                lastFlip = 0
            end
        end

        if flipOrama3 then
            if lastFlip == 0 then
                setValue("scale", 10)
                queueEase(localStep, localStep+4, 'scale', 1, 'cubeOut')
                lastFlip = 1
            elseif lastFlip == 1 then
                setValue("scale", 10)
                queueEase(localStep, localStep+4, 'scale', 1, 'cubeOut')
                lastFlip = 0
            end
        end

        if spinGod then
            if curBeat % 16 == 0 then
                queueEase(localStep, localStep+31, 'centerrotateY', 0, 'cubeInOut')
            elseif curBeat % 16 == 8 then
                queueEase(localStep, localStep+31, 'centerrotateY', 360*64, 'cubeInOut')
            end
        end

        if jumpy2 then
            if curBeat % 2 == 0 then 
                queueEase(localStep, localStep+3, 'mirrorY', 1, 'sineOut')
            else
                queueEase(localStep, localStep+3, 'mirrorY', 0, 'sineOut')
            end
        end


        if revModSwap then
            mirXPos=mirXPos+1
            queueEase(localStep, localStep+3, 'mirrorX', mirXPos, 'cubeOut')
            if modNum == 0 then
                queueEase(localStep, localStep+3, 'split', 1, 'cubeOut')
                queueEase(localStep, localStep+3, 'alternate', 0, 'cubeOut')
                queueEase(localStep, localStep+3, 'cross', 0, 'cubeOut')
                modNum = 1
            elseif modNum == 1 or modNum == 3 then
                queueEase(localStep, localStep+3, 'split', 0, 'cubeOut')
                queueEase(localStep, localStep+3, 'alternate', 1, 'cubeOut')
                queueEase(localStep, localStep+3, 'cross', 0, 'cubeOut')
                if modNum == 1 then modNum = 2 else modNum = 0 end
            elseif modNum == 2 then
                queueEase(localStep, localStep+3, 'split', 0, 'cubeOut')
                queueEase(localStep, localStep+3, 'alternate', 0, 'cubeOut')
                queueEase(localStep, localStep+3, 'cross', 1 , 'cubeOut')
                modNum = 3
            end
        end
    elseif difficultyName == "FNF" then
        if rave1 then
            doBurstOnStep(localStep)
            doZoomOnStep(localStep)
        end
        if rave3 then
            doZoomOnStep(localStep)
            doBurstOnStep(localStep)
            cameraFlash('camVisual', 'FF0000', 0.5, true)
            if curBeat % 2 == 0 then
                doTiltOnStep(localStep, -15)
            else
                doTiltOnStep(localStep, 15)
            end
        end
        if rave2 then
            doBurstOnStep(localStep)
            doZoomOnStep(localStep)
        end
        if not getProperty("pixelBF.animation.curAnim.name.startsWith('sing')") and getProperty("pixelBF.animation.curAnim.finished") then
            playAnim("pixelBF", "idle")
        end
        if curBeat % 4 == 0 then
            playAnim("pixelGF", "danceLeft")
        elseif curBeat % 4 == 2 then
            playAnim("pixelGF", "danceRight")
        end
    end
end
mirXPos = 0
mirAnPos = 0
modNum = 0 


queueContFunc(0, 999999999999999999, function(step)
    local beat = step / 4;
    for col = 0, 3 do
        local speed = getValue("haloSpeed", 0)
        local input = (col + 1 + beat) * math.rad(360 / 4)
        local radiusX = getValue("haloRadiusX", 0)
        local radiusZ = getValue("haloRadiusZ", 0)
        setValue("transform" .. col .. "X", radiusX * math.sin(input) * speed, 0)
        setValue("transform" .. col .. "Z", radiusZ * math.cos(input) * speed, 0)
    end
end)