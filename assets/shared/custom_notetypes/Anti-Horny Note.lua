function onUpdatePost()
    for i = 0, getProperty("notes.length")-1 do
        if getPropertyFromGroup('notes', i, 'noteType') == 'Anti-Horny Note' then
            setPropertyFromGroup("notes", i, 'texture', 'ANTIHORNYNOTE')
            setPropertyFromGroup("notes", i, 'noteSplashData.disabled', true)
            setPropertyFromGroup("notes", i, 'ratingDisabled', true)
            setPropertyFromGroup("notes", i, 'noMissAnimation', true)
        end
    end
end

function goodNoteHit(a,b,c)
    if c == 'Anti-Horny Note' then
        playAnim("boyfriend", "attack", true)
        playAnim("dad", "singLEFT-alt", true)
    end
end

function noteMiss(a,b,c)
    if c == 'Anti-Horny Note' then
        playAnim("boyfriend", "attack", true)
        playAnim("dad", "singDOWN-alt", true)
    end
end