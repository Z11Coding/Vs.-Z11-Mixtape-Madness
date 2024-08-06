package undertale;

import objects.Bar;
import backend.Highscore;
import backend.Achievements;
import objects.TypedAlphabet;
import cutscenes.DialogueBox;
import backend.util.WindowUtil;
import flixel.input.keyboard.FlxKey;
import flixel.addons.text.FlxTypeText;
import flixel.FlxState;
import undertale.*;
import undertale.BULLETPATTERN.*;
import undertale.SOUL.*;
import undertale.SOUL.ITEM;
import flixel.ui.FlxBar;
class BATTLEFIELD extends MusicBeatState
{
    //Basic Stuff
    var box:FlxSprite;
    var boxB:FlxSprite;
    var soul:FlxSprite;
    var monsterS:FlxSprite;
    var curMode:String = 'menu';
    var human:SOUL;
    var monster:MSOUL;
    var butNobodyCame:Bool = false;

    //Menu Stuff
    var hp:Bar;
    var hpTxt:FlxText;
    var healthTxt:FlxText;
    var buttons:FlxTypedGroup<FlxSprite>;
    var menu:FlxTypedGroup<FlxText>;
    var name:FlxText;
    var underText:FlxTypeText;
    var dialogueCamera:FlxCamera;
    var options:Array<String> = [];
    var items:Array<String>;
    var menuItems:Array<String> = [
		"FIGHT", "ACT", "ITEM", "MERCY"
	];
    var act:Array<String> = [
		"Check"
	];
    var mercy:Array<String> = [
		"Spare", "Flee"
	];

    //Collision Stuff
    var bProp:Array<Dynamic> = [];
    var bInd:Int = 0;

    //Box Stuff
    var targetW:Float = 450;
    var targetH:Float = 200;
    var boxX:Float = (1280 / 2) - 25;
    var boxY:Float = (720 / 2) + 75;
    var boxW:Float = 0;
    var boxH:Float = 0;
    var boxA:Float = 1;

    //Soul Stuff
    var pX:Float = 0;
    var pY:Float = 0;
    var isBlue:Bool = false;
    var gravDir:Int = 270;
    var vsp:Float = 0;
    var grav:Float = 0.26;
    var moving:Bool = false;
    var ground:Bool = false;
    var rxm:Float = 0;
    var rym:Float = 0;
    var canMove:Bool = true;
    var notice:Float = 0;
    public var health:Float = 0;

    //Attack Stuff
    var heavy:Bool = false;
    var sfx:Map<String, FlxSound> = new Map<String, FlxSound>();
    var spawned = {};

    public function new(human:SOUL = null, monster:MSOUL = null) {
        if (human != null) this.human = human;
        if (monster != null) this.monster = monster;
        else butNobodyCame = true;
        super();
    } //For the multi-route thing

