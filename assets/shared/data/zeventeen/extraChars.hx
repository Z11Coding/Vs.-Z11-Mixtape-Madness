import objects.Character;
import haxe.ds.StringMap;
import Std;

/*typedef PackingInfo = {
	var name:String;
	var self:Character;
	//var cache:StringMap<Character>;
	var noteTypes:Array<Dynamic>;
	var killSelf:Dynamic; // hscript only really
}*/

var extraChars:StringMap<Dynamic> = new StringMap(); // DON'T TOUCH THIS OR IT COULD BREAK THE SCRIPT!

var onCharBop = function(onPercent:Int) {
	for (curChar in extraChars)
		if (curChar.self != null && onPercent % curChar.self.danceEveryNumBeats == 0 && curChar.self.animation.curAnim != null && !StringTools.startsWith(curChar.self.animation.curAnim.name, 'sing'))
			if (!curChar.self.stunned && game.startedCountdown && game.generatedMusic)
				curChar.self.dance();
}

// Character bops B)
function onCountdownTick(tick:Countdown, counter:Int) onCharBop(counter);
function onBeatHit() onCharBop(curBeat);

function onUpdatePost(elapsed:Float) {
	for (curChar in extraChars)
		if (curChar.self != null && (!game.controls.NOTE_LEFT && !game.controls.NOTE_DOWN && !game.controls.NOTE_UP && !game.controls.NOTE_RIGHT) && game.startedCountdown && game.generatedMusic)
			if (!curChar.self.stunned && curChar.self.holdTimer > Conductor.stepCrochet * 0.0011 * curChar.self.singDuration && curChar.self.animation.curAnim != null && StringTools.startsWith(curChar.self.animation.curAnim.name, 'sing') && !StringTools.endsWith(curChar.self.animation.curAnim.name, 'miss'))
				curChar.self.dance();
}

var extraNoteCall = function(setChar:Dynamic, daNote:Note, isPlayerNote:Bool, hasMissed:Bool) {
	var funcName:String = hasMissed ? 'extraNoteMiss' : 'extraNoteHit';
	game.callOnLuas(funcName, [game.notes.members.indexOf(daNote), daNote.noteData, daNote.noteType, daNote.isSustainNote, setChar.name, isPlayerNote]);
	game.callOnHScript(funcName, [daNote, setChar, isPlayerNote]);
}

var allNoteTriggers = function(daNote:Note, hasMissed:Bool) {
	for (curChar in extraChars) {
		if (extraChars.exists(curChar.name) && curChar.self != null) {
			for (noteTypes in curChar.noteTypes) {
				var mustPressTarget = noteTypes[1] == null ? daNote.mustPress : noteTypes[1];
				if (daNote.noteType == noteTypes[0] && daNote.mustPress == mustPressTarget) {
					curChar.isPlayer = mustPressTarget;
					if (!noteTypes[2]) {
						curChar.self.playAnim(game.singAnimations[daNote.noteData] + ((hasMissed && curChar.self.hasMissAnimations) ? 'miss' : '') + daNote.animSuffix, true);
						if (!hasMissed) curChar.self.holdTimer = 0;
					}
					extraNoteCall(curChar, daNote, mustPressTarget, hasMissed);
				}
			}
		}
	}
}

// I combined them, cause yes.
function goodNoteHit(daNote:Note) allNoteTriggers(daNote, false);
function opponentNoteHit(daNote:Note) allNoteTriggers(daNote, false);
function noteMiss(daNote:Note) allNoteTriggers(daNote, true);
function opponentNoteMiss(daNote:Note) allNoteTriggers(daNote, true); // jic

function onEventPushed(name:String, value1:String, value2:String) {
	switch (name) {
		case 'Change Extra Character':
			precacheCharacter(value1, value2);
	}
}

