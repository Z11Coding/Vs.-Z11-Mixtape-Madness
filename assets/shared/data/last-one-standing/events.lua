local defaultZoom = 1.2
local enableZoom = false
local camMulti = 4
local camZoomAggressive = false
local curZoom
local isZooming = false
local bfOffset = -250
function onCreatePost()
    makeLuaSprite("black", null, -500, -500)
    makeGraphic("black", screenWidth*5, screenHeight*5, '000000')
    --setObjectCamera("black", 'hud')
    setProperty("black.alpha", 0.8)
    addLuaSprite("black", true)
    setProperty("camHUD.alpha", 1)

    makeLuaText('skip', 'Press Space To Skip', 400, 0, 0)
    setObjectCamera('skip', 'other')
    scaleObject('skip', 2, 2, true)
    screenCenter("skip", 'xy')
    setProperty('skip.alpha', 0)
    addLuaText('skip')
    curZoom = getProperty('defaultCamZoom')
    setProperty('gf.alpha', 0)
    initLuaShader("B&W")
	makeLuaSprite("shaderThing")
	makeGraphic("shaderThing", screenWidth, screenHeight)
	setSpriteShader("shaderThing", "B&W")

	addHaxeLibrary("ShaderFilter", "openfl.filters")
	runHaxeCode([[
		//game.camGame.setFilters([new ShaderFilter(game.getLuaObject("shaderThing").shader)]);
		//game.camHUD.setFilters([new ShaderFilter(game.getLuaObject("shaderThing").shader)]);
	]])
    setProperty('healthBar.barWidth', getProperty('healthBar.bg.width') - 120)
    setProperty('healthBar.barHeight', getProperty('healthBar.bg.height') - 150)
    setProperty('healthBar.barOffset.x', getProperty('healthBar.barOffset.x') + 65)
    setProperty('healthBar.barOffset.y', getProperty('healthBar.barOffset.y') + 30)
    setProperty('healthBar.bg.y', getProperty('healthBar.bg.y') - 40)
    setProperty('iconP1.y', getProperty('iconP1.y') - 10)
    setProperty('iconP2.y', getProperty('iconP2.y') - 10)
    --THIS BAR TOOK WAY TOO LONG TO DO HOLY
end

function onStepHit()
    if curStep == 1 and getProperty('deathCounter') > 0 then
        doTweenAlpha('sdfghj', 'skip', 1, 1, 'sineInOut')
        allowSkip = true
    end
    if curStep == 120 then
        doTweenAlpha('hud', 'camHUD', 0.5, 1, 'sineInOut')
        doTweenZoom('zoomOut', 'camGame', 0.9, 3, 'sineInOut')
        setProperty('defaultCamZoom', 0.9)
        defaultZoom = 0.9
    end
    if curStep == 248 then
        doTweenAlpha('hud', 'camHUD', 1, 1, 'sineInOut')
        doTweenAlpha('black', 'black', 0.4, 1, 'sineInOut')
    end
    if curStep == 512 then
        doTweenAlpha('hud', 'camHUD', 0, 3, 'sineInOut')
        doTweenAlpha('black', 'black', 1, 3, 'sineInOut')
        doTweenZoom('zoomOut', 'camGame', 1.9, 9, 'sineInOut')
        setProperty('defaultCamZoom', 1.9)
        doTweenZoom('zoomOut', 'camHUD', 3, 3, 'sineInOut')
        defaultZoom = 1.9
    end
    if curStep == 528 then
        doTweenAlpha('sdfghj', 'skip', 0, 1, 'sineInOut')
        allowSkip = false
    end
    if curStep == 607 then
        doTweenAlpha('hud', 'camHUD', 1, 3, 'sineInOut')
        doTweenAlpha('black', 'black', 0, 3, 'sineInOut')
        doTweenZoom('zoomOut', 'camGame', 0.9, 6, 'sineInOut')
        setProperty('defaultCamZoom', 0.9)
        doTweenZoom('zoomOut', 'camHUD', 1, 3, 'sineInOut')
        defaultZoom = 0.9
    end
    if curStep == 640 then
        enableZoom = true
        camZoomAggressive = true
    end
    if curStep == 768 then
        setProperty('camZoomingMult', 2)
        camMulti = 2
    end
    if curStep == 896 then
        camMulti = 1
    end
    if curStep == 1151 then
        cameraFlash('camGame', 'be201c', 1, false)
        enableZoom = false
    end
    if curStep == 1407 then
        cameraFlash('camGame', 'be201c', 0.3, false)
    end
    if curStep == 1663 then
        doTweenZoom('zoomOut', 'camGame', 1.2, 1, 'sineInOut')
        setProperty('defaultCamZoom', 1.2)
        defaultZoom = 1.2
        setProperty('camZoomingMult', 1)
        camMulti = 2
    end
    if curStep == 1919 then
        cameraFlash('camGame', 'ffffff', 1, false)
        setProperty('black.alpha', 0.8)
        setProperty('camZoomingMult', 0)
        camMulti = 4
        camZoomAggressive = false
        bfOffset = -150
        playAnim('papshead', 'fade away', true)
    end
    if curStep == 2047 then
        doTweenAlpha('black', 'black', 0, 10, 'sineInOut')
        doTweenZoom('zoomOut', 'camGame', 0.9, 10, 'sineInOut')
        setProperty('defaultCamZoom', 0.9)
        defaultZoom = 0.9
    end
    if curStep == 2432 then
        cameraFlash('camGame', 'ffffff', 1, false)
        setProperty('camZoomingMult', 1)
        enableZoom = true
    end
    if curStep == 2560 then
        setProperty('camZoomingMult', 2)
    end
    if curStep == 2625 then
        cameraFlash('camGame', 'be201c', 0.3, false)
    end
    if curStep == 2688 then
        setProperty('camZoomingMult', 3)
        camMulti = 1
        camZoomAggressive = true
    end
    if curStep == 3072 then
        cameraFlash('camGame', 'be201c', 0.3, false)
    end
    if curStep == 3200 then
        cameraFlash('camGame', 'be201c', 0.3, false)
        camMulti = 4
        camZoomAggressive = false
        enableZoom = false
        setProperty('camZoomingMult', 1)
    end
    if curStep == 3456 then
        cameraFlash('camGame', 'ffffff', 0.3, false)
    end
    if curStep == 3712 then
        doTweenAlpha('hud', 'camHUD', 0, 3, 'sineInOut')
        doTweenAlpha('black', 'black', 1, 3, 'sineInOut')
    end
