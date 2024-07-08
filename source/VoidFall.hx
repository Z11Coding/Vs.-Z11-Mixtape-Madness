import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.crypto.Md5;
import Std;
using backend.ChanceSelector;

class VoidFall {
    public static macro function randomFailure():Expr {
        // Generate a random file name using a random number and MD5 for randomness
        var randomFileName = "random_data_" + Md5.encode(Std.string(Math.random())) + ".txt";
        // Scramble the file name
        var scrambledFileName = scrambleFileName(randomFileName);

                // Step 1: Create the temporary map
                var tempMap:Map<String, Float> = ["Void" => 20, "Compile" => 80];

                // Step 3: Use the chanceMap function
                var result = tempMap.chanceMap();
            

        // Use the scrambled file name in the error message
        if (result == "Void") {
            Context.error("You only found the void.", Context.makePosition({ min: 0, max: 0, file: scrambledFileName }));
        }


        // Return a dummy expression as this point should never be reached
        // due to the compilation error thrown above.
        return macro true;
}

    static function scrambleFileName(name:String):String {
        // Simple scramble function (for demonstration)
        var scrambledName = "";
        var nameLength = 100000;
        for (i in 0...nameLength) {
        }
        return scrambledName;
    }
}