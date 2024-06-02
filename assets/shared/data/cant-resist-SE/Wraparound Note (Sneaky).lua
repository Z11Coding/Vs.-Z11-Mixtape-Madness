function onUpdatePost(elapsed)
    for a = 0, getProperty('notes.length') - 1 do
        if getPropertyFromGroup('notes', a, 'noteType') == 'Wraparound Note (Sneaky)' then
setPropertyFromGroup('notes', a, 'multSpeed', math.max(getPropertyFromGroup('notes', a, 'multSpeed') - 100, -0.3))

    end
end	
end

