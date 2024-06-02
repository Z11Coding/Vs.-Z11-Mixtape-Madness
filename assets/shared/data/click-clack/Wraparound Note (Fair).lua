function onUpdatePost(elapsed)
    for a = 0, getProperty('notes.length') - 1 do
        if getPropertyFromGroup('notes', a, 'noteType') == 'Wraparound Note (Fair)' then
setPropertyFromGroup('notes', a, 'multSpeed', math.max(getPropertyFromGroup('notes', a, 'multSpeed') - 0.010, -1))

    end
end	
end

