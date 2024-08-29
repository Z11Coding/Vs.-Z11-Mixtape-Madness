function onUpdatePost()
    for i = 0, getProperty("notes.length")-1 do
        if getPropertyFromGroup('notes', i, 'noteType') == 'Bat Note' then
            setPropertyFromGroup("notes", i, 'texture', 'noteskins/BATNOTE')
	    setPropertyFromGroup("notes", i, 'noteSplashData.disabled', true)
	    setPropertyFromGroup("notes", i, 'ratingDisabled', true)
	    setPropertyFromGroup("notes", i, 'noMissAnimation', true)
        end
    end
end

function goodNoteHit(a,b,c)
    if c == 'Bat Note' then
        playAnim("boyfriend", "attack", true)
        playAnim("dad", "singLEFT-alt", true)
	setProperty('boyfriend.specialAnim', true)
    end
end

function noteMiss(a,b,c)
    if c == 'Bat Note' then
        playAnim("boyfriend", "attack", true)
        playAnim("dad", "singDOWN-alt", true)
	setProperty('boyfriend.specialAnim', true)
    end
end