function onEvent(name:String, value1:String, value2:String) {
	switch (name) {
		// Was gonna just use the base "Change Character" event, but I couldn't figure out a good system for the last character (value1) called.
		case 'Change Extra Character':
			if (extraChars.exists(value1) && extraChars.get(value1).self != null) {
				var prevProp = {
					x: extraChars.get(value1).self.x - extraChars.get(value1).self.positionArray[0],
					y: extraChars.get(value1).self.y - extraChars.get(value1).self.positionArray[1],
					alpha: extraChars.get(value1).self.alpha,
					player: extraChars.get(value1).self.isPlayer,
					noteTypes: extraChars.get(value1).noteTypes,
					order: game.members.indexOf(extraChars.get(value1).self)
				};
				removeCharacter(value1, true);
				precacheCharacter(value1, value2);
				makeCharacter(value1, value2, [prevProp.x, prevProp.y], prevProp.player, prevProp.noteTypes);
				/*addCharacter(value1);
				remove(extraChars.get(value1).self, true);*/
				insert(prevProp.order, extraChars.get(value1).self);
			}
	}
}

// Possible full on precache system in the future?
function precacheCharacter(setChar:String, addToCache:String) {
	game.addCharacterToList(addToCache, 2); // 2 means gf so it all just goes to her lol
}

/**
 * @param tag The `Character` objects tag.
 * @param character The character's json file name.
 * @param charPos The x and y position. `[20, 50]`
 * @param isPlayer Ok so in this case just look at this as is facing left.
 * @param noteTypes Notes that make the character sing. `[["the note type name", "true is player, false is opponent and null is for both", "Play no animation?"], etc]`
 */
function makeCharacter(tag:String, character:String, ?charPos:Array<Float> = null, ?isPlayer:Bool = false, ?noteTypes:Array<Dynamic> = null) {
	if (tag == 'dad' || tag == 'gf' || tag == 'boyfriend') return debugPrint('makeCharacter: You can\'t use their names dummy! XD');
	else if (tag.length < 1 || tag == null) return debugPrint('makeCharacter: The name can\'t be blank!');
	else if (extraChars.exists(tag) && extraChars.get(tag).self == null) return debugPrint('makeCharacter: This name is already in use!');
	charPos = charPos == null ? (isPlayer ? [game.boyfriendGroup.x + 350, game.boyfriendGroup.y] : [game.dadGroup.x - 350, game.dadGroup.y]) : charPos;
	noteTypes = noteTypes == null ? [['No Animation', isPlayer, false]] : noteTypes;

	var char:Character = new Character(charPos[0], charPos[1], character, isPlayer);
	char.x += char.positionArray[0];
	char.y += char.positionArray[1];
	setVar(tag, char);
	game.setOnScripts(tag + 'Name', char.curCharacter);
	char.dance();
	
	extraChars.set(tag, {name: tag, self: char, /*cache: new StringMap(),*/ noteTypes: noteTypes, killSelf: function() { removeCharacter(tag, true); }});
}

/**
 * @param tag The `Character` objects tag.
 * @param front Should they spawn in the very front?
 */
function addCharacter(tag:String, ?front:Bool = false) {
	if (extraChars.exists(tag)) {
		var char = extraChars.get(tag).self;
		if (front) add(char);
		else insert(game.members.indexOf(psychlua.LuaUtils.getLowestCharacterGroup()), char);
	}
}

/**
 * @param tag The `Character` objects tag.
 * @param destroy Should they he completely removed?
 */
function removeCharacter(tag:String, ?destroy:Bool = true) {
	if (extraChars.exists(tag))
		if (destroy) {
			var char = extraChars.get(tag).self;
			removeVar(tag);
			game.setOnScripts(tag + 'Name', null);
			char.kill();
			char.destroy();
			extraChars.remove(tag);
		} else remove(extraChars.get(tag).self);
}

/**
 * @param tag The `Character` objects tag.
 * @param char The character themselves.
 * @param noteTypes Notes that make the character sing. `[["the note type name", "true is player, false is opponent and null is for both", "Play no animation?"], etc]`
 */
