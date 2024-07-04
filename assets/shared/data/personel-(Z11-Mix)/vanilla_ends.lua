function onUpdate(elapsed)
	for i = 0, getProperty('notes.length') - 1 do
		sus = getPropertyFromGroup('notes', i, 'isSustainNote');
		susEnd = getPropertyFromGroup('notes', i, 'animation.curAnim.name'):find('holdend');
		if stringStartsWith(version, '0.7') then
		   versionCompatible = "states."
		else
		   versionCompatible = ""
		end
		if sus and susEnd and not getPropertyFromClass(versionCompatible..'PlayState', 'isPixelStage') then
		setPropertyFromGroup('notes', i, 'scale.y', 0.7);
		setPropertyFromGroup('notes', i, 'offset.y', downscroll and -10 or 10);
	end
    end
end