package rx.observables;
import rx.observables.IObservable;
import rx.disposables.ISubscription;
import rx.disposables.Composite;
import rx.observers.IObserver;
import rx.notifiers.Notification;
import rx.Observer;
typedef CombineLatestState<T> = {
    var latest:Array<T>;
    var counter:Int;
}
class CombineLatest<T,R> extends Observable<R> {
    var _source:Array<Observable<T>>;
    var _combinator:Array<T> -> R;

    public function new(source:Array<Observable<T>>, combinator:Array<T> -> R) {
        super();
        _source = source;
        _combinator = combinator;
    }

    override public function subscribe(observer:IObserver<R>):ISubscription {
        var __latest = new Array<T>();
        for (i in 0..._source.length) {
            __latest[i] = null;
        }
        var state = AtomicData.create({latest:__latest, counter:_source.length});
        //lock
        var on_next = function(i:Int) {
            return function(v:T) {
                AtomicData.update(function(s:CombineLatestState<T>) {
                    s.latest[i] = v;
                    if (!Lambda.has(s.latest, null)) {
                        observer.on_next(_combinator(s.latest));
                    }
                    return s;
                }, state);
            };
        };
        //lock
        var on_completed = function() {
            AtomicData.update(function(s:CombineLatestState<T>) {
                s.counter--;
                if (s.counter == 0) {
                    observer.on_completed();
                }
                return s;
            }, state);

        };
        var __unsubscribe = Composite.create();

        for (i in 0..._source.length) {
            var combineLatest_observer = Observer.create(on_completed, observer.on_error, on_next(i));
            var subscription = _source[i].subscribe(combineLatest_observer);
            __unsubscribe.add(subscription);
        }
        return __unsubscribe;
    }
}
 