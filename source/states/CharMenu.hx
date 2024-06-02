package states;

import backend.Section.SwagSection;
import backend.Song.SwagSong;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.effects.FlxFlicker;
import flixel.group.FlxGroup;
import flixel.util.FlxTimer;
import lime.utils.Assets;
import haxe.Json;
import objects.Boyfriend.Boyfriend;
import objects.Character.Character;
import objects.HealthIcon;
import flixel.ui.FlxBar;
import flixel.addons.transition.FlxTransitionableState;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
#if MODS_ALLOWED
import sys.io.File;
import sys.FileSystem;
#end

typedef CharacterMenu = {
    var name:String;
    var characterName:String;
    var portrait:String;
}

class CharMenu extends MusicBeatState
{
    public static var menuItems:Array<String> = ['bf'];
    public static var characters:Array<String> = [''];
    var daBG:Array<String> = ['BG11', 'Screen'];

    public static var curSelected:Int = 0;
    var txtDescription:FlxText;
    var gimmikName:FlxText;
    var gimmikDescription:FlxText;
    var shitCharacter:FlxSprite;
	var shitCharacterBetter:Boyfriend;
    var icon:HealthIcon;
    var menuBG:FlxSprite;
    var pausebg:FlxSprite;
    public var tagertY:Float = 0;
    public var iconbf:Boyfriend;
    public static var characterShit:Array<CharacterMenu>;
	public static var gftype:String = 'gf';
    public static var daSelected:String = menuItems[curSelected];
    public static var curCharacter:Int = 0;
    public var curCharacter2:String = DEFAULT_CHARACTER;
    private var grpMenu:FlxTypedGroup<Alphabet>;
    private var grpMenuImage:FlxTypedGroup<FlxSprite>;
    public static var alreadySelected:Bool = false;
    var doesntExist:Bool = false;
    private var iconArray:Array<Boyfriend> = [];
    public static var custom:Bool = false;
    public static var DEFAULT_CHARACTER:String = 'bf'; //In case a character is missing, it will use BF on its place
    public static var bfOnly:Bool = false;
    public static var bfsOnly:Bool = false;
    public static var diffallow:Bool = false;
    public var sh_r:Float = 600;
    var unlockCheck:Array<Bool> = [FlxG.save.data.bfMultiUnlock, 
        FlxG.save.data.playableGFUnlock, FlxG.save.data.playablejellyUnlock, 
        FlxG.save.data.playableneoUnlock, FlxG.save.data.playablespoopyUnlock];

    public var names:Array<String> = ["(PICKING THIS CHARACTER WILL SET BF AND GF TO SONG DEFAULT)"];

    var txtOptionTitle:FlxText;

