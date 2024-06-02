function onCreatePost()
    for i = 0, getProperty('unspawnNotes.length')-1 do
        if getPropertyFromGroup('unspawnNotes', i, 'noteType') == 'jealousyNote' then
            setPropertyFromGroup("unspawnNotes", i, 'rgbShader.r', 0xFF2BFAFA)
            setPropertyFromGroup("unspawnNotes", i, 'rgbShader.b', 0xFF3BA3BC)
            setPropertyFromGroup("unspawnNotes", i, 'rgbShader.g', 0xFF00A2D3)
            setPropertyFromGroup("unspawnNotes", i, 'ignoreNote', true)
            setPropertyFromGroup("unspawnNotes", i, 'hitCausesMiss', true)
            setPropertyFromGroup("unspawnNotes", i, 'lowPriority', true)
        end
    end
end

missArray = {'singLEFTmiss', 'singDOWNmiss', 'singUPmiss', 'singRIGHTmiss'}
dodgeArray = {'dodgeLEFT', 'dodgeDOWN', 'dodgeUP', 'dodgeRIGHT'}

function goodNoteHit(index, noteDir, noteType, isSustainNote)
    if noteType == 'jealousyNote' then
        setHealth(getHealth() - 0.05)
        playAnim('boyfriend', missArray[getRandomInt(0, 3)], true)
    end
end

function noteMiss(index, noteDir, noteType, isSustainNote)
    if noteType == 'jealousyNote' then
        playAnim('boyfriend', dodgeArray[getRandomInt(0, 3)], true)
    end
end