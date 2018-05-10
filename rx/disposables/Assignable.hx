package rx.disposables;

import rx.disposables.ISubscription;
import rx.Subscription;
typedef RxAssignableState = {
    var is_unsubscribed:Bool;
    @:optional var subscription:ISubscription;
}
class AssignableState {

    static public function unsubscribe(state) {
        state.is_unsubscribed = true;
    }

    static public function set(state, subscription:ISubscription) {
        state.subscription = subscription;
    }

}
class Assignable implements ISubscription {


    var state:AtomicData<RxAssignableState>;

    public function is_unsubscribed() {
        var s = AtomicData.unsafe_get(state);
        return s.is_unsubscribed;
    }

    public function unsubscribe() {
        var old_state = AtomicData.update_if(
            (function(s:RxAssignableState) return !s.is_unsubscribed),
            (function(s:RxAssignableState) {
                AssignableState.unsubscribe(s);
                return s;
            }
            ),
            state);

        var was_unsubscribed = old_state.is_unsubscribed ;
        var subscription = old_state.subscription;
        if (!was_unsubscribed && subscription != null) subscription.unsubscribe();

    }

    static public function create() {
        return new Assignable();
    }

    public function new(?subscription) {
        state = AtomicData.create({
            is_unsubscribed:false,
            subscription :subscription});
    }


    public function __set(old_state:RxAssignableState, subscription:ISubscription) {
        //todo

        var was_unsubscribed = old_state.is_unsubscribed;
        if (was_unsubscribed) subscription.unsubscribe();
    }


}