package undertale;

import flixel.FlxSprite;
import undertale.BULLETPATTERN;

enum SOULTYPES
{
    RED;
    BLUE;
    YELLOW;
    PURPLE;
}

class SOUL {
    public var health:Float = 20;
    public var maxHealth:Float = 20;
    public var type:SOULTYPES = RED;
    public var name:String = 'UNKNOWN';
    public var storage:Array<String> = ['Food 1', 'Food 2', 'Food 3'];
    public var LOVE:Int = 1;
    public var gold:Int = 0;
    public var sprite:FlxSprite;
    public static var instance:SOUL;
    private var damageCooldown:Float = 0;
    private var cooldownTime:Float = 1.0; // 1 second cooldown

    public function new(health:Float = 20, type:SOULTYPES = RED, name:String = 'UNKNOWN', LOVE:Int = 1) {
        this.health = health;
        this.type = type;
        this.name = name;
        this.LOVE = LOVE;
        this.sprite = getSoulSprite();
    }

    function getSoulSprite():FlxSprite {
        this.sprite = new FlxSprite(0, 0, Paths.image('mechanics/ut/soul/soul'));
        return this.sprite;
    }

    public function update(elapsed:Float, soul:FlxSprite):Void {
        if (damageCooldown > 0) {
            damageCooldown -= elapsed;
            switch (damageCooldown%2)
            {
                case 0:
                    soul.color = FlxColor.fromString('#FF0000');
                case 1:
                    soul.color = FlxColor.fromString('#8f0000');
            }
        }
    }

    public function applyDamage(damageType:DamageType, damage:Float):Void {
        if (damageType.getType() == "KARMA"  || damageCooldown <= 0) {
            if (health > 0) 
            {
                health -= damage;
                FlxG.sound.play(Paths.sound('ut/hurtsound'));
            }
            if (damageType.getType() != "KARMA") {
                damageCooldown = cooldownTime;
            }
        }
    }
}