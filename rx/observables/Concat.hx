package rx.observables;
import rx.observables.IObservable;
import rx.disposables.ISubscription;
import rx.disposables.Composite;
import rx.observers.IObserver;
import rx.notifiers.Notification;
import rx.Observer;
class ConcatAppend<T> extends Observable<T> {
    var _source1:IObservable<T>;
    var _source2:IObservable<T>;
    var _unsubscribe:Composite;

    public function new(source1:IObservable<T>, source2:IObservable<T>, unsubscribe:Composite) {
        super();
        _source1 = source1;
        _source2 = source2;
        _unsubscribe = unsubscribe;
    }

    override public function subscribe(observer:IObserver<T>):ISubscription {
        var o1_observer = Observer.create(
            function() {
                _unsubscribe.add(_source2.subscribe(observer));
            },
            observer.on_error,
            function(v:T) {
                observer.on_next(v);
            }
        );

        _unsubscribe.add(_source1.subscribe(o1_observer));
        return _unsubscribe;
    }
}
class Concat<T> extends Observable<T> {
    var _source:Array<Observable<T>>;

    public function new(source:Array<Observable<T>>) {
        super();
        _source = source;
    }

    override public function subscribe(observer:IObserver<T>):ISubscription {
        var __unsubscribe = Composite.create();
        var acc:Observable<T> = _source[0];
        for (i in 1..._source.length) {
            acc = new ConcatAppend(acc, _source[i], __unsubscribe);

        }
        acc.subscribe(observer);

        return __unsubscribe;


    }
}
 