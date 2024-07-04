package backend;

import objects.Note; 

class JSONCache {
    // Assuming a simple structure for demonstration
    static var cache:Map<String, Dynamic> = new Map<String, Dynamic>();

    public static function loadJson(filePath:String, callback:Dynamic->Void):Void {
        if (cache.exists(filePath)) {
            // If the JSON is already cached, use it
            callback(cache.get(filePath));
        } else {
            // Load and parse the JSON from a local file, then cache it
            var fileContents = sys.io.File.getContent(filePath);
            var parsed = haxe.Json.parse(fileContents);
            cache.set(filePath, parsed);
            callback(parsed);
        }
    }
    public static function addToCache(filePath:String):Void {
        try {
            var fileContents = sys.io.File.getContent(filePath);
            var parsed = haxe.Json.parse(fileContents);
            cache.set(filePath, parsed); // Cache the entire parsed JSON
            trace("Data loaded successfully");

            // Assuming parsed is a Dynamic object, directly check if "notes" exists and is an array
            if (Reflect.hasField(parsed, "notes") && Reflect.isObject(parsed.notes)) {
                var notes:Array<Dynamic> = Reflect.field(parsed, "notes");
                trace("Notes found in JSON. Further caching data...");
                for (note in notes) {
                    if (Reflect.hasField(note, "sectionNotes") && Reflect.isObject(note.sectionNotes)) {
                        var noteList:Array<Note> = [];
                        var sectionNotes:Array<Dynamic> = Reflect.field(note, "sectionNotes");
                        for (sectionNote in sectionNotes) {
                            if (sectionNote != null && sectionNote.length >= 2) {
                                var noteObj:Note = new Note(sectionNote[0], sectionNote[1]);
                                noteList.push(noteObj);
                            }
                        }
                        cache.set(filePath, noteList);
                        trace("Notes cached successfully");
                    }
                }
            }            } catch (error:Dynamic) {
                trace("Failed to load data: " + error + " at " + filePath);
            }
        }
    
    public static function get(filePath:String):Dynamic {
        return cache.get(filePath);
    }

    public static function exists(filePath:String):Bool {
        return cache.exists(filePath);
    }

    public static function clearCache():Void {
        cache = new Map<String, Dynamic>();
    }

    public static function remove(filePath:String):Void {
        cache.remove(filePath);
    }

    public static function update(filePath:String, data:Dynamic):Void {
        cache.set(filePath, data);
    }

    public static function save(filePath:String):Void {
        var data = cache.get(filePath);
        var jsonData = haxe.Json.stringify(data);
        sys.io.File.saveContent(filePath, jsonData);
    }

    public static function saveAll():Void {
        for (filePath in cache.keys()) {
            save(filePath);
        }
    }

    public static function loadAll():Void {
        for (filePath in cache.keys()) {
            loadJson(filePath, function(data:Dynamic) {
                trace("Loaded data from: " + filePath);
            });
        }
    }

    public static function printCache():Void {
        for (filePath in cache.keys()) {
            trace(filePath + " : " + cache.get(filePath));
        }
    }

    // public static function printCacheSize():Int {
    //     return cache.size();
    // }

    public static function pushCache():Map<String, Dynamic> {
        return cache;
    }

    public static function popCache(newCache:Map<String, Dynamic>):Void {
        cache = newCache;
    }

    public static function charts():Array<String> {
        var chartList:Array<String> = [];
        for (filePath in cache.keys()) {
            var data = cache.get(filePath);
            if (Reflect.hasField(data, "notes") && Reflect.isObject(data.notes)) {
                var notes:Array<Dynamic> = Reflect.field(data, "notes");
                for (note in notes) {
                    if (Reflect.hasField(note, "sectionNotes") && Reflect.isObject(note.sectionNotes)) {
                        chartList.push(filePath);
                    }
                }
            }
        }
        return chartList;
    }
} 