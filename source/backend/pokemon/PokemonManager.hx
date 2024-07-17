package backend.pokemon;
class PokeSprite {
    public var front:String;
    public var back:String;

    public function new(sprite:String, moe:Bool = false) {
        this.front = sprite + (moe ? "-moe" : "") + "-front";
        this.back = sprite + (moe ? "-moe" : "") + "-back";
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
    var moe:Bool;
    var ability:String;
    var heldItem:PokeItems;
}

typedef PokeItems = {
    var name:String;
    var effect:String;
    var category:PokemonItemCategory;
}

enum PokemonItemCategory {
    Health;
    Battle;
    Evolution;
    Status;
    Misc;
}

typedef PokeTrainer = {
    var name:String;
    var team:Team;
    var items:Array<PokeItems>;
}

class PokePlayer {
    public var trainer:PokeTrainer;
    public var items:Array<PokeItems>;
    public var saveData:SaveData;

    public function new(trainer:PokeTrainer, items:Array<PokeItems>, saveData:SaveData) {
        this.trainer = trainer;
        this.items = items;
        this.saveData = saveData;
    }
}

class SaveData {
    // Define the properties of the save data here
}

class SaveManager {
    public var saveData:SaveData;

    public function new() {
        saveData = new SaveData();
    }

    public function saveGame(player:PokePlayer):Void {
        // Save the game using the player's data and the save data
    }

    public function loadGame():PokePlayer {
        // Load the game and return a PokePlayer object with the loaded data
        return new PokePlayer(/* loaded trainer */, /* loaded items */, saveData);
    }
}

typedef Team = {
    var pokemon:Array<Pokemon>;
    
    public function new(pokemon:Array<Pokemon>) {
        if (pokemon.length > 6) {
            throw "Team can only have 6 Pokemon";
        }
        this.pokemon = pokemon;
    }
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

    public static function createPokeSprite(spriteName:String, moe:Bool = false):PokeSprite {
        return new PokeSprite(spriteName, moe);
    }
}

class TypeWeaknessManager {
    static var weaknesses:Map<PokeType, Array<{type:PokeType, percentage:Float}>> = new Map();
    static var immunities:Map<PokeType, Array<PokeType>> = new Map();
    static var resistances:Map<PokeType, Array<{type:PokeType, percentage:Float}>> = new Map();

