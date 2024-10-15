package shop;

class PlayerInfo {
    public static var curMoney:Int = 0;
    public static var curItems:Map<String, Dynamic> = new Map<String, Dynamic>();

    public static function saveInfo()
    {
        trace(curMoney);
        curItems.set('money', curMoney);
        FlxG.save.data.curItems = curItems;
        ShopData.saveShop();
        FlxG.save.flush();
    }

    public static function loadInfo()
    {
        curItems = FlxG.save.data.curItems;

        curMoney = curItems.get('money');
    }

}