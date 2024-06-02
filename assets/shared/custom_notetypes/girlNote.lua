function onUpdatePost(elapsed)
    for i = 0, getProperty('notes.length') - 1 do
        if getPropertyFromGroup('notes', i, 'noteType') == "girlNote" then
            setPropertyFromGroup('notes', i, 'noAnimation', true)
        end
    end
end