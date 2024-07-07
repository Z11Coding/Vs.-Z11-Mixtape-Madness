import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;

@:generic
class HoldableVariable {
	public static macro function createVariable(expression:Expr):Expr {
		var exprType = Context.typeof(expression);
		switch exprType {
			case TFun(_, _):
				// If the expression is a function, use it directly
				return macro new Variable($expression);
			default:
				// Correctly embed the expression within an anonymous function
				return macro new Variable(function() return $e{expression});
		}
	}
}

