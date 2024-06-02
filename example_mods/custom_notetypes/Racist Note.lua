function onUpdatePost()
    for i = 0, getProperty("notes.length") - 1 do
        if getPropertyFromGroup('notes', i, 'noteType') == 'Racist Note' then
            setPropertyFromGroup('notes', i, 'noAnimation', true)
        end
    end
end

local racistArray = {
    [0] = 'singLEFT',
    [1] = 'singDOWN',
    [2] = 'singUP',
    [3] = 'singRIGHT'
}
function opponentNoteHit(a,b,c,d)
    if c == 'Racist Note' then
        playAnim('dad', 'racist'..racistArray[b], true)
        triggerEvent("Alt Idle Animation", 'dad', 'racist')
    end
    if c == '' then
        triggerEvent("Alt Idle Animation", 'dad', '')
    end
end