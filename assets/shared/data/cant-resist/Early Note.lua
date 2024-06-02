function onSpawnNote(id, noteData, noteType, isSustainNote)
	for i = id,id do
      local strumTime = getPropertyFromGroup('unspawnNotes', a, 'strumTime');
      local noteData = getPropertyFromGroup('unspawnNotes', a, 'noteData');
      if getPropertyFromGroup('unspawnNotes', a, 'noteType') == 'Early Note' then
         setPropertyFromGroup("unspawnNotes", a, "offsetY", -700)
         setPropertyFromGroup("unspawnNotes", a, "multAlpha", 0.1)
         if getPropertyFromGroup("unspawnNotes", a, "isSustainNote") then 
            setPropertyFromGroup("unspawnNotes", a, "offsetY", -700 + 10)
            setPropertyFromGroup("unspawnNotes", a, "multAlpha", 0.05)
         end
      end
   end
end
   
--subscribe to An Ammar at YT
--subscribe to An Ammar at YT

function onUpdatePost(elapsed)
   for a = 0, getProperty('notes.length') - 1 do
      local strumTime = getPropertyFromGroup('notes', a, 'strumTime');
      local noteData = getPropertyFromGroup('notes', a, 'noteData');
      local sus = getPropertyFromGroup('notes', a, 'isSustainNote');
      if getPropertyFromGroup('notes', a, 'noteType') == 'Early Note' then

         
         if (strumTime - getSongPosition()) < 1600 / scrollSpeed then
            setPropertyFromGroup("notes", a, "offsetY", lerp(getPropertyFromGroup("notes", a, "offsetY"), 0 , elapsed * (3 * scrollSpeed)))
            setPropertyFromGroup("notes", a, "multAlpha", lerp(getPropertyFromGroup("notes", a, "multAlpha"), (sus and 0.6 or 1) , elapsed * (8 * scrollSpeed)))
         end

      end
   end
end

function lerp(a, b, t)
   return a + (b - a) * t
end