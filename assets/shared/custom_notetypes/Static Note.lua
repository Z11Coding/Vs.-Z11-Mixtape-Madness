function onCreate()
	--Iterate over all notes
	for i = 0, getProperty('unspawnNotes.length')-1 do
		if getPropertyFromGroup('unspawnNotes', i, 'noteType') == 'Static Note' then
			setPropertyFromGroup('unspawnNotes', i, 'texture', 'noteskins/STATICNOTE_assets'); 
			if getPropertyFromGroup('unspawnNotes', i, 'mustPress') then --Doesn't let Dad/Opponent notes get ignored
				setPropertyFromGroup('unspawnNotes', i, 'ignoreNote', false); --Miss has penalties
				makeAnimatedLuaSprite('hitstatic', 'mechanics/personel/exe/hitStatic', -380, -90);
				addAnimationByPrefix('hitstatic', 'static', 'staticANIMATION', 24, true);
				setObjectCamera('hitstatic', 'camHUD')
				setProperty('hitstatic.alpha', 0)
				scaleObject('hitstatic', 3, 3);
				addLuaSprite('hitstatic', true);
			end
		end
	end
end

function noteMiss(id, direction, noteType, isSustainNote)
	if noteType == 'Static Note' then
		runTimer('HitStatic', 0.01);
		playSound('hitStatic1', 0.5);
		characterPlayAnim('boyfriend', 'hurt', true);
		runTimer('StaticRemove2', 0.5);
	elseif noteType == 'Static Note' then
		characterPlayAnim('boyfriend', 'hurt', true);
	end
end

function onTimerCompleted(tag, loops, loopsLeft)
	-- A loop from a timer you called has been completed, value "tag" is it's tag
	-- loops = how many loops it will have done when it ends completely
	-- loopsLeft = how many are remaining
	if loopsLeft >= 1 then
		setProperty('health', getProperty('health')-0.000);
	end
		
	if tag == 'StaticRemove2' then
		setProperty('hitstatic.alpha', 0)
	end

	if tag == 'HitStatic' then
		setProperty('hitstatic.alpha', 0.85)
	end
end
