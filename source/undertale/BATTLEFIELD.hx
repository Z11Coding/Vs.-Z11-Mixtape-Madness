package undertale;

import shaders.ShadersHandler;
import objects.Bar;
import backend.Highscore;
import backend.Achievements;
import objects.TypedAlphabet;
import cutscenes.DialogueBox;
import backend.util.WindowUtil;
import flixel.input.keyboard.FlxKey;
import flixel.FlxState;
import undertale.*;
import undertale.BULLETPATTERN;
import undertale.BULLETPATTERN.EventSequence;
import undertale.SOUL;
import undertale.SOUL.ITEM;
import flixel.ui.FlxBar;
class BATTLEFIELD extends MusicBeatState
{
    //Basic Stuff
    var box:FlxSprite;
    var boxB:FlxSprite;
    var soul:FlxSprite;
    var monsterS:FlxSprite;
    var speechBubble:FlxSprite;
    var curMode:String = 'menu';
    var human:SOUL;
    var monster:MSOUL;
    var butNobodyCame:Bool = false;
    public var isGenocide:Bool = true;
    public static var instance:BATTLEFIELD;
    public var bubbleOffset:Map<String, Array<Dynamic>>;


    //Menu Stuff
    var hp:Bar;
    var enemyHP:Bar;
    var hpTxt:FlxSprite;
    var healthTxt:FlxText;
    var damageTxt:FlxText;
    var LOVETxt:FlxText;
    var buttons:FlxTypedGroup<FlxSprite>;
    var menu:FlxTypedGroup<FlxText>;
    var bulletGroup:FlxTypedGroup<FlxSprite>;
    var name:FlxText;
    var underText:UnderTextParser;
    var monsterText:UnderTextParser;
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
    public var targetW:Float = 450;
    public var targetH:Float = 200;
    public var boxX:Float = (1280 / 2) - 25;
    public var boxY:Float = (720 / 2) + 75;
    var boxW:Float = 0;
    var boxH:Float = 0;
    public var boxA:Float = 1;

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
    public var canMove:Bool = false;
    var notice:Float = 0;
    public var health:Float = 0;
    public var enemyHealth:Float = 0;

    //Attack Stuff
    var heavy:Bool = false;
    var sfx:Map<String, FlxSound> = new Map<String, FlxSound>();
    var battleThing:FlxSprite;
    var target:FlxSprite;
    var slash:FlxSprite;
	var enemyMaxHealth:Float;
    public var turnCounter:Int = 0;

