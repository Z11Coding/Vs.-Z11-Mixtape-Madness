package backend.modchart.modifiers;

import flixel.FlxSprite;
import backend.modchart.*;
import backend.math.*;
import objects.playfields.NoteField;

class OpponentModifier extends source.backend.modchart.NoteModifier {
	override function getName()
		return 'opponentSwap';

	inline function sign(x:Int)
		return x == 0 ? 0 : (x <= -1 ? -1 : 1);

	override function getPos(diff:Float, tDiff:Float, beat:Float, pos:Vector3, data:Int, player:Int, obj:FlxSprite, field:NoteField)
    {
		var distX = FlxG.width / modMgr.playerAmount; // theres probably a way to optimize this (division is expensive!) but i think this is a good way of doing this rn

		pos.x += distX * sign((player + 1) * 2 - 3) * getValue(player);
		// any pN > 0 should go right whereas any pN < 0 should go left 
        return pos;
    }
}