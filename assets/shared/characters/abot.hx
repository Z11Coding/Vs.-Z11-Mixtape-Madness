import states.stages.objects.ABotSpeaker;

var abot:ABotSpeaker;

function onCreatePost()
{
    abot = new ABotSpeaker(game.gfGroup.x, game.gfGroup.y + 550);
    abot.x -= 80;
    abot.y -= 200;
    abot.antialiasing = ClientPrefs.data.globalAntialiasing;

    updateABotEye("dad", true);
    game.addBehindGF(abot);
}

function onSongStart() abot.snd = FlxG.sound.music;

function onMoveCamera(who) updateABotEye(who, false);

function updateABotEye(who:String = "dad", finishInstantly:Bool = false)
{
    if (who == "dad") abot.lookLeft(); else abot.lookRight();

    if (finishInstantly) abot.eyes.anim.curFrame = abot.eyes.anim.length - 1;
}