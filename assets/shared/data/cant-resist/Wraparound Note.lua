function onUpdatePost(elapsed)
    for a = 0, getProperty('notes.length') - 1 do
        if getPropertyFromGroup('notes', a, 'noteType') == 'Wraparound Note' then
            setPropertyFromGroup('notes', a, 'multSpeed', getPropertyFromGroup('notes', a, 'multSpeed') - 0.010)
    end
end	
end

