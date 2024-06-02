import flixel.FlxG;
import backend.Difficulty;
var bfCam:PsychCamera;
var steelCam:PsychCamera;
function onCreatePost()
{
    
    bfCam = new FlxCamera();
    //bfCam.bgColor.alpha = 0;
    bfCam.x = 640;
    bfCam.width = FlxG.width/2;
    FlxG.cameras.add(bfCam, false);

    steelCam = new FlxCamera();
    //steelCam.bgColor.alpha = 0;
    //steelCam.copyFrom(game.camGame);
    steelCam.width = FlxG.width/2;
    FlxG.cameras.add(steelCam, true);

    FlxG.cameras.add(game.camOther, true);
    FlxG.cameras.add(game.camHUD, true);
    FlxCamera.defaultCameras = [bfCam, steelCam, game.camGame];

    //trace("yeah it works");
}

function onSongStart()
{
}

function onUpdate()
{
    steelCam.scroll.x = game.dad.getMidpoint().x - 350;
    steelCam.scroll.y = game.dad.getMidpoint().y - 220;

    bfCam.scroll.x = game.boyfriend.getMidpoint().x - 350;
    bfCam.scroll.y = game.boyfriend.getMidpoint().y - 500;
}

function onStepHit()
{
    if (curStep == 152)
    {
        FlxTween.tween(bfCam, {y: 3000}, 1, {ease: FlxEase.sineInOut});
        FlxTween.tween(steelCam, {y: -3000}, 1, {ease: FlxEase.sineInOut});
    }
    if (curStep == 383)
    {
        FlxTween.tween(steelCam, {y: 0}, 1, {ease: FlxEase.sineInOut});
    }
    if (curStep == 416)
    {
        FlxTween.tween(steelCam, {y: 3000}, 1, {ease: FlxEase.sineInOut});
    }
    if (curStep == 1010)
    {
        FlxTween.tween(steelCam, {y: 0}, 1, {ease: FlxEase.sineInOut});
    }
    if (curStep == 1056)
    {
        FlxTween.tween(steelCam, {y: 3000}, 1, {ease: FlxEase.sineInOut});
    }
    if (curStep == 1264)
    {
        FlxTween.tween(steelCam, {y: 0}, 1, {ease: FlxEase.sineInOut});
    }
    if (curStep == 1312)
    {
        FlxTween.tween(steelCam, {y: 3000}, 1, {ease: FlxEase.sineInOut});
    }
    if (curStep == 1537)
    {
        FlxTween.tween(steelCam, {y: 0}, 1, {ease: FlxEase.sineInOut});
    }
    if (curStep == 1568)
    {
        FlxTween.tween(bfCam, {y: 0}, 1, {ease: FlxEase.sineInOut});
    }
    if (curStep == 1816)
    {
        FlxTween.tween(steelCam, {y: 3000}, 1, {ease: FlxEase.sineInOut});
        FlxTween.tween(bfCam, {y: -3000}, 1, {ease: FlxEase.sineInOut});
    }
    if (curStep == 2032)
    {
        FlxTween.tween(steelCam, {y: 0}, 1, {ease: FlxEase.sineInOut});
    }
    if (curStep == 2073)
    {
        FlxTween.tween(steelCam, {y: 3000}, 1, {ease: FlxEase.sineInOut});
    }
    if (curStep == 2290)
    {
        FlxTween.tween(steelCam, {y: 0}, 1, {ease: FlxEase.sineInOut});
    }
    if (curStep == 2336)
    {
        FlxTween.tween(steelCam, {y: 3000}, 1, {ease: FlxEase.sineInOut});
    }
    if (curStep == 2536)
    {
        FlxTween.tween(steelCam, {y: 0}, 1, {ease: FlxEase.sineInOut});
    }
    if (curStep == 2578)
    {
        FlxTween.tween(steelCam, {y: 3000}, 1, {ease: FlxEase.sineInOut});
    }
    if (curStep == 2840)
    {
        FlxTween.tween(steelCam, {y: 0}, 1, {ease: FlxEase.sineInOut});
        FlxTween.tween(bfCam, {y: 0}, 1, {ease: FlxEase.sineInOut});
    }
    if (curStep == 3162)
    {
        FlxTween.tween(steelCam, {y: 3000}, 1, {ease: FlxEase.sineInOut});
        FlxTween.tween(bfCam, {y: -3000}, 1, {ease: FlxEase.sineInOut});
    }
    if (curStep == 3352)
    {
        FlxTween.tween(steelCam, {y: 0}, 1, {ease: FlxEase.sineInOut});
    }
    if (curStep == 3417)
    {
        FlxTween.tween(steelCam, {y: 3000}, 1, {ease: FlxEase.sineInOut});
        if (Difficulty.getString() == 'Serious') FlxTween.tween(bfCam, {y: 0}, 1, {ease: FlxEase.sineInOut});
    }
    if (curStep == 3448)
    {
        if (Difficulty.getString() == 'Serious') FlxTween.tween(bfCam, {y: -3000}, 1, {ease: FlxEase.sineInOut});
    }
    if (curStep == 3608)
    {
        FlxTween.tween(steelCam, {y: 0}, 1, {ease: FlxEase.sineInOut});
    }
    if (curStep == 3669)
    {
        FlxTween.tween(steelCam, {y: 3000}, 1, {ease: FlxEase.sineInOut});
    }
    if (curStep == 3894)
    {
        FlxTween.tween(steelCam, {y: 0}, 1, {ease: FlxEase.sineInOut});
    }
    if (curStep == 3927)
    {
        FlxTween.tween(steelCam, {y: 3000}, 1, {ease: FlxEase.sineInOut});
    }
}