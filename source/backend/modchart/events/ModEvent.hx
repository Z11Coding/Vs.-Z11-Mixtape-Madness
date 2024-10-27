// @author Nebula_Zorua

package backend.modchart.events;

class ModEvent extends BaseEvent {
	public var modName:String = '';
	public var endVal:Float = 0;
	public var player:Int = -1;

	private var mod:source.backend.modchart.Modifier;

	public function new(step:Float, modName:String, target:Float, player:Int = -1, modMgr:source.backend.modchart.ModManager)
	{
		super(step, modMgr);
		this.modName = modName;
		this.player = player;
		endVal = target;

		this.mod = modMgr.get(modName);
	}
}