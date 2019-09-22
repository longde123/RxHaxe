package rx.observables;
import rx.observables.IObservable;
import rx.disposables.ISubscription;
import rx.disposables.Composite;
import rx.observers.IObserver;
import rx.notifiers.Notification;
import rx.Observer;
/*  (* Implementation based on:
   * https://github.com/Netflix/RxJava/blob/master/rxjava-core/src/main/java/rx/operators/OperationMerge.java
   *)
   */
class Merge<T> extends Observable<T> {
    var _source:Observable<Observable<T>>;

    public function new(source:Observable<Observable<T>>) {
        super();
        _source = source;
    }

    override public function subscribe(actual_observer:IObserver<T>):ISubscription {
        var observer = Observer.synchronize(actual_observer);
        var __unsubscribe = Composite.create();
        var is_stopped = AtomicData.create(false);
        var child_counter = AtomicData.create(0);
        var parent_completed = false;
        var stop = function() {
            var was_stopped = AtomicData.compare_and_set(false, true, is_stopped);
            if (!was_stopped) __unsubscribe.unsubscribe();
            return was_stopped ;
        };

        var stop_if_and_do = function(cond:Bool, thunk:Void -> Void) {
            if ((!AtomicData.get(is_stopped)) && cond) {
                var was_stopped = stop();
                if (!was_stopped) thunk();
            }
        };

        var child_observer = Observer.create(
            function() {
                var count = AtomicData.update_and_get(Utils.pred, child_counter);
                stop_if_and_do((count == 0 && parent_completed), observer.on_completed);
            },
            function(e:String) {
                stop_if_and_do(true, (function() { observer.on_error(e);}));
            },
            function(v:T) {
                if (!(AtomicData.get(is_stopped))) observer.on_next(v);
            }
        );

        var parent_observer = Observer.create(
            function() {
                parent_completed = true;
                var count = AtomicData.get(child_counter);
                stop_if_and_do((count == 0), observer.on_completed);
            },
            observer.on_error,
            function(observable:Observable<T>) {
                if (!AtomicData.get(is_stopped)) {
                    AtomicData.update(Utils.succ, child_counter);
                    var child_subscription = observable.subscribe(child_observer);
                    __unsubscribe.add(child_subscription);
                }
            }
        );

        var parent_subscription = _source.subscribe(parent_observer);
        var subscription = Composite.create([parent_subscription, __unsubscribe]);

        return subscription;

    }
}
 