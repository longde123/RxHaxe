package rx.observables;
import rx.observables.IObservable;
import rx.disposables.ISubscription;
import rx.disposables.Binary;
import rx.disposables.SingleAssignment;
import rx.observers.IObserver;
import rx.notifiers.Notification;
import rx.Observer;

class SkipUntil<T> extends Observable<T> {
    var _source:IObservable<T>;
    var _other:IObservable<T>;

    public function new(source:IObservable<T>, other:IObservable<T>) {
        super();
        _source = source;
        _other = other;
    }

    override public function subscribe(observer:IObserver<T>):ISubscription {
        //lock
        var triggered = false;
        var otherSubscription = SingleAssignment.create();
        var other_observer = Observer.create(
            function() {
                triggered = true;
                otherSubscription.unsubscribe();
            },
            function(e:String) {
                triggered = true;
                otherSubscription.unsubscribe();
            },
            function(v:T) {
                triggered = true;
                otherSubscription.unsubscribe();
            }
        );
        otherSubscription.set(_other.subscribe(other_observer));
        var skipUntil_observer = Observer.create(
            function() {
                if (triggered)
                    observer.on_completed();
            },
            function(e:String) {
                if (triggered)
                    observer.on_error(e);
            },
            function(v:T) {
                if (triggered)
                    observer.on_next(v);
            }
        );
        var sourceSubscription = _source.subscribe(skipUntil_observer);
        return Binary.create(sourceSubscription, otherSubscription);
    }
}
 