    public function new(?human:SOUL = null, ?monster:MSOUL = null, isGenocide:Bool = true) {
        this.isGenocide = isGenocide;
        if (human != null) this.human = human;
        if (monster != null) this.monster = monster;
        else if (monster == null && isGenocide) butNobodyCame = true;
        super();
        instance = this;
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
        Language.reloadPhrases();

		#if ACHIEVEMENTS_ALLOWED Achievements.load(); #end

		Highscore.load();
        #end
        //simply for testing
        if (isGenocide)
        {
            human = new SOUL(RED, 'Chara', 20);
            monster = new MSOUL('Z11Tale', 4, 1, 100000, 9999, 500, false, true, isGenocide);
            monster.initFlavorText = 'Battle against the truly determined...[pause:1]\nLet\'s see how much he\'ll take before he breaks...';
            monster.flavorTextList = [
                'You feel like you\'ve done this before somewhere...', 
                'Z11Tale asks his blasters what they want for dinner\n[pause:5]They\'re still deciding',
                'Smells like DETERMINATION',
                'Z11Tale rubs his sword\nit shimmers in multiple different colors in response',
                'Z11Tale reminds himself of your sins\nHis grip on his sword tightens',
                'Z11Tale\'s soul glimmers within him\nYou wonder how many monsters died to make him this strong...',
                'DETERMINATION'
            ];
        }
        else
        {
            human = new SOUL(RED, 'Frisk', 1);
            monster = new MSOUL('Z11Tale', 4, 1, 100, 9999, 500, false, true, isGenocide);
            monster.initFlavorText = 'Z11Tale prepares for a fun battle.';
            monster.flavorTextList = [
                'Z11Tale eyes someone behind him.\nHe seems annoyed by them.', 
                'Z11Tale does a series of backflips.\n(He\'s not actually, he just put that there to look cool)',
                'Z11Tale turns around to yell at someone behind him tto quit cheering\nYou can hear a faint "awww" in the distance.',
                'You ask if Z11Tale isn\'t human\nHe shows you his soul which was, indeed, human.',
                'Z11Tale starts thinking about grillby\'s.\nZ11tale is hungry now.',
                'Z11Tale\'s bops to the song with intense enjoyment.',
                'You start to wonder how long Z11Tale\'s been down here.\nThe thought makes your head hurt.'
            ];
        }
        trace(human.atk);
        health = human.health;
        items = human.storage;
        trace(monster.health);

        enemyHealth = monster.health;
        enemyMaxHealth = monster.maxHealth;

        var bg:FlxSprite = new FlxSprite(310, 100).loadGraphic(Paths.image('undertale/ui/bg'));
        bg.setGraphicSize(Std.int(bg.width) * 1.5);
        bg.scrollFactor.set();
        bg.screenCenter(X);
        bg.x += 30;
        //add(bg); mfw i realize this doesn't need to be here


        name = new FlxText(270, 600, 0, human.name, 30);
        name.scrollFactor.set();
        name.setFormat(Paths.font("determination-extended.ttf"), 30, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        add(name);

        hp = new Bar(620, name.y - 5, 'hp', function() return health, 0, human.maxHealth);
        hp.barWidth = 50 * (human.LOVE/5);
        hp.barHeight = 30;
        add(hp);
        hp.setColors(FlxColor.YELLOW, FlxColor.RED);
        hp.updateBar();

        hpTxt = new FlxSprite(hp.x - 50, 607).loadGraphic(Paths.image('undertale/ui/spr_hpname_0'));
        hpTxt.scrollFactor.set();
        hpTxt.scale.x = 1.8;
	    hpTxt.scale.y = 1.8;
        add(hpTxt);

        LOVETxt = new FlxText(name.x + 130, 600, 0, "LV "+human.LOVE, 30);
        LOVETxt.scrollFactor.set();
        LOVETxt.setFormat(Paths.font("determination-extended.ttf"), 30, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        add(LOVETxt);

        healthTxt = new FlxText(hp.barWidth + 650, 603, 0, "DIE", 30);
        healthTxt.scrollFactor.set();
        healthTxt.setFormat(Paths.font("determination-extended.ttf"), 25, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        add(healthTxt);

        boxB = new FlxSprite().loadGraphic(Paths.image('undertale/ui/boxBorder'));
        box = new FlxSprite().loadGraphic(Paths.image('undertale/ui/box'));
        soul = human.sprite;
        monsterS = monster.sprite;
        monsterS.y = -750;
        monsterS.screenCenter(X);
        monsterS.x += 30;
        boxB.screenCenter();
        box.screenCenter();
        soul.screenCenter();
        monsterS.scale.x = 0.2;
	    monsterS.scale.y = 0.2;
        soul.scale.x = 1.8;
	    soul.scale.y = 1.8;
        add(monsterS);
        add(boxB);
        add(box);
        add(soul);

        // testing nonsense
        var overlayColor:Array<Float> = [1.0, 0.0, 0.0, 1.0]; 
        var satinColor:Array<Float> = [0.0, 1.0, 0.0, 1.0]; 
        var innerShadowColor:Array<Float> = [0.0, 0.0, 1.0, 1.0]; 
        var innerShadowAngle:Float = 45.0; 
        var innerShadowDistance:Float = 10.0; 

        // a-
        shaders.ShadersHandler.applyRTXShader(monsterS, overlayColor, satinColor, innerShadowColor, innerShadowAngle, innerShadowDistance);
        //monsterS.shader = new shaders.Shaders.RTX();

        enemyHP = new Bar(monsterS.x + 200, monsterS.y + 1050, 'bosshp', function() return (enemyHealth / enemyMaxHealth) * 100, 0, 100);
        enemyHP.barWidth = 700;
        enemyHP.barHeight = 25;
        add(enemyHP);
        enemyHP.setColors(FlxColor.fromString('#00FF00'), FlxColor.fromString('#FF0000'));
        enemyHP.updateBar();
        enemyHP.alpha = 0;

        damageTxt = new FlxText(enemyHP.x + 300, enemyHP.y - 100, 0, "99", 30);
        damageTxt.scrollFactor.set();
        damageTxt.setFormat(Paths.font("hachicro.ttf"), 25, FlxColor.RED, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        damageTxt.alignment = FlxTextAlign.CENTER;
        damageTxt.size = 40;
        add(damageTxt);
        damageTxt.alpha = 0;

        battleThing = new FlxSprite(395, 425).loadGraphic(Paths.image('undertale/ui/spr_target_0')); 
        battleThing.scale.x = 1.4;
	    battleThing.scale.y = 1.4;
        add(battleThing);
        battleThing.alpha = 0;

        target = new FlxSprite(240, 425);
        target.frames = Paths.getSparrowAtlas('undertale/ui/target');
        target.animation.addByPrefix('wait', "spr_targetchoice0000", 0);
        target.animation.addByPrefix('strike', "spr_targetchoice", 10, true);
        target.scale.x = 1.4;
	    target.scale.y = 1.4;
        add(target);
        target.alpha = 0;   

        slash = new FlxSprite(650, 100);
        slash.frames = Paths.getSparrowAtlas('undertale/ui/slash');
        slash.animation.addByPrefix('wait', "spr_slice0000", 0);
        slash.animation.addByPrefix('attack', "spr_slice", 10);
        slash.scale.x = 1.4;
	    slash.scale.y = 1.4;
        add(slash);
        slash.alpha = 0;


        underText = new UnderTextParser(300, 400, Std.int(FlxG.width * 0.6), '', 32);
        underText.font = Paths.font("determination-extended.ttf");
        underText.color = 0xFFFFFFFF;
        underText.prefix = '* '; 
        underText.sounds = [FlxG.sound.load(Paths.sound('ut/monsterfont'), 0.6)];
		add(underText);
        underText.alpha = 0;

        bubbleOffset = new Map<String, Array<Dynamic>>();

        speechBubble = new FlxSprite(monsterS.x + 430, 100);
        speechBubble.frames = Paths.getSparrowAtlas('undertale/ui/SpechBubbles');
        speechBubble.animation.addByPrefix('leftwide', "leftwide", 0);
        addOffset('leftwide', 300, 0, 280, 40);
        speechBubble.animation.addByPrefix('rightwide', "rightwide", 0);
        addOffset('rightwide', -300, 0, 280);
        speechBubble.animation.addByPrefix('rightlarge', "rightlarge", 0);
        addOffset('rightlarge', -300, 40, 240);
        speechBubble.animation.addByPrefix('leftlarge', "leftlarge", 0);
        addOffset('leftlarge', 300, 40, 240, 20);
        speechBubble.animation.addByPrefix('rightlong', "rightlong", 0);
        addOffset('rightlong', -300, 40, 100, 20);
        speechBubble.animation.addByPrefix('leftlargeminus', "leftlargeminus", 0);
        addOffset('leftlargeminus', 300, 40, 240, 30);
        speechBubble.animation.addByPrefix('empty', "empty", 0);
        addOffset('empty', 0, 0);
        speechBubble.animation.addByPrefix('rightlargeminus', "rightlargeminus", 0);
        addOffset('rightlargeminus', -300, 40, 240);
        speechBubble.animation.addByPrefix('leftwideminus', "leftwideminus", 0);
        addOffset('leftwideminus', 300, 40, 240);
        speechBubble.animation.addByPrefix('rightwideminus', "rightwideminus", 0);
        addOffset('rightwideminus', -300, 40, 240, 20);
        speechBubble.animation.addByPrefix('left', "left", 0);
        addOffset('left', 300, 0, 260, 20);
        speechBubble.animation.addByPrefix('leftshort', "leftshort", 0);
        addOffset('leftshort', 100, 0, 150, 40);
        speechBubble.animation.addByPrefix('right', "right", 0);
        addOffset('right', -300, 0, 300);
        speechBubble.animation.addByPrefix('rightshort', "rightshort", 0);
        addOffset('rightshort', -300, 0, 150, 20);
        speechBubble.scale.x = 1.4;
	    speechBubble.scale.y = 1.4;
        add(speechBubble);
        speechBubble.alpha = 0;


        monsterText = new UnderTextParser(300, 400, Std.int(speechBubble.width), '', 32);
        monsterText.font = Paths.font("determination-extended.ttf");
        monsterText.color = 0xFF000000;
        monsterText.sounds = [FlxG.sound.load(Paths.sound('ut/monsterfont'), 0.6)];
		add(monsterText);
        monsterText.alpha = 0;

        bulletGroup = new FlxTypedGroup<FlxSprite>();
		add(bulletGroup);

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
        if (FlxG.random.bool(1)) daSong = 'beatEmDownGMix';
        if (isGenocide) daSong = 'battleTillTheEnd';
        FlxG.sound.playMusic(Paths.music(daSong), 0.8, true);

        sequence = new EventSequence(human);
    }

    //I love stealing functions
    public function addOffset(name:String, x:Float = 0, y:Float = 0, width:Float = 100, addx:Float = 0)
	{
		bubbleOffset[name] = [x, y, width, addx];
	}

    function speechFunc(box:String = 'right', ?text:String = '', ?sound:String = 'monsterfont', ?size:Int = 30, ?speed:Float = 0.04)
    {
        speechBubble.updateHitbox();
        speechBubble.animation.play(box, true);
        var daOffset:Array<Dynamic> = [];
        if (bubbleOffset.exists(box))
        {
            daOffset = bubbleOffset.get(box);
            speechBubble.offset.set(daOffset[0], daOffset[1]);
        }
        monsterText.x = speechBubble.x - daOffset[0] - daOffset[3];
        monsterText.y = speechBubble.y - daOffset[1];
        monsterText.fieldWidth = daOffset[2];
        monsterText.size = size;
        monsterText.updateHitbox();
        monsterText.sounds = [FlxG.sound.load(Paths.sound('ut/$sound'), 0.6)];
        if (box == 'empty')
        {
            speechBubble.alpha = 0;
            monsterText.alpha = 0;
            monsterText.resetText('');
        }
        else
        {
            speechBubble.alpha = 1;
            monsterText.alpha = 1;
            monsterText.resetText(text);
            monsterText.start(speed, true);
        }
    }

    function doAttack(lod:Int) {
        trace(lod);
        attacked = true;
        FlxG.sound.play(Paths.sound('ut/slice'));

        target.animation.play('strike');
        slash.animation.play('attack');
        slash.alpha = 1;

        new FlxTimer().start(0.6, function(tmr:FlxTimer)
        {
            slash.animation.play('wait', true);
            slash.alpha = 0;
        });

        new FlxTimer().start(1, function(tmr:FlxTimer)
        {
            slash.animation.play('wait', true);
            enemyHP.alpha = 1;
            damageTxt.alpha = 1;
            FlxTween.tween(damageTxt, {y: enemyHP.y - 40}, 1.5, {ease: FlxEase.bounceOut});
            FlxG.sound.play(Paths.sound('ut/hitsound'));
            damageTxt.text = ''+(DamageCalculator.getDamage(lod, human, monster));
            FlxTween.num(monster.health, (monster.health -= DamageCalculator.getDamage(lod, human, monster)), 1.5, {ease: FlxEase.expoInOut}, function(num)
            {
                monster.health = num;
                //trace('tweened to: '+monster.health);
            });
            //monster.health -= DamageCalculator.getDamage(lod, human, monster); //dont ask why i did it this way.
            new FlxTimer().start(2, function(tmr:FlxTimer)
            {
                enemyHP.alpha = 0;
                damageTxt.alpha = 0;
                FlxTween.tween(battleThing, {alpha: 0}, 0.5);
                FlxTween.tween(target, {alpha: 0}, 0.5);
                FlxTween.tween(battleThing.scale, {x: 0.8, y:1}, 0.5, {onComplete: function(twn:FlxTween) { 
                    target.x = 240;
                    attacked = false;
                    damageArea = 0;
                    damageTxt.y = enemyHP.y - 100;
                    target.animation.play('wait', true);
                }});
                if (isGenocide) monster.progress++;
                curMenu = 'monDialogue';
                speechFunc('right', 'hehehehe.\nbones.', 'Z11', 20);
            });
        });
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
                options = [];
                selected = true;
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
                            menu.members[i].x = 100;
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
        allowUIDialogue = true;
        regenMenu('nothing');
        curMenu = 'attack';
        typeFunc(thing.flavorText, 0.04, 1);
        FlxG.sound.play(Paths.sound('ut/healsound'), 0.6);
        // if (thing.action == HEAL) human.health += thing.value;
    }

    function menuAction(thing:String) {
        //if (!isGenocide) monster.progress++; //ill attach this to something later
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
                useItem(undertale.SOUL.ITEMS.instance.useItem(thing));
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

    public function addToField(item:FlxObject) {
        if (item != null) add(item);
    }

    public function setAttack(curAtt:String)
    {
        switch (curAtt)
        {
            case 'test 1':
                curAttack = 'test 1';
                attackTimer = 1;
                interTimer = 12;
                triggered = false;
            default: //DONT TOUCH
                curAttack = '';
                attackTimer = -1;
                interTimer = -1;
                triggered = true;
        }
    }

    var allCheck = 0;
    var changeBoxSize:Bool = false;
    var selected:Bool = false;
    var inMenu:Bool = false;
    var measureAtk:Bool = false;
    var attacked:Bool = false;
    var damageArea:Int = 0;

    var attackTimer:Int = -1;
    var interTimer:Int = 0;
    var triggered:Bool = true;
    var sequence:EventSequence;
    var curAttack:String;
    var curTime:Float = 0;
    var dialTriggered:Bool = false;
    var allowUIDialogue:Bool = true;

    var pageMin:Int = 0;
    var pageMax:Int = 3;
    override function update(elapsed:Float) {
        //I love manually updating EVERYTHING!!!!
        target.animation.update(elapsed);
        slash.animation.update(elapsed);
        speechBubble.animation.update(elapsed);
        if (sequence != null) sequence.update();
        human.update(elapsed, soul);
        underText.update(elapsed);
        monsterText.update(elapsed);
        hp.updateBar();
        enemyHP.updateBar();

        if (human.health > human.maxHealth) human.health = human.maxHealth;
        if (monster.health < 0) monster.health = 0;
        health = human.health;
        healthTxt.text = human.health + ' / ' + human.maxHealth;

        enemyHealth = monster.health;
        enemyMaxHealth = monster.maxHealth;

        for (bullet in bulletGroup.members)
        {
            if (bullet != null && bullet.alpha == 0)
            {
                bulletGroup.remove(bullet);
            }
        }

        switch (curAttack)
        {
            case 'test 1':
                if (curTime % 20 == 0)
                {
                    var test:BULLETPATTERN;
                    var testSprite:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image('undertale/bullets/boneMini'));
                    testSprite.screenCenter();
                    testSprite.y += 200;
                    testSprite.scale.x = FlxG.random.float(1,2);
                    testSprite.scale.y = FlxG.random.float(1,2);
                    bulletGroup.add(testSprite);

                    var test = new BULLETPATTERN(testSprite, new undertale.BULLETPATTERN.DamageType(2));
                    test.moveTo(FlxG.random.int(-280, 1280), FlxG.random.int(-300, 1300), FlxG.random.int(1, 10));
                    test.moveTo(FlxG.random.int(-400, 1400), FlxG.random.int(-600, 1600), FlxG.random.int(1, 10));
                    test.fadeOut(FlxG.random.int(1, 10));
                    sequence.addEvent(test);
                }
            default:
                sequence.events = [];
        }
        if (triggered) curTime++;
        if (attackTimer > -1 && !triggered)
        {
            triggered = true;
            new FlxTimer().start(interTimer, function(tmr:FlxTimer) {
                if(tmr.finished && tmr.loopsLeft > 0) {
                    attackTimer--;
                }
                else if(tmr.finished && tmr.loopsLeft == 0) {
                    setAttack('');
                    for (i in bulletGroup.members)
                    {
                        bulletGroup.remove(i);
                    }
                    canMove = false;
                    attackTimer = -1;
                    curTime = 0;
                }
            }, attackTimer);
        }

        if (FlxG.keys.justPressed.B) canMove = false;
        if (FlxG.keys.justPressed.V) canMove = true;
        if (FlxG.keys.justPressed.I) isBlue = true;
        if (FlxG.keys.justPressed.O) isBlue = false;
        if (FlxG.keys.justPressed.Q) human.health--;
        if (FlxG.keys.justPressed.F) 
        {
            setAttack('test 1');
        }
        var upP = controls.UI_LEFT_P || controls.UI_UP_P;
		var downP = controls.UI_RIGHT_P || controls.UI_DOWN_P;
        var enter = controls.ACCEPT;
        var back = controls.BACK;
        if (underText.text.charAt(underText.text.length-1) == ".") underText.delay = 3;
        else underText.delay = daSpeed;
        if (underText.text.charAt(underText.text.length-1) == "\n") underText.delay = 0.3;
        else underText.delay = daSpeed;

        if (monsterText.text.charAt(underText.text.length-1) == ".") underText.delay = 3;
        else monsterText.delay = daSpeed;
        if (monsterText.text.charAt(underText.text.length-1) == "@") 
        {
            StringTools.replace(monsterText.text, '@', '\n');
            monsterText.delay = 0.3;
        }
        else monsterText.delay = daSpeed;
        if (!canMove)
        {
            if (curMenu == 'main')
            {
                allowUIDialogue = true;
                if (underText.alpha == 0) 
                {
                    typeFunc((if (monster.progress == 0) monster.initFlavorText else monster.flavorTextList[FlxG.random.int(0, monster.flavorTextList.length)]));
                    selected = false;
                    inMenu = false;
                }
                for (item in buttons.members)
                {
                    if (item.ID == curSelected && item.animation.curAnim.name == 'idle') changeSelection();
                }
            }

            if (curMenu == 'item')
            {
                //Extremely jank but it works
                if (curSelectedItem <= 3)
                {
                    pageMin = 0;
                    pageMax = 3;
                }
                else if (curSelectedItem <= 7)
                {
                    pageMin = 4;
                    pageMax = 7;
                }
                for (i in 0...menu.members.length)
                {
                    if (menu.members[i] != null)
                    {
                        if (menu.members[i].ID == curSelectedItem) menu.members[i].alpha = 1;
                        else if (menu.members[i].ID >= pageMin && menu.members[i].ID <= pageMax) menu.members[i].alpha = 0.5;
                        else menu.members[i].alpha = 0;
                    }
                }
            }

            if (!allowUIDialogue) typeFunc(true);
            
            if (curMenu == 'attack' && enter)
            {
                trace('Pressed enter!');
                curMenu = 'monDialogue';
            }
            
            if (curMenu == 'monDialogue' && !dialTriggered)
            {
                allowUIDialogue = false;
                speechFunc('right', 'hehehehe.\nbones.', 'Z11', 20);
                dialTriggered = true; //Safety my beloved
            }
            else if (curMenu == 'monDialogue' && enter)
            {
                speechFunc('empty');
                canMove = true;
                setAttack('test 1');
                curMenu = 'main';
            }
            
            if (curMenu != 'fight' || curMenu != 'monDialogue' || curMenu != 'attack')
            {
                if (upP)
                {
                    changeSelection(-1);
                }
                if (downP)
                {
                    changeSelection(1);
                }
            }
            else
            {
                soul.alpha = 0;
                for (item in buttons.members) item.animation.play('idle');
            }

            targetW = 800;

            if (!selected)
            {
                if (enter && !inMenu) 
                {
                    allowUIDialogue = false;
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
                            
                        selected = true;
                    }
                }
            }

            if (back && !selected)
            {
                regenMenu('MAIN');
            } 

            if (curMenu == 'fight')
            {
                if (!attacked)
                {
                    if (target.x == 240)
                    {           
                        FlxTween.tween(target, {alpha: 1}, 0.5);             
                        FlxTween.tween(battleThing, {alpha: 1}, 0.5);
                        FlxTween.tween(battleThing.scale, {x: 1.4, y:1.4}, 0.5);
                    }

                    if (target.x > 240 && damageArea < 90)
                    {
                        damageArea++;
                        if (FlxG.keys.justPressed.ENTER || FlxG.keys.justPressed.Z)
                        {
                            doAttack(damageArea);
                        }
                    }
                    else if (damageArea == 90)
                    {
                        doAttack(damageArea);
                    }
                    target.x += 10;
                }
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