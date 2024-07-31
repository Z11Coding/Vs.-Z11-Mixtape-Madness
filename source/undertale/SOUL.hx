package undertale;

enum SOULTYPES
{
    RED;
    BLUE;
    YELLOW;
    PURPLE;
}

class SOUL
{
    public var health:Float = 20; //Make it global so that I can do whatever
    public var maxHealth:Float = 20; //Make it global so that I can do whatever
    public var type:SOULTYPES = RED;
    public var name:String = 'UNKNOWN';
    public var storage:Array<String> = ['Food 1', 'Food 2', 'Food 3'];
    public var LOVE:Int = 1;

    public static var instance:SOUL; //Felt like this will probably be needed sometime later

    public function new(health:Float = 20, type:SOULTYPES = RED, name:String = 'UNKNOWN', LOVE:Int = 1) {
        this.health = health;
        this.type = type;
        this.name = name;
        this.LOVE = LOVE;
    }

    function getSoulSprite():FlxSprite
    {
        return new FlxSprite(0, 0, Paths.image('mechanics/ut/soul'));
    }
}