package source.yutautil;

import haxe.Http;
import haxe.macro.Compiler;

class Main {
    static function main() {
        var url = "http://example.com/source.hx";
        fetchSourceCode(url, function(sourceCode) {
            compileSourceCode(sourceCode);
        });
    }

    static function fetchSourceCode(url:String, callback:String->Void):Void {
        var http = new Http(url);
        http.onData = function(data:String) {
            callback(data);
        };
        http.onError = function(error:String) {
            trace("Failed to fetch source code: " + error);
        };
        http.request();
    }

    static function compileSourceCode(sourceCode:String):Void {
        try {
            Compiler.addFile("dynamicSource.hx", sourceCode);
            Compiler.compile();
            trace("Compilation successful");
        } catch (e:Dynamic) {
            trace("Compilation failed: " + e);
        }
    }
}