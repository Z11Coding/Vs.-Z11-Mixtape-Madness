package undertale;

class MSOUL {
    public var name:String = 'UNKNOWN';
    public var health:Float = 20;
    public var maxHealth:Float = 20;
    public var sprite:FlxSprite;
    public var expToGive:Int = 1;
    public var goldToGive:Int = 0;
    public var atk:Int = 0;
    public var def:Int = 0;
    public var canSpare:Bool = false;
    public var canHurt:Bool = true; //basically like sans's ability to dodge
    /*
        If i ever decide to expand this feature for some ungodly reason, 
        this allows regualr monsters to work seperately from boss ones.
    */
    public var isBossMonster:Bool = true;

    public static var instance:MSOUL;

    public function new(name:String = '???', attack:Int = 0, defense:Int = 0, maxHealth:Float = 1, expToGive:Int = 0, goldToGive:Int = 0, canSpare:Bool = false, canHurt:Bool = true) {
        this.name = name;
        this.health = maxHealth;
        this.maxHealth = maxHealth;
        this.expToGive = expToGive;
        this.goldToGive = goldToGive;
        this.canSpare = canSpare;
        this.canHurt = canHurt;
        this.sprite = getMonsterSprite();
        this.atk = attack;
        this.def = defense;
        instance = this;
    }

    function getMonsterSprite(monster:String = 'test', isBattle:Bool = true):FlxSprite {
        this.sprite = new FlxSprite(0, 0, Paths.image('undertale/monster/${if (isBattle) 'battle/' else 'overworld/'}$monster'));
        return this.sprite;
    }

    function getMugshotSprite(monster:String = 'test'):FlxSprite {
        var mugshot:FlxSprite = new FlxSprite(0, 0, Paths.image('undertale/mugshots/$monster'));
        return mugshot;
    }
}