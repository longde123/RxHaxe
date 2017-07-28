package rx.observables;
import rx.observables.IObservable;
import rx.disposables.ISubscription; 
import rx.observers.IObserver;
import rx.notifiers.Notification;
import rx.Observer;
 
class Append<T> extends Observable<T>
{   
    var  _source1:IObservable<T>;
    var  _source2:IObservable<T>;
    public function new( source1:IObservable<T>,source2:IObservable<T>)
    {
         super();
        _source1 = source1;
         _source2 = source2;
    } 
    override public function subscribe( observer:IObserver<T>):ISubscription{ 
         var o1_observer = Observer.create(
                function(){ 
                    _source2.subscribe(observer);
                },
                observer.on_error,
                function(v:T){ 
                    observer.on_next(v); 
                }
         );
   
        return _source1.subscribe(o1_observer);
    }
}
 