    override function create() 
    {
        ClientPrefs.loadCharSlect();
        alreadySelected = false;    

        bfsOnly = bfOnly;

        if (bfOnly)
        {
            menuItems = ['bf'];
        }

        if (unlockCheck[0])
        {
            menuItems.push('bf-multi');
            names.push("Bf but he's WAY too smooth.");
        }

        if (unlockCheck[1])
        {
            menuItems.push('playablegf');
            names.push('Playable GF By Dusk!, Voideyedpanda and Redsty Phoenix');
            menuItems.push('playablegfdemon');
            names.push('Playable GF By Dusk!, Voideyedpanda and Redsty Phoenix (Demon Ver.)');
        }

        if (unlockCheck[2])
        {
            menuItems.push('playablegfjelly');
            names.push('Playable GF By Dusk! and bluberries');
        }
        
        if (unlockCheck[3])
        {
            menuItems.push('playablegfneo');
            names.push('Playable GF By Dusk! and Mr.M0isty');
        }

        if (unlockCheck[4])
        {
            menuItems.push('playablegfcatmaid');
            names.push('Playable GF By Dusk! and iov');
        }

        if (unlockCheck[5])
        {
            menuItems.push('spooky-bfgf');
            names.push('BF and GF Doing Da Spooky Dance by coldjam');
        }
        
        menuBG = new FlxSprite().loadGraphic(Paths.image(daBG[FlxG.random.int(1, 2)]));
        menuBG.setGraphicSize(Std.int(menuBG.width * 1.1));
        menuBG.updateHitbox();
        menuBG.screenCenter();
        menuBG.antialiasing = true;
        add(menuBG);

        if (!ClientPrefs.data.lowQuality)
        {
            pausebg = new FlxSprite().loadGraphic(Paths.image('pausemenubg'));
            pausebg.color = 0xFF1E1E1E;
            pausebg.scrollFactor.set();
            pausebg.updateHitbox();
            pausebg.screenCenter();
            pausebg.antialiasing = ClientPrefs.data.globalAntialiasing;
            add(pausebg);
            pausebg.x += 200;
            pausebg.y -= 200;
            pausebg.alpha = 0;
            FlxTween.tween(pausebg, {
                x: 0,
                y: 0,
                alpha: 1
            }, 1, {ease: FlxEase.quadOut});
        }

        grpMenu = new FlxTypedGroup<Alphabet>();
        add(grpMenu);

        grpMenuImage = new FlxTypedGroup<FlxSprite>();
        add(grpMenuImage);

        for (i in 0...menuItems.length)
        {
            var songText:Alphabet = new Alphabet(170, (70 * i) + 230, menuItems[i], true);
            songText.isMenuItem = true;
            songText.targetY = i;
            grpMenu.add(songText);
            //songText.x += 40;
            //DON'T PUT X IN THE FIRST PARAMETER OF new ALPHABET()!
            //songText.screenCenter(X);
            iconbf = new Boyfriend(0, 0, menuItems[i]);
            iconbf.screenCenter(XY);
            //icon.scale.set(0.8, 0.8);

            //Using a FlxGroup is too much fuss!
            iconArray.push(iconbf);
            add(iconbf);
        }

        var charSelHeaderText:Alphabet = new Alphabet(0, 50, 'Character Select', true);
        charSelHeaderText.screenCenter(X);
        add(charSelHeaderText);

        var arrows:FlxSprite = new FlxSprite().loadGraphic(Paths.image('arrows'));
        arrows.setGraphicSize(Std.int(arrows.width * 1.1));
        arrows.screenCenter();
        arrows.antialiasing = true;
        add(arrows);

        txtOptionTitle = new FlxText(FlxG.width * 0.7, 10, 0, "", 32);
        txtOptionTitle.setFormat("assets/fonts/FridayNightFunkin.ttf", 32, FlxColor.WHITE, RIGHT);
        txtOptionTitle.alpha = 0.7;
        add(txtOptionTitle);

        changeSelection();

        cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];

