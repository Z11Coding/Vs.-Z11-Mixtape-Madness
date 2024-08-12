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

    private function handleFormattingTags(text:String):Map<Int, Void->Void> {
        var formattingLocations:Map<Int, Void->Void> = new Map<Int, Void->Void>();
        var i:Int = 0;
        while (i < text.length) {
            if (text.charAt(i) == '[') {
                var endTag:Int = text.indexOf(']', i);
                if (endTag != -1) {
                    var tag:String = text.substring(i + 1, endTag);
                    var parts:Array<String> = tag.split(":");
                    switch (parts[0]) {
                        case 'slow':
                            var slowSpeed:Float = parseFloat(parts[1]);
                            if (!Math.isNaN(slowSpeed)) {
                                formattingLocations.set(i, function() {
                                    speed = defaultSpeed + slowSpeed;
                                });
                            }
                        case 'fast':
                            var fastSpeed:Float = parseFloat(parts[1]);
                            if (!Math.isNaN(fastSpeed)) {
                                formattingLocations.set(i, function() {
                                    speed = defaultSpeed - fastSpeed;
                                });
                            }
                        case 'pause':
                            var pauseDuration:Float = parseFloat(parts[1]);
                            if (!Math.isNaN(pauseDuration)) {
                                formattingLocations.set(i, function() {
                                    pauseDuration = this.pauseDuration;
                                });
                            }
                        default:
                            trace("Unknown tag: " + parts[0]);
                    }
                    i = endTag + 1;
                    continue;
                }
            }
            i++;
        }
        return formattingLocations;
    }
    
    private function removeFormattingTags(text:String):String {
        var result:String = "";
        var i:Int = 0;
        var offset:Int = 0; // to keep track of the offset caused by tag removal
        while (i < text.length) {
            if (text.charAt(i) == '[') {
                var endTag:Int = text.indexOf(']', i);
                if (endTag != -1) {
                    var tagLength:Int = endTag - i + 1;
                    var tagIndex:Int = i - offset; // adjust the index based on the offset
                    _formattingLocations.remove(tagIndex); // remove the old index
                    i = endTag + 1;
                    offset += tagLength; // update the offset
                    continue;
                }
            }
            result += text.charAt(i);
            i++;
        }
    
        // update the remaining indices in _formattingLocations
        var updatedLocations:Map<Int, Void->Void> = new Map<Int, Void->Void>();
        for (index in _formattingLocations.keys()) {
            var newIndex:Int = index - offset;
            var value:Void->Void = _formattingLocations.get(index);
            updatedLocations.set(newIndex, value);
        }
        _formattingLocations = updatedLocations;
    
        return result;
    }
    
    // Example usage
    private function processText(text:String):String {
        _formattingLocations = handleFormattingTags(text);
        return removeFormattingTags(text);
    }

    private function reactFunction():Void {
        // Code to react when typedText reaches the specified location
    }
}