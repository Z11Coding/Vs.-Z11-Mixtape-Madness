import haxe.ds.StringMap;
import StringTools;
import objects.Character;

var chara:Character;
var charaMap:StringMap;

function onCreate() {
    charaMap = new StringMap();
    chara = new Character(350, 50, 'chara-flip', true);
    startCharacterPos(chara);
    game.boyfriendGroup.add(chara);
    setVar('chara', chara);
    chara.alpha = 0;

}

function startCharacterPos(char) {
    char.x += char.positionArray[0];
    char.y += char.positionArray[1];
}

function onEvent(eventName, value1, value2, strumTime)
{
    if(eventName == 'Change Other Character')
    {
        if(chara.curCharacter != value2) {
            if (!charaMap.exists(value2)) {
                addCharacterToList(value2);
            }
            var lastAlpha:Float = chara.alpha;
            chara.alpha = 0.00001;
            chara = charaMap.get(value2);
            chara.alpha = lastAlpha;
        }
    }
}

function onCountdownTick(tick, counter)
{
    if (counter % chara.danceEveryNumBeats == 0 && chara.animation.curAnim != null && !StringTools.startsWith(chara.animation.curAnim.name, 'sing') && !chara.stunned)
        chara.dance();
}

function onBeatHit()
{
    if (curBeat % chara.danceEveryNumBeats == 0 && chara.animation.curAnim != null && !StringTools.startsWith(chara.animation.curAnim.name, 'sing') && !chara.stunned)
        chara.dance();
}

function onUpdate(elapsed)
{
	if(chara.animation.curAnim != null && chara.holdTimer > Conductor.stepCrochet * (0.0011 / FlxG.sound.music.pitch) * chara.singDuration && StringTools.startsWith(chara.animation.curAnim.name, 'sing') && !StringTools.startsWith(chara.animation.curAnim.name, 'miss')) {
        chara.dance();
    }
}

function goodNoteHit(note:Note)
{
    var animToPlay:String = game.singAnimations[Std.int(Math.abs(Math.min(game.singAnimations.length-1, note.noteData)))];
    var animCheck:String = 'hey';
    if(chara != null)
    {
        if(note.noteType == 'Chara' || note.noteType == 'BothPlay') {
            chara.playAnim(animToPlay + note.animSuffix, true);
            chara.holdTimer = 0;
            
            if(note.noteType == 'Hey!') {
                if(chara.animOffsets.exists(animCheck)) {
                    chara.playAnim(animCheck, true);
                    chara.specialAnim = true;
                    chara.heyTimer = 0.6;
                }
            }
        }
    }
}

function noteMiss(note:Note)
{
    var animToPlay:String = game.singAnimations[Std.int(Math.abs(Math.min(game.singAnimations.length-1, note.noteData)))] + 'miss';
    var char:Character = chara;
    if(char != null)
    {
        char.playAnim(animToPlay + note.animSuffix, true);
        char.holdTimer = 0;
    }
}

function noteMissPress(direction)
{
    var animToPlay:String = game.singAnimations[direction];
    var char:Character = chara;
    if(char != null)
    {
        char.playAnim(animToPlay + 'miss', true);
        char.holdTimer = 0;
    }
}

function onStepHit()
{
    if (curStep == 2047)
    {
        FlxTween.tween(chara, {alpha: 0.8}, 5, {ease: FlxEase.sineInOut});
    }
}