--my collection lol
--thx Camellia mod, weegee mod, oh **** a shark mod, dark sheep mod, roses modchart mod, techno mod, and the person who made the modchart engine mod. oh, and the Djentbot mod
local resetti = false
local spincenter = false
local swayGO = false 
local swayGOMessy = false 
local originalCamHudAngle

local hudrotate = false
local hudrotatecalm = false
local swayingsmall = false
local swayinglarge = false
local swayingbigger = false
local swayingbiggest = false
local swayingbiggest2 = false
local swaySlowP1 = false 
local swaySlowP2 = false 
local swaySlow = false 
local swayFast = false 
local swayIntense = false 
local swayIntense2 = false 
local swayIntense3 = false 
local swayIntense4 = false
local glitch = false 
local glitchier = false 
local shifted = false 
local glitched = false 

local fading = false 
local faded = false 
local fadingFast = false 
local fadedFast = false 

local partySideways = false 
local partiedSideways = false 
local partyIDiagonal = false 
local partyODiagonal = false 
local partiedIDiagonal = false 
local partiedODiagonal = false 
local partyRoundLeft = false 
local partyRoundRight = false 
local partyWave = false 

local partySideways2 = false 
local partiedSideways2 = false 
local partyIDiagonal2 = false 
local partyODiagonal2 = false 
local partiedIDiagonal2 = false 
local partiedODiagonal2 = false 

local waitForBeatMove = false
local waitForBeatFade = false
local waitForStepMove = false 

local hudX = 0
local hudY = 0

local spinCrazy = false
local spin = false

local hit = false
local directionMulti = 1
local heightMulti = 1

local direction = 2

local l1 = false
local l2 = false
local swayingForce = 1;

local swayingbiggest = false
local swayingbiggest2 = false
local swayingdown = false -- No Used

local gl = false
local sl = false
local bign = false
local lol = false

local noteleftright = false
local manicnotes = false
local zoa1 = false
local l = false
local ll = false
local swayingForce = 1;

local mk1 = false

local justbf = false
local space = false
local space2 = false
local okay = false
local lesgo = false
local alright = false
local rotateScreen = false
local move = false

function start (song)
	hudX = getHudX()
    hudY = getHudY()
	useDownscroll(false)
	spinLength = 0
    lerpVal = 1 -- initialize the lerp Value at 0.

	WhiteBG = makeSprite('WhiteBG','whitebg', true)
	BlackBG = makeSprite('BlackFade','blackbg', true)
	WhiteFade = makeSprite('WhiteBG','whitefade', false)
	BlackFade = makeSprite('BlackFade','blackfade', false)
	Fading = makeSprite('Fading','fading', false)

	setActorX(200,'whitebg')
	setActorY(500,'whitebg')
	setActorAlpha(0,'whitebg')
	setActorScale(4,'whitebg')
	
	setActorX(200,'blackbg')
	setActorY(500,'blackbg')
	setActorAlpha(1,'blackbg')
	setActorScale(4,'blackbg')

	setActorX(30,'fading')
	setActorY(427,'fading')
	setActorAlpha(0,'fading')
	setActorScale(2,'fading')
	
	setActorX(200,'blackfade')
	setActorY(500,'blackfade')
	setActorAlpha(1,'blackfade')
	setActorScale(4,'blackfade')
	
	setActorX(200,'whitefade')
	setActorY(500,'whitefade')
	setActorAlpha(0,'whitefade')
	setActorScale(4,'whitefade')

	setActorAlpha(0,'boyfriend')
	setActorAlpha(0,'dad')
	setActorAlpha(0,'girlfriend')

	hide = false
	showOnlyStrums = true
    downscroll = false
	
    shakenote = true
	
	setHudPosition(0, 1000)
end

function reset()
	for i=0,7 do
		tweenPosXAngle(i, _G['defaultStrum'..i..'X'] + 0,getActorAngle(i) + 360, 0.1, 'setDefault')
        tweenPosYAngle(i, _G['defaultStrum'..i..'Y'] + 0,getActorAngle(i) + 360, 0.1, 'setDefault')
	end
	camHudAngle = 0
end


