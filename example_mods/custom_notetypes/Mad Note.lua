function onUpdatePost()
    for i = 0, getProperty("notes.length") - 1 do
        if getPropertyFromGroup('notes', i, 'noteType') == 'Mad Note' then
            setPropertyFromGroup('notes', i, 'noAnimation', true)
        end
    end
end

local madArray = {
    [0] = 'singLEFT',
    [1] = 'singDOWN',
    [2] = 'singUP',
    [3] = 'singRIGHT'
}
function opponentNoteHit(a,b,c,d)
    if c == 'Mad Note' then
        playAnim('dad', 'mad'..madArray[b], true)
        triggerEvent("Alt Idle Animation", 'dad', 'mad')
    end
    if c == '' then
        triggerEvent("Alt Idle Animation", 'dad', '')
    end
end