-- This script made by BillyLOLwkwk
-- dont ever change this variable from path to cooldown
local path = ''
local scale = 0
local boyX = 0
local boyY = 0
local flipX = false --(Just in case if needed for the next update)
local anim = {}
local i = 0
local ofs = {}
local fps = {}
local cooldown = {false, false, false, false}
local noAntialiasing = false
local tweenDirection = 'quadOut'

-- you can change this one to custom it yourself
local shadow = true -- true if you want turn on the shadow and false if you want turn it off
local range = 75 -- for the shadow range
local duration = 0.35 -- for how long the shadow still
local color = true
local hexColor = '00f2ff' -- must be hex color


function startWith(text, prefix)
    return text:find(prefix,1,true) == 1
end

function updateShadow()
	path = getProperty('boyfriend.imageFile')
	scale = getProperty('boyfriend.jsonScale')
	boyX = getProperty('boyfriend.x')
	boyY = getProperty('boyfriend.y')
	flipX = getProperty('boyfriend.originalFlipX') 
	for i = 0, getProperty('boyfriend.animationsArray.length')-1 do
		if getPropertyFromGroup('boyfriend.animationsArray', i, 'anim') == 'singLEFT' then
			anim[1] = getPropertyFromGroup('boyfriend.animationsArray', i, 'name')
			ofs[1] = getPropertyFromGroup('boyfriend.animationsArray', i, 'offsets')[1]
			ofs[2] = getPropertyFromGroup('boyfriend.animationsArray', i, 'offsets')[2]
			fps[1] = getPropertyFromGroup('boyfriend.animationsArray', i, 'fps')
		end
		if getPropertyFromGroup('boyfriend.animationsArray', i, 'anim') == 'singDOWN' then
			anim[2] = getPropertyFromGroup('boyfriend.animationsArray', i, 'name')
			ofs[3] = getPropertyFromGroup('boyfriend.animationsArray', i, 'offsets')[1]
			ofs[4] = getPropertyFromGroup('boyfriend.animationsArray', i, 'offsets')[2]
			fps[2] = getPropertyFromGroup('boyfriend.animationsArray', i, 'fps')
		end
		if getPropertyFromGroup('boyfriend.animationsArray', i, 'anim') == 'singUP' then
			anim[3] = getPropertyFromGroup('boyfriend.animationsArray', i, 'name')
			ofs[5] = getPropertyFromGroup('boyfriend.animationsArray', i, 'offsets')[1]
			ofs[6] = getPropertyFromGroup('boyfriend.animationsArray', i, 'offsets')[2]
			fps[3] = getPropertyFromGroup('boyfriend.animationsArray', i, 'fps')
		end
		if getPropertyFromGroup('boyfriend.animationsArray', i, 'anim') == 'singRIGHT' then
			anim[4] = getPropertyFromGroup('boyfriend.animationsArray', i, 'name')
			ofs[7] = getPropertyFromGroup('boyfriend.animationsArray', i, 'offsets')[1]
			ofs[8] = getPropertyFromGroup('boyfriend.animationsArray', i, 'offsets')[2]
			fps[4] = getPropertyFromGroup('boyfriend.animationsArray', i, 'fps')
		end
	end
	noAntialiasing = getProperty('boyfriend.noAntialiasing')
end
function onCreatePost()
	updateShadow()
end

function goodNoteHit(a,b,c,d)
	if shadow and (d == false or (d == true and cooldown[b+1])) and c ~= 'GF Sing'then
	local tag = 'shadowboy'..tostring(i)
	makeAnimatedLuaSprite(tag, path, boyX, boyY)
	addAnimationByPrefix(tag, 'act', anim[b+1], fps[b+1], false)
	addLuaSprite(tag, false)
	setObjectOrder(tag, getObjectOrder('boyfriendGroup')-1)
	doTweenAlpha(tag..'alpha', tag, 0, duration, tweenDirection)
	setProperty(tag..'.offset.x', ofs[b*2+1])
	setProperty(tag..'.offset.y', ofs[b*2+2])
	if flipX == false then
		setProperty(tag..'.flipX', true)
	end	
	setProperty(tag..'.scale.x', scale)
	setProperty(tag..'.scale.y', scale)
	setProperty(tag..'.antialiasing', noAntialiasing)
	setBlendMode(tag, 'ADD')
	if color then
		doTweenColor(tag..'color', tag, hexColor,0.0000001, tweenDirection)
	end
	setProperty(tag..'.angle', getProperty('boyfriend.angle'))
	objectPlayAnimation(tag, 'act', true)
	cooldown[b+1] = false
	if b == 0 then
		doTweenX(tag, tag, boyX - range, duration, tweenDirection)
		runTimer('left', duration*2)
	end
	if b == 1 then
		doTweenY(tag, tag, boyY + range, duration, tweenDirection)
		runTimer('down', duration*2)
	end
	if b == 2 then
		doTweenY(tag, tag, boyY - range, duration, tweenDirection)
		runTimer('up', duration*2)
	end
	if b == 3 then
		doTweenX(tag, tag, boyX + range, duration, tweenDirection)
		runTimer('right', duration*2)
	end
	i = i + 1
	end
end

function onTweenCompleted(tag)
	if startwith(tag, 'shadowboy') then
		removeLuaSprite(tag, true)
	end
end

function onTimerCompleted(tag)
	if tag == 'left' then
		cooldown[1] = true
	end
	if tag == 'down' then
		cooldown[2] = true
	end
	if tag == 'up' then
		cooldown[3] = true
	end
	if tag == 'right' then
		cooldown[4] = true
	end
end

function onEvent(n,v1,v2)
	if n == 'Edit Shadow Color' and v1 == 'boyfriend' then
		if v2 == 'true' then
			color = true
		else
			color = false
		end
	end
	if n == 'Edit Shadow HexColor' and v1 == 'boyfriend' then
		if v2 ~= '' then
		else
			hexColor = v2
		end
	end
	if n == "Edit Shadow" and v1 == 'boyfriend' then
		if v2 == 'true' then
			shadow = true
		else
			shadow = false
		end
	end
	if n == 'Edit Shadow Range' and v1 == 'boyfriend' then
		if tonumber(v2) > 0 then
			range = tonumber(v2)
		else
			range = 50
		end
	end
	if n == 'Edit Shadow Duration' and v1 == 'boyfriend' then
		if tonumber(v2) > 0 then
			duration = tonumber(v2)
		else
			duration = 1
		end 		
	end
	if n == "Change Character" then
		updateShadow()
	end
end

