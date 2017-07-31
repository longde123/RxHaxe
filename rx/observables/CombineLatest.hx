package rx.observables;
import rx.observables.IObservable;
import rx.disposables.ISubscription; 
import rx.disposables.Composite; 
import rx.observers.IObserver;
import rx.notifiers.Notification;
import rx.Observer;
 
class CombineLatest<T> extends Observable<T>
{   
    var _source:Array<Observable<T>>; 
    var _combinator:Array<T>->T;
    public function new( source:Array<Observable<T>>,combinator:Array<T>->T)
    {
         super();
        _source = source;
        _combinator=combinator;
    } 
    override public function subscribe( observer:IObserver<T>):ISubscription{ 
        
        var  latest:Array<T>=[];
        var completed =_source.length;
        //lock
        var on_next=function(i:Int) {
                return function(v:T){  
                    latest[i]=v; 
                    if(!Lambda.has(latest,null))
                    {
                        observer.on_next(_combinator(latest));
                    }

                };
        };
        //lock
        var on_completed= function(){  
                completed--;
                if(completed==0)
                {
                    observer.on_completed();
                } 
        }; 
        var __unsubscribe = Composite.create(); 
        for (i in 0..._source.length)
        {
            latest[i]=null;
        }
        for (i in 0..._source.length)
        {
            var combineLatest_observer = Observer.create(on_completed,observer.on_error, on_next(i));
            var subscription= _source[i].subscribe(combineLatest_observer);            
            __unsubscribe.add(subscription);
        }
        return __unsubscribe;      
    }
}
 