package rx.observables;
import rx.observables.IObservable;
import rx.disposables.ISubscription; 
import rx.disposables.Binary; 
import rx.disposables.SingleAssignment; 
import rx.observers.IObserver;
import rx.notifiers.Notification;
import rx.Observer;
 
class TakeUntil<T> extends Observable<T>
{   
    var  _source:IObservable<T>; 
    var  _other:IObservable<T>; 
    public function new( source:IObservable<T>,other:IObservable<T>)
    {
         super();
        _source = source; 
        _other=other;
    } 
    override public function subscribe( observer:IObserver<T>):ISubscription{    
     
        var otherSubscription=SingleAssignment.create ();
        var other_observer = Observer.create(
            function(){                   
                observer.on_completed();
                otherSubscription.unsubscribe();
            },
            function(e:String){
                observer.on_completed();
                otherSubscription.unsubscribe();
            },
            function(v:T){ 
                observer.on_completed();
                otherSubscription.unsubscribe();
            }
        ); 

        otherSubscription.set(_other.subscribe(other_observer));
        var takeUntil_observer = Observer.create(
            function(){       
                     observer.on_completed();
            },
            function(e:String){
                     observer.on_error(e);
            },
            function(v:T){ 
                     observer.on_next(v);
            }
        ); 
        var sourceSubscription= _source.subscribe(takeUntil_observer);
        return Binary.create(sourceSubscription,otherSubscription);
    }
}
 