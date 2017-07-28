package rx.subjects;
import rx.observables.IObservable;
import rx.observers.IObserver;
import rx.subjects.ISubject;
import rx.AtomicData;
import rx.disposables.ISubscription;
import rx.notifiers.Notification;
import rx.Subscription;
import rx.Utils;
typedef ReplayState<T>={
    var queue: List<Notification<T>>;
    var  is_stopped: Bool;
    var observers: Array<IObserver<T>>;
}
class  Replay<T>  implements  ISubject<T>
{ 
     /* Implementation based on:
     * https://rx.codeplex.com/SourceControl/latest#Rx.NET/Source/System.Reactive.Linq/Reactive/Subjects/ReplaySubject.cs
     * https://github.com/Netflix/RxJava/blob/master/rxjava-core/src/main/java/rx/subjects/ReplaySubject.java
     */
    var state:AtomicData<ReplayState<T>>;
    inline function   update( f ) return   AtomicData.update(f,state);
    inline function   sync ( f ) return AtomicData.synchronize(f,state);
    inline function   if_not_stopped ( f ) return sync (function(s) return if (! s.is_stopped)  f(s));
    static public function  create<T>(  ){
         
        return new Replay<T>();
    } 
    public function  new () {

        state = AtomicData.create({
                                        queue :new List<Notification<T>>(),
                                        is_stopped : false,
                                        observers : []
                                        });
    }
    public function subscribe( _observer:IObserver<T>):ISubscription{
 
        sync(function(s:ReplayState<T>){
                var observers =  s.observers.push(_observer);
                //AtomicData.unsafe_set { s with observers } state;
                for (  iter in s.queue){
                    switch(iter) {
                        case OnCompleted:
                            _observer.on_completed ();
                        case OnError(e):
                            _observer.on_error(e); 
                        case  OnNext (v) :
                            _observer.on_next(v);                
                    }  
                }     
            });
        
   
        return  Subscription.create(function() { 
                    update(function(s:ReplayState<T>){
                            s.observers = Utils.unsubscribe_observer(_observer,s.observers);
                            return s;
                    }); 
            });
    }
    public function  unsubscribe () {
        update(function(s:ReplayState<T>){
                    s.observers = [];
                    return s;
            }); 
    } 
    
    public function  on_completed (){
           if_not_stopped(function(s:ReplayState<T>){
             // AtomicData.unsafe_set { s with is_stopped = true } state;
                s.is_stopped = true;
                s.queue.add(OnCompleted);
            
               for ( iter in s.observers)iter.on_completed();
           });
    }

    public function on_error(e:String) {
            if_not_stopped(function(s:ReplayState<T>){
             // AtomicData.unsafe_set { s with is_stopped = true } state;
                s.is_stopped = true;
                s.queue.add(OnError(e)); 
               for ( iter in s.observers)iter.on_error(e);
           });
    }
    public function  on_next( v:T ){ 
        if_not_stopped(function(s:ReplayState<T>){
             // AtomicData.unsafe_set { s with is_stopped = true } state;
             
                s.queue.add(OnNext(v)); 
               for (iter in s.observers)iter.on_next(v);
           });
    } 
}