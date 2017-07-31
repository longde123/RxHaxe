package rx.observables;
import rx.observables.IObservable;
import rx.disposables.ISubscription; 
import rx.observers.IObserver;
import rx.notifiers.Notification;
import rx.Observer;
typedef BufferState<T>={     
     var list:Array<T>; 
}
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
        var state=AtomicData.create({list:new Array<T>()});
        var buffer_observer = Observer.create(
            function(){ 
                //lock
                AtomicData.update_if(function(s:BufferState<T>){
                    return (s.list.length > 0);
                },function(s:BufferState<T>){
                    observer.on_next(s.list);
                    return s;
                },state);                
                observer.on_completed();
            },
            function(e:String){
                //lock
                AtomicData.update_if(function(s:BufferState<T>){
                    return (s.list.length > 0);
                },function(s:BufferState<T>){
                    observer.on_next(s.list);
                    return s;
                },state);  

                observer.on_error(e);
            },
            function(v:T){ 
                //lock
                AtomicData.update_if(function(s:BufferState<T>){
                    return (s.list.length < _count);
                },function(s:BufferState<T>){
                    s.list.push(v); 
                    if (s.list.length == _count)
                    {
                        observer.on_next(s.list);
                        s.list = new Array<T>();
                    }
                    return s;
                },state);
              
            }
        );
   
        return _source.subscribe(buffer_observer);
    }
}
 