end

function onBeatHit()
    if camZoomAggressive then
        if curBeat % camMulti == 0 then
            --setProperty('FlxG.camera.zoom', getProperty('FlxG.camera.zoom') + 0.015 * getProperty('camZoomingMult'))
            curZoom = defaultZoom + 0.015 * getProperty('camZoomingMult')
            --doTweenZoom('zoomOut2', 'FlxG.camera.zoom', curZoom, 0.1, 'sineInOut')
            triggerEvent("Add Camera Zoom", 0.015 * getProperty('camZoomingMult'), '0')
            setProperty('camHUD.zoom', getProperty('camHUD.zoom') + 0.03 * getProperty('camZoomingMult'))
        end
    end
    if enableZoom then
        if curBeat % 64 == 0 then
            isZooming = true
            doTweenZoom('zoomOut', 'camGame', getProperty('camGame.zoom') + 0.1, 0.1, 'sineInOut')
            setProperty('defaultCamZoom', getProperty('defaultCamZoom')+0.1)
        end
        if curBeat % 64 == 4 then
            doTweenZoom('zoomOut', 'camGame', getProperty('camGame.zoom') + 0.1, 0.1, 'sineInOut')
            setProperty('defaultCamZoom', getProperty('defaultCamZoom')+0.1)
        end
        if curBeat % 64 == 8 then
            doTweenZoom('zoomOut', 'camGame', getProperty('camGame.zoom') + 0.1, 0.1, 'sineInOut')
            setProperty('defaultCamZoom', getProperty('defaultCamZoom')+0.1)
        end
        if curBeat % 64 == 12 then
            doTweenZoom('zoomOut', 'camGame', getProperty('camGame.zoom') + 0.1, 0.1, 'sineInOut')
            setProperty('defaultCamZoom', getProperty('defaultCamZoom')+0.1)
        end
        if curBeat % 64 == 15 then
            doTweenZoom('zoomOut', 'camGame', getProperty('camGame.zoom') - 0.3, 0.1, 'sineInOut')
            setProperty('defaultCamZoom', getProperty('defaultCamZoom')-0.3)
        end
        if curBeat % 64 == 16 then
            doTweenZoom('zoomOut', 'camGame', getProperty('camGame.zoom') + 0.1, 0.1, 'sineInOut')
            setProperty('defaultCamZoom', getProperty('defaultCamZoom')+0.1)
        end
        if curBeat % 64 == 20 then
            doTweenZoom('zoomOut', 'camGame', getProperty('camGame.zoom') + 0.1, 0.1, 'sineInOut')
            setProperty('defaultCamZoom', getProperty('defaultCamZoom')+0.1)
        end
        if curBeat % 64 == 24 then
            doTweenZoom('zoomOut', 'camGame', getProperty('camGame.zoom') + 0.1, 0.1, 'sineInOut')
            setProperty('defaultCamZoom', getProperty('defaultCamZoom')+0.1)
        end
        if curBeat % 64 == 28 then
            doTweenZoom('zoomOut', 'camGame', getProperty('camGame.zoom') + 0.1, 0.1, 'sineInOut')
            setProperty('defaultCamZoom', getProperty('defaultCamZoom')+0.1)
        end
        if curBeat % 64 == 31 then
            doTweenZoom('zoomOut', 'camGame', getProperty('camGame.zoom') + 0.2, 0.1, 'sineInOut')
            setProperty('defaultCamZoom', getProperty('defaultCamZoom')-0.2)
        end
        if curBeat % 64 == 32 then
            isZooming = false
            doTweenZoom('zoomOut', 'camGame', defaultZoom, 0.1, 'sineInOut')
            setProperty('defaultCamZoom', defaultZoom)
        end
    end
end

function onUpdatePost(w)
    if not isZooming then
        --doTweenZoom('zoomOut', 'camGame', defaultZoom, 0.1, 'sineInOut')
        --setProperty('defaultCamZoom', defaultZoom)
    end
    setShaderFloat("shaderThing", "iTime", os.clock())
end

function lerp(a,b,t)
    return a*(1-t)+b*t
end