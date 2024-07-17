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

