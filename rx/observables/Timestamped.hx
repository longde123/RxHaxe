
package rx.observables;
import rx.observables.IObservable;
import rx.disposables.ISubscription; 
import rx.observers.IObserver;
import rx.notifiers.Notification;
import rx.Observer; 
import rx.Scheduler;
class Timestamped<T>{      
    public var value:T;
    public var timestamp:Float;  
    public function new ( value:T,timestamp:Float)
    {
        this.value=value;
        this.timestamp=timestamp;
    }
}