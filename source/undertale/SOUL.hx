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
    public var atk:Int = 1;
    public var def:Int = 0;
    public var sprite:FlxSprite;
    public static var instance:SOUL;
    private var damageCooldown:Float = 0;
    private var cooldownTime:Float = 1.0; // 1 second cooldown

    public function new(health:Float = 20, attack:Int = 0, defense:Int = 0, type:SOULTYPES = RED, name:String = 'UNKNOWN', LOVE:Int = 1) {
        this.health = health;
        this.type = type;
        this.name = name;
        this.LOVE = LOVE;
        this.atk = attack;
        this.def = defense;
        this.sprite = getSoulSprite();
        instance = this;
    }

    function getSoulSprite():FlxSprite {
        this.sprite = new FlxSprite(0, 0, Paths.image('undertale/soul/soul'));
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

enum ACTION
{
    HEAL;
    ITEM;
}
class ITEM {
    public var name:String;
    public var action:ACTION;
    public var value:Float;
    public var flavorText:String = 'This item doesn\'t have flavor text!\nOh, the horror!';
    public function new(name:String, action:ACTION, ?value:Float = 0, ?flavorText:String = 'This item doesn\'t have flavor text!\nOh, the horror!')
    {
        this.name = name;
        this.action = action;
        this.value = value;
        this.flavorText = flavorText;
    }
}
class ITEMS {
    public static var instance:ITEMS;
    public var fallback:ITEM = new ITEM('error', HEAL, 0, "If you're reading this...\nyou messed up somewhere!");
    public var test1:ITEM = new ITEM('Food 1', HEAL, 10, 'You ate the Food 1!\nYou healed 10HP and passed the test!');
    public var test2:ITEM = new ITEM('Food 2', HEAL, 20, 'You ate the Food 2!\nSpicy!\nYou healed 20HP');
    public var test3:ITEM = new ITEM('Food 3', HEAL, 1, 'You ate the Food 3!\nEw. it\'s cold...\nYou healed 1HP anyway, though...');
    public function new() {
        instance = this;
    }
}

//TODO: make this better
class Inventory {
    public static function getItem(item:String):ITEMS {
        switch (item)
        {
            case 'Food 1':
                return new ITEMS().test1;
            case 'Food 2':
                return new ITEMS().test2;
            case 'Food 3':
                return new ITEMS().test3;
        }
        return new ITEMS().fallback;
    }
}