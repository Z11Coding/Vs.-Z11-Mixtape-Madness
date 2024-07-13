package backend;

import haxe.Reflect;

class DynamicIterator {
	public static function iterate(dynamicObject:Dynamic):Iterator<{field:String, value:Dynamic}> {
		var fields:Array<String> = Reflect.fields(dynamicObject);
		var index:Int = 0;
		
		return {
			hasNext: function():Bool {
				return index < fields.length;
			},
			next: function():{field:String, value:Dynamic} {
				var field:String = fields[index++];
				return { field: field, value: Reflect.field(dynamicObject, field) };
			}
		};
	}
}

