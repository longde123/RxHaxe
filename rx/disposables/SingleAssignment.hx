package rx.disposables;
import rx.disposables.Assignable.RxAssignableState;
import rx.disposables.Assignable.AssignableState;
import rx.disposables.Assignable;
import rx.disposables.Assignable;
import rx.Subscription;
class SingleAssignment extends Assignable {
    public function new() {
        super();
    }

    static public function create() {
        return new SingleAssignment();
    }

    public function set(subscription:ISubscription) {
        var old_state = AtomicData.update_if(
            function(s:RxAssignableState) return !s.is_unsubscribed,
            function(s) {
                if (s.subscription == null)
                    AssignableState.set(s, subscription);
                else
                    throw "SingleAssignment";
                return s;
            }, state);

        __set(old_state, subscription);
    }
} 