package rx.observables;
import rx.observables.IObservable;
import rx.disposables.ISubscription; 
import rx.disposables.SingleAssignment; 
import rx.observers.IObserver;
import rx.notifiers.Notification;
import rx.Observer;
 
class Last<T> extends Observable<T>
{   
    var  _source:IObservable<T>;
    var _defaultValue:Null<T>; 
    public function new( source:IObservable<T>,defaultValue:Null<T>)
    {
         super();
        _source = source;
        _defaultValue=defaultValue;
    } 
    override public function subscribe( observer:IObserver<T>):ISubscription{ 
        var notPublished:Bool=true;  
        var lastValue:Null<T>;     
        var defaultIfEmpty_observer = Observer.create(
            function(){  
                if (notPublished){
                    if(_defaultValue!=null){
                            observer.on_next(_defaultValue);
                    }
                    else{ 
                        observer.on_error("sequence is empty");
                    }                      
                }
                else{
                    if(lastValue!=null){
                            observer.on_next(lastValue);
                    }
                    else{ 
                        observer.on_error("sequence is empty");
                    }  
                }

                observer.on_completed();
            },
            function(e:String){
                observer.on_error(e);          
            },
            function(v:T){ 
                notPublished = false;
                lastValue=v; 
            } 
        ); 
        return _source.subscribe(defaultIfEmpty_observer);
    }
}
 