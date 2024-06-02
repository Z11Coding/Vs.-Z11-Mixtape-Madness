local hits = 0
function onCreate()
	for i = 0, getProperty('unspawnNotes.length')-1 do
		if getPropertyFromGroup('unspawnNotes', i, 'noteType') == 'Pain Note' then
			setPropertyFromGroup('unspawnNotes', i, 'color', getColorFromHex('000000'));
						if getPropertyFromGroup('unspawnNotes', i, 'mustPress') then --Doesn't let Dad/Opponent notes get ignored
				setPropertyFromGroup('unspawnNotes', i, 'ignoreNote', true); --Miss has no penalties
				end
				end
			end
		end

				
function goodNoteHit(id, noteData, noteType, isSustainNote)
if noteType == 'Pain Note' then
playAnim('boyfriend', 'hurt', true)
hit = true
math.randomseed(os.time())
effect = math.random(0,1)
alwaysScared = math.random(0,1)
if effect == 1 then
triggerEvent('Change Scroll Speed', '-1', '8')

	end
	end

function onCreatePost()
end

			



function onUpdate()
if hit then
if alwaysScared == 1 then
		playAnim('boyfriend', 'scared', false)
		end
hurtRate = 0
        setProperty('playbackRate', getProperty('playbackRate') - 0.001)
		end
		if getProperty('playbackRate') == 0 or getProperty('playbackRate') < 0 then
		setProperty('health', getProperty('health') - 0.001 + hurtRate)
		hurtRate = hurtRate + 0.001
		playAnim('boyfriend', 'scared', false)
		end
end
end
			
			