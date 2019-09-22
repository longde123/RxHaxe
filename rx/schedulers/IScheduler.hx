package rx.schedulers;
import rx.disposables.ISubscription;
import rx.Core;
interface IScheduler extends Base {

    public function schedule_relative(delay:Null<Float>, action:Void -> Void):ISubscription;

    public function schedule_recursive(action:(Void -> Void) -> Void):ISubscription;

    public function schedule_periodically(initial_delay:Null<Float>, period:Null<Float>, action:Void -> Void):ISubscription;
}

