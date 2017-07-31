
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
typedef BehaviorState<T>={
    var last_notification:  Notification<T> ; 
    var observers: Array<IObserver<T>>;
}
class  Behavior<T> extends Observable<T>  implements  ISubject<T>
{ 
     static public function  create<T>( default_value:T ){
         
        return new Behavior<T>(default_value);
    } 
        /* Implementation based on:
     * https://github.com/Netflix/RxJava/blob/master/rxjava-core/src/main/java/rx/subjects/BehaviorSubject.java
     */
    var state:AtomicData<BehaviorState<T>>;
    inline function update(f) return AtomicData.update(f,state); 
    inline function sync(f) return AtomicData.synchronize(f,state);

    public function new(default_value:T){
        super();
        state = AtomicData.create({
                                last_notification : OnNext(default_value),
                                observers : []});

    }
    override public function subscribe( _observer:IObserver<T>):ISubscription{      
        sync(function(s:BehaviorState<T>){
            var observers =  s.observers.push(_observer);
            //AtomicData.unsafe_set { s with observers } state; 
            switch(s.last_notification ) {
                case OnCompleted:
                    _observer.on_completed ();
                case OnError(e):
                    _observer.on_error(e); 
                case  OnNext (v) :
                    _observer.on_next(v);                
            }  
                
        });         
        return  Subscription.create(function() { 
                    update(function(s:BehaviorState<T>){
                            s.observers = Utils.unsubscribe_observer(_observer,s.observers);
                            return s;
                    }); 
            });
    }
    public function  unsubscribe () {
        update(function(s:BehaviorState<T>){
                    s.observers = [];
                    return s;
            }); 
    } 
    
    public function  on_completed (){
        sync(function(s:BehaviorState<T>){  
                s.last_notification=OnCompleted;
               for ( iter in s.observers)iter.on_completed();
           });
    }

    public function on_error(e:String) {
        sync(function(s:BehaviorState<T>){
                s.last_notification=OnError(e); 
                  //  AtomicData.unsafe_set
               for ( iter in s.observers)iter.on_error(e);
           });
    }
    public function  on_next( v:T ){ 
        sync(function(s:BehaviorState<T>){        
                s.last_notification=OnNext(v); 
                  //  AtomicData.unsafe_set
               for (iter in s.observers)iter.on_next(v);
           });
    } 
  
}