package rx.observables;
import rx.observables.IObservable;
import rx.disposables.ISubscription;
import rx.disposables.SingleAssignment;
import rx.observers.IObserver;
import rx.notifiers.Notification;
import rx.Observer;
import rx.Utils;
/*   (* Implementation based on:
   * https://github.com/Netflix/RxJava/blob/master/rxjava-core/src/main/java/rx/operators/OperationTake.java
   *)
   */
class Take<T> extends Observable<T> {
    var _source:IObservable<T>;
    var n:Int;

    public function new(source:IObservable<T>, n:Int) {
        super();
        _source = source;
        this.n = n;
    }

    override public function subscribe(observer:IObserver<T>):ISubscription {

        if (n < 1) {
            var __observer = Observer.create(null, null, function(v) {});
            var __unsubscribe = _source.subscribe(__observer);
            __unsubscribe.unsubscribe();
            return Subscription.empty();
        }

        var counter = AtomicData.create(0) ;
        var error = false;
        var __unsubscribe = SingleAssignment.create();
        var on_completed_wrapper = function() {
            if (!error && AtomicData.get_and_set(n, counter) < n) {
                observer.on_completed();
            }
        }
        var on_error_wrapper = function(e) {
            if (!error && AtomicData.get_and_set(n, counter) < n) {
                observer.on_error(e);
            }
        }

        var take_observer = Observer.create(on_completed_wrapper, on_error_wrapper,
        function(v) {
            if (!error) {
                var count = AtomicData.update_and_get(Utils.succ, counter);
                if (count <= n) {
                    try {
                        observer.on_next(v);
                    } catch (e:String) {
                        error = true;
                        observer.on_error(e);
                        __unsubscribe.unsubscribe();
                    }
                    if (!error && count == n) {
                        observer.on_completed();
                    }
                }
                if (!error && count >= n) {
                    __unsubscribe.unsubscribe();
                }
            }});

        var result = _source.subscribe(take_observer);
        __unsubscribe.set(result);
        return result ;

    }
}
 