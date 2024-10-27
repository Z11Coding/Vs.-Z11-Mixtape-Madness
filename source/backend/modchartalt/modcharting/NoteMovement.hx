package backend.modchartalt.modcharting;

#if (PSYCH && PSYCHVERSION >= "0.7")
import states.PlayState;
import objects.Note;
#else
import PlayState;
import Note;
#end

using StringTools;

class NoteMovement
{
    public static var keyCount = 4;
    public static var playerKeyCount = 4;
    public static var totalKeyCount = 8;
    public static var arrowScale:Float = 0.7;
    public static var arrowSize:Float = 112;
    public static var defaultStrumX:Array<Float> = [];
    public static var defaultStrumY:Array<Float> = [];
    public static var defaultStrumZ:Array<Float> = [];
    public static var defaultSkewX:Array<Float> = [];
    public static var defaultSkewY:Array<Float> = [];
    public static var defaultScale:Array<Float> = [];
    public static var arrowSizes:Array<Float> = [];

    public static function getDefaultStrumPos(game:PlayState)
    {
        defaultStrumX = []; //reset
        defaultStrumY = [];
        defaultStrumZ = []; 
        defaultSkewX = [];
        defaultSkewY = []; 
        defaultScale = [];
        arrowSizes = [];
        keyCount = Note.ammo[PlayState.mania];
        playerKeyCount = Note.ammo[PlayState.mania];

        for (field in PlayState.instance.playfields.members)
        {   
            for (i in 0...(Note.ammo[PlayState.mania]))
            {
                var strum = field.strumNotes[i];
                defaultSkewX.push(strum.skew.x);
                defaultSkewY.push(strum.skew.y);
                defaultStrumX.push(strum.x);
                defaultStrumY.push(strum.y);
                defaultStrumZ.push(strum.z);
                var s = Note.scales[PlayState.mania];
                defaultScale.push(s);
                arrowSizes.push(160*s);
            }
        }
        totalKeyCount = keyCount + playerKeyCount;
    }
    public static function getDefaultStrumPosEditor(game:backend.modchartalt.modcharting.ModchartEditorState)
    {
        #if (PSYCH && !DISABLE_MODCHART_EDITOR)
        defaultStrumX = []; //reset
        defaultStrumY = []; 
        defaultStrumZ = []; 
        defaultSkewX = [];
        defaultSkewY = [];
        defaultScale = [];
        arrowSizes = [];
        keyCount = Note.ammo[PlayState.mania];
        playerKeyCount = Note.ammo[PlayState.mania];


        for (field in game.playfields.members)
        {   
            for (i in 0...(Note.ammo[PlayState.mania]))
            {
                var strum = field.strumNotes[i];
                defaultSkewX.push(strum.skew.x);
                defaultSkewY.push(strum.skew.y);
                defaultStrumX.push(strum.x);
                defaultStrumY.push(strum.y);
                var s = 0.7;

                defaultScale.push(s);
                arrowSizes.push(160*s);
            }
        }
        #end
    }
    public static function setNotePath(daNote:Note, lane:Int, scrollSpeed:Float, curPos:Float, noteDist:Float, incomingAngleX:Float, incomingAngleY:Float)
    {
        daNote.x = defaultStrumX[lane];
        daNote.y = defaultStrumY[lane];
        daNote.z = defaultStrumZ[lane];

        var pos = ModchartUtil.getCartesianCoords3D(incomingAngleX,incomingAngleY, curPos*noteDist*2);
        //trace(ClientPrefs.data.drawDistanceModifier);
        daNote.y += pos.y;
        daNote.x += pos.x;
        daNote.z += pos.z;

        daNote.skew.x = defaultSkewX[lane];
        daNote.skew.y = defaultSkewY[lane];
    }

    public static function getLaneDiffFromCenter(lane:Int)
    {
        var col:Float = lane%Note.ammo[PlayState.mania];
        if ((col+1) > (keyCount*0.5))
        {
            col -= (keyCount*0.5)+1;
        }
        else 
        {
            col -= (keyCount*0.5);
        }

        //col = (col-col-col); //flip pos/negative

        //trace(col);

        return col;
    }


}
