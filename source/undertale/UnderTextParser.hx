package undertale;

import flixel.addons.text.FlxTypeText;
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
        if (_waiting || paused) return;

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

        if (_typing || _erasing) {
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
                                        speed = defaultSpeed - fastSpeed;
                                    });
                                }
                            case 'pause':
                                var pauseDuration:Float = Std.parseFloat(parts[2]);
                                if (!Math.isNaN(pauseDuration)) {
                                    formattingLocations.set(result.length, function() {
                                        pauseDuration = this.pauseDuration;
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

// class PatternSplitter {
//     public static function splitWithPattern(input:String, brackets:Array<String>, splits:Array<String>):Dynamic {
//         var partsArray:Array<String> = [];
//         var bracketStr:String = brackets.join('');

//         // Find the start and end positions of the pattern using the brackets
//         var startBracket:String = brackets[0];
//         var endBracket:String = brackets[1];
//         var startPos:Int = input.indexOf(startBracket);
//         var endPos:Int = input.indexOf(endBracket, startPos + 1);

//         if (startPos != -1 && endPos != -1) {
//             // Extract the content inside the brackets
//             var content:String = input.substring(startPos + 1, endPos);

//             // Split the content using the provided splits
//             var splitPattern:String = splits.join('|');
//             var parts:Array<String> = content.split(new EReg(splitPattern, 'g'));

//             // Add the parts to partsArray
//             for (part in parts) {
//                 partsArray.push(part);
//             }

//             // Add the splits to partsArray
//             for (split in splits) {
//                 partsArray.push(split);
//             }
//         }

//         return { partsArray: partsArray, brackets: bracketStr };
//     }
// }

