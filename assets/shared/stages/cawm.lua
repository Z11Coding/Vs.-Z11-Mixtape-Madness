reveal = false
treehouse = false
start = true
ening = false
hideHud = false

function onCreate()
  setProperty('camHUD.alpha',0)
  makeLuaSprite('back','CAWM/back',0,0)
  scaleObject('back',1.5,1.5)
  addLuaSprite('back',false)
  setProperty('back.alpha',0)

  makeAnimatedLuaSprite('ning','CAWM/Lighting',-550,-400)
  addAnimationByPrefix('ning','Lightnin','LIGHTNING',24,true)
  addLuaSprite('ning',false)
  setProperty('ning.alpha',1)
  scaleObject('ning',2.2,2.2)

  makeLuaSprite('backtree','CAWM/tree',0,0)
  scaleObject('backtree',1.5,1.5)
  addLuaSprite('backtree',false)
  setProperty('backtree.alpha',0)

  makeAnimatedLuaSprite('rain','CAWM/Rain',1050,700)
  addAnimationByPrefix('rain','rainshit','Rain',24,true)
  addLuaSprite('rain',true)
  playAnim('rain','rainshit',true)
  setProperty('rain.alpha',0)

  makeLuaSprite('glitch','CAWM/reveal/BackGlitch',970,1590)
  scaleObject('glitch',0.7,0.7)
  addLuaSprite('glitch',false)
  setProperty('glitch.alpha',0)

  makeLuaSprite('glitcha','CAWM/reveal/AboveGlitch',970,1590)
  scaleObject('glitcha',0.7,0.7)
  addLuaSprite('glitcha',false)
  setProperty('glitcha.alpha',0)

  makeLuaSprite('hill','CAWM/reveal/HillStuff',970,1590)
  scaleObject('hill',0.7,0.7)
  addLuaSprite('hill',false)
  setProperty('hill.alpha',0)

  makeLuaSprite('part','CAWM/reveal/Particles',970,1590)
  scaleObject('part',0.5,0.5)
  addLuaSprite('part',true)
  setProperty('part.alpha',1)

  makeLuaSprite('dang','CAWM/reveal/Dangling',970,1590)
  scaleObject('dang',0.7,0.7)
  addLuaSprite('dang',false)
  setProperty('dang.alpha',0)

  makeLuaSprite('corr','CAWM/reveal/Corruption',970,1590)
  scaleObject('corr',0.7,0.7)
  addLuaSprite('corr',false)
  setProperty('corr.alpha',0)

  makeLuaSprite('img','CAWM/intro/IMG_8337',1050,1450)
  scaleObject('img',0.7,0.7)
  addLuaSprite('img',false)
  setProperty('img.alpha',1)

  makeLuaSprite('img2','CAWM/intro/Ilustracion_sin_titulo-1',1150,1450)
  scaleObject('img2',0.65,0.65)
  addLuaSprite('img2',true)
  setBlendMode('img2','multiply')
  setProperty('img2.alpha',1)

  makeLuaSprite('ill2','CAWM/intro/Ilustracion_sin_titulo-2',1090,1500)
  scaleObject('ill2',0.6,0.6)
  addLuaSprite('ill2',false)
  setProperty('ill2.alpha',1)

  makeLuaSprite('ill','CAWM/intro/Ilustracion_sin_titulo-3',1150,1450)
  addLuaSprite('ill',true)
  setProperty('ill.alpha',1)

  makeLuaSprite('camera','CAWM/reveal/CameraShtuff',-200,-50)
  addLuaSprite('camera',false)
  setProperty('camera.alpha',0)
  setObjectCamera('camera','other')
  setBlendMode('camera','normal')
  scaleObject('camera',0.6,0.6)

  makeLuaSprite('bg2', '', 0, 0)
  setScrollFactor('bg2', 0, 0)
  makeGraphic('bg2', 3840, 2160, '000000')
  addLuaSprite('bg2', false)
  setProperty('bg2.alpha', 1)
  setObjectCamera('bg2','other')
  screenCenter('bg2', 'xy')
