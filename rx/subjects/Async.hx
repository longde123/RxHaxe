

package rx.subjects;
import rx.observables.IObservable;
import rx.observers.IObserver;
import rx.subjects.ISubject;
import rx.AtomicData;
import rx.disposables.ISubscription;
import rx.notifiers.Notification;
import rx.Subscription;
import rx.Utils;
import rx.Observable;
typedef AsyncState<T>={
    @:optional  var last_notification:  Notification<T> ; 
    var is_stopped: Bool;
    var observers: Array<IObserver<T>>;
}
   /* Implementation based on:
     * https://rx.codeplex.com/SourceControl/latest#Rx.NET/Source/System.Reactive.Linq/Reactive/Subjects/AsyncSubject.cs
     * https://github.com/Netflix/RxJava/blob/master/rxjava-core/src/main/java/rx/subjects/AsyncSubject.java
     */
class  Async<T> extends Observable<T>  implements  ISubject<T>
{ 
   var state :AtomicData<AsyncState<T>>;
   static public function  create<T>(  ){
         
        return new Async<T>();
    } 
    function emit_last_notification (_observer:IObserver<T> ,s:AsyncState<T>)
    {
        switch(s.last_notification ) {
                    case OnCompleted:
                        throw  "Bug in AsyncSubject: should not store  notification .OnCompleted as last notificaition";
                    case OnError(e):{
                            _observer.on_error(e);                            
                        }
                    case  OnNext (v) :{
                            _observer.on_next(v); 
                            _observer.on_completed();  
                        }
                    default: { 
                        
                    }                 
                }  
    }

    inline function update(f) return AtomicData.update(f,state); 
    inline function sync(f) return AtomicData.synchronize(f,state);
    inline function   if_not_stopped ( f ) return sync (function(s) return if (! s.is_stopped)  f(s));
    public function new () {
        super();
        state = AtomicData.create({
            last_notification : null,
            is_stopped : false,
            observers : []
        });
    }
 
    override  public function subscribe( _observer:IObserver<T>):ISubscription{      
        sync(function(s:AsyncState<T>){
            var observers =  s.observers.push(_observer);
            //AtomicData.unsafe_set { s with observers } state; 
            if(s.is_stopped)
                emit_last_notification(_observer, s);
           
                
        });         
        return  Subscription.create(function() { 
                    update(function(s:AsyncState<T>){
                            s.observers = Utils.unsubscribe_observer(_observer,s.observers);
                            return s;
                    }); 
            });
    }
    public function  unsubscribe () {
        update(function(s:AsyncState<T>){
                    s.observers = [];
                    return s;
            }); 
    }  
    public function  on_completed (){
        if_not_stopped(function(s:AsyncState<T>){  
               s.is_stopped = true;
               for ( iter in s.observers) emit_last_notification(iter,s);
           });
    }

    public function on_error(e:String) {
        if_not_stopped(function(s:AsyncState<T>){
                s.is_stopped = true;
                s.last_notification=OnError(e); 
                  //  AtomicData.unsafe_set
               for ( iter in s.observers)iter.on_error(e);
           });
    }
    public function  on_next( v:T ){ 
        if_not_stopped(function(s:AsyncState<T>){        
                s.last_notification=OnNext(v); 
                  //  AtomicData.unsafe_set 
           });
    }  
}