    static function __init__() {
        weaknesses.set(PokeType.Normal, [{type: PokeType.Fighting, percentage: 1.0}]);
        weaknesses.set(PokeType.Fire, [{type: PokeType.Water, percentage: 2.0}, {type: PokeType.Ground, percentage: 1.5}, {type: PokeType.Rock, percentage: 1.5}]);
        weaknesses.set(PokeType.Water, [{type: PokeType.Electric, percentage: 1.5}, {type: PokeType.Grass, percentage: 0.5}]);
        weaknesses.set(PokeType.Electric, [{type: PokeType.Ground, percentage: 0.0}]);
        weaknesses.set(PokeType.Grass, [{type: PokeType.Fire, percentage: 2.0}, {type: PokeType.Ice, percentage: 2.0}, {type: PokeType.Poison, percentage: 1.5}, {type: PokeType.Flying, percentage: 1.5}, {type: PokeType.Bug, percentage: 1.5}]);
        weaknesses.set(PokeType.Ice, [{type: PokeType.Fire, percentage: 2.0}, {type: PokeType.Fighting, percentage: 2.0}, {type: PokeType.Rock, percentage: 1.5}, {type: PokeType.Steel, percentage: 1.5}]);
        weaknesses.set(PokeType.Fighting, [{type: PokeType.Flying, percentage: 1.5}, {type: PokeType.Psychic, percentage: 1.5}, {type: PokeType.Fairy, percentage: 1.5}]);
        weaknesses.set(PokeType.Poison, [{type: PokeType.Ground, percentage: 1.5}, {type: PokeType.Psychic, percentage: 1.5}]);
        weaknesses.set(PokeType.Ground, [{type: PokeType.Water, percentage: 2.0}, {type: PokeType.Grass, percentage: 2.0}, {type: PokeType.Ice, percentage: 1.5}]);
        weaknesses.set(PokeType.Flying, [{type: PokeType.Electric, percentage: 2.0}, {type: PokeType.Ice, percentage: 2.0}, {type: PokeType.Rock, percentage: 1.5}]);
        weaknesses.set(PokeType.Psychic, [{type: PokeType.Bug, percentage: 1.5}, {type: PokeType.Ghost, percentage: 1.5}, {type: PokeType.Dark, percentage: 1.5}]);
        weaknesses.set(PokeType.Bug, [{type: PokeType.Fire, percentage: 2.0}, {type: PokeType.Flying, percentage: 2.0}, {type: PokeType.Rock, percentage: 1.5}]);
        weaknesses.set(PokeType.Rock, [{type: PokeType.Water, percentage: 2.0}, {type: PokeType.Grass, percentage: 2.0}, {type: PokeType.Fighting, percentage: 2.0}, {type: PokeType.Ground, percentage: 2.0}, {type: PokeType.Steel, percentage: 1.5}]);
        weaknesses.set(PokeType.Ghost, [{type: PokeType.Ghost, percentage: 1.5}, {type: PokeType.Dark, percentage: 1.5}]);
        weaknesses.set(PokeType.Dragon, [{type: PokeType.Ice, percentage: 2.0}, {type: PokeType.Dragon, percentage: 2.0}, {type: PokeType.Fairy, percentage: 2.0}]);
        weaknesses.set(PokeType.Dark, [{type: PokeType.Fighting, percentage: 1.5}, {type: PokeType.Bug, percentage: 1.5}, {type: PokeType.Fairy, percentage: 1.5}]);
        weaknesses.set(PokeType.Steel, [{type: PokeType.Fire, percentage: 2.0}, {type: PokeType.Fighting, percentage: 2.0}, {type: PokeType.Ground, percentage: 2.0}]);
        weaknesses.set(PokeType.Fairy, [{type: PokeType.Poison, percentage: 2.0}, {type: PokeType.Steel, percentage: 2.0}]);

        immunities.set(PokeType.Ghost, [PokeType.Normal, PokeType.Fighting]);
        immunities.set(PokeType.Normal, [PokeType.Ghost]);

        resistances.set(PokeType.Fire, [{type: PokeType.Grass, percentage: 0.5}, {type: PokeType.Ice, percentage: 0.5}, {type: PokeType.Bug, percentage: 0.5}, {type: PokeType.Steel, percentage: 0.5}, {type: PokeType.Fairy, percentage: 0.5}]);
        resistances.set(PokeType.Water, [{type: PokeType.Fire, percentage: 0.5}, {type: PokeType.Steel, percentage: 0.5}, {type: PokeType.Water, percentage: 0.5}, {type: PokeType.Ice, percentage: 0.5}]);
        // Add more resistances as needed
    }

    public static function isWeakAgainst(type:PokeType, againstType:PokeType):Bool {
        return weaknesses.exists(type) && weaknesses.get(type).some(function(weakness) return weakness.type == againstType);
    }

    public static function isImmuneTo(type:PokeType, againstType:PokeType):Bool {
        return immunities.exists(type) && immunities.get(type).indexOf(againstType) != -1;
    }

    public static function isResistantTo(type:PokeType, againstType:PokeType):Bool {
        return resistances.exists(type) && resistances.get(type).some(function(resistance) return resistance.type == againstType);
    }

    public static function calculateEffectiveness(moveType:PokeType, pokemonTypes:Array<PokeType>):Float {
        var effectivenessMultiplier:Float = 1.0;
    
        for (pokemonType in pokemonTypes) {
            if (isImmuneTo(pokemonType, moveType)) {
                return 0; // Immediate immunity
            } else if (isWeakAgainst(pokemonType, moveType)) {
                effectivenessMultiplier *= 2.0; // Weakness doubles effectiveness
            } else if (isResistantTo(pokemonType, moveType)) {
                effectivenessMultiplier *= 0.5; // Resistance halves effectiveness
            }
            // No change for neutral effectiveness
        }
    
        return effectivenessMultiplier;
    }
    
    public static function getWeaknesses(type:PokeType):Array<{type:PokeType, percentage:Float}> {
        return weaknesses.get(type);
    }
    
    public static function getImmunities(type:PokeType):Array<PokeType> {
        return immunities.get(type);
    }
    
    public static function getResistances(type:PokeType):Array<{type:PokeType, percentage:Float}> {
        return resistances.get(type);
    }
}




