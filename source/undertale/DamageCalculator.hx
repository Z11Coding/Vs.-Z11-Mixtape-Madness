package undertale;

import undertale.*;
class DamageCalculator {

    //simplistic for now, but i plan to expand this entire class
    public static function getDamage(rating:String, hSoul:SOUL, mSoul:MSOUL):Float {
        var initalDamage:Float = hSoul.atk;
        switch (rating)
        {
            case 'bad':
                initalDamage *= 1.2;
            case 'good':
                initalDamage *= 1.5;
            case 'perfect':
                initalDamage *= 2;
        }

        initalDamage -= mSoul.def;
        initalDamage = Std.int(initalDamage);
        return initalDamage;
    }
}