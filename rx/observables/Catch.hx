package rx.observables;
import rx.observables.IObservable;
import rx.disposables.ISubscription; 
import rx.disposables.SerialAssignment; 
import rx.observers.IObserver;
import rx.notifiers.Notification;
import rx.Observer;
 
class Catch<T> extends Observable<T>
{   
    var  _source:IObservable<T>;
    var _errorHandler:String->IObservable<T>;
    public function new( source:IObservable<T>,errorHandler:String->IObservable<T>)
    {
         super();
        _source = source;
        _errorHandler=errorHandler;
    } 
    override public function subscribe( observer:IObserver<T>):ISubscription{ 
        var serialDisposable = SerialAssignment.create();
        
        var catch_observer = Observer.create(
            function(){  
                observer.on_completed();
            },
            function(e:String){
                var next = _errorHandler(e);
                serialDisposable.set(next.subscribe(observer));
                observer.on_error(e);
          
            },
            function(v:T){ 
                observer.on_next(v);
            }
        );
  
        serialDisposable.set(_source.subscribe(catch_observer));
        return serialDisposable;
    }
}
 