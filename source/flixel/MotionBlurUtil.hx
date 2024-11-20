package flixel;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.group.FlxTypedGroup;
import flixel.util.FlxSpriteUtil;
import flixel.MotionBlur;

class MotionBlurUtil {
    public static function addMotionBlurToSprites(?camera:FlxCamera, quality:MotionBlurQuality):Void {
        var group:FlxGroup = FlxG.state.members;
        if (group == null) return;

        if (camera == null) camera = FlxG.camera;

        for (sprite in group.members) {
            if (sprite != null && Std.is(sprite, FlxSprite)) {
                var flxSprite:FlxSprite = cast sprite;
                var motionBlur = new MotionBlur(flxSprite, quality);
                FlxG.state.add(motionBlur);
            }
        }
    }
}