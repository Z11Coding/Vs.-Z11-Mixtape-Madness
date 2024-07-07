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
    public var watchedVariable: Void -> Dynamic; // Now a function returning Dynamic
    public var func: Void -> Void;
    private var lastValue: Dynamic;
    private var destroyOnTrigger: Null<Bool>;
    private static var instances: Array<EventFunc> = [];

    public inline function new(eventName: String, eventType: EventType, watchedVariable: Void -> Dynamic, func: Void -> Void, ?destroyOnTrigger: Bool = true) {
        this.eventName = eventName;
        this.eventType = eventType;
        this.watchedVariable = watchedVariable;
        this.func = func;
        this.lastValue = watchedVariable(); // Evaluate to initialize
        this.destroyOnTrigger = destroyOnTrigger;
        instances.push(this);
    }

    public inline function check(): Bool {
        var currentValue = watchedVariable(); // Evaluate the expression
        var triggered = false;
        switch eventType {
            case GreaterThan(value):
                if (Std.is(currentValue, Float) && currentValue > value) {
                    triggered = true;
                }
            case LessThan(value):
                if (Std.is(currentValue, Float) && currentValue < value) {
                    triggered = true;
                }
            case EqualTo(value):
                if (currentValue == value) {
                    triggered = true;
                }
            case Change:
                if (currentValue != lastValue) {
                    triggered = true;
                }
        }
        if (triggered) {
            execute();
            lastValue = currentValue; // Update lastValue after execution
            return true;
        }
        lastValue = currentValue; // Always update lastValue
        return false;
    }


    private inline function execute(): Void {
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

    public inline function update(): Void {
        check();
    }

    public static inline function updateAll(): Void {
        for (instance in instances) {
            instance.update();
        }
    }

    public static inline function destroyAll(): Void {
        for (instance in instances) {
            instance = null;
        }
        instances = [];
    }

    public static inline function tracker(v:Dynamic):Dynamic {
        trace(v);
        return v;
    }
}


    // class Tracker {
    // }

