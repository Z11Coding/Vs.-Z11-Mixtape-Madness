package backend.modules;

import flixel.FlxState;
import haxe.Serializer;
import haxe.Unserializer;

class SaveState {
	private static var savedStates:Map<String, String> = new Map<String, String>();

	// Save the current state
	public static function saveState(stateName:String, state:FlxState):Void {
		var serializedState = Serializer.run(state);
		savedStates.set(stateName, serializedState);
	}

	// Load a saved state
	public static function loadState(stateName:String):FlxState {
		var serializedState = savedStates.get(stateName);
		if (serializedState != null) {
			return Unserializer.run(serializedState);
		}
		return null;
	}

	// Switch to a saved state
	public static function switchToState(stateName:String):Void {
		var state = loadState(stateName);
		if (state != null) {
			FlxG.switchState(state);
		}
	}
}

