package rx.schedulers;
import haxe.Timer;
import rx.disposables.ISubscription;
import rx.Core;
import rx.Thread;


class NewThreadBase implements Base {
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
        var discardable = DiscardableAction.create(action1);
        Thread.create(discardable.action);
        return discardable.unsubscribe();

    }
}

class NewThread extends MakeScheduler {
    public function new() {
        super();
        baseScheduler = new NewThreadBase();

    }

}