package backend;

import flixel.FlxState;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.math.FlxRandom;
import flixel.state.*;
import substates.StickerSubState;
import flixel.FlxSprite;



class TransitionState {
    public static var stickers:FlxTypedGroup<StickerSprite>;
    static function switchState(targetState:Class<FlxState>, ?onComplete:Dynamic, ?stateArgs:Array<Dynamic> = null):Void {
        FlxG.switchState(Type.createInstance(targetState, stateArgs != null ? stateArgs : []));
        if (onComplete != null && Reflect.isFunction(onComplete)) {
            onComplete();
        }
        trace("Switched to state: " + Type.getClassName(targetState));
    }


    public static function transitionState(targetState:Class<FlxState>, options:Dynamic = null, ?args:Array<Dynamic>):Void {
        trace("Transitioning to state: " + Type.getClassName(targetState));
        trace("Options: " + options);
        if (options == null) {
            // If options are null, select a random transition
            trace("Random transition selected due to null options.");
            var transitions = ["fadeOut", "fadeColor", "slideLeft", "slideRight", "slideUp", "slideDown", "slideRandom", "fallRandom", "fallSequential", "stickers"];
            var random = new FlxRandom();
            options = {
                transitionType: transitions[random.int(0, transitions.length - 1)],
                duration: random.float(0.5, 2), // Random duration between 0.5 and 2 seconds
                color: random.color() // Random color for fadeColor transition
            };
            trace("Random options: " + options);
        }
        var duration:Float = options != null && Reflect.hasField(options, "duration") ? options.duration : 1;
        var onComplete = options != null && Reflect.hasField(options, "onComplete") ? options.onComplete : null;
        var transitionType:String = options != null && Reflect.hasField(options, "transitionType") ? options.transitionType : "fadeOut";
        trace("Transition type: " + transitionType);
        trace("Duration: " + duration);
        trace("On complete: " + onComplete);
        trace("Args: " + args);
        trace("Target state: " + Type.getClassName(targetState));
        trace("Options: " + options);
        
        switch (transitionType) {
            case "fadeOut":
                FlxTween.tween(FlxG.camera, { alpha: 0 }, duration, {
                    onComplete: function(_) {
                        switchState(targetState, onComplete, args);
                    }
                });
            case "fadeColor":
                var color:Int = options != null && Reflect.hasField(options, "color") ? options.color : FlxColor.BLACK;
                FlxG.camera.fade(color, duration, true, function():Void {
                    switchState(targetState, onComplete, args);
                });
            case "slideLeft":
                slideScreen(-FlxG.width, 0, duration, targetState, onComplete, args);
            case "slideRight":
                slideScreen(FlxG.width, 0, duration, targetState, onComplete, args);
            case "slideUp":
                slideScreen(0, -FlxG.height, duration, targetState, onComplete, args);
            case "slideDown":
                slideScreen(0, FlxG.height, duration, targetState, onComplete, args);
            case "slideRandom":
                var directions = ["slideLeft", "slideRight", "slideUp", "slideDown"];
                var randomDirection = new FlxRandom().shuffleArray(directions, 1)[0];
                transitionState(targetState, { duration: duration, transitionType: randomDirection, onComplete: onComplete }, args);
                return; // Prevent further execution in this call
                case "fallRandom":
                    var sprites: Array<FlxSprite> = [];
                    var completedTweens = 0;
                    var totalTweens = 0;
                
                    // Collect valid sprites
                    trace("Collecting sprites...");
                    for (object in FlxG.state.members) {
                        if (object != null && Std.is(object, FlxSprite)) {
                            sprites.push(cast(object));
                        }
                    }
                    totalTweens = sprites.length;
                
                    // Function to check if all tweens are complete
                    var checkAllComplete = function() {
                        if (completedTweens >= totalTweens) {
                            switchState(targetState, onComplete, args);
                        }
                    };
                
                    // Apply a tween to each sprite with a random delay
                    for (sprite in sprites) {
                        var delay = FlxG.random.float(0, 1); // Adjust max delay as needed
                        var direction = FlxG.random.float(-1, 1);
                        var timer = new FlxTimer();
                        timer.start(delay, function(timer:FlxTimer) {
                            FlxTween.tween(sprite, { y: FlxG.height + sprite.height, x: sprite.x + direction * FlxG.random.float(100, 200) }, duration, {
                                onComplete: function(_) {
                                    sprite.exists = false;
                                    completedTweens++;
                                    checkAllComplete();
                                }
                            });
                        }, 1);
                    }
                
                    // In case there are no sprites, directly switch state
                    if (totalTweens == 0) {
                        switchState(targetState, onComplete, args);
                    }
                
                case "fallSequential":
                    var randomDirection:Bool = true; // Ensure this is defined appropriately
                    var delayIncrement = 0.0;
                    var objectsToTween: Array<FlxSprite> = [];
                    
                    // Collect valid objects first
                    trace("Collecting sprites...");

                    for (object in FlxG.state.members) {
                        if (object != null && Std.is(object, FlxSprite)) {
                            objectsToTween.push(cast(object));
                        }
                    }
                    
                    // Function to process each object with a delay
                    var processNextObject: Void->Void = null;
                    processNextObject = function() {
                        if (objectsToTween.length > 0) {
                            var sprite = objectsToTween.shift();
                            var direction = randomDirection ? FlxG.random.float(-1, 1) : 0;
                            FlxTween.tween(sprite, { y: FlxG.height + sprite.height, x: sprite.x + direction * FlxG.random.float(100, 200) }, duration, {
                                onComplete: function(_) {
                                    sprite.exists = false;
                                    new FlxTimer().start(0.1, function(timer:FlxTimer) { processNextObject(); }, 1);
                                }
                            });
                        } else {
                            // All objects processed, switch state
                            switchState(targetState, onComplete, args);
                        }
                    };
                    
                    // Start processing with the first object
                    processNextObject();

                    case "stickers":
                        FlxG.state.openSubState(new substates.StickerSubState(null,  (sticker) -> Type.createInstance(targetState, args != null ? args : [])));

                // case "stickersAlt": 
                //     var stickers: Array<FlxSprite> = [];
                //     var completedTweens = 0;
                //     var totalTweens = 0;
                
                //     // Collect valid sprites
                //     for (object in FlxG.state.members) {
                //         if (object != null && Std.is(object, FlxSprite)) {
                //             stickers.push(cast(object));
                //         }
                //     }
                //     totalTweens = stickers.length;
                
                //     // Function to check if all tweens are complete
                //     var checkAllComplete = function() {
                //         if (completedTweens >= totalTweens) {
                //             switchState(targetState, onComplete, args);
                //         }
                //     };
                
                //     // Apply a tween to each sprite with a random delay
                //     for (sticker in stickers) {
                //         var delay = FlxG.random.float(0, 1); // Adjust max delay as needed
                //         var direction = FlxG.random.float(-1, 1);
                //         var timer = new FlxTimer();
                //         timer.start(delay, function(timer:FlxTimer) {
                //             FlxTween.tween(sticker, { y: FlxG.height + sticker.height, x: sticker.x + direction * FlxG.random.float(100, 200) }, duration, {
                //                 onComplete: function(_) {
                //                     sticker.exists = false;
                //                     completedTweens++;
                //                     checkAllComplete();
                //                 }
                //             });
                //         }, 1);
                //     }
                
                    // In case there are no sprites, directly switch state
                 //   if (totalTweens == 0) {
                   //     switchState(targetState, onComplete, args);
        }
        trace("Transition complete!");
}

    static function slideScreen(x:Float, y:Float, duration:Float, targetState:Class<FlxState>, onComplete:Dynamic, ?args:Array<Dynamic>):Void {
        FlxTween.tween(FlxG.camera.scroll, { x: x, y: y }, duration, {
            onComplete: function(_) {
                switchState(targetState, onComplete, args);
            }
        });
    }

    function getTargetState(state:FlxState) {
        
    }
}