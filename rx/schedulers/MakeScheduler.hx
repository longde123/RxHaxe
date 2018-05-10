package rx.schedulers;
import haxe.Timer;
import rx.disposables.ISubscription;
import rx.disposables.MultipleAssignment;
import rx.disposables.Composite;
import rx.Subscription;
import rx.Core;
class MakeScheduler implements IScheduler {
    public var baseScheduler:Base;

    public function new() {

    }

    public function now():Float {

        return Timer.stamp();

    }

    public function schedule_absolute(due_time:Null<Float>, action:Void -> Void):ISubscription {

        return baseScheduler.schedule_absolute(due_time, action);
    }

    public function schedule_relative(delay:Null<Float>, action:Void -> Void):ISubscription {

        var due_time = baseScheduler.now() + delay;
        return baseScheduler.schedule_absolute(due_time, action);
    }

    function schedule_k(child_subscription:MultipleAssignment, parent_subscription:Composite, k:(Void -> Void) -> Void):ISubscription {
        var k_subscription = if (parent_subscription.is_unsubscribed()) {
              Subscription.empty();
        } else {
              baseScheduler.schedule_absolute(null, function() {
                  k(function() {
                      schedule_k(child_subscription, parent_subscription, k);
                  });
            });
        };

        child_subscription.set(k_subscription);
        return child_subscription;
    }

    public function schedule_recursive(cont:(Void -> Void) -> Void) {
        var child_subscription = MultipleAssignment.create(Subscription.empty());
        var parent_subscription = Composite.create([child_subscription]);
        var scheduled_subscription = baseScheduler.schedule_absolute(null, function()  {
            schedule_k(child_subscription, parent_subscription, cont);
        } );
        parent_subscription.add(scheduled_subscription);
        return parent_subscription;
    }

    function loop(completed:AtomicData<Bool>, period:Null<Float>, action:Void -> Void,parent :Composite ):Void {
        if (!AtomicData.unsafe_get(completed)) {
            var started_at = now();
            action () ;
            var time_taken = (now()) - started_at;
            var delay = period - time_taken;
            var unsubscribe2 = schedule_relative(delay, function() {
                loop(completed, period, action,parent);
            } );
            parent.add(unsubscribe2);
        }
    }


// initial_delay:Float , due_time: Float ,action:Void-> ISubscription 
    public function schedule_periodically(initial_delay:Null<Float>, period:Null<Float>, action:Void -> Void):ISubscription {
        var completed = AtomicData.create(false);
        var delay:Null<Float> = 0;
        if (initial_delay != null)delay = initial_delay;
        var parent_subscription:Composite = Composite.create([]);
        var unsubscribe1 = schedule_relative(delay, function() {
            loop(completed, period, action,parent_subscription);
        });
        parent_subscription.add(unsubscribe1);
        return Subscription.create(function() {
            AtomicData.set(true, completed);
            parent_subscription.unsubscribe();
        });
    }


}

