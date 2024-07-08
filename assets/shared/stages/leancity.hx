function onCreatePost()
{
    game.gf.setGraphicSize(Std.int(game.gf.width * 0.6));
}

var lastPos = '';
function onMoveCamera(toPos) {
    if (lastPos != toPos)
    {
        lastPos = toPos;
        if (toPos == 'gf')
        {
            game.defaultCamZoom = 1.8;
        }
        else
        {
            game.defaultCamZoom = 0.8;
        }
    }

}