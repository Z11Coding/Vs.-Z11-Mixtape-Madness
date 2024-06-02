------------Settings

iconP1 = 'Z_icon'               --- Put here the name of the file of the icons (for Player 1)
iconP2 = 'z12'                  --- Put here the name of the file of the icons (for Player 2)
winning = false                 --- if true, then the Player 1 and Player 2 will be have on their winning icons (450x150 file)

colorP1 = '247F96'              --- Put here the HEX code of the color that you want (for Player 1)
colorP2 = 'A98475'              --- Put here the HEX code of the color that you want (for Player 2)

following = false                --- if true, the normal notes will move the second healthbar, but if it is false, only will move with the doublebar notes
canDie = true                  --- if true, you will die if the second healthbar is too low!!!

------------DONT TOUCH NOTHING BELOW THIS TEXT!!!!

local health = 296.5
local pos = 640.5
local dead = false

------------

function onCreatePost()
    p1 = getVar("Player2")
    p2 = getVar("Opponent2")
    makeLuaSprite('coP2', nil, 0, 0)
    makeGraphic('coP2', 593, 12, rgbToHex(getProperty(p2..".healthColorArray")))
    addLuaSprite('coP2', true)
    setObjectCamera('coP2', 'hud')

    makeLuaSprite('bar', 'healthBar', 340, 125)
    setObjectCamera('bar', 'hud')
    scaleLuaSprite('bar', 0.999, 0.98)
    addLuaSprite('bar', true)

    if winning == false then
    makeAnimatedLuaSprite('icP1', nil, pos, 50)
    loadGraphic('icP1', 'icons/icon-'.. iconP1, 150)
    addAnimation('icP1', 'icons/icon-'.. iconP1, {0, 1}, 0, true)
    addAnimation('icP1', 'icons/icon-'.. iconP1, {1, 0}, 0, true)
    setProperty('icP1.animation.curAnim.curFrame', '1')
    addLuaSprite('icP1', true)
    setProperty('icP1.flipX', true)
    setObjectCamera('icP1', 'hud')

    makeAnimatedLuaSprite('icP2', nil, pos, 50)
    loadGraphic('icP2', 'icons/icon-'.. iconP2, 150)
    addAnimation('icP2', 'icons/icon-'.. iconP2, {0, 1}, 0, true)
    addAnimation('icP2', 'icons/icon-'.. iconP2, {1, 0}, 0, true)
    setProperty('icP2.animation.curAnim.curFrame', '1')
    addLuaSprite('icP2', true)
    setObjectCamera('icP2', 'hud')
    else
    makeAnimatedLuaSprite('icP1', nil, pos, 50)
    loadGraphic('icP1', 'icons/icon-'.. iconP1, 150)
    addAnimation('icP1', 'icons/icon-'.. iconP1, {0, 1, 2}, 0, true)
    addAnimation('icP1', 'icons/icon-'.. iconP1, {1, 0, 2}, 0, true)
    addAnimation('icP1', 'icons/icon-'.. iconP1, {1, 2, 0}, 0, true)
    setProperty('icP1.animation.curAnim.curFrame', '2')
    addLuaSprite('icP1', true)
    setProperty('icP1.flipX', true)
    setObjectCamera('icP1', 'hud')

    makeAnimatedLuaSprite('icP2', nil, 0, 50)
    loadGraphic('icP2', 'icons/icon-'.. iconP2, 150)
    addAnimation('icP2', 'icons/icon-'.. iconP2, {0, 1, 2}, 0, true)
    addAnimation('icP2', 'icons/icon-'.. iconP2, {1, 0, 2}, 0, true)
    addAnimation('icP2', 'icons/icon-'.. iconP2, {1, 2, 0}, 0, true)
    setProperty('icP2.animation.curAnim.curFrame', '2')
    addLuaSprite('icP2', true)
    setObjectCamera('icP2', 'hud')
    end

    if downscroll then
      setProperty('scoreTxt.y', 165)
      setObjectOrder('iconP1', getObjectOrder('bar') + 1)
      setObjectOrder('iconP2', getObjectOrder('bar') + 1)
    end
    if not downscroll then
      setProperty('bar.y', 595)
      setProperty('icP1.y', 520)
      setProperty('icP2.y', 520)
      setProperty('scoreTxt.y', 675)
      setObjectOrder('iconP1', getObjectOrder('bar') + 1)
      setObjectOrder('iconP2', getObjectOrder('bar') + 2)
    end
    setVar("health2", health)
    setVar("pos", pos)
