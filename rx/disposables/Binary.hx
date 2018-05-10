package rx.disposables;

import rx.disposables.ISubscription;
import rx.Subscription;


class Binary implements ISubscription {

    var state:AtomicData<Bool>;
    var first:ISubscription;
    var second:ISubscription;

    public function unsubscribe() {

        var was_unsubscribed = AtomicData.compare_and_set(false, true, state);
        if (!was_unsubscribed) {
            first.unsubscribe();
            second.unsubscribe();
        }
    }

    static public function create(first:ISubscription, second:ISubscription) {
        return new Binary(first, second);
    }

    public function new(first:ISubscription, second:ISubscription) {
        this.first = first;
        this.second = second;
        state = AtomicData.create(false);
    }


    public function is_unsubscribed():Bool return AtomicData.unsafe_get(state);

}