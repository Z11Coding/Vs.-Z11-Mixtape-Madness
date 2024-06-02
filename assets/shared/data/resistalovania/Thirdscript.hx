function onStrumLaneCreation(laneTag:String) {
	if (laneTag == 'Z11') {
		for (i in 0...4) {
			var strumLane = getVar(laneTag + 'Strums');
			strumLane.members[i].y = playerStrums.members[i].y - 100 * (ClientPrefs.data.downScroll ? 1 : -1);
			strumLane.members[i].alpha = 0;
			strumLane.members[i].x += -230 + (FlxG.width / 11) * (strumLane.members[i].noteData);
		}
	}
}