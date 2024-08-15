package undertale;
import flixel.FlxSprite;
import flixel.tweens.FlxTween;
import openfl.display.Shader;
import flixel.util.FlxColor;
import openfl.geom.Vector3D;
import flixel.math.FlxPoint;
import flixel.math.FlxMath;
import math.Vector3;
import flixel.system.FlxAssets.FlxShader;
import modchart.ModManager;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup;
import lime.math.Vector2;
import lime.math.Vector4;
import openfl.Vector;
import flixel.tweens.FlxEase;
import flixel.util.FlxSort;
import flixel.tweens.FlxTween;
import lime.app.Event;
import flixel.math.FlxAngle;
import backend.Conductor;
import states.PlayState.Wife3;
import objects.Note;
import objects.NoteObject;
import objects.StrumNote;
import objects.Character;
import objects.NoteSplash;
import undertale.BATTLEFIELD;

abstract DamageType(Float) {
    public static inline var NORMAL = 0;
    public static inline var KARMA = 1;
    public static inline var BLUE = 2;
    public static inline var ORANGE = 3;

    public function new(value:Float) this = value;

    // Threader.runInThread(() -> {
    //     trace("DamageType: " + this);
    // });

    public function getDamage(damage:Float = 0):Float {
        switch (this) {
            case NORMAL:
                return 1.0;
            case KARMA:
                return 1.0;
            case BLUE:
                return 1.0; // Damage logic for BLUE can be handled separately
            case ORANGE:
                return 1.0; // Damage logic for ORANGE can be handled separately
        }
        return 0;
    }

    public function getType():String {
        switch (this) {
            case NORMAL:
                return "NORMAL";
            case KARMA:
                return "KARMA";
            case BLUE:
                return "BLUE";
            case ORANGE:
                return "ORANGE";
        }
        return "Unknown";
    }

    public function shouldApplyDamage(isMoving:Bool):Bool {
        switch (this) {
            case BLUE:
                return !isMoving; // Apply damage if the player is not moving
            case ORANGE:
                return isMoving; // Apply damage if the player is moving
            default:
                return true; // Apply damage for NORMAL and KARMA
        }
    }
}
class BULLETPATTERN {
    public var sprite:FlxSprite;
    public var damageType:DamageType;
    public var hurtbox:Hurtbox;

    private var actions:Map<Int, {action: Void -> Void, duration: Float}>;
    private var currentActionIndex:Int = 0;
    private var actionTimer:Float = 0;
    public var damageModifier:Float = 1.0;


    public function new(sprite:FlxSprite, damageType:DamageType) {
        this.sprite = sprite;
        this.damageType = damageType;
        this.hurtbox = new Hurtbox(sprite);
        Hurtbox.hurtboxes.set(this, this.hurtbox);
        this.actions = new Map<Int, {action: Void -> Void, duration: Float}>();
    }

    public function update():Void {
        var index:Int = -1;
        for (i in actions.keys()) {
            index++;
        }
        this.hurtbox.sprite.x = this.sprite.x;
        this.hurtbox.sprite.y = this.sprite.y;
        // Execute the current action
        if (currentActionIndex < index) {
            var currentAction:{action: Void -> Void, duration: Float} = actions.get(currentActionIndex);
            if (actionTimer == 0) {
                currentAction.action();
            }
            actionTimer += -1;
            if (actionTimer >= currentAction.duration) {
                currentActionIndex++;
                actionTimer = 0;
            }
        }
    }

    public function addAction(action:Void -> Void, duration:Float):Void {
        var index:Int = -1;
        for (i in actions.keys()) {
            index++;
        }
        actions.set(index, {action: action, duration: duration});
    }

    public function moveTo(x:Float, y:Float, duration:Float):Void {
        addAction(() -> {
            FlxTween.tween(sprite, {x: x, y: y}, duration, {onComplete: onActionComplete});
        }, duration);
    }

    public function setTo(x:Float, y:Float, duration:Float, complete:Bool):Void {
        addAction(() -> {
            sprite.x = x;
            sprite.y = y;
            if (complete) onActionComplete;
        }, duration);
    }

    public function fadeOut(duration:Float):Void {
        addAction(() -> {
            FlxTween.tween(sprite, {alpha: 0}, duration, {onComplete: onActionComplete});
        }, duration);
    }

