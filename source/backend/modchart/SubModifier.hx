package source.backend.modchart;

class SubModifier extends source.backend.modchart.Modifier { // also called an aux mod
    var name:String = 'unspecified';

    override function getName() return name;
/* 	override function shouldExecute(player:Int, value:Float) return false; */
    override function getOrder() return source.backend.modchart.Modifier.ModifierOrder.LAST;
	override function doesUpdate() return false;

	public function new(name:String, modMgr:source.backend.modchart.ModManager, ?parent:source.backend.modchart.Modifier) {
        super(modMgr, parent);
        this.name = name;
    }
}