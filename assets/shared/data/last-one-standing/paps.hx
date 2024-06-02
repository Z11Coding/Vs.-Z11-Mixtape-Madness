import haxe.ds.StringMap;
import StringTools;
import objects.Character;
var paps:Character;
var papsMap:StringMap;

function onCreate() {
    papsMap = new StringMap();
    paps = new Character(-450, 50, 'papyrus_kinemorto');
    startCharacterPos(paps, true);
    game.dadGroup.add(paps);
    setVar('paps', paps);
    paps.alpha = 0;

    addCharacterToList('tankman-player');
    addCharacterToList('tankman-player');

}

function startCharacterPos(char:Character) {
    char.x += char.positionArray[0];
    char.y += char.positionArray[1];
}


function addCharacterToList(newCharacter:String) 
{
    if(!papsMap.exists(newCharacter)) {
        var newpaps:Character = new Character(350, 50, newCharacter, true);
        papsMap.set(newCharacter, newpaps);
        game.dadGroup.add(newpaps);
        startCharacterPos(newpaps);
        newpaps.alpha = 0.00001;
    }
}

function onCountdownTick(tick:Countdown, counter:Int)
{
    if (counter % paps.danceEveryNumBeats == 0 && paps.animation.curAnim != null && !StringTools.startsWith(paps.animation.curAnim.name, 'sing') && !paps.stunned)
        paps.dance();
}

function onBeatHit()
{
    if (curBeat % paps.danceEveryNumBeats == 0 && paps.animation.curAnim != null && !StringTools.startsWith(paps.animation.curAnim.name, 'sing') && !paps.stunned)
        paps.dance();
}

function onUpdate(elapsed:Float)
{
	if(paps.animation.curAnim != null && paps.holdTimer > Conductor.stepCrochet * (0.0011 / FlxG.sound.music.pitch) * paps.singDuration && StringTools.startsWith(paps.animation.curAnim.name, 'sing') && !StringTools.startsWith(paps.animation.curAnim.name, 'miss')) {
        paps.dance();
    }
}

function opponentNoteHit(note:Note)
{
    var animToPlay:String = game.singAnimations[Std.int(Math.abs(Math.min(game.singAnimations.length-1, note.noteData)))];
    var char:Character = paps;
    var animCheck:String = 'hey';
    if(char != null)
    {
        if(note.noteType == 'paps' || note.noteType == 'BothOpp') {
            char.playAnim(animToPlay + note.animSuffix, true);
            char.holdTimer = 0;
            
            if(note.noteType == 'Hey!') {
                if(char.animOffsets.exists(animCheck)) {
                    char.playAnim(animCheck, true);
                    char.specialAnim = true;
                    char.heyTimer = 0.6;
                }
            }
        }
    }
}

function onStepHit()
{
    if (curStep == 2047)
    {
        FlxTween.tween(paps, {alpha: 0.8}, 5, {ease: FlxEase.sineInOut});
    }
}