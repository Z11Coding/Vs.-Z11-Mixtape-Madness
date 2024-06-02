local switchBool = false
local buttonOffsetX = 0
local offsetX = -50

function onCreate()
    makeLuaText('debug', 'SaveState 1 Loaded', 500, 0, 0)
    setTextSize("debug", 50)
    screenCenter("debug", 'xy')
    addLuaText('debug')
end

function onSongStart()
    doTweenAlpha('fade', 'debug', 0, 1, 'sineOut')
end

function onStepHit()
    if curStep == 336 then
        setTextString("debug", "SaveState 2 Saved")
        setProperty('debug.alpha', 1)
        doTweenAlpha('fade', 'debug', 0, 1, 'sineOut')
    end
    if curStep == 350 then
        triggerEvent("loadSave", 2)
    end
    if curStep == 366 then
        triggerEvent("loadSave", 1)
    end 
    if curStep == 464 then
        setTextString("debug", "SaveState 2 Saved")
        setProperty('debug.alpha', 1)
        doTweenAlpha('fade', 'debug', 0, 1, 'sineOut')
    end
    if curStep == 480 then
        triggerEvent("loadSave", 2)
    end
    if curStep == 496 then
        triggerEvent("loadSave", 1)
    end
    if curStep == 600 then
        setTextString("debug", "SaveState 2 Saved")
        setProperty('debug.alpha', 1)
        doTweenAlpha('fade', 'debug', 0, 1, 'sineOut')
    end
    if curStep == 608 then
        triggerEvent("loadSave", 2)
    end
    if curStep == 616 then
        triggerEvent("loadSave", 1)
    end
    if curStep == 624 then
        triggerEvent("loadSave", 2)
    end
    if curStep == 632 then
        triggerEvent("loadSave", 1)
    end
    if curStep == 728 then
        triggerEvent("loadSave", 2)
    end
    if curStep == 736 then
        triggerEvent("loadSave", 1)
    end
    if curStep == 744 then
        triggerEvent("loadSave", 2)
    end
    if curStep == 752 then
        triggerEvent("loadSave", 1)
    end
    if curStep == 760 then
        triggerEvent("loadSave", 2)
    end
end

function onCreatePost()
	makeAnimatedLuaSprite('button','buttonPress', 30 , (downscroll and 420 or 70))
	addAnimationByPrefix('button', 'redpress', 'button redANIM', 30, false)
	addAnimationByPrefix('button', 'bluepress', 'button blueANIM', 30, false)
	objectPlayAnimation('button','bluepress')
	setObjectCamera('button','hud')
	scaleObject('button',0.85,0.85)
	if not middlescroll then
		screenCenter('button','x')
	end
	--addLuaSprite('button')

	makeLuaText('spacebur','Press Spacebar to switch between these note colors!', 0, 0)
	setProperty('spacebur.alpha', 0.6)
	screenCenter('spacebur')
	addLuaText('spacebur')

	buttonOffsetX = getProperty('button.offset.x')
	setProperty('button.offset.x', buttonOffsetX + offsetX)

	for i = 0, getProperty('unspawnNotes.length')-1 do
		if getPropertyFromGroup('unspawnNotes', i, 'noteType') == 'State1' then
            if not switchBool then 
                setPropertyFromGroup('unspawnNotes', i, 'multAlpha', 0); 
            else 
                setPropertyFromGroup('unspawnNotes', i, 'multAlpha', 1); 
            end
		end
		if getPropertyFromGroup('unspawnNotes', i, 'noteType') == 'State2' then
			if switchBool then 
                setPropertyFromGroup('unspawnNotes', i, 'multAlpha', 0); 
            else 
                setPropertyFromGroup('unspawnNotes', i, 'multAlpha', 1); 
            end
		end
	end
end

function noteSwitch(numbar)
for i = 0, getProperty('notes.length') - 1 do
	if getPropertyFromGroup('notes', i, 'noteType') == 'State1' and numbar == 2 then
		setPropertyFromGroup('notes', i, 'canBeHit', false)
		setPropertyFromGroup('notes', i, 'hitCausesMiss', true)
		setPropertyFromGroup('notes', i, 'multAlpha', 0);
	elseif getPropertyFromGroup('notes', i, 'noteType') == 'State2' and numbar == 2 then
		setPropertyFromGroup('notes', i, 'canBeHit', true)
		setPropertyFromGroup('notes', i, 'hitCausesMiss', false)
		setPropertyFromGroup('notes', i, 'multAlpha', 1);
	end

	if getPropertyFromGroup('notes', i, 'noteType') == 'State2' and numbar == 1 then
		setPropertyFromGroup('notes', i, 'canBeHit', false)
		setPropertyFromGroup('notes', i, 'hitCausesMiss', true)
		setPropertyFromGroup('notes', i, 'multAlpha', 0);
	elseif getPropertyFromGroup('notes', i, 'noteType') == 'State1' and numbar == 1 then
		setPropertyFromGroup('notes', i, 'canBeHit', true)
		setPropertyFromGroup('notes', i, 'hitCausesMiss', false)
		setPropertyFromGroup('notes', i, 'multAlpha', 1);
	end

end
end

function onEvent(eventName, value1, value2)
    if eventName == 'loadSave' then
        if value1 == '1' then
            setTextString("debug", "SaveState 1 Loaded")
            setProperty('debug.alpha', 1)
            doTweenAlpha('fade', 'debug', 0, 1, 'sineOut')
            noteSwitch(1)
            switchBool = false
        end
        if value1 == '2' then
            setTextString("debug", "SaveState 2 Loaded")
            setProperty('debug.alpha', 1)
            doTweenAlpha('fade', 'debug', 0, 1, 'sineOut')
            noteSwitch(2)
            switchBool = true
        end
    end
end


timer = 4
function onUpdatePost(elapsed)
	if timer >= 0 then
		timer = timer - elapsed
	else
		doTweenAlpha('twin','spacebur', 0, 0.2)
	end

	if switchBool then	
        objectPlayAnimation('button','redpress')
        setProperty('button.offset.x', 132 + offsetX)
    else
        objectPlayAnimation('button','bluepress')
        setProperty('button.offset.x', buttonOffsetX + offsetX)
    end
end