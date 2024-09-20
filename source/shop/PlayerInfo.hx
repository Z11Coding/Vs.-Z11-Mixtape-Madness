package shop;

class PlayerInfo {
    public static var curMoney:Int = 0;
    public static var curItems:Map<String, Dynamic> = new Map<String, Dynamic>();

    public static function saveInfo()
    {
        curItems.set('money', curMoney);
        FlxG.save.data.curItems = curItems;
    }

}