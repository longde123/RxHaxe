package rx.observables;
import rx.observables.IObservable;
import rx.disposables.ISubscription; 
import rx.observers.IObserver;
import rx.notifiers.Notification;
import rx.Observer;
import rx.Utils;
 /*   
   */
class Map<T,R> extends Observable<R>
{   
    var  _source:IObservable<T>;
    var  _f:T->R;    
    public function new( source:IObservable<T>,f:T->R)
    {
         super();
        _source = source;
        _f=f;
    } 
    override  public function subscribe( observer:IObserver<R>):ISubscription{
        var  map_observer = Observer.create(
            observer.on_completed,
            observer.on_error,
            function(v:T){
                observer.on_next(_f(v));
            }
        );       
        return _source.subscribe(map_observer);
    }
}
 