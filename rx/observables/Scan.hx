package rx.observables;
import rx.observables.IObservable;
import rx.disposables.ISubscription;
import rx.observers.IObserver;
import rx.notifiers.Notification;
import rx.Observer;
import rx.Utils;
/*
   */
class Scan<T, R> extends Observable<R> {
    var _source:IObservable<T>;
    var _accumulator:R -> T -> R;
    var _seed:Null<R>;

    public function new(source:IObservable<T>, seed:Null<R>, accumulator:R -> T -> R) {
        super();
        _source = source;
        _accumulator = accumulator;
        _seed = seed;
    }

    override public function subscribe(observer:IObserver<R>):ISubscription {
        var accumulation:Null<R> = null;
        var isFirst = true;
        var scan_observer = Observer.create(
            observer.on_completed,
            observer.on_error,
            function(value:T) {
                if (isFirst) {
                    isFirst = false;
                    accumulation = _accumulator(_seed, value);
                }
                else {
                    accumulation = _accumulator(accumulation, value);
                }
                observer.on_next(accumulation);
            }
        );
        return _source.subscribe(scan_observer);
    }
}
 