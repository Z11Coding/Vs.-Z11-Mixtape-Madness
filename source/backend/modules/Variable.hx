package backend.modules;

class Variable<T> {
	var expr:Void->T;

	public function new(expr:Void->T) {
		
		this.expr = expr;
        trace("Variable created.");
        trace(this.expr);
	}

	public function evaluate():T {
		return this.expr();
	}
}

