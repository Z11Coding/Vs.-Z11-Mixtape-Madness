local allowCountdown = false
-- Dialogue (When a dialogue is finished, it calls startCountdown again)
local Selected = 0
function onNextDialogue(count) --dumbass character selection screen
	-- triggered when the next dialogue line starts, 'line' starts with 1
	if keyPressed('right') then --Selects GF
		Selected = 1
	elseif keyPressed('left') then --Selects Pico
		Selected = 2
	end
end

function onSkipDialogue(count)
	-- triggered when you press Enter and skip a dialogue line that was still being typed, dialogue line starts with 1
end

function onUpdate()
	if Selected == 1 then
		setProperty('RPGState.answer', 'song');
	elseif Selected == 2 then
		setProperty('RPGState.answer', 'questions');
	end
end