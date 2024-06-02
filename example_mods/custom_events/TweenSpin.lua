function onEvent(name, value1, value2)
	-- bf notespin
	noteTweenAngle('A',4 , value2 , value1, linear);
	noteTweenAngle('B',5 , value2 , value1, linear);
	noteTweenAngle('C',6 , value2 , value1, linear);
	noteTweenAngle('D',7 , value2 , value1, linear);
	
	-- oppt notespin
	noteTweenAngle('E',0 , value2 , value1, linear);
	noteTweenAngle('F',1 , value2 , value1, linear);
	noteTweenAngle('G',2 , value2 , value1, linear);
	noteTweenAngle('H',3 , value2 , value1, linear);
	
	
end

function onEvent(name, value1, value2)
	songPos = getSongPosition()
	local currentBeat = (songPos/3000)*(curBpm/20)
			function onUpdate(elapsed)
					noteTweenY('a', 4, defaultPlayerStrumY0 - value1*math.sin((currentBeat+4*0.25)*math.pi), 0.6)
					noteTweenY('b', 5, defaultPlayerStrumY1 - value1*math.sin((currentBeat+5*0.25)*math.pi), 0.6)
					noteTweenY('c', 6, defaultPlayerStrumY2 - value1*math.sin((currentBeat+6*0.25)*math.pi), 0.6)
					noteTweenY('d', 7, defaultPlayerStrumY3 - value1*math.sin((currentBeat+7*0.25)*math.pi), 0.6)
	
					noteTweenY('e', 0, defaultOpponentStrumY0 + value2*math.sin((currentBeat+4*0.25)*math.pi), 0.6)
					noteTweenY('f', 1, defaultOpponentStrumY1 + value2*math.sin((currentBeat+5*0.25)*math.pi), 0.6)
					noteTweenY('g', 2, defaultOpponentStrumY2 + value2*math.sin((currentBeat+6*0.25)*math.pi), 0.6)
					noteTweenY('h', 3, defaultOpponentStrumY3 + value2*math.sin((currentBeat+7*0.25)*math.pi), 0.6)
			end
	end