end

function onStepHit()
  if curStep == 128 then
    doTweenAlpha('woah3', 'bg2', 0, 10, 'sineIn')
  elseif curStep == 248 then
    doTweenAlpha('woah33', 'camHUD', 1, 2, 'linear')
    setProperty('glitchshit.alpha', 0)
    setProperty('uiGroup.visible', false)
    setValue('alpha', 1, 1)
    for i = 0, getProperty('notes.length') - 1 do
      if not getPropertyFromGroup('notes', i, 'mustPress') then
        setPropertyFromGroup('notes', i, 'visible', false)
      end
    end
    for i = 0, getProperty('unspawnNotes.length') - 1 do
      if not getPropertyFromGroup('unspawnNotes', i, 'mustPress') then
        setPropertyFromGroup('unspawnNotes', i, 'visible', false)
      end
    end
  elseif curStep == 256 then
    start = false
  elseif curStep == 504 then
    setProperty("defaultCamZoom",1.3)
    doTweenAlpha('woah11', 'camHUD', 0, 0.5, 'linear')
  elseif curStep == 512 then
    setValue('alpha', 0, 1)
    for i = 0, getProperty('notes.length') - 1 do
      if not getPropertyFromGroup('notes', i, 'mustPress') then
        setPropertyFromGroup('notes', i, 'visible', true)
      end
    end
    for i = 0, getProperty('unspawnNotes.length') - 1 do
      if not getPropertyFromGroup('unspawnNotes', i, 'mustPress') then
        setPropertyFromGroup('unspawnNotes', i, 'visible', true)
      end
    end
    doTweenAlpha('woah10', 'camHUD', 1, 1, 'linear')
    setShaderFloat("dad", "_BlockSize", 50.0);
    setShaderFloat("dad", "_MaxRGBSplitX", 1.0);
		setShaderFloat("dad", "_MaxRGBSplitY", 1.0);
    setShaderFloat("unstable", "_BlockSize", 8.0);
    setShaderFloat("unstable", "_MaxRGBSplitX", 4.0);
		setShaderFloat("unstable", "_MaxRGBSplitY", 4.0);
    setProperty("defaultCamZoom",0.9)
  elseif curStep == 737 then
    --doTweenX('dadmover7','dad',700,0.001,'linear')
    --doTweenY('dadmover6','dad',650,0.001,'linear')
    setObjectCamera('bg2','camGame')
    setProperty("defaultCamZoom",1)
    doTweenAlpha('woah', 'bg2', 1, 1.75, 'linear')
    setProperty('part.alpha',0)
  elseif curStep == 768 then
    doTweenAlpha('woah2', 'bg2', 0, 0.25, 'linear')
    reveal = true
    start = false
    treehouse = false
  elseif curStep == 1008 then
    setProperty('bg2.alpha', 1)
    setObjectCamera('bg2','camOther')
  elseif curStep == 1024 then
    setProperty('glitchshit.alpha', 1)
    setProperty('uiGroup.visible', true)
    setProperty('bg2.alpha', 0)
    setShaderFloat("dad", "_BlockSize", 0.0);
    setShaderFloat("dad", "_MaxRGBSplitX", 0.0);
		setShaderFloat("dad", "_MaxRGBSplitY", 0.0);

    setShaderFloat("unstable", "_BlockSize", 0.0);
    setShaderFloat("unstable", "_MaxRGBSplitX", 0.0);
		setShaderFloat("unstable", "_MaxRGBSplitY", 0.0);
    setProperty('cameraSpeed',50)
    treehouse = true
    reveal = false
    start = false
  elseif curStep == 1025 then
    setProperty('cameraSpeed',1)
  elseif curStep == 1520 then
    setProperty('bg2.alpha', 1)
    setObjectCamera('bg2','camHUD')
    setProperty('glitchshit.alpha', 0)
    setProperty('uiGroup.visible', false)
    setValue('alpha', 1, 1)
    for i = 0, getProperty('notes.length') - 1 do
      if not getPropertyFromGroup('notes', i, 'mustPress') then
        setPropertyFromGroup('notes', i, 'visible', false)
      end
    end
    for i = 0, getProperty('unspawnNotes.length') - 1 do
      if not getPropertyFromGroup('unspawnNotes', i, 'mustPress') then
        setPropertyFromGroup('unspawnNotes', i, 'visible', false)
      end
    end
  elseif curStep == 1536 then
    setProperty('bg2.alpha', 0)
    setObjectCamera('bg2','camHUD')
    setProperty('glitchshit.alpha',1)
    setProperty('uiGroup.visible', true)
    setValue('alpha', 0, 1)
    for i = 0, getProperty('notes.length') - 1 do
      if not getPropertyFromGroup('notes', i, 'mustPress') then
        setPropertyFromGroup('notes', i, 'visible', true)
      end
    end
    for i = 0, getProperty('unspawnNotes.length') - 1 do
      if not getPropertyFromGroup('unspawnNotes', i, 'mustPress') then
        setPropertyFromGroup('unspawnNotes', i, 'visible', true)
      end
    end
  elseif curStep == 1776 then
    setProperty('bg2.alpha', 1)
    setObjectCamera('bg2','camHUD')
    setProperty('glitchshit.alpha',0)
    setProperty('uiGroup.visible', false)
    for i = 0, getProperty('opponentStrums.length') - 1 do
      setProperty('opponentStrums.members['..i..'].visible', false)
    end
    for i = 0, getProperty('notes.length') - 1 do
      if not getPropertyFromGroup('notes', i, 'mustPress') then
        setPropertyFromGroup('notes', i, 'visible', false)
      end
    end
    for i = 0, getProperty('unspawnNotes.length') - 1 do
      if not getPropertyFromGroup('unspawnNotes', i, 'mustPress') then
        setPropertyFromGroup('unspawnNotes', i, 'visible', false)
      end
    end
  elseif curStep == 1792 then
    setProperty('glitchshit.alpha', 0)
    setProperty('uiGroup.visible', false)
    setValue('alpha', 1, 1)
    for i = 0, getProperty('notes.length') - 1 do
      if not getPropertyFromGroup('notes', i, 'mustPress') then
        setPropertyFromGroup('notes', i, 'visible', false)
      end
    end
    for i = 0, getProperty('unspawnNotes.length') - 1 do
      if not getPropertyFromGroup('unspawnNotes', i, 'mustPress') then
        setPropertyFromGroup('unspawnNotes', i, 'visible', false)
      end
    end
    setProperty('cameraSpeed',50)
    setProperty('bg2.alpha', 0)
    setObjectCamera('bg2','camHUD')
    doTweenX('dadmover4','dad',1125,0.0001,'linear')
    doTweenY('dadmover5','dad',1725,0.0001,'linear')
    start = true
    reveal = false
    treehouse = false
  elseif curStep == 1793 then
    setProperty('cameraSpeed',1)
  elseif curStep == 1905 then
    setValue('alpha', 1, 1)
    for i = 0, getProperty('notes.length') - 1 do
      if not getPropertyFromGroup('notes', i, 'mustPress') then
        setPropertyFromGroup('notes', i, 'visible', false)
      end
    end
    for i = 0, getProperty('unspawnNotes.length') - 1 do
      if not getPropertyFromGroup('unspawnNotes', i, 'mustPress') then
        setPropertyFromGroup('unspawnNotes', i, 'visible', false)
      end
    end
    start = false
    reveal = true
    treehouse = false
  elseif curStep == 2032 then
    reveal = false
    doTweenAlpha('woah4', 'bg2', 1, 1.1, 'linear')
  elseif curStep == 2048 then
    setProperty('glitchshit.alpha', 1)
    setProperty('uiGroup.visible', true)
    setValue('alpha', 0, 1)
    for i = 0, getProperty('notes.length') - 1 do
      if not getPropertyFromGroup('notes', i, 'mustPress') then
        setPropertyFromGroup('notes', i, 'visible', true)
      end
    end
    for i = 0, getProperty('unspawnNotes.length') - 1 do
      if not getPropertyFromGroup('unspawnNotes', i, 'mustPress') then
        setPropertyFromGroup('unspawnNotes', i, 'visible', true)
      end
    end
    setProperty('bg2.alpha', 0)
    setProperty('cameraSpeed',50)
    start = false
    reveal = false
    treehouse = true
  elseif curStep == 2049 then
    setProperty('cameraSpeed',1)
  elseif curStep == 2544 then
    setObjectCamera('bg2','camHUD')
    setProperty('bg2.alpha', 1)
    setProperty('glitchshit.alpha', 0)
    setProperty('uiGroup.visible', false)
    setValue('alpha', 1, 1)
    for i = 0, getProperty('notes.length') - 1 do
      if not getPropertyFromGroup('notes', i, 'mustPress') then
        setPropertyFromGroup('notes', i, 'visible', false)
      end
    end
    for i = 0, getProperty('unspawnNotes.length') - 1 do
      if not getPropertyFromGroup('unspawnNotes', i, 'mustPress') then
        setPropertyFromGroup('unspawnNotes', i, 'visible', false)
      end
    end
  elseif curStep == 2560 then
    setProperty('cameraSpeed',50)
    start = true
    reveal = false
    treehouse = false
  elseif curStep == 2561 then
    setValue('alpha', 0, 1)
    for i = 0, getProperty('notes.length') - 1 do
      if not getPropertyFromGroup('notes', i, 'mustPress') then
        setPropertyFromGroup('notes', i, 'visible', true)
      end
    end
    for i = 0, getProperty('unspawnNotes.length') - 1 do
      if not getPropertyFromGroup('unspawnNotes', i, 'mustPress') then
        setPropertyFromGroup('unspawnNotes', i, 'visible', true)
      end
    end
    setProperty('bg2.alpha', 0)
    doTweenX('dadmover4','dad',1125,0.0001,'linear')
    doTweenY('dadmover5','dad',1725,0.0001,'linear')
    start = false
    reveal = true
    treehouse = false
  elseif curStep == 2816 then
    setProperty('glitchshit.alpha', 1)
    setProperty('uiGroup.visible', true)
    start = false
    reveal = false
    treehouse = true
  elseif curStep == 3068 then
    setProperty('bg2.alpha', 1)
    setObjectCamera('bg2','other')
    doTweenY('dadmover8','dad',2850,0.0001,'linear')
    doTweenY('bfmover19','boyfriend',2450,0.0001,'linear')
  elseif curStep == 3072 then
    setProperty('cameraSpeed',1)
    start = false
    reveal = false
    treehouse = false
    ending = true
  elseif curStep == 3328 then
    doTweenY('dadmover8','dad',2850,0.0001,'linear')
    doTweenY('bfmover19','boyfriend',2450,0.0001,'linear')
  elseif curStep == 3840 then
    ending = false
    setObjectCamera('bg2','other')
  end

  if curStep >= 768 and curStep <= 1007 or curStep >= 1920 and curStep <= 2031 then
    if curStep % 64 == 0 then
      triggerEvent('Add Camera Zoom', '0.05', '0.03')
    end
    if curStep % 64 == 6 then
      triggerEvent('Add Camera Zoom', '0.05', '0.03')
    end
    if curStep % 64 == 12 then
      triggerEvent('Add Camera Zoom', '0.05', '0.03')
    end
    if curStep % 64 == 16 then
      triggerEvent('Add Camera Zoom', '0.05', '0.03')
    end
    if curStep % 64 == 22 then
      triggerEvent('Add Camera Zoom', '0.05', '0.03')
    end
    if curStep % 64 == 28 then
      triggerEvent('Add Camera Zoom', '0.05', '0.03')
    end
    if curStep % 64 == 30 then
      triggerEvent('Add Camera Zoom', '0.05', '0.03')
    end
    if curStep % 64 == 32 then
      triggerEvent('Add Camera Zoom', '0.05', '0.03')
    end
    if curStep % 64 == 38 then
      triggerEvent('Add Camera Zoom', '0.05', '0.03')
    end
    if curStep % 64 == 44 then
      triggerEvent('Add Camera Zoom', '0.05', '0.03')
    end
    if curStep % 64 == 48 then
      triggerEvent('Add Camera Zoom', '0.05', '0.03')
    end
    if curStep % 64 == 54 then
      triggerEvent('Add Camera Zoom', '0.05', '0.03')
    end
    if curStep % 64 == 60 then
      triggerEvent('Add Camera Zoom', '0.05', '0.03')
    end
  end

  if curStep >= 2560 and curStep <= 2811 or curStep >= 2816 and curStep <= 3056 then
    if curStep % 64 == 0 then
      triggerEvent('Add Camera Zoom', '0.05', '0.03')
    end
    if curStep % 64 == 6 then
      triggerEvent('Add Camera Zoom', '0.05', '0.03')
    end
    if curStep % 64 == 12 then
      triggerEvent('Add Camera Zoom', '0.05', '0.03')
    end
    if curStep % 64 == 16 then
      triggerEvent('Add Camera Zoom', '0.05', '0.03')
    end
    if curStep % 64 == 22 then
      triggerEvent('Add Camera Zoom', '0.05', '0.03')
    end
    if curStep % 64 == 28 then
      triggerEvent('Add Camera Zoom', '0.05', '0.03')
    end
    if curStep % 64 == 30 then
      triggerEvent('Add Camera Zoom', '0.05', '0.03')
    end
    if curStep % 64 == 32 then
      triggerEvent('Add Camera Zoom', '0.05', '0.03')
    end
    if curStep % 64 == 38 then
      triggerEvent('Add Camera Zoom', '0.05', '0.03')
    end
    if curStep % 64 == 44 then
      triggerEvent('Add Camera Zoom', '0.05', '0.03')
    end
    if curStep % 64 == 48 then
      triggerEvent('Add Camera Zoom', '0.05', '0.03')
    end
    if curStep % 64 == 54 then
      triggerEvent('Add Camera Zoom', '0.05', '0.03')
    end
    if curStep % 64 == 60 then
      triggerEvent('Add Camera Zoom', '0.05', '0.03')
    end
  end
