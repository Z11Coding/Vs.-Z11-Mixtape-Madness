function onCreatePost()
    for i = 0, getProperty('unspawnNotes.length')-1 do
        setPropertyFromGroup('unspawnNotes', i, 'noAnimation', true);
    end
end
function onBeatHit()
triggerEvent('Camera Follow Pos', 720, 525)
end