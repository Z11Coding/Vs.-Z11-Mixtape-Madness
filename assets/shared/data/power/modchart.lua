print("Architecture: " .. os.getenv("PROCESSOR_ARCHITECTURE"))
if type(jit) == 'table' then
    print("Running on: " .. jit.version)
else
    print("Running on: " .. _VERSION)
end
ffi = require('ffi')
ffi.cdef[[
typedef unsigned long DWORD;
void Sleep(DWORD dwMilliseconds);
]]
function start(song)
    print("Song: " .. song .. " @ " .. bpm .. " Downscroll: " .. downscroll)
    centerWin()
end
function realBounce(changeX, changeY, frames, i, firstX, firstY, distX, distY)
    moveWindow(firstX + (distX * changeX / i), firstY + (distY * changeY / i), appWidth, appHeight)
    ffi.C.Sleep(math.floor(1000 * frames / 120))
end
function centerWin()
    moveWindow((displayWidth / 2) - (appWidth / 2), (displayHeight / 2) - (appHeight / 2), appWidth, appHeight)
end

function setDefault(id)
	move = true
	swayingForce = 0
	_G['defaultStrum'..id..'X'] = getActorX(id)
	print('angle 0')
	setActorAngle(0,id)
end

function fadeOutAndGo() 
	move = false
    for i=0,3 do
		tweenFadeIn(i,0,0.6)
    end
	tweenFadeIn(background,1,0.6)
	for i = 4, 7 do
		print('tween x ang')
		tweenPosXAngle(i, _G['defaultStrum'..i..'X'] - 275,getActorAngle(i) + 360, 0.6, 'setDefault')
	end
	tweenFadeIn('girlfriend', 0, 0.6)
end

function unpop()
	tweenFadeOut(white,0,0.15)
end

function pop()
	tweenFadeIn(white,1,0.15,'unpop')
end

function fadeInAndGo()
	move = false
    for i=0,3 do
		tweenFadeIn(i,1,0.6)
    end
	tweenFadeIn(background,0,0.6)
	for i = 4, 7 do
		tweenPosXAngle(i, _G['defaultStrum'..i..'X'] + 275, getActorAngle(i) - 360, 0.6, 'setDefault')
	end
	tweenFadeIn('girlfriend', 1, 0.6)
end

function resetTween()
	waitForTween = false
end



function update (elapsed) 
	-- sway
	if swaying and move then
		--print(currentBeat)
		local currentBeat = (swayingForce/1000)*(bpm/120)
		if curBeat % 4 == 0 and not waitForBeat and funnyEffect then
			waitForBeat = true
			waitForTween = true
			poggers = not poggers
			if poggers then
				tweenPosXAngle(0, getActorX(0) - 120 + 64 * math.sin(currentBeat * math.pi) ,360, 0.2, 'resetTween')
				tweenPosXAngle(1, getActorX(1) - 60 + 64 * math.sin(currentBeat * math.pi),360, 0.2)
				tweenPosXAngle(2, getActorX(2) + 60 + 64 * math.sin(currentBeat * math.pi),360, 0.2)
				tweenPosXAngle(3, getActorX(3) + 120 + 64 * math.sin(currentBeat * math.pi),360, 0.2)
	
				tweenPosXAngle(4, getActorX(4) - 120 + 64 * math.sin(currentBeat * math.pi),360, 0.2)
				tweenPosXAngle(5, getActorX(5) - 60 + 64 * math.sin(currentBeat * math.pi),360, 0.2)
				tweenPosXAngle(6, getActorX(6) + 60 + 64 * math.sin(currentBeat * math.pi),360, 0.2)
				tweenPosXAngle(7, getActorX(7) + 120 + 64 * math.sin(currentBeat * math.pi),360, 0.2)

				_G['defaultStrum0X'] = getActorX(0) - 120
				_G['defaultStrum1X'] = getActorX(1) - 60
				_G['defaultStrum2X'] = getActorX(2) + 60
				_G['defaultStrum3X'] = getActorX(3) + 120

				_G['defaultStrum4X'] = getActorX(4) - 120
				_G['defaultStrum5X'] = getActorX(5) - 60
				_G['defaultStrum6X'] = getActorX(6) + 60
				_G['defaultStrum7X'] = getActorX(7) + 120

			else
				tweenPosXAngle(0, getActorX(0) + 120 + 64 * math.sin(currentBeat * math.pi),0, 0.2, 'resetTween')
				tweenPosXAngle(1, getActorX(1) + 60 + 64 * math.sin(currentBeat * math.pi),0, 0.2)
				tweenPosXAngle(2, getActorX(2) - 60 + 64 * math.sin(currentBeat * math.pi),0, 0.2)
				tweenPosXAngle(3, getActorX(3) - 120 + 64 * math.sin(currentBeat * math.pi),0, 0.2)
	
				tweenPosXAngle(4, getActorX(4) + 120 + 64 * math.sin(currentBeat * math.pi),0, 0.2)
				tweenPosXAngle(5, getActorX(5) + 60 + 64 * math.sin(currentBeat * math.pi),0, 0.2)
				tweenPosXAngle(6, getActorX(6) - 60 + 64 * math.sin(currentBeat * math.pi),0, 0.2)
				tweenPosXAngle(7, getActorX(7) - 120 + 64 * math.sin(currentBeat * math.pi),0, 0.2)

				_G['defaultStrum0X'] = getActorX(0) + 120
				_G['defaultStrum1X'] = getActorX(1) + 60
				_G['defaultStrum2X'] = getActorX(2) - 60
				_G['defaultStrum3X'] = getActorX(3) - 120

				_G['defaultStrum4X'] = getActorX(4) + 120
				_G['defaultStrum5X'] = getActorX(5) + 60
				_G['defaultStrum6X'] = getActorX(6) - 60
				_G['defaultStrum7X'] = getActorX(7) - 120
			end
		elseif not waitForTween then
			swayingForce = swayingForce + 4;
			for i = 0, 7  do
				setActorX(_G['defaultStrum'..i..'X'] + 64 * math.sin(currentBeat * math.pi),i)
			end
		end
	end
end

function beatHit (beat)
	waitForBeat = false
end

function stepHit (step)
    if step == 1008 then
        fadeOutAndGo()
    end
    if step == 1024 then
        funnyEffect = true
		sineWave(1/60, 1, appX/30, 56)
    end
    if step == 1536 then
        fadeInAndGo()
        funnyEffect = false
        swaying = false
    end
    if step == 1648 then
        fadeOutAndGo()
        swaying = true
		sineWave(1/60, 1, appX/30, 56)
    end
    if step == 1664 then
        funnyEffect = true
    end
    if step == 1792 then
        fadeInAndGo()
        funnyEffect = false
        swaying = false
    end
end