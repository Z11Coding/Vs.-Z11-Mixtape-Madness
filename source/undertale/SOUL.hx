package undertale;

import flixel.FlxSprite;

enum SOULTYPES
{
    RED;
    BLUE;
    YELLOW;
    PURPLE;
}

class SOUL
{
    public var health:Float = 20;
    public var maxHealth:Float = 20;
    public var type:SOULTYPES = RED;
    public var name:String = 'UNKNOWN';
    public var storage:Array<String> = ['Food 1', 'Food 2', 'Food 3'];
    public var LOVE:Int = 1;
    public static var instance:SOUL;
    private var damageCooldown:Float = 0;
    private var cooldownTime:Float = 1.0; // 1 second cooldown

    public function new(health:Float = 20, type:SOULTYPES = RED, name:String = 'UNKNOWN', LOVE:Int = 1) {
        this.health = health;
        this.type = type;
        this.name = name;
        this.LOVE = LOVE;
    }

    function getSoulSprite():FlxSprite {
        return new FlxSprite(0, 0, Paths.image('mechanics/ut/soul'));
    }

    public function update(elapsed:Float):Void {
        if (damageCooldown > 0) {
            damageCooldown -= elapsed;
        }
    }

    public function applyDamage(damageType:DamageType, damage:Float):Void {
        if (damageType == DamageType.KARMA || damageCooldown <= 0) {
            health -= damage;
            if (damageType != DamageType.KARMA) {
                damageCooldown = cooldownTime;
            }
        }
    }
}