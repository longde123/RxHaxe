package rx.schedulers;
import rx.disposables.ISubscription;
import rx.Core;
typedef DiscardableActionState = {
    var ready:Bool;
    var un_subscribe:ISubscription;
    var action:Void -> ISubscription;
}


class DiscardableAction {

    static public function create(_action:Void -> ISubscription):DiscardableAction {
        return new DiscardableAction(_action);
    }
    var state:AtomicData<DiscardableActionState>;

    public function was_ready() {
        var old_state = AtomicData.update_if((function(s:DiscardableActionState) return s.ready),
        (function(s:DiscardableActionState) { s.ready = false; return s; }),
        state);
        return old_state.ready;
    }

    public function action() {
        if (was_ready()) {
            AtomicData.update((function(s:DiscardableActionState) {
                s.un_subscribe= s.action() ;
                return s;
            }), state);
        }
    }

    public function unsubscribe() {
        return AtomicData.unsafe_get(state).un_subscribe ;
    }

    public function new(_action:Void -> ISubscription) {
        var actionState:DiscardableActionState = {
            ready: true,
            un_subscribe :Subscription.empty(),
            action:null
        };
        state = AtomicData.create(actionState);

        AtomicData.update(function(s:DiscardableActionState) {
            s.action = _action;
            s.un_subscribe = Subscription.create(function() {
                AtomicData.update(function(s1:DiscardableActionState) { s1.ready = false; return s1;}, state);
            });
            return s;
        }, state);


    }
}