function update (elapsed)
    local currentBeat = (songPos / 1000)*(bpm/60)
    local currentBeatWave = (songPos / 1000)*(bpm/60)
    if movestrum1 then
        for i = 4,7 do 
            tweenPosXAngle(i, _G['defaultStrum'..i..'X'] - 640,getActorAngle(i) + 360, 0.1, 'setDefault')
        end
        for i = 0,3 do 
            tweenPosXAngle(i, _G['defaultStrum'..i..'X'] + 640,getActorAngle(i) + 360, 0.1, 'setDefault')
        end 
    end
    if movestrum2 then
        for i = 4,7 do 
            tweenPosXAngle(i, _G['defaultStrum'..i..'X'] + 2,getActorAngle(i) + 360, 0.1, 'setDefault')
        end
        for i = 0,3 do 
           tweenPosXAngle(i, _G['defaultStrum'..i..'X'] - 2,getActorAngle(i) + 360, 0.1, 'setDefault')
        end 
    end
    if movestrum3 then
        for i = 4,7 do 
            tweenPosYAngle(i, _G['defaultStrum'..i..'Y'] + 400,getActorAngle(i) + 360, 0.1, 'setDefault')
        end
    end
    if movestrum4 then
        for i = 0,3 do 
            tweenPosYAngle(i, _G['defaultStrum'..i..'Y'] + 400,getActorAngle(i) + 360, 0.1, 'setDefault')
         end 
        for i = 4,7 do 
            tweenPosYAngle(i, _G['defaultStrum'..i..'Y'] + 0,getActorAngle(i) + 360, 0.1, 'setDefault')
        end
    end
    if movestrum5 then
        for i = 4,7 do 
            tweenPosXAngle(i, _G['defaultStrum'..i..'X'] - 640,getActorAngle(i) + 360, 0.1, 'setDefault')
        end
        for i = 0,3 do 
            tweenPosXAngle(i, _G['defaultStrum'..i..'X'] + 640,getActorAngle(i) + 360, 0.1, 'setDefault')
        end 
    end
    if movestrum6 then
        for i = 4,7 do 
            tweenPosXAngle(i, _G['defaultStrum'..i..'X'] + 0,getActorAngle(i) + 360, 0.1, 'setDefault')
        end
        for i = 0,3 do
           tweenPosXAngle(i, _G['defaultStrum'..i..'X'] - 0,getActorAngle(i) + 360, 0.1, 'setDefault')
        end 
    end
    if movestrum7 then
        for i = 0,3 do 
            tweenPosYAngle(i, _G['defaultStrum'..i..'Y'] + 0,getActorAngle(i) + 360, 0.1, 'setDefault')
         end 
        for i = 4,7 do 
            tweenPosYAngle(i, _G['defaultStrum'..i..'Y'] + 400,getActorAngle(i) + 360, 0.1, 'setDefault')
        end
    end
    if movestrum8 then
        for i = 0,3 do 
            tweenPosYAngle(i, _G['defaultStrum'..i..'Y'] + 0,getActorAngle(i) + 360, 0.1, 'setDefault')
         end 
        for i = 4,7 do 
            tweenPosYAngle(i, _G['defaultStrum'..i..'Y'] + 0,getActorAngle(i) + 360, 0.1, 'setDefault')
        end
    end
    if swap then
		for i=0,3 do
			setActorX(_G['defaultStrum'..i..'X'] - 300 * math.sin((currentBeat + i*0)) + 350, i)
		end
		for i=4,7 do
			setActorX(_G['defaultStrum'..i..'X'] + 300 * math.sin((currentBeat + i*0)) - 275, i)
		end
	end
    if swapup then
		for i=0,3 do
			setActorY(_G['defaultStrum'..i..'Y'] + 200 * math.sin((currentBeat + i*0)) + 70, i)
		end
		for i=4,7 do
			setActorY(_G['defaultStrum'..i..'Y'] + 200 * math.sin((currentBeat + i*0)) + 70, i)
		end
	end
    if spinpog then
		for i=4,7 do
			setActorX(_G['defaultStrum'..i..'X'] + 300 * math.sin((currentBeat + i*0)) - 275, i)
			setActorY(_G['defaultStrum'..i..'Y'] - 50 * math.cos((currentBeat + i*0)) + 0, i)
		end
	end
    if water then
		for i=0,3 do
			setActorX(_G['defaultStrum'..i..'X'] - 256 * math.sin(currentBeat / 5) + 275, i)
			setActorY(_G['defaultStrum'..i..'Y'] - 50 * math.cos(currentBeat) + 10,i)
		end
		for i=4,7 do
			setActorX(_G['defaultStrum'..i..'X'] + 256 * math.sin(currentBeat / 5) - 275, i)
			setActorY(_G['defaultStrum'..i..'Y'] - 50 * math.cos(currentBeat) + 10,i)
		end
	end
    if swayinglarge then
		for i=0,7 do
			setActorX(_G['defaultStrum'..i..'X'] + 32 * math.sin((currentBeat + i*1)), i)
			setActorY(_G['defaultStrum'..i..'Y'] + 32 * math.cos((currentBeat + i*1)) + 10, i)
		end
	end
    if shakenote then
		for i=0,7 do
			setActorX(_G['defaultStrum'..i..'X'] + 3 * math.sin((currentBeat * 10 + i*0.25) * math.pi), i)
			setActorY(_G['defaultStrum'..i..'Y'] + 3 * math.cos((currentBeat * 10 + i*0.25) * math.pi) + 10, i)
		end
	end
    if shakearrow == true then
        for i=0,7 do
            setActorX(_G['defaultStrum'..i..'X'] + 32 * math.sin((currentBeat + i*0) * math.pi), i)
            setActorY(_G['defaultStrum'..i..'Y'] + 0 * math.cos((currentBeat + i*0) * math.pi), i)
        end
    end
    if shakearrow2 == true then
        for i=0,7 do
            setActorX(_G['defaultStrum'..i..'X'] + 64 * math.sin((currentBeat + i*0) * math.pi), i)
            setActorY(_G['defaultStrum'..i..'Y'] + 0 * math.cos((currentBeat + i*0) * math.pi), i)
        end
    end
    if shakearrow3 == true then
        for i=0,7 do
                setActorX(_G['defaultStrum'..i..'X'] + 64 * math.sin((currentBeat + i*0) * math.pi), i)
                setActorY(_G['defaultStrum'..i..'Y'] + 32 * math.cos((currentBeat + i*0) * math.pi), i)
        end
    end
    if rotateScreen then
		camHudAngle = 5 * math.sin(currentBeat * 0.504)
	end
    if alright then
		for i=0,7 do
			setActorX(_G['defaultStrum'..i..'X'] + 25 * math.sin((currentBeat + i*0)) * 2, i)
			setActorY(_G['defaultStrum'..i..'Y'] - 25 * math.cos((currentBeat - i*0)) * 2, i)
		end
	end
    if lesgo then
		for i=0,7 do
			setActorX(_G['defaultStrum'..i..'X'] - 50 - math.sin((currentBeat - i*20)) - 70, i)
			setActorY(_G['defaultStrum'..i..'Y'] + 60 * math.cos((currentBeat + i*10) * math.pi), i)
		end
	end
    if okay then
		for i=0,7 do
			setActorX(_G['defaultStrum'..i..'X'] / 502 - math.sin((currentBeat - i*0)) - 100, i)
			setActorY(_G['defaultStrum'..i..'Y'] / 90 * math.cos((currentBeat + i*102) * math.pi), i)
		end
	end
    if space then
		for i=0,7 do
			setActorX(_G['defaultStrum'..i..'X'] - 50 / math.sin((currentBeat + i/20)) - 70, i)
			setActorY(_G['defaultStrum'..i..'Y'] - 15 * math.cos((currentBeat - i-40)) + 30, i)
		end
	end
    if space2 then
		for i=0,7 do
			setActorX(_G['defaultStrum'..i..'X'] + 1 * math.sin((currentBeat + i*0)) - 1, i)
			setActorY(_G['defaultStrum'..i..'Y'] + 5 * math.cos((currentBeat + i*5)) - 10, i)
		end
	end
    if justbf then
        for i=0,3 do -- fade out the first 4 receptors (the ai receptors)
            tweenPosXAngle(i, _G['defaultStrum'..i..'X'] - 1000,getActorAngle(i) + 1000, 0.6, 'setDefault')
        end
        for i = 4, 7 do -- go to the center
            tweenPosXAngle(i, _G['defaultStrum'..i..'X'] - 275,getActorAngle(i) + 360, 0.6, 'setDefault')
        end
    end
	if swayGO then 
        for i = 4, 7 do 
            setActorX(_G['defaultStrum'..i..'X'] - 32 * math.sin((currentBeat + i*0)), i)
            setActorY(_G['defaultStrum'..i..'Y'] - 64 * math.cos((currentBeat + i*32) * math.pi),i)
        end 
    end
    if swayGOMessy then 
        for i = 4, 7 do 
            setActorX(_G['defaultStrum'..i..'X'] - 32 * math.sin((currentBeat + i*5)), i)
            setActorY(_G['defaultStrum'..i..'Y'] - 64 * math.cos((currentBeat + i*32) * math.pi),i)
        end 
    end
	if strumcircle then 
        for i=0,7 do
			setActorX(_G['defaultStrum'..i..'X'] + 32 * math.sin((currentBeat + i*0.25) * math.pi), i)
			setActorY(_G['defaultStrum'..i..'Y'] + 32 * math.cos((currentBeat + i*0.25) * math.pi), i)
		end
    end
	if strumcircle then 
        camHudAngle = 4 * math.sin(currentBeatWave * math.pi) --Code stolen from DarkSheep lmao (please don't kill me KadeDev)
    end
	if strumcirclereset then 
        camHudAngle = originalCamHudAngle
    end
	if mk1 then
        for i=0,7 do
            setActorX(_G['defaultStrum'..i..'X'] + 24 * math.sin((currentBeat + i*0.05) * math.pi), i)
            setActorY(_G['defaultStrum'..i..'Y'] + 8 * math.cos((currentBeat + i*0.10) * math.pi), i)
        end
    end
	if noteleftright then
        for i=0,7 do
			setActorX(_G['defaultStrum'..i..'X'] + 105 * math.sin((currentBeat + i*0.38)), i)
			setActorY(_G['defaultStrum'..i..'Y'],i)
		end
	end
    if manicnotes then -- not used
		for i=0,7 do
			setActorX(_G['defaultStrum'..i..'X'] + 65 * math.sin((currentBeat + i*0.30) * math.pi), i)
			setActorY(_G['defaultStrum'..i..'Y'] + 60 * math.cos((currentBeat + i*0.24) * math.pi), i)
		end
	end
    if zoa1 then
        for i=0,7 do
			setActorX(_G['defaultStrum'..i..'X'] + 100 * math.sin((currentBeat + i*0)), i)
			setActorY(_G['defaultStrum'..i..'Y'] + 50 * math.cos((currentBeat + i*0.30) * math.pi), i)
		end
    end
    if bign then
		for i=0,7 do
			setActorX(_G['defaultStrum'..i..'X'] + 36 * math.sin((currentBeat + i*0.25) * math.pi), i)
			setActorY(_G['defaultStrum'..i..'Y'] + 74 * math.cos((currentBeat + i*0.08) * math.pi), i)
		end
	end
    if lol then
		for i=0,7 do
			setActorX(_G['defaultStrum'..i..'X'] + 14 * math.sin((currentBeat + i*0.10) * math.pi), i)
			setActorY(_G['defaultStrum'..i..'Y'] + 32 * math.cos((currentBeat + i*0) * math.pi), i)
		end
	end
	if swayingdown then -- No Used
        for i=0,7 do
			setActorX(_G['defaultStrum'..i..'X'] + 16 * math.sin((currentBeat + i*0.8) * math.pi), i)
			setActorY(_G['defaultStrum'..i..'Y'] - 20 * math.cos((currentBeat + i*0.12) * math.pi) ,i)
		end
	end
	if swayingbiggest3 then
		for i=0,3 do
			setActorX(_G['defaultStrum'..i..'X'] + 320 * math.sin((currentBeat + i*0)) + 350, i)
			setActorY(_G['defaultStrum'..i..'Y'] + 70 * math.cos((currentBeat + i*5.45) * math.pi),i)
		end
		for i=4,7 do
			setActorX(_G['defaultStrum'..i..'X'] - 320 * math.sin((currentBeat + i*0)) - 275, i)
			setActorY(_G['defaultStrum'..i..'Y'] - 79 * math.cos((currentBeat + i*5.45) * math.pi),i)
		end
	end
	if spinCrazy then -- spinning crazy
        camHudAngle = 32 * math.sin(currentBeat * math.pi)
        if getHudX() < 320 then
            setHudPosition(getHudX() + 4, 32 * math.cos(currentBeat * math.pi))
        else
            setHudPosition(-640, 32 * math.cos(currentBeat * math.pi))
        end
    end
	if spin then
        if getHudX() + 640 > 1280 and not hit then
            hit = not hit
            direction = 2 * directionMulti
        elseif hit then
            if getHudX() - 640 > -1280 and hit then
                direction = -2 * directionMulti
            else
                hit = not hit
                direction = 2 * directionMulti
            end
        end
        setHudPosition(getHudX() + direction, 32 * math.cos(currentBeat * math.pi) * heightMulti)
    end
	function playerTwoTurn()
		camGame:tweenZoom(1.3,(crochet * 4) / 1000)
	end

	if glitch then 
        if curBeat % 4 == 0 then 
            shifted = not shifted
            if shifted then 
                for i = 0, 7 do 
                    setActorX(_G['defaultStrum'..i..'X'] + 40 * math.sin((currentBeat + i*0)), i)
                end
            else
                for i = 0, 7 do 
                    setActorX(_G['defaultStrum'..i..'X'] - 40 * math.sin((currentBeat + i*0)), i)
                end
            end
        end
    end
    if glitchier then 
        if curBeat % 2 == 0 then 
            shifted = not shifted
            if shifted then 
                for i = 0, 7 do 
                    setActorX(_G['defaultStrum'..i..'X'] + 40 * math.sin((currentBeat + i*0)), i)
                end
                glitched = not glitched
                if glitched then 
                    for i = 0, 7 do 
                        setActorY(_G['defaultStrum'..i..'Y'] + 10 * math.sin((currentBeat + i*0)), i)
                    end
                else 
                    for i = 0, 7 do 
                        setActorY(_G['defaultStrum'..i..'Y'] - 10 * math.sin((currentBeat + i*0)), i)
                    end
                end
            else
                for i = 0, 7 do 
                    setActorX(_G['defaultStrum'..i..'X'] - 40 * math.sin((currentBeat + i*0)), i)
                end
            end
        end
    end
    if fading then 
        if curBeat % 16 == 0 and not waitForBeatFade then 
            waitForBeatFade = true
            faded = not faded 
            if faded then 
                for i = 0, 7 do 
                    tweenFadeIn(i, 0.1, 4.35)
                end
            else 
                for i = 0, 7 do 
                    tweenFadeOut(i, 1, 4.35)
                end
            end
        end
    end
    if partySideways then 
        for i = 0, 7 do 
            tweenPosXAngle(i, _G['defaultStrum'..i..'X'] + 40, getActorAngle(i), 0.25, i)
        end
    end
    if partySidewaysReset then
        for i = 0, 7 do 
            tweenPosXAngle(i, _G['defaultStrum'..i..'X'] - 40, getActorAngle(i), 0.25, i)
        end
    end
    if partyIDiagonal then 
        if curBeat % 1 == 0 and not waitForBeatMove then 
            waitForBeatMove = true
            partiedIDiagonal = not partiedIDiagonal
            if partiedIDiagonal then 
                for i = 4, 7 do 
                    tweenPosXAngle(i, _G['defaultStrum'..i..'X'] + 40, getActorAngle(i), 0.25, i)
                    tweenPosYAngle(i, _G['defaultStrum'..i..'Y'] - 40, getActorAngle(i), 0.25, i)
                end
                for i = 0, 3 do 
                    tweenPosXAngle(i, _G['defaultStrum'..i..'X'] - 40, getActorAngle(i), 0.25, i)
                    tweenPosYAngle(i, _G['defaultStrum'..i..'Y'] - 40, getActorAngle(i), 0.25, i)
                end
            else 
                for i = 4, 7 do 
                    tweenPosXAngle(i, _G['defaultStrum'..i..'X'] - 40, getActorAngle(i), 0.25, i)
                    tweenPosYAngle(i, _G['defaultStrum'..i..'Y'] + 40, getActorAngle(i), 0.25, i)
                end
                for i = 0, 3 do 
                    tweenPosXAngle(i, _G['defaultStrum'..i..'X'] + 40, getActorAngle(i), 0.25, i)
                    tweenPosYAngle(i, _G['defaultStrum'..i..'Y'] + 40, getActorAngle(i), 0.25, i)
                end
            end
        end
    end
    if partyODiagonal then 
        if curBeat % 1 == 0 and not waitForBeatMove then 
            waitForBeatMove = true
            partiedODiagonal = not partiedODiagonal
            if partiedODiagonal then 
                for i = 4, 7 do 
                    tweenPosXAngle(i, _G['defaultStrum'..i..'X'] - 40, getActorAngle(i), 0.25, i)
                    tweenPosYAngle(i, _G['defaultStrum'..i..'Y'] - 40, getActorAngle(i), 0.25, i)
                end
                for i = 0, 3 do 
                    tweenPosXAngle(i, _G['defaultStrum'..i..'X'] + 40, getActorAngle(i), 0.25, i)
                    tweenPosYAngle(i, _G['defaultStrum'..i..'Y'] - 40, getActorAngle(i), 0.25, i)
                end
            else 
                for i = 4, 7 do 
                    tweenPosXAngle(i, _G['defaultStrum'..i..'X'] + 40, getActorAngle(i), 0.25, i)
                    tweenPosYAngle(i, _G['defaultStrum'..i..'Y'] + 40, getActorAngle(i), 0.25, i)
                end
                for i = 0, 3 do 
                    tweenPosXAngle(i, _G['defaultStrum'..i..'X'] - 40, getActorAngle(i), 0.25, i)
                    tweenPosYAngle(i, _G['defaultStrum'..i..'Y'] + 40, getActorAngle(i), 0.25, i)
                end
            end
        end
    end
    if partySideways2 then 
        if curStep % 2 == 0 and not waitForStepMove then 
            waitForStepMove = true
            partiedSideways2 = not partiedSideways2
            if partiedSideways2 then 
                for i = 0, 7 do 
                    tweenPosXAngle(i, _G['defaultStrum'..i..'X'] + 40, getActorAngle(i), 0.1, i)
                end
            else 
                for i = 0, 7 do 
                    tweenPosXAngle(i, _G['defaultStrum'..i..'X'] - 40, getActorAngle(i), 0.1, i)
                end
            end
        end
    end
    if partyIDiagonal2 then 
        if curStep % 2 == 0 and not waitForStepMove then 
            waitForStepMove = true
            partiedIDiagonal2 = not partiedIDiagonal2
            if partiedIDiagonal2 then 
                for i = 4, 7 do 
                    tweenPosXAngle(i, _G['defaultStrum'..i..'X'] + 40, getActorAngle(i), 0.1, i)
                    tweenPosYAngle(i, _G['defaultStrum'..i..'Y'] - 40, getActorAngle(i), 0.1, i)
                end
                for i = 0, 3 do 
                    tweenPosXAngle(i, _G['defaultStrum'..i..'X'] - 40, getActorAngle(i), 0.1, i)
                    tweenPosYAngle(i, _G['defaultStrum'..i..'Y'] - 40, getActorAngle(i), 0.1, i)
                end
            else 
                for i = 4, 7 do 
                    tweenPosXAngle(i, _G['defaultStrum'..i..'X'], getActorAngle(i), 0.1, i)
                    tweenPosYAngle(i, _G['defaultStrum'..i..'Y'], getActorAngle(i), 0.1, i)
                end
                for i = 0, 3 do 
                    tweenPosXAngle(i, _G['defaultStrum'..i..'X'], getActorAngle(i), 0.1, i)
                    tweenPosYAngle(i, _G['defaultStrum'..i..'Y'], getActorAngle(i), 0.1, i)
                end
            end
        end
    end
    if partyODiagonal2 then 
        if curStep % 2 == 0 and not waitForStepMove then 
            waitForStepMove = true
            partiedODiagonal2 = not partiedODiagonal2
            if partiedODiagonal2 then 
                for i = 4, 7 do 
                    tweenPosXAngle(i, _G['defaultStrum'..i..'X'] - 40, getActorAngle(i), 0.1, i)
                    tweenPosYAngle(i, _G['defaultStrum'..i..'Y'] - 40, getActorAngle(i), 0.1, i)
                end
                for i = 0, 3 do 
                    tweenPosXAngle(i, _G['defaultStrum'..i..'X'] + 40, getActorAngle(i), 0.1, i)
                    tweenPosYAngle(i, _G['defaultStrum'..i..'Y'] - 40, getActorAngle(i), 0.1, i)
                end
            else 
                for i = 4, 7 do 
                    tweenPosXAngle(i, _G['defaultStrum'..i..'X'], getActorAngle(i), 0.1, i)
                    tweenPosYAngle(i, _G['defaultStrum'..i..'Y'], getActorAngle(i), 0.1, i)
                end
                for i = 0, 3 do 
                    tweenPosXAngle(i, _G['defaultStrum'..i..'X'], getActorAngle(i), 0.1, i)
                    tweenPosYAngle(i, _G['defaultStrum'..i..'Y'], getActorAngle(i), 0.1, i)
                end
            end
        end
    end
    if partyRoundLeft then 
        for i = 0, 7 do 
			setActorX(_G['defaultStrum'..i..'X'] - 80 * math.sin((currentBeat + i*0) * math.pi), i)
			setActorY(_G['defaultStrum'..i..'Y'] + 32 * math.cos((currentBeat + i*4) * math.pi),i)
        end 
    end
    if partyRoundRight then 
        for i = 0, 7 do 
			setActorX(_G['defaultStrum'..i..'X'] + 80 * math.sin((currentBeat + i*0) * math.pi), i)
			setActorY(_G['defaultStrum'..i..'Y'] + 32 * math.cos((currentBeat + i*4) * math.pi),i)
        end 
    end
    if partyWave then 
        for i = 0, 3 do 
			setActorX(_G['defaultStrum'..i..'X'] + 64 * math.sin((currentBeat + i*0)), i)
			setActorY(_G['defaultStrum'..i..'Y'] + 32 * math.cos((currentBeat + i*128) * math.pi),i)
        end 
        for i = 4, 7 do 
			setActorX(_G['defaultStrum'..i..'X'] - 64 * math.sin((currentBeat + i*0)), i)
			setActorY(_G['defaultStrum'..i..'Y'] + 32 * math.cos((currentBeat + i*128) * math.pi),i)
        end 
    end
	
	if swaySlowP1 then 
        for i = 0, 3 do 
            setActorX(_G['defaultStrum'..i..'X'] - 32 * math.sin((currentBeat + i*0)) + 16, i)
            setActorY(_G['defaultStrum'..i..'Y'],i)
        end 
    end
    if swaySlowP2 then 
        for i = 4, 7 do 
            setActorX(_G['defaultStrum'..i..'X'] - 32 * math.sin((currentBeat + i*0)) + 16, i)
            setActorY(_G['defaultStrum'..i..'Y'],i)
        end 
    end
    if swaySlow then 
        for i = 0, 7 do 
            setActorX(_G['defaultStrum'..i..'X'] + 32 * math.sin((currentBeat + i*0)), i)
            setActorY(_G['defaultStrum'..i..'Y'],i)
        end 
    end
    if swayFast then 
        for i = 0, 7 do 
            setActorX(_G['defaultStrum'..i..'X'] + 64 * math.sin((currentBeat + i*0)), i)
            setActorY(_G['defaultStrum'..i..'Y'],i)
        end 
    end
    if swayIntense then 
        for i = 0, 3 do 
			setActorX(_G['defaultStrum'..i..'X'] - 64 * math.sin((currentBeat + i*0)) + 16, i)
			setActorY(_G['defaultStrum'..i..'Y'] - 16 * math.cos((currentBeat + i*32) * math.pi),i)
        end 
        for i = 4, 7 do 
			setActorX(_G['defaultStrum'..i..'X'] + 64 * math.sin((currentBeat + i*0)) - 16, i)
			setActorY(_G['defaultStrum'..i..'Y'] - 16 * math.cos((currentBeat + i*32) * math.pi),i)
        end 
    end
    if swayIntense2 then 
        for i = 0, 3 do 
			setActorX(_G['defaultStrum'..i..'X'] + 64 * math.sin((currentBeat + i*0)) - 16, i)
			setActorY(_G['defaultStrum'..i..'Y'] + 16 * math.cos((currentBeat + i*32) * math.pi),i)
        end 
        for i = 4, 7 do 
			setActorX(_G['defaultStrum'..i..'X'] - 64 * math.sin((currentBeat + i*0)) + 16, i)
			setActorY(_G['defaultStrum'..i..'Y'] + 16 * math.cos((currentBeat + i*32) * math.pi),i)
        end 
    end
    if swayIntense3 then 
        for i = 0, 3 do 
			setActorX(_G['defaultStrum'..i..'X'] + 80 * math.sin((currentBeat + i*0)) - 16, i)
			setActorY(_G['defaultStrum'..i..'Y'] + 32 * math.cos((currentBeat + i*32) * math.pi),i)
        end 
        for i = 4, 7 do 
			setActorX(_G['defaultStrum'..i..'X'] - 80 * math.sin((currentBeat + i*0)) + 16, i)
			setActorY(_G['defaultStrum'..i..'Y'] + 32 * math.cos((currentBeat + i*32) * math.pi),i)
        end 
    end
    if swayIntense4 then 
        for i=0,3 do
			setActorX(_G['defaultStrum'..i..'X'] - 320 * math.sin((currentBeat + i*0)) + 320, i)
			setActorY(_G['defaultStrum'..i..'Y'] + 32 * math.cos((currentBeat + i*8) * math.pi),i)
		end
		for i=4,7 do
			setActorX(_G['defaultStrum'..i..'X'] + 320 * math.sin((currentBeat + i*0)) - 320, i)
			setActorY(_G['defaultStrum'..i..'Y'] - 32 * math.cos((currentBeat + i*8) * math.pi),i)
		end
    end

	if zoom then
		setCamZoom(2)
	end
	if hide then
		for i=0,7 do
			setActorAlpha(0,i)
		end
	end
   if swayingsmall then
    for i=0,7 do
			setActorX(_G['defaultStrum'..i..'X'] + 32 * math.sin((currentBeat + i*0)), i)
			setActorY(_G['defaultStrum'..i..'Y'],i)
		end
   end
   if swayinglarge then
    for i=0,7 do
			setActorX(_G['defaultStrum'..i..'X'] + 64 * math.sin((currentBeat + i*0)), i)
			setActorY(_G['defaultStrum'..i..'Y'],i)
		end
   end
   if swayingbigger then
    for i=0,7 do
			setActorX(_G['defaultStrum'..i..'X'] + 64 * math.sin((currentBeat + i*0) * math.pi), i)
			setActorY(_G['defaultStrum'..i..'Y'] + 32 * math.cos((currentBeat + i*5) * math.pi) ,i)
		end
   end
   if swayingbiggest then
    for i=0,3 do
			setActorX(_G['defaultStrum'..i..'X'] + 300 * math.sin((currentBeat + i*0)) + 350, i)
			setActorY(_G['defaultStrum'..i..'Y'] + 64 * math.cos((currentBeat + i*5) * math.pi),i)
		end
		for i=4,7 do
			setActorX(_G['defaultStrum'..i..'X'] - 300 * math.sin((currentBeat + i*0)) - 275, i)
			setActorY(_G['defaultStrum'..i..'Y'] - 64 * math.cos((currentBeat + i*5) * math.pi),i)
		end
   end
   if swayingbiggest2 then
		for i=0,3 do
			setActorX(_G['defaultStrum'..i..'X'] - 300 * math.sin((currentBeat + i*0)) + 350, i)
			setActorY(_G['defaultStrum'..i..'Y'] + 64 * math.cos((currentBeat + i*5) * math.pi),i)
		end
		for i=4,7 do
			setActorX(_G['defaultStrum'..i..'X'] + 300 * math.sin((currentBeat + i*0)) - 275, i)
			setActorY(_G['defaultStrum'..i..'Y'] - 64 * math.cos((currentBeat + i*5) * math.pi),i)
		end
	end
   if resetti then
		for i=0,7 do
			tweenPosXAngle(i, _G['defaultStrum'..i..'X'], 0, 0.6, 'setDefault')
			tweenPosYAngle(i, _G['defaultStrum'..i..'Y'], 0, 0.6, 'setDefault')
		end
	end
	if hudrotate then
	camHudAngle = 5 * math.cos((currentBeat) * 1)
	cameraAngle = -5 * math.cos((currentBeat) * 1)
	end
	if hudrotatecalm then
	camHudAngle = 4 * math.cos((currentBeat) * 0.5)
	cameraAngle = -4 * math.cos((currentBeat) * 0.5)
	end
	if hudreset then
	camHudAngle = 0
	cameraAngle = 0
	end
	if spincenter then
		local currentBeat = (songPos / 1000)*(bpm/150)
		for i=0,3 do
			setActorX(_G['defaultStrum'..i..'X'] + 300 * math.sin((currentBeat + i*5) * math.pi)+ 360, i)
			setActorY(_G['defaultStrum'..i..'Y'],i)
		end
		for i=4,7 do	
			setActorX(_G['defaultStrum'..i..'X'] - 300 * math.sin((currentBeat + i*5) * math.pi)- 275, i)
			setActorY(_G['defaultStrum'..i..'Y'],i)
		end
	end
	if spinmaboi then
        if spinLength < 32 then
            spinLength = spinLength + 0.2
        end
	end
end

function keyPressed (key)
    if curStep >= 128 and curStep < 256
    or curStep >= 383 and curStep < 512 then 
        if key == 'left' then 
            left = not left 
            if left then 
                tweenPosXAngle(4, _G['defaultStrum4X'], getActorAngle(4), 0.05, i)
            else 
                tweenPosXAngle(4, _G['defaultStrum4X'] - 40, getActorAngle(4), 0.05, i)
            end
        end
        if key == 'down' then 
            down = not down 
            if down then 
                tweenPosYAngle(5, _G['defaultStrum5Y'], getActorAngle(5), 0.05, i)
            else
                tweenPosYAngle(5, _G['defaultStrum5Y'] + 40, getActorAngle(5), 0.05, i)
            end
        end
        if key == 'up' then 
            up = not up 
            if up then 
                tweenPosYAngle(6, _G['defaultStrum6Y'], getActorAngle(6), 0.05, i)
            else 
                tweenPosYAngle(6, _G['defaultStrum6Y'] - 40, getActorAngle(6), 0.05, i)
            end
        end
        if key == 'right' then 
            right = not right 
            if right then 
                tweenPosXAngle(7, _G['defaultStrum7X'], getActorAngle(7), 0.05, i)
            else 
                tweenPosXAngle(7, _G['defaultStrum7X'] + 40, getActorAngle(7), 0.05, i)
            end
        end
    end
end

function partyDone()
    partied = false 
end

function beatHit (beat)
	if camerabeat then
		setCamZoom(1)
	end
end

function stepHit (step)
    if curStep == 1 then
        showOnlyStrums = true
        strumLine2Visible = false
        strumLine1Visible = false
    end
end