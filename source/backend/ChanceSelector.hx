package backend;

typedef Chance = {
    item: Dynamic,
    chance: Float // Probability as a percentage (0 to 100)
};
typedef ChanceFunction = {
    func: Void -> Dynamic, // Function to execute
    chance: Float // Chance of execution, assumed to be between 0 and 100
};
class ChanceSelector {
    public static function selectOption(options:Array<Chance>, strict:Bool = false, downsize:Bool = true):Dynamic {
        //trace("Entering selectOption function");
        //trace("Input options: " + options);

        // Validate total probability
        var totalChance:Float = 0;
        for (o in options) {
            if (o.chance < 0 || o.chance > 100) throw 'Chance must be between 0 and 100';
            totalChance += o.chance;
        }
        //trace("Total probability: " + totalChance);

        if (totalChance > 100 && strict) throw 'Total chance exceeds 100%';
        
        if (downsize && totalChance > 100) {
            var scaleFactor:Float = 100 / totalChance;
            for (o in options) {
                o.chance *= scaleFactor;
            }
            totalChance = 100;
        }



        // Create a weighted list ensuring unique items
        var weightedList:Array<Dynamic> = [];
        var totalWeight:Float = 0;
        for (o in options) {
            totalWeight += o.chance;
        }
        var normalizationFactor:Float = 100 / totalWeight; // Adjust based on total weight to ensure representation
        
        for (o in options) {
            // Adjust the count based on the normalization factor to ensure representation
            var count:Float = Math.max(1, Math.round(o.chance * normalizationFactor));
            for (i in 0...Math.floor(count)) {
            weightedList.push(o.item);
            }
        }
        // Convert weighted list into a structured list of potential
        var potentialList:Array<{ item: Dynamic, potential: Float }> = [];
        for (o in options) {
            var potential: Float = o.chance / totalChance;
            potentialList.push({ item: o.item, potential: potential });
        }
        //trace("Potential list: " + potentialList);

        // Random selection from the weighted list
        var randomIndex = Std.random(weightedList.length);
        var selectedOption = weightedList[randomIndex];
        //trace("Selected option: " + selectedOption);

        return selectedOption;
    }

    public static function fromArray(items:Array<Dynamic>):Array<Chance> {
        trace("Entering fromArray function");
        trace("Input items: " + items);

        var options:Array<Chance> = [];
        var chancePerItem = 100 / items.length;
        for (item in items) {
            options.push({item: item, chance: chancePerItem});
        }
        trace("Output options: " + options);

        return options;
    }

    public static function fromMap(map:Map<Dynamic, Float>):Array<Chance> {
        trace("Entering fromMap function");
        trace("Input map: " + map);

        var options:Array<Chance> = [];
        var totalChance:Float = 0;
        for (item in map.keys()) {
            var chance = map.get(item);
            options.push({item: item, chance: chance});
            totalChance += chance;
        }

        if (totalChance > 100) {
            var scaleFactor:Float = 100 / totalChance;
            for (o in options) {
                o.chance *= scaleFactor;
            }
        }

        trace("Output options: " + options);

        return options;
    }

    public static function chanceArrays(items:Array<Dynamic>, chances:Array<Float> = null):Dynamic {
        trace("Entering chanceArrays function");
        trace("Input items:" + items);
        trace("Input chances: " + chances);

        if (chances != null && items.length != chances.length) {
            throw 'Items and chances arrays must be of the same length';
        }

        var options:Array<Chance> = [];
        if (chances == null) {
            // If no chances are provided, distribute chances equally
            var equalChance = 100 / items.length;
            for (item in items) {
                options.push({item: item, chance: equalChance});
            }
        } else {
            // Pair each item with its corresponding chance
            for (i in 0...items.length) {
                options.push({item: items[i], chance: chances[i]});
            }
        }
        trace("Output options: " + options);

        var selectedOption = selectOption(options);
        trace("Selected option: " + selectedOption);

        return selectedOption;
    }

    // Method to accept chance objects directly
    public static function selectFromOptions(options:Array<Chance>):Dynamic {
        trace("Entering selectFromOptions function");
        trace("Input options: " + options);

        var selectedOption = selectOption(options);
        trace("Selected option: " + selectedOption);

        return selectedOption;
    }

    // Method to create chance objects from maps
    public static function selectFromMap(itemChancesMap:Map<Dynamic, Float>):Dynamic {
        //trace("Entering selectFromMap function");
        //trace("Input itemChancesMap: " + itemChancesMap);

        var options:Array<Chance> = [];
        for (item in itemChancesMap.keys()) {
            var chance = itemChancesMap.get(item);
            options.push({item: item, chance: chance});
        }
        //trace("Output options: " +options);

        var selectedOption = selectOption(options);
        //trace("Selected option: " + selectedOption);

        return selectedOption;
    }

        /**
     * Attempts to execute a ChanceFunction based on its chance.
     * @param chanceFunc The ChanceFunction to potentially execute.
     */
     public static function executeChanceFunction(chanceFunc:ChanceFunction):Dynamic {
        var randomNumber = Math.random() * 100; // Generate a random number between 0 and 100
        if (randomNumber <= chanceFunc.chance) {
           return chanceFunc.func(); // Execute the function if the random number is within the chance threshold
        }
        return null; // Return null if the function is not executed
    }
    
