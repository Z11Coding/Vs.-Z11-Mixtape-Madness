package backend.modules;

import haxe.macro.Context;
import haxe.macro.Expr;

class EventFuncMacro {
	public static macro function transformEventFunc():Expr {
		// Get the current class method's AST
		var method = Context.getLocalMethod();
		var body = Context.getTypedExpr(Context.getMethodBody(method));
        trace("DEBUG: Transforming EventFunc calls in method " + Context.currentPos().className + "." + Context.currentPos().methodName;
		
		// Function to recursively search and transform EventFunc constructor calls
		function transform(e:Expr):Expr {
			switch e {
				case ECall(new EField(_, "EventFunc"), args) if args.length == 4 || args.length == 5:
					// Extract arguments
					var eventName = args[0];
					var eventType = args[1];
					var watchedVariable = args[2];
					var func = args[3];
					var destroyOnUse = args.length == 5 ? macro $args[4] : null;
					
					// Transform the watchedVariable argument into a function
					var newWatchedVariable = macro function() return $watchedVariable;
					
					// Reconstruct the call with the transformed argument
					// Check if destroyOnUse was provided
					if (destroyOnUse != null) {
						return macro new EventFunc($eventName, $eventType, $newWatchedVariable, $func, $destroyOnUse);
					} else {
						return macro new EventFunc($eventName, $eventType, $newWatchedVariable, $func);
					}
				case EBlock(exprs):
					// Transform expressions within a block
					return macro { $a{exprs.map(transform)} };
				default:
					// For all other expressions, do not transform
					return e;
			}
		}
		
		// Transform the method body
		var transformedBody = transform(body);
		// Replace the method body with the transformed one
		Context.setMethodBody(method, transformedBody);
		return macro null;
	}
}

