package rx.observables;
import rx.observables.IObservable;
import rx.disposables.ISubscription;
import rx.observers.IObserver;
import rx.notifiers.Notification;
import rx.Observer;
import rx.Utils;
/*  (* Implementation based on:
   * https://github.com/Netflix/RxJava/blob/master/rxjava-core/src/main/java/rx/operators/OperationSkip.java
   *)
   */
class Skip<T> extends Observable<T> {
    var _source:IObservable<T>;
    var n:Int;

    public function new(source:IObservable<T>, n:Int) {
        super();
        _source = source;
        this.n = n;
    }

    override public function subscribe(observer:IObserver<T>):ISubscription {
        var counter = AtomicData.create(0);
        var drop_observer = Observer.create(observer.on_completed, observer.on_error,
        function(v:T) {
            var count = AtomicData.update_and_get(Utils.succ, counter);
            if (count > n) observer.on_next(v);
        });
        return _source.subscribe(drop_observer);
    }
}
 