package yutautil;

typedef FileAssociation = {
    var state:Class<FlxState>;
    var fileType:String;
    var typedef:Dynamic;
    var handler:Dynamic->Void;
}

class FileAssociationData {
    public static var associations:Array<FileAssociation> = [];

    public static function register(association:FileAssociation):Void {
        associations.push(association);
    }

    public static function getAssociation(fileType:String, fileData:Dynamic):FileAssociation {
        for (assoc in associations) {
            if (assoc.fileType == fileType && TypeTools.isOfType(fileData, assoc.typedef)) {
                return assoc;
            }
        }
        return null;
    }

    public static function handleDroppedFile(fileType:String, fileData:Dynamic):Void {
        var assoc = getAssociation(fileType, fileData);
        if (assoc != null) {
            var stateInstance = Type.createInstance(assoc.state, []);
            assoc.handler(fileData);
        } else {
            trace("No association found for file type: " + fileType);
        }
    }
}