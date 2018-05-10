package rx.schedulers;
import haxe.Timer;
import rx.disposables.ISubscription;
import rx.Core;


class ImmediateBase implements Base {
    public function new() {

    }

    public function now():Float {

        return Timer.stamp();

    }

    public function schedule_absolute(due_time:Null<Float>, action:Void -> Void):ISubscription {
        if (due_time == null) {
            due_time = now();
        }

        var action1 = Utils.create_sleeping_action(action, due_time, now);

        return action1();

    }
}

class Immediate extends MakeScheduler {
    public function new() {
        super();
        baseScheduler = new ImmediateBase();

    }

}