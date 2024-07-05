package backend.modules;

enum EventType {
    GreaterThan(value: Float);
    LessThan(value: Float);
    EqualTo(value: Dynamic);
    Change;
}

class EventFunc {
    public var eventName: String;
    public var eventType: EventType;
    public var watchedVariable: Dynamic;
    public var func: Void -> Void;
    private var lastValue: Dynamic;
    private var destroyOnTrigger: Null<Bool>; // New variable to control destruction behavior

    public function new(eventName: String, eventType: EventType, watchedVariable: Dynamic, func: Void -> Void, ?destroyOnTrigger: Bool = true) {
        this.eventName = eventName;
        this.eventType = eventType;
        this.watchedVariable = watchedVariable;
        this.func = func;
        this.lastValue = watchedVariable; // Initialize with the current value
        this.destroyOnTrigger = destroyOnTrigger; // Initialize with the provided value or default to true
    }

    public function check(): Bool {
        var triggered = false;
        switch eventType {
            case GreaterThan(value):
                if (Std.is(watchedVariable, Float) && watchedVariable > value) {
                    triggered = true;
                }
            case LessThan(value):
                if (Std.is(watchedVariable, Float) && watchedVariable < value) {
                    triggered = true;
                }
            case EqualTo(value):
                if (watchedVariable == value) {
                    triggered = true;
                }
            case Change:
                if (watchedVariable != lastValue) {
                    triggered = true;
                }
        }
        if (triggered) {
            execute();
            lastValue = watchedVariable; // Update lastValue for change detection
            return true;
        }
        lastValue = watchedVariable; // Update lastValue for change detection
        return false;
    }

    private function execute(): Void {
        func();
        trace('${eventName} event triggered: ${Std.string(eventType)}');
        if (destroyOnTrigger) {
            // Nullify references to the object
            eventName = null;
            eventType = null;
            watchedVariable = null;
            func = null;
            lastValue = null;
            destroyOnTrigger = null;
            // this = null;
        }
        }

    public  function update(): Void {

        check();
    }
}
