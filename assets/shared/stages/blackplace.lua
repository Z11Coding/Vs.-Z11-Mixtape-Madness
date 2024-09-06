function onCreate()

	makeLuaSprite('ghosttile','stages/ghosts/ghostsStatic')
	setGraphicSize("ghosttile", 0.5, 0.5)
	screenCenter("ghosttile")
	addLuaSprite('ghosttile')

	makeLuaSprite('skulls','stages/ghosts/skulls')
	setGraphicSize("skulls", 0.5, 0.5)
	screenCenter("skulls")
	addLuaSprite('skulls')

	makeAnimatedLuaSprite("ghostbop", "stages/ghosts/ghostBop", -200, 400)
	addAnimationByPrefix("ghostbop", "ghostbop", "ghostbop", 24, false)
	addLuaSprite("ghostbop", true)
	scaleObject("ghostbop", 2, 2, true)

	makeAnimatedLuaSprite("ghostbopmid", "stages/ghosts/ghostBop", 350, 400)
	addAnimationByPrefix("ghostbopmid", "ghostbop", "ghostbop", 24, false)
	addLuaSprite("ghostbopmid", true)
	scaleObject("ghostbopmid", 2, 2, true)

	makeAnimatedLuaSprite("ghostbopmidright", "stages/ghosts/ghostBop", 900, 400)
	addAnimationByPrefix("ghostbopmidright", "ghostbop", "ghostbop", 24, false)
	addLuaSprite("ghostbopmidright", true)
	scaleObject("ghostbopmidright", 2, 2, true)
	setProperty('ghostbopright.flipX',true)

	setProperty('ghostbop.alpha', 0)
	setProperty('ghostbopmid.alpha', 0)
	setProperty('ghostbopmidright.alpha', 0)
	setProperty('ghosttile.alpha', 0)
	setProperty('skulls.alpha', 0)
end

function onCreatePost()
	setProperty('boyfriend.alpha', 0)
	setProperty('gf.alpha', 0)

	initLuaShader('scroll')
	initLuaShader('scroll2')
	setSpriteShader('ghosttile', 'scroll')
	setSpriteShader('skulls', 'scroll2')

	setShaderFloat("scroll",'xSpeed', 0.05)
	setShaderFloat("scroll",'ySpeed', 2)

	setShaderFloat("scroll2",'xSpeed', 0.05)
	setShaderFloat("scroll2",'ySpeed', 2)

    makeLuaSprite('die2')
    makeGraphic('die2',screenWidth,screenHeight,'000000')
    initLuaShader('lens')

    setSpriteShader('die2','lens')

    -- the haxe code is for changing the layr that the shader is applied to
    addHaxeLibrary('ShaderFilter', 'openfl.filters');
    runHaxeCode([[
        game.camGame.setFilters([new ShaderFilter(game.getLuaObject('die2').shader)]);
    ]])

	makeLuaSprite('shaderFloat',1,1)

	setShaderFloat("die2",'strength', getProperty('shaderFloat.x'))
end

function onUpdate()
	cameraSetTarget('dad')

	setShaderFloat("ghosttile", "iTime", os.clock())
	setShaderFloat("skulls", "iTime", os.clock())
	setShaderFloat('die2','iTime',os.clock())

	setShaderFloat("die2",'strength', getProperty('shaderFloat.x'))
end

function onBeatHit()
	cancelTween('shaderBeat')
	setProperty('shaderFloat.x',1.3)
	doTweenX('shaderBeat','shaderFloat',0.8,2,'quadInOut')


	if curBeat % 2 == 0 then
		playAnim('ghostbop','ghostbop',true)
		playAnim('ghostbopmid','ghostbop',true)
		playAnim('ghostbopright','ghostbop',true)
	end
end

function onStepHit()
	if curStep == 256 then
		cameraFlash('game', 'ffffff', 1)
		setProperty('ghosttile.alpha', 1)
	end

	if curStep == 504 then
		doTweenAlpha('ghosttilesFade','ghosttile',0,2,'quadInOut')
	end

	if curStep == 608 then
		pulseBG('ghost')
	end
	if curStep == 613 then
		pulseBG('ghost')
	end
	if curStep == 619 then
		pulseBG('ghost')
	end
	if curStep == 624 then
		pulseBG('ghost')
	end

	if curStep == 736 then
		pulseBG('skull')
	end
	if curStep == 739 then
		pulseBG('skull')
	end
	if curStep == 741 then
		pulseBG('skull')
	end
	if curStep == 744 then
		pulseBG('skull')
	end
	if curStep == 746 then
		pulseBG('skull')
	end
	if curStep == 748 then
		pulseBG('skull')
	end
	if curStep == 752 then
		pulseBG('skull')
	end

	if curStep == 864 then
		pulseBG('ghost')
	end
	if curStep == 869 then
		pulseBG('ghost')
	end
	if curStep == 875 then
		pulseBG('ghost')
	end
	if curStep == 880 then
		pulseBG('ghost')
	end

	if curStep == 992 then
		pulseBG('skull')
	end
	if curStep == 994 then
		pulseBG('skull')
	end
	if curStep == 997 then
		pulseBG('skull')
	end
	if curStep == 1000 then
		pulseBG('skull')
	end
	if curStep == 1002 then
		pulseBG('skull')
	end
	if curStep == 1005 then
		pulseBG('skull')
	end
	if curStep == 1008 then
		pulseBG('skull')
	end

	if curStep == 1024 then
		cameraFlash('game', 'ffffff', 1)
		setProperty('ghosttile.alpha', 1)
		if getPropertyFromClass('backend.CLientPrefs', 'data.modcharts') then
			setValue('drunk', 1)
			setValue('drunkZ', 2)
			setValue('tipsy', 1)
			setValue('cross', 1)
		end
	end
	if curStep == 1152 then
		cameraFlash('game', 'ffffff', 1)
		setProperty('ghosttile.alpha', 0)
		setProperty('skulls.alpha', 0.2)
	end

	if curStep == 1280 then
		cameraFlash('game', 'ffffff', 1)
		setProperty('ghosttile.alpha', 1)
		setProperty('skulls.alpha', 0.2)
		setProperty('ghostbop.alpha', 1)
		setProperty('ghostbopmid.alpha', 1)
		setProperty('ghostbopmidright.alpha', 1)
		if getPropertyFromClass('backend.CLientPrefs', 'data.modcharts') then
			setValue('cross', 0)
			setValue('split', 1)
		end
	end

	if curStep == 1536 then
		cameraFlash('game', 'ffffff', 1)
		doTweenAlpha('skullsFade','skulls',0,1,'quadInOut')
		setProperty('ghostbop.alpha', 0)
		setProperty('ghostbopmid.alpha', 0)
		setProperty('ghostbopmidright.alpha', 0)
		if getPropertyFromClass('backend.CLientPrefs', 'data.modcharts') then
			setValue('split', 0)
			setValue('drunk', 0)
			setValue('drunkZ', 0)
			setValue('tipsy', 0)
			setValue('beat', 1)
		end
	end

	if curStep == 1784 then
		doTweenAlpha('ghosttilesFade','ghosttile',0,2,'quadInOut')
		setValue('beat', 0)
	end
end

function pulseBG(whichBG)
	if whichBG == 'ghost' then
		setProperty('ghosttile.alpha', 1)
		doTweenAlpha('ghosttilesFade','ghosttile',0,crochet/1000/2.5,'quadInOut')
	end
	if whichBG == 'skull' then
		setProperty('skulls.alpha', 0.2)
		doTweenAlpha('skullsFade','skulls',0,crochet/1000/2.5,'quadInOut')
	end
end