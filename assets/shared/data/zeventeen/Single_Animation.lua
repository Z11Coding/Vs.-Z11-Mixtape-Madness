function onCreatePost()
	--luaDebugMode = true;
	
	for i = 0, getProperty("unspawnNotes.length")-1 do
		if getPropertyFromGroup('unspawnNotes', i, 'isSustainNote') then
			setPropertyFromGroup('unspawnNotes', i, 'noAnimation', true);
		end
	end
end

function goodNoteHit(i, d, t, s)
	if not s then
		callMethod('playerStrums.members['..d..'].playAnim', {'static', true});
		callMethod('playerStrums.members['..d..'].playAnim', {'confirm'});
		--callMethod('opponentStrums.members['..i..'].playAnim', {'static'})

		--playAnim("playerStrums.members["..math.abs(i).."]", 'static', true);
        --playAnim("playerStrums.members["..math.abs(i).."]", 'confirm');
    end
    
	if s then
		setProperty('boyfriend.holdTimer', 0);
		--debugPrint('hi');
		if getProperty("playerStrums.animation.curAnim") == nil and "" or getProperty("playerStrums.animation.curAnim.name") == "static" then
			--callMethod('playerStrums.members['..d..'].playAnim', {'confirm'})
			--debugPrint("hshshs");
			setProperty('playerStrums.members['..d..'].animation.curAnim.curFrame', 3);
		end
		
		if(stringStartsWith(getAnimationName("boyfriend"), "sing")) then
			--remove '--' if you want the animation play again once its done		
			--playAnim("boyfriend", getAnimationName("boyfriend"));
			return;
		end
	end
end

function opponentNoteHit(i, d, t, s)
	if not s then
		callMethod('opponentStrums.members['..d..'].playAnim', {'static', true});
		callMethod('opponentStrums.members['..d..'].playAnim', {'confirm'});
		--callMethod('opponentStrums.members['..i..'].playAnim', {'static'})

		--playAnim("playerStrums.members["..math.abs(i).."]", 'static', true);
        --playAnim("playerStrums.members["..math.abs(i).."]", 'confirm');
    end
    
	if s then
		setProperty('dad.holdTimer', 0);
		--debugPrint('hi');
		if getProperty("opponentStrums.animation.curAnim") == nil and "" or getProperty("opponentStrums.animation.curAnim.name") == "static" then
			--callMethod('playerStrums.members['..d..'].playAnim', {'confirm'})
			--debugPrint("hshshs");
			setProperty('opponentStrums.members['..d..'].animation.curAnim.curFrame', 3);
		end
		
		if(stringStartsWith(getAnimationName("dad"), "sing")) then
			--remove '--' if you want the animation play again once its done		
			--playAnim("dad", getAnimationName("dad"));
			return;
		end
	end
end

function getAnimationName(char)
	 return getProperty(char .. ".animation.curAnim") == nil and "" or getProperty(char ..".animation.curAnim.name");
end

function getStrumAnimationName()
	return getProperty("playerStrums.animation.curAnim") == nil and "" or getProperty("playerStrums.animation.curAnim.name");
end