package backend;

import flixel.graphics.FlxGraphic;
import openfl.display.BitmapData;

class ImageCache {

    public static var cache:Map<String, FlxGraphic> = new Map<String, FlxGraphic>();

    public static function add(path:String):Void {
        try {
            var data:FlxGraphic = FlxGraphic.fromBitmapData(GPUBitmap.create(path));
            data.persist = true;
            data.destroyOnNoUse = false;
            //trace(cache);

            cache.set(path, data);
        } catch (e:Dynamic) {
            trace("Error adding image to cache: "+ e);
        }
    }

    public static function get(path:String):FlxGraphic {
        try {
            return cache.get(path);
        } catch (e:Dynamic) {
            trace("Error getting image from cache:"+ e);
            return null;
        }
    }

    public static function exists(path:String):Bool {
        try {
            return cache.exists(path);
        } catch (e:Dynamic) {
            trace("Error checking if image exists in cache: "+ e);
            return false;
        }
    }
}