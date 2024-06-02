function onCreate()
	--Iterate over all notes
	for i = 0, getProperty('unspawnNotes.length')-1 do
		--Check if the note is an Instakill Note
		if getPropertyFromGroup('unspawnNotes', i, 'noteType') == 'haloNote' then
			setPropertyFromGroup('unspawnNotes', i, 'texture', 'Notes/ALL_deathnotes'); --Change texture
			setPropertyFromGroup('unspawnNotes', i, 'hitHealth', '-7567554');
			setPropertyFromGroup('unspawnNotes', i, 'missHealth', '0'); --Default value is: 0.0475, health lost on miss
			setPropertyFromGroup('unspawnNotes', i, 'hitCausesMiss', true);
			setPropertyFromGroup('unspawnNotes', i, 'noteSplashHue', 0); --custom notesplash color, why not			
		end
	end
end

function goodNoteHit(direction, noteData, type, isSustainNote)
    if type == 'haloNote' then
	  setProperty('health', -414451)
	end 
end