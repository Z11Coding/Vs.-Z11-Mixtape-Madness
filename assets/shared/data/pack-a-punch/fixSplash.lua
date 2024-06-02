function goodNoteHit(id,data,type,sus)
    if getPropertyFromGroup('notes',id,'rating') == 'sick' then
        for splash = 0,getProperty('grpNoteSplashes.length') do
            setPropertyFromGroup('grpNoteSplashes',splash,'scale.x',1.2)
            setPropertyFromGroup('grpNoteSplashes',splash,'scale.y',1.2)
            setPropertyFromGroup('grpNoteSplashes',splash,'offset.x',-70)
            setPropertyFromGroup('grpNoteSplashes',splash,'offset.y',-70)
            setPropertyFromGroup('grpNoteSplashes',splash,'alpha',getPropertyFromGroup('grpNoteSplashes',splash,'alpha') + 0.1)
            --updateHitboxFromGroup('grpNoteSplashes',splash)
        end
    end
end