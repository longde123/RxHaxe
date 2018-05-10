package rx.schedulers;
import haxe.Timer;
import rx.disposables.ISubscription;
import rx.Core;
class CurrentThreadBase implements Base {

    var async:AsyncLock;

    public function new() {
        async = AsyncLock.create();
    }

    public function now():Float {

        return Timer.stamp();

    }

    public function enqueue(action:Void -> Void, exec_time:Float) {
        try {
            async.wait(action);
        } catch (e:String) {
            async = AsyncLock.create();
            throw e;

        }

    }

    public function schedule_absolute(due_time:Null<Float>, action:Void -> Void):ISubscription {
        if (due_time == null) {
            due_time = now();
        }
        var action1 = Utils.create_sleeping_action(action, due_time, now);
        var discardable = DiscardableAction.create(action1);
        enqueue(discardable.action, due_time);
        return discardable.unsubscribe();

    }


}

class CurrentThread extends MakeScheduler {
    var currentThreadBase:CurrentThreadBase;

    public function new() {
        super();
        baseScheduler = currentThreadBase = new CurrentThreadBase();

    }

}