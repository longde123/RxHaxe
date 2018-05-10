package rx.observables;
import rx.observables.IObservable;
import rx.disposables.ISubscription;
import rx.observers.IObserver;
import rx.notifiers.Notification;

import rx.Observer;
import rx.Mutex;
class Blocking<T> {
/* Implementation based on:
 * https://github.com/Netflix/RxJava/blob/master/rxjava-core/src/main/java/rx/observables/BlockingObservable.java
 */
    var mutex:Mutex;
    var queue:Array<Notification<T>>;
    var materialize:Materialize<T>;
    var index:Int;

    public function new(observable:IObservable<T>) {
        mutex = new Mutex();
        queue = new Array<Notification<T>>();
        var observer = Observer.create(null, null, function(n:Notification<T>) {
            mutex.acquire();
            queue.push(n);
            mutex.release();
        });

        materialize = new Materialize(observable);
        materialize.subscribe(observer);
        index = 0;
    }

    public function hasNext():Bool {
        return index < queue.length;
    }

    public function next():T {
        var v = queue[index++];
        return switch(v ) {
            case OnCompleted:throw "No_more_elements";
            case OnError(e):throw e;
            case OnNext(vv) :return vv ;
        }
    }

    static public function to_enum<T>(observable:IObservable<T>) {
        /* Implementation based on:
        * https://github.com/Netflix/RxJava/blob/master/rxjava-core/src/main/java/rx/operators/OperationToIterator.java
        */
        return new Blocking(observable);
    }

    static public function single<T>(observable:IObservable<T>) {
        var _enum = to_enum(new Single(observable)).next();
        return _enum;
    }

}
 