function importCharacter(tag:String, char:Character, ?noteTypes:Array<Dynamic> = null) {
	if (tag == 'dad' || tag == 'gf' || tag == 'boyfriend') return debugPrint('importCharacter: You can\'t use their names dummy! XD');
	else if (tag.length < 1 || tag == null) return debugPrint('importCharacter: The name can\'t be blank!');
	else if (extraChars.exists(tag) && extraChars.get(tag).self == null) return debugPrint('importCharacter: This name is already in use!');
	noteTypes = noteTypes == null ? [['No Animation', char.isPlayer, false]] : noteTypes;
	extraChars.set(tag, {name: tag, self: char, /*cache: new StringMap(),*/ noteTypes: noteTypes, killSelf: function() { removeCharacter(tag, true); }});
	setVar(tag, char);
	game.setOnScripts(tag + 'Name', char.curCharacter);
	return extraChars.get(tag); // return jic
}

/**
 * If `type` is "set" then `input` should be `[[String, Bool, Bool], etc]`.    
 * If `type` is "add" then `input` should be `[String, Bool, Bool]`.    
 * If `type` is "remove" then `input` should be `String`.    
 * If `type` is "replace" then `input` should be `[[String, Bool, Bool], [String, Bool, Bool]]`.
 * @param tag The `Character` objects tag.
 * @param input Notes that make the character sing. `[[The note type name, true is player vise versa and null is both, Plays no animation], etc]`
 * @param type Should it set, add, remove or replace?
 */
function setCharNoteTypes(tag:String, ?input:Dynamic = null, ?type:String = 'set') {
	if (input != null && extraChars.exists(tag)) {
		if (type == 'set' && Std.isOfType(input[0], Array)) extraChars.get(tag).noteTypes = input;
		else if (type == 'add' && Std.isOfType(input[0], String)) extraChars.get(tag).noteTypes.push(input);
		// else if (type == 'remove' && Std.isOfType(input, String)) extraChars.get(tag).noteTypes.remove(input); // not done
		//else if (type == 'replace' && (Std.isOfType(input[0], Array) && Std.isOfType(input[1], Array)))
		// not done
	}
}

/**
 * Note: This only effects the base characters. Not the ones created by the script!
 * @param noteType The name of a noteType.
 * @param haveAnim Should the note have animations play?
 * @param mustPress Wanna specify opponent or player?
 */
function shouldNotePlayAnim(noteType:String, ?haveAnim:Bool = null, ?mustPress:Bool = null) {
	if (haveAnim != null) {
		if (noteType == 'Alt Animation' || noteType == 'Hey!' || noteType == 'Hurt Note' || noteType == 'GF Sing' || noteType == 'No Animation') return debugPrint('shouldNotePlayAnim: You can\'t use the "' + noteType + '" noteType!');
		else {
			for (daNote in game.unspawnNotes) {
				if ((daNote.noteType == noteType) && (daNote.mustPress == mustPress || mustPress == null)) {
					daNote.noAnimation = !haveAnim;
					daNote.noMissAnimation = !haveAnim;
				}
			}
			for (daNote in game.notes) {
				if ((daNote.noteType == noteType) && (daNote.mustPress == mustPress || mustPress == null)) {
					daNote.noAnimation = !haveAnim;
					daNote.noMissAnimation = !haveAnim;
				}
			}
		}
	} else return debugPrint('shouldNotePlayAnim: haveAnim can\'t be null!');
}

// `createGlobalCallback` allows use in lua, `setOnHScript` allows use in hx and `makeForBoth` is well... for both.
var makeForBoth = function(tag:String, value:Dynamic) { // using setOnLuas would crash, idk why
	createGlobalCallback(tag, value); // creates function for lua
	game.setOnHScript(tag, value); // creates function for hscript
}
makeForBoth('precacheCharacter', precacheCharacter);
createGlobalCallback('makeCharacter', makeCharacter);
createGlobalCallback('addCharacter', addCharacter);
createGlobalCallback('removeCharacter', removeCharacter);
game.setOnHScript('importCharacter', importCharacter);
makeForBoth('setCharNoteTypes', setCharNoteTypes);
makeForBoth('shouldNotePlayAnim', shouldNotePlayAnim);