        super.create();
    }

    override function update(elapsed:Float) 
    {
        txtOptionTitle.text = names[curSelected].toUpperCase();
        txtOptionTitle.x = FlxG.width - (txtOptionTitle.width +10);
        if (txtOptionTitle.text == '')
        {
            txtOptionTitle.text = 'blank lmao';
        }    

        var upP = controls.UI_LEFT_P;
        var downP = controls.UI_RIGHT_P;
        var accepted = controls.ACCEPT;

        if (!alreadySelected)
        {
            if (iconArray[curSelected].animation.curAnim.name == 'idle' && iconArray[curSelected].animation.curAnim.finished && doesntExist)
                iconArray[curSelected].playAnim('idle', true);

            if (upP) changeSelection(-1);

            if (downP) changeSelection(1);
            
            if (accepted)
            {
                if (iconArray[curSelected].hasHeyAnimations && doesntExist)
                    iconArray[curSelected].playAnim('hey', true);
                else if (!iconArray[curSelected].hasHeyAnimations && doesntExist)
                    iconArray[curSelected].playAnim('singUP', true);
                FlxFlicker.flicker(iconArray[curSelected], 0);
                alreadySelected = true;
                daSelected = menuItems[curSelected];
                if (menuItems[curSelected] != 'bf')
                {
                    PlayState.SONG.player1 = daSelected;
                    PlayState.SONG.gfVersion = gftype;
                }
                FlxG.sound.play(Paths.sound('confirmMenu'));
                new FlxTimer().start(1, function(tmr:FlxTimer)
                {
                    FlxG.switchState(new MainMenuState());
                });
            }
            
            if (controls.BACK) FlxG.switchState(new MainMenuState());
        }

        super.update(elapsed);
        var rotRateSh = (elapsed/100) / 9.5;
        var sh_toy = -Math.sin(rotRateSh * 2) * sh_r * 0.45;
        for (item in grpMenu.members)
        {
            item.x += (sh_toy - item.x) / 12;
        }

        if (FlxG.sound.music != null)
            Conductor.songPosition = FlxG.sound.music.time;
    }

    function changeSelection(change:Int = 0):Void
        {
            curSelected += change;

            if (curSelected < 0)
                curSelected = menuItems.length - 1;
            if (curSelected >= menuItems.length)
                curSelected = 0;

            /*if (ginAllowed && !bfOnly)
            {
                if (curSelected < 0)
                    curSelected = 0;
                if (curSelected >= 24)
                    curSelected = 0;
            }
            if (!ginAllowed && !bfOnly)
            {
                if (curSelected < 0)
                    curSelected = 0;
                if (curSelected >= 23)
                    curSelected = 0;
            }
            if (bfOnly)
            {
                if (curSelected < 0)
                    curSelected = 0;
                if (curSelected >= 0)
                    curSelected = 0;
            }*/
            var otherInt:Int = 0;

            for (i in 0...iconArray.length)
                {
                    iconArray[i].alpha = 0;
                }
            
            iconArray[curSelected].alpha = 1;
            iconArray[curSelected].screenCenter(XY);

            /*if (curSelected == otherInt)
            {
                menuItems.alpha = 0;
            }*/

            for (item in grpMenu.members)
                {
                    item.targetY = otherInt - curSelected;
                    otherInt++;

                    item.alpha = 0;
                    //item.setGraphicSize(Std.int(item.width * 0.8));

                    if (item.targetY == 0)
                        {
                            // item.setGraphicSize(Std.int(item.width));
                        }
                }
            
            charCheck();
        }

        function charCheck()
        {
            doesntExist = false;
            daSelected= menuItems[curSelected];
            var storedColor:FlxColor = 0xFFFFFF;
            remove(icon);

            switch (daSelected)
            {
                case "bf-multi":
                    menuBG.color = 0x87ceeb;
                    gftype = 'gfReanim';
                case "playablegf" | "playablegfdemon":
                    menuBG.color = 0xc42121;
                    gftype = 'bfgf';
                case "playablegfjelly":
                    menuBG.color = 0xc42121;
                    gftype = 'bfgf';
                case "playablegfneo":
                    menuBG.color = 0x251a9d;
                    gftype = 'bfgf';
                case "playablegfcatmaid":
                    menuBG.color = 0xc42121;
                    gftype = 'bfgf';
                case "spooky-bfgf":
                    menuBG.color = 0x87ceeb;
                    gftype = 'Empty';
                default:
                    menuBG.color = 0x87ceeb;
                    gftype = 'gf';
            }

            //shitCharacter.updateHitbox();
            //shitCharacter.screenCenter(XY);

            doesntExist = true;

            var healthBarBG:FlxSprite = new FlxSprite(0, FlxG.height * 0.9).loadGraphic('healthBar');
            healthBarBG.screenCenter(X);
            healthBarBG.scrollFactor.set();
            healthBarBG.visible = false;
            add(healthBarBG);

            var healthBar:FlxBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), this,
                'health', 0, 2);
            healthBar.scrollFactor.set();
            healthBar.createFilledBar(0xFFFF0000, 0xFFFF0000);
            healthBar.visible = false;
            // healthBar
            add(healthBar);
            icon = new HealthIcon(menuItems[curSelected], true);
            icon.y = healthBar.y - (icon.height / 2);
            icon.screenCenter(X);
            icon.setGraphicSize(-4);
            icon.y -= 20;
            add(icon); 
        }
    
        override function beatHit()
        {
            super.beatHit();
    
            FlxG.camera.zoom = zoomies;
    
            FlxTween.tween(FlxG.camera, {zoom: 1}, Conductor.crochet / 1300, {
                ease: FlxEase.quadOut
            });
        }
}