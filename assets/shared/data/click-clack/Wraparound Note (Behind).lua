function onUpdatePost(elapsed)
    for a = 0, getProperty('notes.length') - 1 do
        if getPropertyFromGroup('notes', a, 'noteType') == 'Wraparound Note (Behind)' then
setPropertyFromGroup('notes', a, 'multSpeed', math.max(getPropertyFromGroup('notes', a, 'multSpeed') - 0.010, -0.2))

    end
end	
end

