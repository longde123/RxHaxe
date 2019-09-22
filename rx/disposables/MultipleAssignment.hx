package rx.disposables;
import rx.disposables.Assignable.RxAssignableState;
import rx.disposables.Assignable.AssignableState;
import rx.disposables.Assignable;
import rx.Subscription;
class MultipleAssignment extends Assignable {
    public function new(subscription:ISubscription) {
        super(subscription);
    }

    static public function create(subscription:ISubscription) {
        return new MultipleAssignment(subscription);
    }

    public function set(subscription:ISubscription) {
        var old_state = AtomicData.update_if(
            function(s:RxAssignableState) return !s.is_unsubscribed,
            function(s) {
                AssignableState.set(s, subscription);
                return s;
            },
            state);
        __set(old_state, subscription);
    }
} 
