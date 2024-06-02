import flixel.graphics.FlxGraphic;
var isWinningDad:Bool = false;
var isWinningBF:Bool = false;
function onCreatePost()
{
    
    changeIcon();
}

function onEvent(name, value1, value2)
{
    if(name == 'Change Character')
    {
        changeIcon();
    }
}


function onUpdatePost()
{
    if (game.iconP1.animation.frames == 3) {
        if (game.healthBar.percent < 20)
            game.iconP1.animation.curAnim.curFrame = 1;
        else if (game.healthBar.percent >80)
            game.iconP1.animation.curAnim.curFrame = 2;
        else
            game.iconP1.animation.curAnim.curFrame = 0;
    } 
    else {
        if (game.healthBar.percent < 20)
            game.iconP1.animation.curAnim.curFrame = 1;
        else
            game.iconP1.animation.curAnim.curFrame = 0;
    }

    if (game.iconP2.animation.frames == 3) {
        if (game.healthBar.percent > 80)
            game.iconP2.animation.curAnim.curFrame = 1;
        else if (game.healthBar.percent < 20)
            game.iconP2.animation.curAnim.curFrame = 2;
        else 
            game. iconP2.animation.curAnim.curFrame = 0;
    } else {
        if (game.healthBar.percent > 80)
            game.iconP2.animation.curAnim.curFrame = 1;
        else 
            game.iconP2.animation.curAnim.curFrame = 0;
    }

}



function changeIcon()
{
    var dadGraphic:FlxGraphic = Paths.image('icons/icon-' + game.dad.healthIcon, false); 
    var bfGraphic:FlxGraphic = Paths.image('icons/icon-' + game.boyfriend.healthIcon, false);
    if(dadGraphic.width == 450) {
        game.iconP2.loadGraphic(Paths.image('icons/icon-' + game.dad.healthIcon, false), true, Math.floor(dadGraphic.width / 3), Math.floor(dadGraphic.height));
        game.iconP2.iconOffsets[0] = (game.iconP2.width - 150) / 3;
        game.iconP2.iconOffsets[1] = (game.iconP2.height - 150) / 3;
        game.iconP2.updateHitbox();

        game.iconP2.animation.add(game.iconP2.char, [0, 1, 2], 0, false, game.iconP2.isPlayer);
        game.iconP2.animation.play(game.iconP2.char);
    }

    if(bfGraphic.width == 450) {
        game.iconP1.loadGraphic(Paths.image('icons/icon-' + game.boyfriend.healthIcon, false), true, Math.floor(bfGraphic.width / 3), Math.floor(bfGraphic.height));
        game.iconP1.iconOffsets[0] = (game.iconP1.width - 150) / 3;
        game.iconP1.iconOffsets[1] = (game.iconP1.height - 150) / 3;
        game.iconP1.updateHitbox();

        game.iconP1.animation.add(game.iconP1.char, [0, 1, 2], 0, false, game.iconP1.isPlayer);
        game.iconP1.animation.play(game.iconP1.char);
    }
}