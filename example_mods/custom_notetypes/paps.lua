function onUpdatePost()
    for i = 0, getProperty('notes.length') - 1 do
        if getPropertyFromGroup('notes', i, 'noteType') == 'paps' then
            setPropertyFromGroup('notes', i, 'noAnimation', true)
        end
        if getPropertyFromGroup('notes', i, 'noteType') == 'Chara' then
            setPropertyFromGroup('notes', i, 'noAnimation', true)
        end
    end
end