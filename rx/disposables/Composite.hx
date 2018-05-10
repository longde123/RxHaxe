package rx.disposables;
import rx.disposables.ISubscription;
typedef RxCompositeState = {
    var is_unsubscribed:Bool;
    var subscriptions:Array<ISubscription>;
}
class CompositeState {


    static public function unsubscribe(state:RxCompositeState) {
        state.is_unsubscribed = true;
    }

    static public function add(state:RxCompositeState, subscription:ISubscription) {
        state.subscriptions.push(subscription);
    }

    static public function remove(state:RxCompositeState, subscription:ISubscription) {
        state.subscriptions = state.subscriptions.filter(function(s:ISubscription)return s != subscription);
    }

    static public function clear(state:RxCompositeState) {
        state.subscriptions = [];
    }

}


class Composite implements ISubscription {

    /* Implementation based on:
   * https://github.com/Netflix/RxJava/blob/master/rxjava-core/src/main/java/rx/subscriptions/CompositeSubscription.java
   */

    var state:AtomicData<RxCompositeState>;


    static public function create(?subscriptions:Array<ISubscription>) {
        return new Composite(subscriptions);
    }

    public function new(?_subscriptions:Array<ISubscription>) {
        var stat:RxCompositeState = {
            is_unsubscribed:false,
            subscriptions :_subscriptions != null ? _subscriptions : new Array<ISubscription>()
        };
        state = AtomicData.create(stat);
    }

    public function is_unsubscribed() {
        return AtomicData.unsafe_get(state).is_unsubscribed;
    }

    public function unsubscribe() {

        var old_state = AtomicData.update_if((function(s:RxCompositeState) return !s.is_unsubscribed),
        (function(s:RxCompositeState) {
            CompositeState.unsubscribe(s);
            return s;
        }),
        state);
        var was_unsubscribed = old_state.is_unsubscribed;
        var subscriptions = old_state.subscriptions;


        if (!was_unsubscribed) unsubscribe_from_all(subscriptions);
    }

    public function unsubscribe_from_all(subscriptions:Array<ISubscription>) {
        var exceptions = Lambda.fold(subscriptions, function(_unsubscribe:ISubscription, exns:Array<String>) {
            try {
                _unsubscribe.unsubscribe();
            } catch (e:String) {
                exns.push(e);
            }
            return exns;
        }, []);

        if (exceptions.length > 0) throw exceptions.toString() ;
    }


    public function add(subscription:ISubscription) {
        var old_state = AtomicData.update_if(
            (function(s:RxCompositeState) return !s.is_unsubscribed),
            (function(s:RxCompositeState) {
                CompositeState.add(s, subscription);
                return s;
            }),
            state);
        if (old_state.is_unsubscribed) subscription.unsubscribe();
    }

    public function remove(subscription:ISubscription) {
        var old_state = AtomicData.update_if(
            (function(s:RxCompositeState) return !s.is_unsubscribed),
            (function(s:RxCompositeState) {
                CompositeState.remove(s, subscription);
                return s;
            }),
            state);
        if (!old_state.is_unsubscribed) subscription.unsubscribe();
    }

    public function clear() {
        var old_state = AtomicData.update_if(
            (function(s:RxCompositeState) return !s.is_unsubscribed),
            (function(s:RxCompositeState) {
                CompositeState.clear(s);
                return s;
            }),
            state);
        var was_unsubscribed = old_state.is_unsubscribed ;
        var subscriptions = old_state.subscriptions;
        if (!was_unsubscribed) unsubscribe_from_all(subscriptions);
    }


}
