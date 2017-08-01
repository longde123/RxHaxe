package rx.observables;
import rx.observables.IObservable;
import rx.disposables.ISubscription; 
import rx.disposables.SingleAssignment; 
import rx.observers.IObserver;
import rx.notifiers.Notification;
import rx.Observer;
 
class DefaultIfEmpty<T> extends Observable<T>
{   
    var  _source:IObservable<T>;
    var _defaultValue:T;
    public function new( source:IObservable<T>,defaultValue:T)
    {
         super();
        _source = source;
        _defaultValue=defaultValue;
    } 
    override public function subscribe( observer:IObserver<T>):ISubscription{ 
        var hasValue:Bool=false;       
        var defaultIfEmpty_observer = Observer.create(
            function(){  
                if (!hasValue)
                {
                    observer.on_next(_defaultValue);
                }
                observer.on_completed();
            },
            function(e:String){
                observer.on_error(e);          
            },
            function(v:T){ 
                hasValue=true;
                observer.on_next(v); 
            }
        ); 
        return _source.subscribe(defaultIfEmpty_observer);
    }
}
 