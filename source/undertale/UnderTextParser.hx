package undertale;

import flixel.addons.text.FlxTypeText;
import flixel.input.keyboard.FlxKey;
import flixel.FlxG;

class UnderTextParser extends FlxTypeText {
    private var speed:Float;
    private var defaultSpeed:Float;
    private var pauseDuration:Float;
    private var _formattingLocations:Map<Int, Void->Void>;

    public function new(X:Float, Y:Float, Width:Int, Text:String, Size:Int = 8, EmbeddedFont:Bool = true, Speed:Float = 0.05) {
        super(X, Y, Width, "", Size, EmbeddedFont);
        this._finalText = processText(Text);
        this.defaultSpeed = Speed;
        this.speed = Speed;
        this.pauseDuration = 0;
    }

    override public function update(elapsed:Float):Void {
        //if (_waiting || paused) return;

        for (index in _formattingLocations.keys()) {
            if (_length == index) {
                var value:Void->Void = _formattingLocations.get(index);
                value();
            }
        }

        delay = speed;  

        if (pauseDuration > 0) {
            pauseDuration -= elapsed;
            paused = true;
            return;
        }

        if (pauseDuration <= 0) {
            paused = false;
            pauseDuration = 0;
        }

        if (_length < _finalText.length && _typing) {
            _timer += elapsed;
        }

        if (_length > 0 && _erasing) {
            _timer += elapsed;
        }

        if ((_typing || _erasing) && !paused) {
            if (_typing && _timer >= speed) {
                _length += Std.int(_timer / speed);
                if (_length > _finalText.length) _length = _finalText.length;
                _timer = 0;
            }

            if (_erasing && _timer >= speed) {
                _length -= Std.int(_timer / speed);
                if (_length < 0) _length = 0;
                _timer = 0;
            }

            if ((_typing && _timer >= speed) || (_erasing && _timer >= speed)) {
                _timer = 0;
            }
        }

        super.update(elapsed);
    }

    private function processText(text:String):String {
        var formattingLocations:Map<Int, Void->Void> = new Map<Int, Void->Void>();
        var result:String = "";
        var i:Int = 0;
        var offset:Int = 0; // to keep track of the offset caused by tag removal
    
        while (i < text.length) {
            if (text.charAt(i) == '[') {
                var endTag:Int = text.indexOf(']', i);
                if (endTag != -1) {
                    var tag:String = text.substring(i, endTag + 1);
                    var splitResult = PatternSplitter.splitWithPattern(tag);
                    if (splitResult.brackets == '[]') {
                        var parts:Array<String> = splitResult.partsArray;
                        switch (parts[0]) {
                            case 'slow':
                                var slowSpeed:Float = Std.parseFloat(parts[2]);
                                if (!Math.isNaN(slowSpeed)) {
                                    formattingLocations.set(result.length, function() {
                                        speed = defaultSpeed + slowSpeed;
                                    });
                                }
                            case 'fast':
                                var fastSpeed:Float = Std.parseFloat(parts[2]);
                                if (!Math.isNaN(fastSpeed)) {
                                    formattingLocations.set(result.length, function() {
                                        if ((defaultSpeed - fastSpeed) > 0) speed = defaultSpeed - fastSpeed;
                                        else trace('Your speed is too fast!');
                                    });
                                }
                            case 'setspeed':
                                var setSpeed:Float = Std.parseFloat(parts[2]);
                                if (!Math.isNaN(setSpeed)) {
                                    formattingLocations.set(result.length, function() {
                                        speed = setSpeed;
                                    });
                                }
                            case 'pause':
                                var pDuration:Float = Std.parseFloat(parts[2]);
                                if (!Math.isNaN(pDuration)) {
                                    formattingLocations.set(result.length, function() {
                                        pauseDuration = pDuration;
                                        _length++;
                                    });
                                }
                            case 'reset':
                                formattingLocations.set(result.length, function() {
                                    speed = defaultSpeed;
                                    pauseDuration = 0;
                                });
                            default:
                                trace("Unknown tag: " + parts[0]);
                        }
                        i = endTag + 1;
                        continue;
                    }
                }
            }
            result += text.charAt(i);
            i++;
        }
    
        // Update the remaining indices in formattingLocations
        var updatedLocations:Map<Int, Void->Void> = new Map<Int, Void->Void>();
        for (index in formattingLocations.keys()) {
            var newIndex:Int = index - offset;
            var value:Void->Void = formattingLocations.get(index);
            updatedLocations.set(newIndex, value);
        }
        formattingLocations = updatedLocations;
    
        _formattingLocations = formattingLocations;
        return result;
    }

    public override function resetText(text:String):Void {
        _finalText = processText(text);
        super.resetText(_finalText);
    }

    private function reactFunction():Void {
        // Code to react when typedText reaches the specified location
    }
}

class PatternSplitter {
    public static function splitWithPattern(input:String):Dynamic {
        var partsArray:Array<String> = [];
        var brackets:String = '';

        // Regular expression to match the pattern [tag:value]
        var pattern:EReg = ~/^\[(\w+):(\d+(\.\d+)?)\]$/;

        if (pattern.match(input)) {
            var tag:String = pattern.matched(1);
            var value:String = pattern.matched(2);

            partsArray.push(tag);
            partsArray.push(':');
            partsArray.push(value);

            brackets = '[]';
        }

        return { partsArray: partsArray, brackets: brackets };
    }
}
