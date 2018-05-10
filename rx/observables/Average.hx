package rx.observables;
import rx.observables.IObservable;
import rx.disposables.ISubscription;
import rx.observers.IObserver;
import rx.notifiers.Notification;
import rx.Observer;
typedef AverageState = {
    var sum:Float;
    var count:Int;
}
class Average<T> extends Observable<Float> {
    var _source:IObservable<T>;

    public function new(source:IObservable<T>) {
        super();
        _source = source;
    }

    override public function subscribe(observer:IObserver<Float>):ISubscription {

        var state = AtomicData.create({sum:0.0, count:0});
        var average_observer = Observer.create(
            function() {
                var s:AverageState = AtomicData.unsafe_get(state);
                if (s.count == 0.0) throw "Sequence contains no elements.";
                var average:Float = s.sum / s.count;
                observer.on_next(average);
                observer.on_completed();
            },
            observer.on_error,
            function(value:T) {
                AtomicData.update(function(s:AverageState) {
                    try {
                        s.sum = s.sum + cast(value);
                        s.count = s.count + 1;
                    }
                    catch (ex:String) {
                        observer.on_error(ex);
                    }
                    return s;
                }, state);

            }
        );

        return _source.subscribe(average_observer);
    }
}
 