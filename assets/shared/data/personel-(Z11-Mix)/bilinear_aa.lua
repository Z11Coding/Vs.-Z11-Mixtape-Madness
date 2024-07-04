function onCreatePost()
	if shadersEnabled then
		initLuaShader("bilinear_aa")
		makeLuaSprite("bilinear_aa")
		makeGraphic("bilinear_aa", screenWidth, screenHeight)
		setSpriteShader("bilinear_aa", "bilinear_aa")

		addHaxeLibrary("ShaderFilter", "openfl.filters")
		runHaxeCode([[
			game.camGame.setFilters([new ShaderFilter(game.getLuaObject("bilinear_aa").shader)]);
			game.camHUD.setFilters([new ShaderFilter(game.getLuaObject("bilinear_aa").shader)]);
		]])
	end
end