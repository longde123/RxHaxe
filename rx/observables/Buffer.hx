package rx.observables;
import rx.observables.IObservable;
import rx.disposables.ISubscription; 
import rx.observers.IObserver;
import rx.notifiers.Notification;
import rx.Observer;
 
class Buffer<T> extends Observable<Array<T>>
{   
    var  _source:IObservable<T>;
    var _count:Int;
    public function new( source:IObservable<T>,count:Int)
    {
         super();
        _source = source;
        _count=count;
    } 
    override public function subscribe( observer:IObserver<Array<T>>):ISubscription{ 
        //lock
        var list=new Array<T>();
        var buffer_observer = Observer.create(
            function(){ 
                //lock
                if (list.length > 0)
                {
                    observer.on_next(list);
                }
                observer.on_completed();
            },
            function(e:String){
                //lock
                if (list.length > 0)
                {
                    observer.on_next(list);
                }
                observer.on_error(e);
            },
            function(v:T){ 
                //lock
                list.push(v); 
                if (list.length == _count)
                {
                    observer.on_next(list);
                    list = new Array<T>();
                }
            }
        );
   
        return _source.subscribe(buffer_observer);
    }
}
 