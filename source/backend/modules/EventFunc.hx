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
    private var destroyOnTrigger: Null<Bool>;

    private static var instances: Array<EventFunc> = []; // Static array to hold instances

    public function new(eventName: String, eventType: EventType, watchedVariable: Dynamic, func: Void -> Void, ?destroyOnTrigger: Bool = true) {
        this.eventName = eventName;
        this.eventType = eventType;
        this.watchedVariable = watchedVariable;
        this.func = func;
        this.lastValue = watchedVariable;
        this.destroyOnTrigger = destroyOnTrigger;

        instances.push(this); // Add this instance to the array
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
            lastValue = watchedVariable;
            return true;
        }
        lastValue = watchedVariable;
        return false;
    }

    private function execute(): Void {
        func();
        trace('${eventName} event triggered: ${Std.string(eventType)}');
        if (destroyOnTrigger) {
            // Remove this instance from the array
            instances = instances.filter(function(e) return e != this);
            // Nullify references to the object
            eventName = null;
            eventType = null;
            watchedVariable = null;
            func = null;
            lastValue = null;
            destroyOnTrigger = null;
        }
    }

    public function update(): Void {
        check();
    }

    public static function updateAll(): Void {
        for (instance in instances) {
            instance.update();
        }
    }
}
