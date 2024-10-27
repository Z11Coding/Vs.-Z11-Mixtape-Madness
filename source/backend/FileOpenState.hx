package backend;

// import StateMap;
import flixel.FlxG;
import flixel.FlxState;
import flixel.group.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;

class FileOpenState extends FlxState {
    public static var stateMap:Map<String, Class<Dynamic>>;

    override function create() {
        stateMap = new Map<String, Class<Dynamic>>();

        // Add states that associate with the same file type to stateMap
        for (assoc in FileAssociationData.associations) {
            if (assoc.fileType == "SwagSong") {
                stateMap.set(Type.getClassName(assoc.state), assoc.state);
            }
        }

        FlxG.camera.bgColor = FlxColor.BLACK;

        var text:FlxText = new FlxText(0, 0, FlxG.width, "FileOpenState", 32);
        text.setFormat(null, 32, FlxColor.WHITE, "center");
        add(text);

        super.create();
    }
}