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

abstract DamageType(Int) {
    public static inline var NORMAL = 0;
    public static inline var KARMA = 1;

    public function new(value:Int) this = value;

    public function getDamage(damage:Float = 0):Float {
        switch (this) {
            case NORMAL:
                return Std.int(damage);
            case KARMA:
                return 1.0;
        }
        return null;
    }

    public function getType():String {
        switch (this) {
            case NORMAL:
                return "NORMAL";
            case KARMA:
                return "KARMA";
        }
        return "Unknown";
    }
}

class BULLETPATTERN {
    public var sprite:FlxSprite;
    public var damageType:DamageType;
    public var hurtbox:Hurtbox;
    private var actions:Array<Void -> Void>;
    private var currentActionIndex:Int = 0;
    public var damageModifier:Float = 1.0;

    public function new(sprite:FlxSprite, damageType:DamageType) {
        this.sprite = sprite;
        this.damageType = damageType;
        this.hurtbox = new Hurtbox(sprite);
        this.actions = [];
        this.damageModifier = damageType.getDamage();
    }

    public function update():Void {
        // Execute the current action
        if (currentActionIndex < actions.length) {
            actions[currentActionIndex]();
            currentActionIndex++;
        }
    }

    public function addAction(action:Void -> Void):Void {
        actions.push(action);
    }

    public function moveTo(x:Float, y:Float, duration:Float):Void {
        addAction(() -> {
            FlxTween.tween(sprite, {x: x, y: y}, duration, {onComplete: onActionComplete});
        });
    }

    public function fadeOut(duration:Float):Void {
        addAction(() -> {
            FlxTween.tween(sprite, {alpha: 0}, duration, {onComplete: onActionComplete});
        });
    }

    private function onActionComplete(tween:FlxTween):Void {
        // Move to the next action
        currentActionIndex++;
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
            event.update();
            event.hurtbox.checkCollision(soul, event.damageType);
        }
    }
}

    class Hurtbox {
        public var sprite:FlxSprite;
    
        public function new(sprite:FlxSprite) {
            this.sprite = sprite;
        }
    
        public function checkCollision(soul:SOUL, damageType:DamageType):Void {
            if (sprite.overlaps(soul.instance.getSoulSprite())) { // ????? (This one's your problem, Z.)
                soul.applyDamage(damageType, damageModifier);
            }
        }
    }