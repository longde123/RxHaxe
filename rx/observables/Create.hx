package rx.observables;
import rx.observables.IObservable;
import rx.disposables.ISubscription;
import rx.observers.IObserver;
import rx.notifiers.Notification;
import rx.Observer;
import rx.disposables.SingleAssignment;
import rx.disposables.Composite;
/**

      var observer = Observer.create(
                function(){  
                },
                function(e){

                },
                function(v:T){ 
                    observer.on_next(v); 
                }
         );
**/
class Create<T> extends Observable<T> {
    var _subscribe:IObserver<T> -> ISubscription;

    public function new(_subscribe:IObserver<T> -> ISubscription) {
        this._subscribe = _subscribe;
        super();
    }

    override public function subscribe(observer:IObserver<T>):ISubscription {
        return _subscribe(observer);
    }
}