end

function onUpdate()
  setProperty('healthBar.alpha', 0);
	setProperty('iconP2.alpha', 0);
  setProperty('iconP1.alpha', 0);
  if keyboardJustPressed('ONE') then
    hideHud = not hideHud
    setProperty('camHUD.alpha', 1)
    setProperty('uiGroup.visible', not hideHud)
    setProperty('noteGroup.visible', not hideHud)
  end
  if start == true then
    setProperty("defaultCamZoom",0.9)
    setProperty('ill.alpha',1)
    setProperty('ill2.alpha',1)
    setProperty('img.alpha',1)
    setProperty('img2.alpha',1)
    --doTweenX('dadmover4','dad',1125,0.0001,'linear')
    --doTweenY('dadmover5','dad',1725,0.0001,'linear')

    setProperty('rain.alpha',0)
    setProperty('glitch.alpha',0)
    setProperty('glitcha.alpha',0)
    setProperty('hill.alpha',0)
    setProperty('part.alpha',0)
    setProperty('dang.alpha',0)
    setProperty('corr.alpha',0)
    setProperty('camera.alpha',0)
    setProperty('boyfriend.alpha',0)
    setProperty('back.alpha',0)
    setProperty('backtree.alpha',0)
  elseif reveal == true then
    doTweenY('dadmover2','dad',1475,0.0001,'linear')
    setProperty('glitch.alpha',1)
    setProperty('glitcha.alpha',1)
    setProperty('hill.alpha',1)
    setProperty('part.alpha',1)
    setProperty('dang.alpha',1)
    setProperty('corr.alpha',1)
    setProperty('camera.alpha',1)
    setProperty("defaultCamZoom",0.8)
    --setProperty('camGame.scroll.y', 1380)

    setProperty('rain.alpha',0)
    setProperty('ill.alpha',0)
    setProperty('ill2.alpha',0)
    setProperty('img.alpha',0)
    setProperty('img2.alpha',0)
  elseif treehouse == true then
    doTweenX('dadmover','dad',1850,0.0001,'linear')
    doTweenY('dadmover3','dad',2050,0.0001,'linear')
    setProperty('boyfriend.alpha',1)
    setProperty('back.alpha',1)
    setProperty('backtree.alpha',1)
    setProperty('rain.alpha',1)
    setProperty('boyfriend.color',getColorFromHex('5D4371'));

    setProperty('glitch.alpha',0)
    setProperty('glitcha.alpha',0)
    setProperty('hill.alpha',0)
    setProperty('part.alpha',0)
    setProperty('dang.alpha',0)
    setProperty('corr.alpha',0)
    setProperty('ill.alpha',0)
    setProperty('ill2.alpha',0)
    setProperty('img.alpha',0)
    setProperty('img2.alpha',0)
  elseif ending == true then
    doTweenX('dadmover4','dad',2450,0.0001,'linear')
    doTweenY('dadmover7','dad',2350,0.0001,'sineOut')
    doTweenAngle('bfspin','boyfriend',180,0.0001,'linear')
    doTweenX('bfmover4','boyfriend',2950,0.0001,'linear')
    doTweenY('bfmover222','boyfriend',2350,0001,'linear')
    setObjectCamera('bg2','camGame')
    setProperty("defaultCamZoom",1.1)
    setProperty('boyfriend.flipX', true)
    setProperty('boyfriend.color',getColorFromHex('FFFFFF'));
    for i=0,3 do
      noteTweenAlpha(i+16, i, math.floor(curStep/9999), 0.3)
      noteTweenAlpha(i+16, i, math.floor(curStep/9999), 4-7)

      setProperty('rain.alpha',0)
      setProperty('camera.alpha',0)
      setProperty('glitch.alpha',0)
      setProperty('glitcha.alpha',0)
      setProperty('hill.alpha',0)
      setProperty('part.alpha',0)
      setProperty('dang.alpha',0)
      setProperty('corr.alpha',0)
      setProperty('ill.alpha',0)
      setProperty('ill2.alpha',0)
      setProperty('img.alpha',0)
      setProperty('img2.alpha',0)
      setProperty('ning.alpha',0)
    end
end
end

function onSectionHit()
  if treehouse == true and mustHitSection == true then
    setProperty("defaultCamZoom",0.8)
  elseif treehouse == true and not mustHitSection == true then
    setProperty("defaultCamZoom",0.6)
  end
end

function onUpdatePost()
    setShaderFloat("dad", "iTime", os.clock())
end

function onBeatHit()
  if curBeat % 8 == 0 and treehouse == true then
    playAnim('ning', 'Lightnin', false)
  end
  if curBeat >= 256 and curBeat <= 287 or curBeat >= 291 and curBeat <= 380 or curBeat >= 520 and curBeat <= 543 or curBeat >= 548 and curBeat <= 636 then
    triggerEvent('Add Camera Zoom', '0.05', '0.03')
  end
  if curBeat >= 383 and curBeat <= 444 or curBeat >= 768 and curBeat <= 896 then
    if curBeat % 2 == 0 then
      triggerEvent('Add Camera Zoom', '0.05', '0.03')
    end
  end
end

function onCreatePost()
  setTextFont('scoreTxt', 'finn.ttf')
  setTextFont('timeTxt', 'finn.ttf')
  setTextFont('botplayTxt', 'finn.ttf')
end