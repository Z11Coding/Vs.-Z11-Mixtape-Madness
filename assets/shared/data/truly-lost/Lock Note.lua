function onCreate()
	--Iterate over all notes
	for i = 0, getProperty('unspawnNotes.length')-1 do
		--Check if the note is an Instakill Note
		if getPropertyFromGroup('unspawnNotes', i, 'noteType') == 'Lock Note' then
			setPropertyFromGroup('unspawnNotes', i, 'hitCausesMiss', true); --Change texture
			setPropertyFromGroup('unspawnNotes', i, 'ignoreNote', true); --Change texture
			setPropertyFromGroup('unspawnNotes', i, 'colorSwap.hue', 0.2); --Change texture
		end
	end
end

local locked = 4
function noteMiss(id, direction, noteType, isSustainNote)
    if noteType == 'Lock Note' then
        locked = direction
		runTimer('UL', stepCrochet / 31, 1)
		--debugPrint("Locked.")
		runTimer('FR', 0.01, 1)
    end
end

function onUpdatePost(elapsed)
    for a = 0, getProperty('notes.length') - 1 do
        noteData = getPropertyFromGroup('notes', a, 'noteData')
		noteType = getPropertyFromGroup('notes', a, 'noteType')
        if noteData == locked then
            setPropertyFromGroup('notes', a, 'canBeHit', false)
            setPropertyFromGroup('notes', a, 'colorSwap.hue', 0.5)
		else
			if noteType ~= 'Lock Note' then
				setPropertyFromGroup('notes', a, 'colorSwap.hue', 1)
				setPropertyFromGroup('notes', a, 'hitCausesMiss', false)
			end
        end
    end
	if freezed then
		setPropertyFromGroup('playerStrums', locked, 'colorSwap.brightness', getPropertyFromGroup('playerStrums', locked, 'colorSwap.brightness') - 1)
	else
		setPropertyFromGroup('playerStrums', locked, 'colorSwap.brightness', getPropertyFromGroup('playerStrums', locked, 'colorSwap.brightness'))
	end
end

function onTimerCompleted(tag, loops, loopsLeft)
	if tag == 'UL' then
		locked = 4
		--debugPrint("Unlocked!")
		freezed = false
	elseif tag == 'FR' then
		freezed = true
	end
end