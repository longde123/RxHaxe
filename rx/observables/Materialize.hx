package rx.observables;
import rx.observables.IObservable;
import rx.disposables.ISubscription; 
import rx.observers.IObserver;
import rx.notifiers.Notification;
import rx.Observer;
//type +'a observable = 'a observer -> subscription
/* Implementation based on:
   * https://github.com/Netflix/RxJava/blob/master/rxjava-core/src/main/java/rx/operators/OperationMaterialize.java
   */

class Materialize<T> extends Observable<Notification<T>>
{   
    var  _source:IObservable<T>;

    public function new( source:IObservable<T>)
    {
         super();
        _source = source;
        
    } 
   
    override public function subscribe( observer:IObserver<Notification<T>>):ISubscription{
        var materialize_observer = Observer.create(function(){ 
                observer.on_next(OnCompleted);
                observer.on_completed ();
           },function(e:String){ 
                observer.on_next(OnError(e));
                observer.on_completed ();
           },function(v:T){ 
                observer.on_next(OnNext(v)); 
           }
         );
   
        return _source.subscribe(materialize_observer);
    }
}
 