    /**
     * Creates and possibly executes a ChanceFunction upon initialization.
     * @param func The function to potentially execute.
     * @param chance The chance of the function being executed.
     */
    public static function chanceFunction(func:Void->Dynamic, chance:Float):Void {
        var chanceFunc:ChanceFunction = {func: func, chance: chance};
        executeChanceFunction(chanceFunc); // Attempt to execute the ChanceFunction
    }
}

class ChanceExtensions {

    public static function isChance(item:Dynamic):Bool {
        return Reflect.hasField(item, "item") && Reflect.hasField(item, "chance") && Std.is(item.chance, Float);
    }

    // Extension method for Array
    public static function chanceArray(array:Array<Dynamic>):Dynamic {
        trace("Entering chanceArray function");
        trace("Input array: " + array);

        var options = ChanceSelector.fromArray(array);
        trace("Options: " + options);

        var selectedOption = ChanceSelector.selectOption(options);
        trace("Selected option: " + selectedOption);

        return selectedOption;
    }

    // Extension method for Map
    public static function chanceMap(map:Map<Dynamic, Float>):Dynamic {
        //trace("Entering chanceMap function");
        //trace("Input map: " + map);

        var selectedOption = ChanceSelector.selectFromMap(map);
        //trace("Selected option: " + selectedOption);

        return selectedOption;
    }

    public static function chanceDynamicMap(map:Map<Dynamic, Dynamic>, returnKey:Bool = true):Dynamic {
        trace("Entering chanceDynamicMap function");
        trace("Input map: " + map);
        trace("Input returnKey: " + returnKey);

        var array:Array<Dynamic> = [];
        for (item in map.keys()) {
            array.push(item);
        }

        var options = ChanceSelector.fromArray(array);
        trace("Options: " + options);

        var selectedOption = ChanceSelector.selectOption(options);
        trace("Selected option: " + selectedOption);

        if (returnKey) {
            return selectedOption;
        } else {
            return map.get(selectedOption);
        }
    }

    // Extension method for Bool
    public static function chanceBool(value:Bool, chance:Float):Bool {
        trace("Entering chanceBool function");
        trace("Input value: " + value);
        trace("Input chance: " + chance);

        var oppositeValueChance = 100 - chance;
        var options:Array<Chance> = [
            {item: value, chance: chance},
            {item: !value, chance: oppositeValueChance}
        ];
        trace("Options: "+ options);

        var selectedOption = ChanceSelector.selectFromOptions(options);
        trace("Selected option: "  , selectedOption);

        return selectedOption;
    }

    // Extension method for weighted bool
    public static function TrueFalse(trueChance:Float, falseChance:Float):Bool {
        trace("Entering TrueFalse function");
        trace("Input trueChance: "+ trueChance);
        trace("Input falseChance: "+ falseChance);

        var options:Array<Chance> = [
            {item: true, chance: trueChance},
            {item: false, chance: falseChance}
        ];
        trace("Options: " + options);

        var selectedOption = ChanceSelector.selectFromOptions(options);
        trace("Selected option: " , selectedOption);

        return selectedOption;
    }

        // Extension method for FlxG
        public static function chanceInt(min:Int, max:Int):Int {
            trace("Entering chanceInt function");
            trace("Input min: " +min);
            trace("Input max: " + max);
    
            var options:Array<Chance> = [];
            for (i in min...max+1) {
                options.push({item: i, chance: 100});
            }
            trace("Options: " + options);
    
            var selectedOption = ChanceSelector.selectFromOptions(options);
            trace("Selected option: " , selectedOption);
    
            return selectedOption;
        }
    
    // public static function chanceAny(input:Dynamic, splitComplexTypes:Bool = false, treatMapsAsChanceMaps:Bool = false, passChanceObjectsFromArray:Bool = true):Dynamic {
    //     if (splitComplexTypes) {
    //         if (Std.is(input, Array)) {
    //             // Handle Array: Split into chance objects
    //             if (passChanceObjectsFromArray) {
    //                 return input.map(item -> {
    //                     if (Std.is(item, Chance)) {
    //                         return item;
    //                     } else {
    //                         return {item: item, chance: 100 / input.length};
    //                     }
    //                 });
    //             } else {
    //                 return input.map(item -> ChanceSelector.selectOption([{item: item, chance: 100 / input.length}]));
    //             }
    //         } else if (Std.is(input, Map)) {
    //             // Handle Map: Depending on treatMapsAsChanceMaps, split into chance objects or treat as a single object
    //             if (treatMapsAsChanceMaps) {
    //                 var mapAsArray:Array<Chance> = [];
    //                 var mapData:Map = [];
    //                 for (key in mapData.keys()) {
    //                     mapData.push({key: key, value: mapData.get(key)});
    //                 }
    //                     mapAsArray.push({item: {key: key, value: mapData.get(key)}, chance: 100 / mapData.keys().length});
    //                 }
    //                 return ChanceSelector.selectOption(mapAsArray);
    //             } else {
    //                 return ChanceSelector.selectOption([{item: input, chance: 100}]);
    //             }
    //         }
            
    //     }


}
