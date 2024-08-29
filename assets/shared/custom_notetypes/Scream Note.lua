function onUpdatePost()
    for i = 0, getProperty("notes.length")-1 do
        if getPropertyFromGroup('notes', i, 'noteType') == 'Scream Note' then
            setPropertyFromGroup("notes", i, 'texture', 'noteskins/SCREAMNOTE')
        end
    end
end

function goodNoteHit(a,b,c)
    if c == 'Scream Note' then
        if a == 0 then
            playAnim("dad", "singLEFT-alt", true)
        end
        if a == 1 then
            playAnim("dad", "singLEFT-alt", true)
        end
        if a == 2 then
            playAnim("dad", "singRIGHT-alt", true)
        end
        if a == 3 then
            playAnim("dad", "singRIGHT-alt", true)
        end
    end
end

function noteMiss(a,b,c)
    if c == 'Scream Note' then
        if a == 0 then
            playAnim("dad", "singLEFT-alt", true)
        end
        if a == 1 then
            playAnim("dad", "singLEFT-alt", true)
        end
        if a == 2 then
            playAnim("dad", "singRIGHT-alt", true)
        end
        if a == 3 then
            playAnim("dad", "singRIGHT-alt", true)
        end
    end
end