end

function rgbToHex(array)
	return string.format('%.2x%.2x%.2x', array[1], array[2], array[3])
end

function goodNoteHit(membersIndex, noteData, noteType, isSustainNote)
    if following == true and not isSustainNote and health <= 590 then
      health = health + 10.5
      pos = pos - 10.5
    end
    if noteType == 'SecondJson' and not isSustainNote and health <= 590 then
        health = health + 10.5
        pos = pos - 10.5
    end
end

function localGoodNoteHit(membersIndex, noteData, noteType, isSustainNote)
  if not isSustainNote and health <= 590 then
    health = health + 10.5
    pos = pos - 10.5
  end
end

function noteMiss(membersIndex, noteData, noteType, isSustainNote)
    if following == true and health >= 20 then
      health = health - 10.5
      pos = pos + 10.5
    end
    if noteType == 'SecondJson' and health >= 20 then
        health = health - 10.5
        pos = pos + 10.5
    end
end

function localOpponentHit(membersIndex, noteData, noteType, isSustainNote)
  if health >= 20 then
    health = health - 10.5
    pos = pos + 10.5
  end
end

function onUpdate()
  health = getVar("health2")
  pos = getVar("pos")
  colorP1 = rgbToHex(getProperty(p1..".healthColorArray"))
  colorP2 = rgbToHex(getProperty(p2..".healthColorArray"))
  if health >= 15 and canDie == false and dead == false then
    removeLuaSprite('coP1', true)
    makeLuaSprite('coP1', nil, pos, 0)
    makeGraphic('coP1', health, 12, rgbToHex(getProperty(p1..".healthColorArray")))
    setObjectOrder('coP1', getObjectOrder('bar'))
    setProperty('coP1.y', getProperty('bar.y') + 3)
    setProperty('coP1.alpha', getProperty('bar.alpha'))
    setProperty('coP1.angle', getProperty('bar.angle'))
    addLuaSprite('coP1', true)
    setObjectCamera('coP1', 'hud')
  end

  removeLuaSprite('coP1', true)
  makeLuaSprite('coP1', nil, pos, 0)
  makeGraphic('coP1', health, 12, rgbToHex(getProperty(p1..".healthColorArray")))
  setObjectOrder('coP1', getObjectOrder('bar'))
  setProperty('coP1.y', getProperty('bar.y') + 3)
  setProperty('coP1.alpha', getProperty('bar.alpha'))
  setProperty('coP1.angle', getProperty('bar.angle'))
  addLuaSprite('coP1', true)
  setObjectCamera('coP1', 'hud')

  if health <= 150 then
    setProperty('icP2.animation.curAnim.curFrame', '1')
    setProperty('icP1.animation.curAnim.curFrame', '0')
  end

  if health >= 470 then
    setProperty('icP2.animation.curAnim.curFrame', '0')
    setProperty('icP1.animation.curAnim.curFrame', '1')
  end

  if health < 470 and health > 150 then
    setProperty('icP1.animation.curAnim.curFrame', '2')
    setProperty('icP2.animation.curAnim.curFrame', '2')
  end

    setProperty('coP2.x', getProperty('bar.x') + 3)
    setProperty('coP2.y', getProperty('bar.y') + 3)
    setProperty('coP2.alpha', getProperty('bar.alpha'))
    setProperty('coP2.angle', getProperty('bar.angle'))

    setProperty('icP1.x', pos - 23)
    setProperty('icP1.angle', getProperty('iconP1.angle'))
    setProperty('icP1.scale.x', getProperty('iconP1.scale.x'))
    setProperty('icP1.scale.y', getProperty('iconP1.scale.y'))

    setProperty('icP2.x', getProperty('icP1.x') - 103)
    setProperty('icP2.angle', getProperty('iconP2.angle'))
    setProperty('icP2.scale.x', getProperty('iconP2.scale.x'))
    setProperty('icP2.scale.y', getProperty('iconP2.scale.y'))

    if health <= 15 and canDie == true then
      setProperty('health', getProperty('health') - 10)
    end
end

function onGameOver()
  dead = true
end