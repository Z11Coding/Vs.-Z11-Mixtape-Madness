package backend.modchart.events;

class BaseEvent {
    public var manager:source.backend.modchart.ModManager;
    public var parent:source.backend.modchart.EventTimeline;
    public var executionStep:Float = 0;
	public var ignoreExecution:Bool = false;
    public var finished:Bool = false;
	public function new(step:Float, manager:source.backend.modchart.ModManager)
	{
		this.manager = manager;
		this.executionStep = step;
	}

    public function run(curStep:Float){}
}