import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;

class HoldableVariable {
	public static macro function createVariable<T>(expression:Expr):Expr {
		var exprType = Context.typeof(expression);
		switch exprType {
			case TFun(_, _):
				// If the expression is a function, use it directly
				return macro new Variable<T>($expression);
			default:
				// Transform the expression into a function for lazy evaluation
				return macro new Variable<T>(function() return $expression);
		}
	}
}

