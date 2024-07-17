package backend.pokemon;

class PokeSprite {
    public var front:String;
    public var back:String;

    public function new(sprite:String) {
        this.front = sprite + "-front";
        this.back = sprite + "-back";
    }

    public function loadFrontSprite():FlxSprite {
        return new FlxSprite(0, 0, front);
    }

    public function loadBackSprite():FlxSprite {
        return new FlxSprite(0, 0, back);
    }
}



enum PokeType {
	Normal;
	Fire;
	Water;
	Grass;
	Electric;
	Ice;
	Fighting;
	Poison;
	Ground;
	Flying;
	Psychic;
	Bug;
	Rock;
	Ghost;
	Dragon;
	Dark;
	Steel;
	Fairy;
}

class PokeTypePair {
    public var types:Array<PokeType>;

    public function new(type1:PokeType, type2:PokeType = null) {
        types = [type1];
        if (type2 != null) {
            types.push(type2);
        }
    }
}

typedef PokeMove = {
	var name:String;
	var damage:Int;
	var type:PokeType;
	var animation:String;
	var statusEffect:String;
}

typedef PokeMoves = Array<PokeMove>;

typedef Pokemon = {
    var id:Int;
    var name:String;
    var stats:{attack:Int, defense:Int, speed:Int, specialAttack:Int, specialDefense:Int};
    var hp:Int;
    var type:PokeTypePair;
    var moves:PokeMoves;
    var sprite:PokeSprite;
}

typedef PokeItems = {
	var name:String;
	var effect:String;
}

typedef PokeTrainer = {
	var name:String;
	var team:Array<Pokemon>;
	var items:Array<PokeItems>;
}

class PokemonManager {
	public var trainers:Array<PokeTrainer>;
	public var allMoves:PokeMoves;
	public var allItems:Array<PokeItems>;

	public function new() {
		trainers = [];
		allMoves = [];
		allItems = [];
	}

	public function addPokeMove(move:PokeMove):Void {
		allMoves.push(move);
	}

	public function addPokeItem(item:PokeItems):Void {
		allItems.push(item);
	}

	public function addTrainer(trainer:PokeTrainer):Void {
		trainers.push(trainer);
	}

	// Function to handle sprite naming convention
	public static function createPokeSprite(spriteName:String):PokeSprite {
		return {
			front: spriteName + "-front",
			back: spriteName + "-back"
		};
	}
}

class TypeWeaknessManager {
	static var weaknesses:Map<PokeType, Array<PokeType>> = new Map();
	static var immunities:Map<PokeType, Array<PokeType>> = new Map();
	static var resistances:Map<PokeType, Array<PokeType>> = new Map();

	// fuck
	static function __init__() {
		weaknesses.set(PokeType.Normal, [PokeType.Fighting]);
		weaknesses.set(PokeType.Fire, [PokeType.Water, PokeType.Ground, PokeType.Rock]);
		weaknesses.set(PokeType.Water, [PokeType.Electric, PokeType.Grass]);
		weaknesses.set(PokeType.Electric, [PokeType.Ground]);
		weaknesses.set(PokeType.Grass, [PokeType.Fire, PokeType.Ice, PokeType.Poison, PokeType.Flying, PokeType.Bug]);
		weaknesses.set(PokeType.Ice, [PokeType.Fire, PokeType.Fighting, PokeType.Rock, PokeType.Steel]);
		weaknesses.set(PokeType.Fighting, [PokeType.Flying, PokeType.Psychic, PokeType.Fairy]);
		weaknesses.set(PokeType.Poison, [PokeType.Ground, PokeType.Psychic]);
		weaknesses.set(PokeType.Ground, [PokeType.Water, PokeType.Grass, PokeType.Ice]);
		weaknesses.set(PokeType.Flying, [PokeType.Electric, PokeType.Ice, PokeType.Rock]);
		weaknesses.set(PokeType.Psychic, [PokeType.Bug, PokeType.Ghost, PokeType.Dark]);
		weaknesses.set(PokeType.Bug, [PokeType.Fire, PokeType.Flying, PokeType.Rock]);
		weaknesses.set(PokeType.Rock, [PokeType.Water, PokeType.Grass, PokeType.Fighting, PokeType.Ground, PokeType.Steel]);
		weaknesses.set(PokeType.Ghost, [PokeType.Ghost, PokeType.Dark]);
		weaknesses.set(PokeType.Dragon, [PokeType.Ice, PokeType.Dragon, PokeType.Fairy]);
		weaknesses.set(PokeType.Dark, [PokeType.Fighting, PokeType.Bug, PokeType.Fairy]);
		weaknesses.set(PokeType.Steel, [PokeType.Fire, PokeType.Fighting, PokeType.Ground]);
		weaknesses.set(PokeType.Fairy, [PokeType.Poison, PokeType.Steel]);

		// Initialize immunities
		immunities.set(PokeType.Ghost, [PokeType.Normal, PokeType.Fighting]);
		immunities.set(PokeType.Normal, [PokeType.Ghost]);
		// Add more immunities as needed

		// Initialize resistances
		resistances.set(PokeType.Fire, [PokeType.Grass, PokeType.Ice, PokeType.Bug, PokeType.Steel, PokeType.Fairy]);
		resistances.set(PokeType.Water, [PokeType.Fire, PokeType.Steel, PokeType.Water, PokeType.Ice]);
		// Add more resistances as needed
	} //lazy

	public static function isWeakAgainst(type:PokeType, againstType:PokeType):Bool {
		return weaknesses.exists(type) && weaknesses.get(type).indexOf(againstType) != -1;
	}

	public static function isImmuneTo(type:PokeType, againstType:PokeType):Bool {
		return immunities.exists(type) && immunities.get(type).indexOf(againstType) != -1;
	}

	public static function isResistantTo(type:PokeType, againstType:PokeType):Bool {
		return resistances.exists(type) && resistances.get(type).indexOf(againstType) != -1;
	}
}



