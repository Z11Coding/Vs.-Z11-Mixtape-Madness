local Chromacrap = 0;

function boundTo(value, min, max)
    return math.max(min, math.min(max, value))
end

function math.lerp(from,to,i) return from+(to-from)*i end

function setChrome(chromeOffset)
    setShaderFloat("temporaryShader", "rOffset", chromeOffset);
    setShaderFloat("temporaryShader", "gOffset", 0.0);
    setShaderFloat("temporaryShader", "bOffset", chromeOffset * -1);
end

function opponentNoteHit(id, noteData, noteType, isSustainNote)
	if noteType == 'Glitch note' then
		Chromacrap = Chromacrap + 0.004; -- edit this
		triggerEvent('Screen Shake', '0.1,0.002', '0,0')
		setShaderFloat("dad", "_BlockSize", 100.0);
		setShaderFloat("dad", "_MaxRGBSplitX", 4.0);
		setShaderFloat("dad", "_MaxRGBSplitY", 4.0);

		setShaderFloat("unstable", "_BlockSize", 1000.0);
		setShaderFloat("unstable", "_MaxRGBSplitX", 50.0);
		setShaderFloat("unstable", "_MaxRGBSplitY", 50.0);
		runTimer('unVert', 0.5)
	end
end

function onTimerCompleted(tag, loops, loopsLeft)
	if tag == 'unVert' then
		if dadName == 'finncawm_reveal' then
			setShaderFloat("dad", "_BlockSize", 100.0);
			setShaderFloat("dad", "_MaxRGBSplitX", 4.0);
			setShaderFloat("dad", "_MaxRGBSplitY", 4.0);

			setShaderFloat("unstable", "_BlockSize", 100.0);
			setShaderFloat("unstable", "_MaxRGBSplitX", 4.0);
			setShaderFloat("unstable", "_MaxRGBSplitY", 4.0);
		else
			setShaderFloat("dad", "_BlockSize", 0.0);
			setShaderFloat("dad", "_MaxRGBSplitX", 0.0);
			setShaderFloat("dad", "_MaxRGBSplitY", 0.0);

			setShaderFloat("unstable", "_BlockSize", 0.0);
			setShaderFloat("unstable", "_MaxRGBSplitX", 0.0);
			setShaderFloat("unstable", "_MaxRGBSplitY", 0.0);
		end
	end
end

function onCreatePost()
    --luaDebugMode = true;
	if (shadersEnabled) then
		initLuaShader("vcr");
		initLuaShader("glitchDist");
		initLuaShader("glitchy2");
		
		makeLuaSprite("temporaryShader");
		makeGraphic("temporaryShader", screenWidth, screenHeight);

		makeLuaSprite("temporaryShader5");
		makeGraphic("temporaryShader5", screenWidth, screenHeight);

		makeLuaSprite("unstable");
		makeGraphic("unstable", 1, 1);
		
		setSpriteShader("temporaryShader", "vcr");
		setSpriteShader("temporaryShader5", "glitchDist");
		setSpriteShader("unstable", "glitchy2");
		setSpriteShader("dad", "glitchy2");
		
		setShaderFloat("dad", "_BlockSize", 0.0);
		setShaderFloat("dad", "_MaxRGBSplitX", 0.0);
		setShaderFloat("dad", "_MaxRGBSplitY", 0.0);
		
		setShaderFloat("unstable", "_BlockSize", 0.0);
		setShaderFloat("unstable", "_MaxRGBSplitX", 0.0);
		setShaderFloat("unstable", "_MaxRGBSplitY", 0.0);

		addHaxeLibrary("ShaderFilter", "openfl.filters");
		runHaxeCode([[
			trace(ShaderFilter);
			game.camGame.setFilters([new ShaderFilter(game.getLuaObject("temporaryShader").shader), new ShaderFilter(game.getLuaObject("unstable").shader)]);
			game.camHUD.setFilters([new ShaderFilter(game.getLuaObject("temporaryShader").shader), new ShaderFilter(game.getLuaObject("unstable").shader)]);
		]]);
	end
end

function onEvent(eventName, value1, value2)
	if eventName == 'Change Character' then
		setSpriteShader("dad", "glitchy2");
		if value2 == 'finncawm_reveal' then
			setShaderFloat("dad", "_BlockSize", 100.0);
			setShaderFloat("dad", "_MaxRGBSplitX", 4.0);
			setShaderFloat("dad", "_MaxRGBSplitY", 4.0);

			setShaderFloat("unstable", "_BlockSize", 10.0);
			setShaderFloat("unstable", "_MaxRGBSplitX", 4.0);
			setShaderFloat("unstable", "_MaxRGBSplitY", 4.0);
		else
			setShaderFloat("dad", "_BlockSize", 0.0);
			setShaderFloat("dad", "_MaxRGBSplitX", 0.0);
			setShaderFloat("dad", "_MaxRGBSplitY", 0.0);

			setShaderFloat("unstable", "_BlockSize", 0.0);
			setShaderFloat("unstable", "_MaxRGBSplitX", 0.0);
			setShaderFloat("unstable", "_MaxRGBSplitY", 0.0);
		end
	end
end
function onUpdate(elapsed)
	if (shadersEnabled) then
		Chromacrap = math.lerp(Chromacrap, 0, boundTo(elapsed *10,0, 30));
		setChrome(Chromacrap);
		setShaderFloat("dad", "iTime", os.clock())
		setShaderFloat("unstable", "iTime", os.clock())
	end
end
function onBeatHit()
	if curBeat % 4 == 0 then
		Chromacrap = Chromacrap + 0.008;
		triggerEvent('Add Camera Zoom', '0.02', '0.02')
	end
end
function onDestroy()
	runHaxeCode([[
		trace('No More Shaders');
		game.camGame.setFilters([]);
		game.camHUD.setFilters([]);
	]]);
end