    public function destroy():Void {
        sprite.kill();
        this.hurtbox.delete();
    }

    private function onActionComplete(tween:FlxTween):Void {
        // Move to the next action
        currentActionIndex++;
        actionTimer = 0;
    }

    public function applyDamage(soul:SOUL):Void {
        soul.applyDamage(damageType, damageType.getDamage());
    }
}

class EventSequence {
    public var events:Array<BULLETPATTERN>;
    public var soul:SOUL;

    public function new(soul:SOUL) {
        this.events = [];
        this.soul = soul;
    }

    public function addEvent(event:BULLETPATTERN):Void {
        events.push(event);
    }

    public function update():Void {
        for (event in events) {
            if (event != null && event.hurtbox != null && event.hurtbox.sprite != null)
            {
                event.update();
                event.hurtbox.checkCollision(soul, event.damageType);
                event.hurtbox.sprite.updateHitbox();
            }
        }
    }
}

class Hurtbox {
    public var sprite:FlxSprite;
    public static var hurtboxes:Map<BULLETPATTERN, Hurtbox> = new Map<BULLETPATTERN, Hurtbox>();

    public function new(sprite:FlxSprite) {
        this.sprite = sprite;
        this.sprite.width = sprite.width;
        this.sprite.height = sprite.height;
        this.sprite.updateHitbox();
        sprite.updateHitbox();
    }
    public function checkCollision(soul:SOUL, damageType:DamageType):Void {
        if (sprite.overlaps(soul.sprite)) { // ????? (You made this complicated to fix-)
            soul.applyDamage(damageType, damageType.getDamage());
        }
    }
    public function destroy():Void {
        this.sprite.kill();
        
    }
    public function delete():Void {
        this.destroy();
    }
}


class Blaster {
    public var x:Float;
    public var y:Float;
    public var x2:Float;
    public var y2:Float;
    public var angle:Float;
    public var startangle:Float;
    public var sound:String;
    public var fire_sound:String;
    public var sprite_prefix:String;
    public var beam_sprite:String;
    public var sprite:FlxSprite;
    public var beam:Beam;
    public var updatetimer:Float;
    public var rotation:Float;
    public var xscale:Float;
    public var yscale:Float;
    public var shootdelay:Float;
    public var speed:Float;
    public var dorotation:Float;
    public var builderspd:Float;
    public var holdfire:Float;
    public function new(x:Float, y:Float, x2:Float, y2:Float, angle:Float, startangle:Float, ?sound:String = null, ?fire_sound:String = null, ?sprite_prefix:String = null, ?beam_sprite:String = null)
    {
        this.sprite_prefix = sprite_prefix;
        if (sprite_prefix == null) this.sprite_prefix = "blaster";
        this.beam_sprite = beam_sprite;
        if (beam_sprite == null) this.beam_sprite = "beam";
        this.sprite = createSprite(sprite_prefix);
        this.sprite.scale.x = 2;
        this.sprite.scale.y = 2;
        this.sprite.x = x;
        this.sprite.y = y;
        this.rotation = 0;
        this.updatetimer = 0;
        this.x = x;
        this.y = y;
        this.x2 = x2;
        this.y2 = y2;
        this.xscale = 1;
        this.yscale = 1;
        this.shootdelay = 40;
        this.speed = 40;
        this.angle = angle % 360;
        this.dorotation = 0;
        this.builderspd = 0;
        this.holdfire = 0;
        this.sound = sound;
        this.fire_sound = fire_sound;
        if (sound == null) this.sound = "ut/gasterintro";
        if (fire_sound == null) this.fire_sound = "ut/gasterfire";
        if (startangle != 0)
        {
            this.dorotation = startangle;
            this.sprite.angle = startangle;
        }
        if (this.sound != null) FlxG.sound.play(Paths.sound(this.sound));
        
        if (this.angle >= 180) this.angle = this.angle-360;
    } 

    function createSprite(image:String):FlxSprite {
        var image:FlxSprite = new FlxSprite().loadGraphic(Paths.image('undertale/bullets/blasters/$image'));
        return image;
    }
}

class Beam {
    public var sprite:FlxSprite;
    public var yscale:Float;
    public var xscale:Float;
    public var x:Float;
    public var y:Float;
}