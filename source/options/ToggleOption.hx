package options;

class ToggleOption extends Option {
	public var enabled:Bool;

	public function new(name:String, type:String, defaultValue:Dynamic, changeValue:Dynamic, minValue:Dynamic = null, maxValue:Dynamic = null) {
		super(name, type, defaultValue, changeValue, minValue, maxValue);
		this.enabled = true;
	}

	public function toggle():Void {
		this.enabled = !this.enabled;
	}

	override public function setValue(value:Dynamic):Void {
		if (this.enabled) {
			Reflect.callMethod(this, Reflect.field(this, "setValue"), [value]);
		}
	}

	override public function getValue():Dynamic {
		if (this.enabled) {
			return Reflect.callMethod(this, Reflect.field(this, "getValue"), []);
		}
		return null;
	}

    // override public function onChange():Void {
    //     if (this.enabled) {
    //         Reflect.callMethod(this, Reflect.field(this, "onChange"), []);
    //     }
    // }
}

