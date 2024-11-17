package shop;
import shaders.ColorShader;

class MoneyPopup extends FlxSpriteGroup {
	public var onFinish:Void->Void = null;
	var alphaTween:FlxTween;
    var money:FlxSprite;
    var popupBG:FlxSprite;
    var theText:FlxText;
    var lerpScore:Int = 0;
    var canLerp:Bool = false;
	public function new(amount:Int, ?camera:FlxCamera = null)
	{
		super(x, y);
        this.y -= 100;
        lerpScore = amount;

        PlayerInfo.curMoney += amount;
        PlayerInfo.saveInfo();

        var colorShader:ColorShader = new ColorShader(0);
		popupBG = new FlxSprite(FlxG.width - 300, 0).makeGraphic(300, 100, 0xF8000000);
        popupBG.visible = false;
		popupBG.scrollFactor.set();
        add(popupBG);

        money = new FlxSprite(0, 0).loadGraphic(Paths.image('globalIcons/Coin'));
        money.setGraphicSize(Std.int(money.width * 0.1));
        money.setPosition(popupBG.getGraphicMidpoint().x - 90, popupBG.getGraphicMidpoint().y - (money.height / 2));
        money.antialiasing = true;
        money.updateHitbox(); 
        money.scrollFactor.set();
		add(money);	

        theText = new FlxText(popupBG.x + 90, popupBG.y + 35, 200, Std.string(amount), 35);
		theText.setFormat(Paths.font("comboFont.ttf"), 35, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        theText.setPosition(popupBG.getGraphicMidpoint().x - 10, popupBG.getGraphicMidpoint().y - (theText.height / 2));
        theText.updateHitbox();
		theText.borderSize = 3;
        theText.scrollFactor.set();
        theText.antialiasing = true;
        add(theText);

        money.shader = colorShader.shader;
        theText.shader = colorShader.shader;

        FlxTween.tween(this, {y: 0}, 0.35, {ease: FlxEase.circOut});

        new FlxTimer().start(0.9, function(tmr:FlxTimer)
		{
            canLerp = true;
            colorShader.amount = 1;
            FlxTween.tween(colorShader, {amount: 0}, 0.8, {ease: FlxEase.expoOut});
            FlxG.sound.play(Paths.sound('confirmMenu'), 0.9);
        });

		var cam:Array<FlxCamera> = FlxCamera.defaultCameras;
		if(camera != null) {
			cam = [camera];
		}
		alpha = 0;
		money.cameras = cam;
		theText.cameras = cam;
		popupBG.cameras = cam;
		alphaTween = FlxTween.tween(this, {alpha: 1}, 0.5, {onComplete: function (twn:FlxTween) {
			alphaTween = FlxTween.tween(this, {alpha: 0}, 0.5, {
				startDelay: 2.5,
				onComplete: function(twn:FlxTween) {
					alphaTween = null;
					remove(this);
					if(onFinish != null) onFinish();
				}
			});
		}});
	}

    override function update(elapsed:Float){
        super.update(elapsed);
        if(canLerp){
            lerpScore = Math.floor(FlxMath.lerp(lerpScore, 0, CoolUtil.boundTo(elapsed * 4, 0, 1)/1.5));
            if(Math.abs(0 - lerpScore) < 10) lerpScore = 0;
        }

        theText.text = Std.string(lerpScore);
        money.setPosition(popupBG.getGraphicMidpoint().x - 90, popupBG.getGraphicMidpoint().y - (money.height / 2));
        theText.setPosition(popupBG.getGraphicMidpoint().x - 10, popupBG.getGraphicMidpoint().y - (theText.height / 2));
    }

	override function destroy() {
		if(alphaTween != null) {
			alphaTween.cancel();
		}
		super.destroy();
	}
}

class ShopData {
    public static var items:Map<String, Dynamic> = new Map<String, Dynamic>();
    public static function initShop()
    {
        /* 
        * Template for adding your own items to the shop if the occasion calls        
        * items.set('Item Name', ['Description', Cost (Int), 'Image Name', Is Hidden (Bool), Is Bought (Bool)]);
        * Go Crazy.
        * -Z11Gaming 
        */

        /*if (FlxG.save.data.shopItems != null) items = FlxG.save.data.shopItems;
        else
        {
            //Test Item
            items.set('Test', ['This is literally just to test the items description', 100, 'emptyAchievement', false, false]);
            items.set('h?', ['h?', 100, 'unknownMod', false, false]);
        }*/

        //This is to test the shop so that when the items are finalized, it wont force you to delete your save to update the shop
        items.set('Fanta Can',         [['[reset]For the love of christ, [pause:0.5]do NOT buy this fanta can.', 'It\'s your funeral...'], 100, 'emptyAchievement', false, false]);
        items.set('Pico Plush',        [['[reset]Found it in an alleyway being protected by some girl with a knife.\n[pause:0.5]I said [pause:0.2]"LOOK OVER THERE!" [pause:0.2]and she said [pause:0.2]"WHERE??" [pause:0.2]and I laughed in her face and ran with the doll.', 'WHAT THE FUCK [pause:0.5]PICO FRIDAY NIGHT FUNKIN!?!?'], 100, 'emptyAchievement', false, false]);
        items.set('Cup of Lean',       [['[reset]I saw a cup with some purple stuff next to this knock-off pair of you and gf.\n[pause:0.5]I was a little thirsty, and I didn\'t think they\'d mind. [pause:0.5]SO I took a sip, [pause:0.5]blacked out, [pause:0.5]and woke up in a sewer... ', 'Actually, [pause:0.5]come to think of it, [pause:0.5]He\'s like you[slow:0.5]...[fast:0.3]But purple.[sfx:vineBoom]'], 100, 'emptyAchievement', false, false]);
        items.set('Ipod',              [["[reset]hey HEY\n[pause:0.7]HANDS OFF MY IPOD.", 'FUCK[pause:0.5] how am I supposed to call my mom now?'], 100, 'emptyAchievement', false, false]);
        items.set('Lost Key',          [['[reset]I found this key when I first moved in. [pause:0.5]Everyone asks where it went but I hold on to it to fuck with them.', 'It was funny while it lasted...'], 100, 'emptyAchievement', false, false]);
        items.set('1UP Mushroom',      [['[reset]...[pause:0.5]You probably could have used this in MM.', 'That mods mid, [pause:0.1]anyway.'], 100, 'emptyAchievement', true, false]);
        items.set('SOUL',              [['[reset]The guy who gave this to me needed a step-latter.', 'Hope the shelf wasn\'t too high for you.'], 100, 'emptyAchievement', true, false]);
        items.set('Tablet',            [['[reset]I took a kids tablet and ran away, [pause:0.5]And her mother chased me for four blocks before she fell flat on her face.', '...[pause:0.5]you don\'t wanna know where that\'s been'], 100, 'emptyAchievement', false, false]);
        items.set('Roof Access Card',  [['[reset]Looking for this?', 'Have fun with that\n[pause:0.5]it\'s basically useless.'], 100, 'emptyAchievement', true, false]);
        items.set('Slushie cup',       [["[reset]Want a drink?", "Gimme a sec"], 100, 'emptyAchievement', FlxG.random.bool(37), false]);
        items.set('Abyss Key',         [['[reset]I woke up one night and this key was just, [pause:0.5]in my mouth.', ''], 100, 'emptyAchievement', false, false]);
        items.set('Mysterious Laptop', [['[reset][set:0.1][pitch:0.5]I   g o t   h u n g r y', '[pitch:0.1][set:0.5]I   G O T   H U N G R Y'], 100, 'emptyAchievement', false, false]);
        items.set('h?',                [['[reset][mpause]h?', 'h?'],                       9999999999999999, 'unknownMod',       false, false]);
    }

    public static function saveShop() {
        FlxG.save.data.shopItems = items;
    }
}