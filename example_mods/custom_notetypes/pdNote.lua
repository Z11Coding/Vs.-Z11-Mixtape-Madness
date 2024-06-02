function onCreate()
	--Iterate over all notes
	for i = 0, getProperty('unspawnNotes.length')-1 do
		--Check if the note is an Instakill Note
		if getPropertyFromGroup('unspawnNotes', i, 'noteType') == 'pdNote' then
			setPropertyFromGroup('unspawnNotes', i, 'texture', 'Notes/PD'); --Change texture
			setPropertyFromGroup('unspawnNotes', i, 'hitHealth', '0.023'); --Default value is: 0.023, health gained on hit
			setPropertyFromGroup('unspawnNotes', i, 'missHealth', '0.0475'); --Default value is: 0.0475, health lost on miss
			setPropertyFromGroup('unspawnNotes', i, 'hitCausesMiss', false);
			setPropertyFromGroup('unspawnNotes', i, 'noteSplashHue', 0); --custom notesplash color, why not			
		end
	end
precacheImage('HUD/text')
end

local textD = 0
function goodNoteHit(direction, noteData, type, isSustainNote)
    if type == 'pdNote' then
	 dodgeAnimPlayR = getRandomInt(1,2)
	  if dodgeAnimPlayR == 1 then
        triggerEvent('Play Animation', 'dodge', 'bf')
	  elseif dodgeAnimPlayR == 2 then
        triggerEvent('Play Animation', 'duck', 'bf')
	  end 
	   textD = textD + 1
       makeAnimatedLuaSprite('dodgeTEXT'..textD, 'HUD/text', 875, 180)
       addAnimationByPrefix('dodgeTEXT'..textD, 'text', 'Dodge', 24, false)
       setObjectCamera('dodgeTEXT'..textD, 'camHUD')
       scaleObject('dodgeTEXT'..textD, 0.8, 0.8)
       setProperty('dodgeTEXT'..textD..'.alpha', 1)   
       addLuaSprite('dodgeTEXT'..textD, true) 	   
	end	  
end
textP = 0
function opponentNoteHit(id, direction, type, isSustainNote)
    if type == 'pdNote' then
      triggerEvent('Play Animation', 'parry', 'dad')  
	   textP = textP + 1
       makeAnimatedLuaSprite('parryTEXT'..textP, 'HUD/text', 175, 180)
       addAnimationByPrefix('parryTEXT'..textP, 'text', 'Parry', 24, false)
       setObjectCamera('parryTEXT'..textP, 'camHUD')
       scaleObject('parryTEXT'..textP, 0.8, 0.8)
       setProperty('parryTEXT'..textP..'.alpha', 1)   
       addLuaSprite('parryTEXT'..textP, true) 	  
	end	  
end
function onUpdate()
   if getProperty('parryTEXT'..textP..'.animation.curAnim.finished') and getProperty('parryTEXT'..textP..'.animation.curAnim.name') == 'text' then
      removeLuaSprite('parryTEXT'..textP, true)
   end
   if getProperty('dodgeTEXT'..textD..'.animation.curAnim.finished') and getProperty('dodgeTEXT'..textD..'.animation.curAnim.name') == 'text' then
      removeLuaSprite('dodgeTEXT'..textD, true)
   end   
end