    override function create() {
        #if UNDERTALE
        FlxG.mouse.visible = false;

		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();

		WindowUtil.initWindowEvents();
		WindowUtil.disableCrashHandler();
		FlxSprite.defaultAntialiasing = true;

		#if LUA_ALLOWED
		Mods.pushGlobalMods();
		#end
		Mods.loadTopMod();

		FlxG.game.focusLostFramerate = 60;
		FlxG.keys.preventDefaultKeys = [TAB, ALT];

		FlxG.save.bind('Mixtape' #if (flixel < "5.0.0"), 'Z11Gaming' #end);
		ClientPrefs.loadPrefs();
		ClientPrefs.reloadVolumeKeys();

		#if ACHIEVEMENTS_ALLOWED Achievements.load(); #end

		Highscore.load();
        #end
        human = new SOUL(20, 1, 1, RED, 'Frisk', 1);
        monster = new MSOUL('Z11Tale', 99, 99, 1000000000, 9999, 500, false, true);

        health = human.health;
        items = human.storage;

        var bg:FlxSprite = new FlxSprite(320, 100).loadGraphic(Paths.image('undertale/ui/bg'));
        bg.setGraphicSize(Std.int(bg.width) * 1.5);
        bg.scrollFactor.set();
        bg.screenCenter(X);
        bg.x += 30;
        add(bg);

        name = new FlxText(250, 600, 0, human.name, 30);
        name.scrollFactor.set();
        name.setFormat(Paths.font("determination-extended.ttf"), 30, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        add(name);

        hp = new Bar(620, name.y - 5, 'hp', function() return health, 0, human.maxHealth);
        hp.barWidth = 50;
        hp.barHeight = 30;
        add(hp);
        hp.setColors(FlxColor.YELLOW, FlxColor.RED);
        hp.updateBar();

        hpTxt = new FlxText(hp.x - 50, 600, 0, "HP", 30);
        hpTxt.scrollFactor.set();
        hpTxt.setFormat(Paths.font("determination-extended.ttf"), 25, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        add(hpTxt);

        healthTxt = new FlxText(700, 600, 0, "DIE", 30);
        healthTxt.scrollFactor.set();
        healthTxt.setFormat(Paths.font("determination-extended.ttf"), 25, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        add(healthTxt);

        boxB = new FlxSprite().loadGraphic(Paths.image('undertale/ui/boxBorder'));
        box = new FlxSprite().loadGraphic(Paths.image('undertale/ui/box'));
        soul = human.sprite;
        monsterS = monster.sprite;
        monsterS.x = 540;
        boxB.screenCenter();
        box.screenCenter();
        soul.screenCenter();
        monsterS.scale.x = 0.5;
	    monsterS.scale.y = 0.5;
        soul.scale.x = 1.8;
	    soul.scale.y = 1.8;
        add(monsterS);
        add(boxB);
        add(box);
        add(soul);

        underText = new FlxTypeText(300, 400, Std.int(FlxG.width * 0.6), '', 32);
        underText.font = Paths.font("determination-extended.ttf");
        underText.color = 0xFFFFFFFF;
        underText.prefix = '* '; 
        underText.sounds = [FlxG.sound.load(Paths.sound('ut/monsterfont'), 0.6)];
		add(underText);
        underText.alpha = 0;

        buttons = new FlxTypedGroup<FlxSprite>();
		add(buttons);

        menu = new FlxTypedGroup<FlxText>();
		add(menu);

        for (i in 0...menuItems.length)
        {
            var button:FlxSprite = new FlxSprite(200 * i, 650);
            button.frames = Paths.getSparrowAtlas('undertale/ui/ui_buttons');
            button.animation.addByPrefix('idle', menuItems[i].toLowerCase() + '_idle');
            button.animation.addByPrefix('selected', menuItems[i].toLowerCase() + '_sel');
            button.antialiasing = ClientPrefs.data.globalAntialiasing;
            button.animation.play('idle');
            button.scale.x = 1.5;
	        button.scale.y = 1.5;
            buttons.add(button);
            button.ID = i;
        }
        buttons.forEach(function(item:FlxSprite)
        {
            item.x += 300;
            item.animation.play('idle');
        });
        //Temporary. Gonna have an intro sequence before it plays the music
        var daSong = 'beatEmDown';
        if (FlxG.random.bool(25)) daSong = 'beatEmDownGMix';
        FlxG.sound.playMusic(Paths.music(daSong), 0.8, true);
    }

    var curMenu:String = 'main';
    function regenMenu(option:String)
    {
        switch (option)
        {
            case 'ACT':
                curMenu = 'act';
                options = act;
            case 'ITEM':
                curMenu = 'item';
                options = items;
            case 'MERCY':
                curMenu = 'mercy';
                options = mercy;
            case 'FIGHT':
                curMenu = 'fight';
                //I'll get there
            case 'nothing':
                curMenu = 'nothing';
                options = [];
            default:
                curMenu = 'main';
                options = [];
        }
        for (i in menu.members)
        {
            menu.remove(i);
        }

        for (i in 0...options.length)
        {
            var button:FlxText = new FlxText(-200, 430, FlxG.width, options[i], 32);
            button.setFormat(Paths.font("determination-extended.ttf"), 32, FlxColor.WHITE, CENTER);
            button.scrollFactor.set();
            menu.add(button);
            button.ID = i;
        }

        if (curMenu != 'main' || curMenu != 'nothing')
        {
            for (i in 0...menu.members.length)
            {
                switch(i%4)
                {
                    case 0:
                        if (menu.members[i] != null)
                        {
                            menu.members[i].x = -200;
                            menu.members[i].y = 430;
                        }
                    case 1:
                        if (curMenu == 'mercy')
                        {
                            if (menu.members[i] != null)
                            {
                                menu.members[i].x = -200;
                                menu.members[i].y = 480;
                            }
                        }
                        else
                        {
                            if (menu.members[i] != null)
                            {
                                menu.members[i].x = 100;
                                menu.members[i].y = 430;
                            }
                        }
                    case 2:
                        if (menu.members[i] != null)
                        {
                            menu.members[i].x = -200;
                            menu.members[i].y = 480;
                        }
                    case 3:
                        if (menu.members[i] != null)
                        {
                            menu.members[i].x = 300;
                            menu.members[i].y = 480;
                        }
                }
            }
        }
        changeSelection();
    }

    var curSelected:Int = 0;
    var curSelectedAct:Int = 0;
    var curSelectedItem:Int = 0;
    var curSelectedMercy:Int = 0;
    function changeSelection(change:Int = 0):Void
	{
		FlxG.sound.play(Paths.sound('ut/menumove'), 0.4);
        switch (curMenu)
        {
            case 'act':
                curSelectedAct += change;
                if (curSelectedAct < 0)
                    curSelectedAct = menu.members.length - 1;
                if (curSelectedAct >= menu.members.length)
                    curSelectedAct = 0;
                for (item in menu.members)
                {
                    if (item != null)
                    {
                        if (item.ID == curSelectedAct) 
                        {
                            soul.x = item.x + 550;
                            soul.y = item.y + 10;
                        }
                    }
                }
            case 'item':
                curSelectedItem += change;
                if (curSelectedItem < 0)
                    curSelectedItem = menu.members.length - 1;
                if (curSelectedItem >= menu.members.length)
                    curSelectedItem = 0;
                for (item in menu.members)
                {
                    if (item != null)
                    {
                        if (item.ID == curSelectedItem) 
                        {
                            soul.x = item.x + 550;
                            soul.y = item.y + 10;
                        }
                    }
                }
            case 'mercy':
                curSelectedMercy += change;
                if (curSelectedMercy < 0)
                    curSelectedMercy = menu.members.length - 1;
                if (curSelectedMercy >= menu.members.length)
                    curSelectedMercy = 0;
                for (item in menu.members)
                {
                    if (item != null)
                    {
                        if (item.ID == curSelectedMercy) 
                        {
                            soul.x = item.x + 550;
                            soul.y = item.y + 10;
                        }
                    }
                }
            default:
                curSelected += change;
                if (curSelected < 0)
                    curSelected = menuItems.length - 1;
                if (curSelected >= menuItems.length)
                    curSelected = 0;
                for (item in buttons.members)
                {
                    if (item.ID == curSelected) 
                    {
                        item.animation.play('selected', true);
                        soul.x = item.x - 11;
                        soul.y = item.y + 15;
                    }
                    else item.animation.play('idle', true);
                }
        }
	}

    var daSpeed:Float = 0.04;
    function typeFunc(?text:String = '', ?sound:String = 'monsterfont', ?speed:Float = 0.04, ?delayBetweenPause:Float = 1, hide:Bool = false)
    {
        daSpeed = speed;
        underText.sounds = [FlxG.sound.load(Paths.sound('ut/$sound'), 0.6)];
    
        var splitName:Array<String> = text.split("\n");
        var trueText:String = splitName[0];
        for (i in 0...splitName.length)
        {
            if (i > 0) trueText += '\n* ' + splitName[i];
        }

        if (hide)
        {
            underText.alpha = 0;
            underText.resetText('');
        }
        else
        {
            underText.alpha = 1;
            underText.resetText(trueText);
            underText.start(speed, true);
        }
    }

    function useItem(thing:ITEM)
    {
        regenMenu('nothing');
        curMenu = 'attack';
        typeFunc(thing.flavorText, 0.04, 1);
        FlxG.sound.play(Paths.sound('ut/healsound'), 0.6);
        if (thing.action == HEAL) human.health += thing.value;
    }

    function menuAction(thing:String) {
        switch (curMenu)
        {
            case 'act':
                switch(thing)
                {
                    case 'Check':
                        regenMenu('nothing');
                        curMenu = 'attack';
                        typeFunc('Z11Tale - ATK 99 DEF 99\nSimply want to have fun\nDangerous if provoked, though.', 0.04, 1.5);
                }
            case 'item':
                useItem(undertale.SOUL.Inventory.getItem(thing));
            case 'mercy':
                switch(thing)
                {
                    case 'Spare':
                    {
                        regenMenu('nothing');
                        curMenu = 'attack';
                        if (monster.canSpare) 
                        {
                            //endBattle(); not quite there yet
                        }
                        else typeFunc('You tried to spare the enemy...\nBut their name wasn\'t yellow!', 0.04, 1.5);
                    }

                    case 'Flee':
                        regenMenu('nothing');
                        curMenu = 'attack';
                        if (monster.canFlee) typeFunc('Don\'t slow me down...', 0.04, 1.5);
                        else typeFunc('Can\'t flee from this enemy!', 0.04, 1.5);
                }
                
        }
    }

    var allCheck = 0;
    var changeBoxSize:Bool = false;
    var test:BULLETPATTERN;
    var selected:Bool = false;
    var inMenu:Bool = false;
    override function update(elapsed:Float) {
        human.update(elapsed, soul);
        underText.update(elapsed);
        hp.updateBar();
        if (human.health > human.maxHealth) human.health = human.maxHealth;
        health = human.health;
        healthTxt.text = human.health + ' / ' + human.maxHealth;
        if (FlxG.keys.justPressed.B) canMove = false;
        if (FlxG.keys.justPressed.V) canMove = true;
        if (FlxG.keys.justPressed.I) isBlue = true;
        if (FlxG.keys.justPressed.O) isBlue = false;
        if (FlxG.keys.justPressed.F) 
        {
            var testSprite:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image('undertale/bullets/boneMini'));
            testSprite.screenCenter();
            testSprite.scale.x = 2;
            testSprite.scale.y = 2;
            add(testSprite);

            test = new BULLETPATTERN(testSprite, new undertale.BULLETPATTERN.DamageType(2));
            test.moveTo(FlxG.random.int(-280, 1280), FlxG.random.int(-300, 1300), FlxG.random.int(1, 10));
            test.moveTo(FlxG.random.int(-400, 1400), FlxG.random.int(-600, 1600), FlxG.random.int(1, 10));
            test.fadeOut(FlxG.random.int(1, 10));
            test.update();
        }
        if (test != null) test.hurtbox.checkCollision(human, test.damageType);
        var upP = controls.UI_LEFT_P || controls.UI_UP_P;
		var downP = controls.UI_RIGHT_P || controls.UI_DOWN_P;
        var enter = controls.ACCEPT;
        var back = controls.BACK;
        if (underText.text.charAt(underText.text.length-1) == ".") underText.delay = 3;
        else underText.delay = daSpeed;
        if (underText.text.charAt(underText.text.length-1) == "\n") underText.delay = 0.3;
        else underText.delay = daSpeed;
        if (!canMove)
        {
            if (curMenu == 'main')
            {
                if (underText.text == '* ') 
                {
                    underText.alpha = 1;
                    underText.resetText('You feel like he\'s mad, yet you can\'t place why.');
                    underText.start(0.04, true);
                    selected = false;
                    inMenu = false;
                }
                for (item in buttons.members)
                {
                    if (item.ID == curSelected && item.animation.curAnim.name == 'idle') changeSelection();
                }
            }
            else if (curMenu != 'attack')
            {
                typeFunc(true);
            }
            else if (curMenu == 'attack' && enter)
            {
                canMove = true;
                curMenu = 'main';
            }
            
            if (upP)
            {
                changeSelection(-1);
            }
            if (downP)
            {
                changeSelection(1);
            }

            targetW = 800;

            if (!selected)
            {
                if (enter && !inMenu) 
                {
                    inMenu = true;
                    regenMenu(menuItems[curSelected]);
                }
                else if (enter && inMenu) 
                {
                    soul.alpha = 0;
                    switch(curMenu)
                    {
                        case 'act':
                            menuAction(menu.members[curSelectedAct].text);
                        case 'item':
                            menuAction(menu.members[curSelectedItem].text);
                        case 'mercy':
                            menuAction(menu.members[curSelectedMercy].text);
                    }
                    selected = true;
                }
            }

            if (back && !selected)
            {
                regenMenu('MAIN');
            } 
        }
        else
        {
            soul.alpha = 1;
            typeFunc(true);
            if (!changeBoxSize)
            {
                targetW = 450;
            }
            for (item in buttons.members)
            {
                item.animation.play('idle', true);
            }
        }

        var hColor = FlxColor.fromString('#FF0000');
        if (isBlue) hColor = FlxColor.fromString("#0000FF");
        soul.color = hColor;

        var toW:Float = targetW;
	    var toH:Float = targetH;

        boxW = boxW + ((toW - boxW) / (10 / (elapsed * 60)));
	    boxH = boxH + ((toH - boxH) / (10 / (elapsed * 60)));

        if (Math.ceil(boxW) == toW || Math.floor(boxW) == toW) boxW = toW;
        if (Math.ceil(boxH) == toH || Math.floor(boxH) == toH) boxH = toH;

        box.scale.x = boxW / 100;
        box.scale.y = boxH / 100;

        boxB.scale.x = (boxW + 16) / 100;
        boxB.scale.y = (boxH + 16) / 100;

        box.x = boxX;
        box.y = boxY;
        boxB.x = boxX;
        boxB.y = boxY;
        if (canMove)
        {   soul.x = boxX + pX;
	        soul.y = boxY + pY;
        }

        box.alpha = boxA;
        boxB.alpha = boxA;

        ground = false;

        var lBd = -boxW / 2 + 65;
        var rBd = boxW / 2 + 20;
        var uBd = -boxH / 2 + 65;
        var dBd = boxH / 2 + 18;

        if (pX <= lBd)
        {
            pX = lBd;
    
            if (gravDir == 180)
            {
                vsp = 0;
                ground = true;
            }
        }
        else if (pX >= rBd)
        {   
            pX = rBd;
    
            if (gravDir == 0)
            {
                vsp = 0;
                ground = true;
            }
        }

        if (pY <= uBd)
        {
            pY = uBd;

            if (gravDir == 90)
            {
                vsp = 0;
                ground = true;
            }
            else if (gravDir == 270) vsp = 0;
        }
        else if (pY >= dBd)
        {
            pY = dBd;

            if (gravDir == 270)
            {
                vsp = 0;
                ground = true;
            }
            else if (gravDir == 90) vsp = 0;
        }

        

        if (ground && heavy)
        {
            FlxG.camera.shake(0.2, 0.005);
            FlxG.sound.play(Paths.sound('ut/impact'), 1);
            //act = 1;
            heavy = false;
        }

        //if (lX != pX || lY != pY) moving = true;

        if (boxW < 48 && boxH < 48)
        {
            pX = 0;
            pY = 0;
        }

        if (notice > 0)
        {
            notice = notice - elapsed * 60;
            soul.color = FlxColor.fromString('#FFFFFF');
            soul.alpha = notice / 10;
        }

        moving = false;
        var lX = pX;
        var lY = pY;
        if (canMove)
        {
            var lxm = rxm;
            var lym = rym;

            var xmov = 0;
            var ymov = 0;

            var gp = false;
            if (FlxG.gamepads.numActiveGamepads > 0) gp = true;

            var kR = FlxG.keys.pressed.RIGHT || FlxG.keys.pressed.D || FlxG.keys.pressed.L ||
            (gp && (FlxG.gamepads.lastActive.pressed.DPAD_RIGHT || FlxG.gamepads.lastActive.pressed.LEFT_STICK_DIGITAL_RIGHT));
            
            var kL = FlxG.keys.pressed.LEFT || FlxG.keys.pressed.A || FlxG.keys.pressed.J ||
            (gp && (FlxG.gamepads.lastActive.pressed.DPAD_LEFT || FlxG.gamepads.lastActive.pressed.LEFT_STICK_DIGITAL_LEFT));
            
            var kU = FlxG.keys.pressed.UP || FlxG.keys.pressed.W || FlxG.keys.pressed.I ||
            (gp && (FlxG.gamepads.lastActive.pressed.DPAD_UP || FlxG.gamepads.lastActive.pressed.LEFT_STICK_DIGITAL_UP));
            
            var kD = FlxG.keys.pressed.DOWN || FlxG.keys.pressed.S || FlxG.keys.pressed.K ||
            (gp && (FlxG.gamepads.lastActive.pressed.DPAD_DOWN || FlxG.gamepads.lastActive.pressed.LEFT_STICK_DIGITAL_DOWN));
            
            
            if (kR) xmov = xmov + 1;
            if (kL) xmov = xmov - 1;
            if (kD) ymov = ymov + 1;
            if (kU) ymov = ymov - 1;

            rxm = xmov;
            rym = ymov;

            var spd = 4.2 * (elapsed * 60);

            var jSpd = 10;
            if (isBlue)
            {
                if (ground == false) vsp = vsp + grav * elapsed * 60;

                if (ground && ((gravDir == 0 && xmov == -1) || (gravDir == 180 && xmov == 1) || (gravDir == 90 && ymov == 1) || (gravDir == 270 && ymov == -1))) vsp = -jSpd;

                if (vsp < 0 && (((gravDir == 0 || gravDir == 180) && xmov == 0 && lxm != 0) || ((gravDir == 90 || gravDir == 270) && ymov == 0 && lym != 0))) vsp = vsp / 4;
                
                if (gravDir == 0 || gravDir == 180) xmov = 0;
                else if (gravDir == 90 || gravDir == 270) ymov = 0;

                soul.angle = -gravDir - 90;
            }
            else
            {
                vsp = 0;
                soul.angle = 0;
            }

            var vBy = vsp * elapsed * 60;
            pX = pX + xmov * spd + Math.cos(flixel.math.FlxAngle.asRadians(gravDir)) * vBy;
            pY = pY + ymov * spd - Math.sin(flixel.math.FlxAngle.asRadians(gravDir)) * vBy;
        }
    }
}