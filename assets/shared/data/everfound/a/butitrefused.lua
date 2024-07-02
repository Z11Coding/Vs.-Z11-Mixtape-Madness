--Script By Villagecool
--Idk who made the fake pause thingy, but thanks
local canDie = true
function onGameOver()
    if canDie then
        openCustomSubstate('temp', true)
    end
    return Function_Stop
end
local fakePaused = false
local randMessage = 0
function fakeGameOver()
    randMessage = math.random(0, 4)
    fakePaused = true
    canDie = false
	makeLuaSprite('funniblackbg', '', 0, 0)
	makeGraphic('funniblackbg', 1280, 720, '000000')
    scaleObject('funniblackbg', 10,10)
	addLuaSprite('funniblackbg', false)
    screenCenter('funniblackbg')

	makeLuaText('refTxt', '', 0, 10, 355)
	setObjectCamera('refTxt', 'camOther')
	setTextSize('refTxt', 50)
	addLuaText('refTxt', true)

    dadWasVisible = getProperty('dad.visible')
    gfWasVisible = getProperty('gf.visible')
    setProperty('dad.visible',false)
    setProperty('gf.visible',false)
    setProperty('camHUD.visible',false)
    triggerEvent('Change Character', 'bf', 'bf-undead')
    runTimer('playanim',0.1)
end
message = {
    [0] = {'b','u','t',' ','i','t',' ','r','e','f','u','s','e','d'},
    [1] = {'n','o','t',' ','y','e','t','!',' ',' ',' ',' ',' ',' '},
    [2] = {'d','o','n','\'','t',' ','g','i','v','e',' ','u','p','!'},
    [3] = {'t','r','y',' ','a','g','a','i','n',',',' ','B','F','!'},
    [4] = {'n','o','t',' ','y','o','u','r',' ','f','a','u','l','t'},
}
messageAlt = {
    [0] = {'fight back!'},
    [1] = {'not yet!'},
    [2] = {'don\'t give up!'},
    [3] = {'keep going, BF!'},
    [4] = {'It\'s that thing\'s fault!'},
    [5] = {'Don\'t Stop Now!'},
    [6] = {'Don\'t Die Yet!'},
    [7] = {'Get Your Revenge!'},
    [8] = {'Set Me Free!'},
    [9] = {'Set Us Free!'},
    [10] = {'I Belive In You!'},
}
local curLetter = 1
function onTimerCompleted(t)
    if t == 'playanim' then
        curLetter = 1
        playSound('fnf_loss_sfx',1)
        playAnim('bfundies', 'firstDeath', true)
        runTimer('playnextanim',3)
        runTimer('playnextsound',1.5)
    end
    if t == 'playnextsound' then
        playSound('fnf_unloss_sfx',1)
    end
    if t == 'playnextanim' then
        runTimer('enterText',0.1,15)
        playAnim('bfundies', 'lastDeath', true)
        runTimer('finish',2.5)
    end
    if t == 'finish' then
        setProperty('health',1)
        setProperty('camHUD.visible',true)
        setProperty('dad.visible',dadWasVisible)
        setProperty('gf.visible',gfWasVisible)
        setProperty('boyfriend.visible',bfWasVisible)
        removeLuaSprite('bfundies', true)
        fakePaused = false
        runTimer('deathTrue',0.1)
        removeLuaSprite('funniblackbg',false)
        removeLuaText('refTxt',false)
        setProperty('ready.visible', true)
        setProperty('ready.alpha', 1)
        setTextString('ready', 'Ready?')
    end
    if t == 'end' then
        closeCustomSubstate()
    end
    if t == 'enterText' then
        setTextString('refTxt', getTextString('refTxt')..message[randMessage][curLetter])
        curLetter = curLetter+1
        playSound('Dialost', 1)
    end
    if t == 'deathTrue' then
        canDie = true
    end
end
function onPause()
    randMessageAlt = math.random(0, 10)
    setTextString('ready', messageAlt[randMessageAlt])
    setProperty('ready.visible', true)
    setProperty('ready.alpha', 1)
    doTweenAlpha("imready", "ready", 0, 1, "sineInOut")
    return Function_Stop
end
function onUpdate(elapsed)
    screenCenter('ready')
    setProperty('ready.y',getProperty('ready.y')-200)
    if getProperty('chartingMode') then
        lockUp = false
    else
        lockUp = true
    end
    if getProperty('ready.alpha') == 0 then
        setProperty('ready.visible', false)
        setProperty('ready.alpha', 1)
    end
end

function onCustomSubstateUpdate(temp, e)
    if temp == 'temp' then
        if fakePaused == true then
            --setTextString('refTxt', getTextString('refTxt')..message[curLetter])
            screenCenter('refTxt')
            setProperty('refTxt.y',getProperty('refTxt.y')-200)
            screenCenter('ready')
            setProperty('ready.y',getProperty('ready.y')-200)
            --cameraSetTarget('boyfriend')
            setProperty('funniblackbg.visible', true)
        elseif fakePaused == false then
            setProperty('funniblackbg.visible', false)
        end
        if fakePaused == false then
            if keyboardJustPressed("ENTER") then
                runTimer('end', 1)
                doTweenAlpha("imready", "ready", 0, 1, "sineInOut")
            end
        end
    end
end

function onCustomSubstateCreate(n)
    if n == 'temp' then
        randMessage = math.random(0, 4)
        fakePaused = true
        canDie = false
        makeLuaSprite('funniblackbg', '', 0, 0)
        makeGraphic('funniblackbg', 1280, 720, '000000')
        scaleObject('funniblackbg', 10,10)
        --addLuaSprite('funniblackbg', false)
        screenCenter('funniblackbg')
        --insertToCustomSubstate("funniblackbg", -1)

        makeLuaText('refTxt', '', 0, 10, 355)
        setObjectCamera('refTxt', 'camOther')
        setTextSize('refTxt', 50)
        addLuaText('refTxt')
        screenCenter('refTxt')
        --insertToCustomSubstate("refTxt", 10)

        makeAnimatedLuaSprite("bfundies", 'characters/BOYFRIEND_DEAD', getProperty('boyfriendGroup.x'), getProperty('boyfriendGroup.y'))
        addAnimationByPrefix("bfundies", "firstDeath", "BF dies", 24, false)
        addAnimationByPrefix("bfundies", "lastDeath", "BF undies", 24, false)
        screenCenter('bfundies')
        --addLuaSprite('bfundies')
        setProperty('bfundies.x', getProperty('bfundies.x') + 70)
        setProperty('bfundies.y', getProperty('bfundies.y') + 90)
        insertToCustomSubstate("bfundies", 1)

        dadWasVisible = getProperty('dad.visible')
        gfWasVisible = getProperty('gf.visible')
        bfWasVisible = getProperty('boyfriend.visible')
        setProperty('dad.visible',false)
        setProperty('gf.visible',false)
        setProperty('boyfriend.visible',false)
        setProperty('camHUD.visible',false)
        runTimer('playanim',0.1)
    end
end

function onCreatePost()
    makeLuaText('ready', 'ready?', 0, 10, 355)
    setObjectCamera('ready', 'camOther')
	setTextSize('ready', 50)
	addLuaText('ready', true)
    setProperty('ready.visible', false)
end