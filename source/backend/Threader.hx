package backend;

import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.macro.ExprTools;
import haxe.macro.Type;
import haxe.macro.Printer;

class Threader {
    public static var cancellableThreads:Map<String, {thread:sys.thread.Thread, cancel:Void->Void}> = new Map();

    public static macro function runInThread(expr:Expr, ?sleepDuration:Float = 0, ?name:String = ""):Expr {
        var sleepExpr = Context.makeExpr(sleepDuration, Context.currentPos());
        var nameExpr = Context.makeExpr(name, Context.currentPos());
        trace("Preparing a threaded section of code:" + expr + " with sleep duration: " + sleepDuration + " and name: " + name);
        return macro {
            #if sys
            var thrd = Thread.create(function() {
                try {
                    trace("Set command to run in a thread...");
                    if ($nameExpr != "") {
                        trace("Thread name: " + $nameExpr);
                    }
                    $expr;
                    if ($sleepExpr > 0) {
                        Sys.sleep($sleepExpr);
                    }
                    trace("Thread finished running command.");
                } catch (e:Dynamic) {
                    trace("Exception in thread: " + e);
                    if ($nameExpr != "") {
                        trace("Errored Thread name: " + $nameExpr);
                    }
                }
            });
            #else
            $expr;
            #end
        };
        trace("Threaded section of code prepared.");
    }

    public static macro function runInCancellableThread(expr:Expr, ?name:String = ""):Expr {
        var nameExpr = Context.makeExpr(name, Context.currentPos());
        var threadName = name != "" ? name : "thread_" + Std.string(Math.random());
        nameExpr = Context.makeExpr(threadName, Context.currentPos());
        trace("Preparing a cancellable threaded section of code:" + expr + " with name: " + name);
        return macro {
            #if sys
            var thrd = Thread.create(function() {
                try {
                    trace("Set command to run in a cancellable thread...");
                    if ($nameExpr != "") {
                        trace("Thread name: " + $nameExpr);
                    }
                    $expr;
                    trace("Thread finished running command.");
                } catch (e:Dynamic) {
                    trace("Exception in thread: " + e);
                    if ($nameExpr != "") {
                        trace("Errored Thread name: " + $nameExpr);
                    }
                }
            });

            Threader.cancellableThreads.set($nameExpr, {thread: thrd, cancel: function() {
                try {
                    thrd = null;
                    trace("Thread " + $nameExpr + " cancelled.");
                } catch (e:Dynamic) {
                    trace("Exception while cancelling thread: " + e);
                }
            }});
            #else
            $expr;
            #end
        };
        trace("Cancellable threaded section of code prepared.");
    }

    public static function cancelThread(name:String):Void {
        if (cancellableThreads.exists(name)) {
            cancellableThreads.get(name).cancel();
            cancellableThreads.remove(name);
        } else {
            trace("No thread found with name: " + name);
        }
    }
}