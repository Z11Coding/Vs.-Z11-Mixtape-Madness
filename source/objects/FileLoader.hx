package objects;

import sys.io.File;

class FileLoader {
	public var filePath:String;
	public var fileContent:String;

	public function new(filePath:String) {
		this.filePath = filePath;
		this.fileContent = loadFileContent(filePath);
	}

	private function loadFileContent(filePath:String):String {
		try {
			return File.getContent(filePath);
		} catch (e:Dynamic) {
			trace('Error reading file: ' + e);
			return null;
		}
	}

	public function getContent():String {
		return fileContent;
	}
}

