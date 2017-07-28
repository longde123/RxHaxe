package rx;
import rx.Core.RxObserver;
import rx.observers.ObserverBase;
import rx.observers.CheckedObserver;
import rx.observers.SynchronizedObserver;
import rx.observers.AsyncLockObserver;
import rx.observers.IObserver;

class Observer<T>  implements IObserver<T>{

    var observer:RxObserver<T>; 
    public function new(?_on_completed:Void->Void, ?_on_error:String->Void, _on_next:T->Void){
        
        observer={ onCompleted:_on_completed,
                    onError:_on_error,
                    onNext:_on_next };

    } 
    public function  on_completed (){
        observer.onCompleted();
    }
   
    public function on_error(e:String) {
        observer.onError(e) ;
    }
    public function  on_next( x:T ){
        
        observer.onNext(x);
    }
    
   
 
    static public function  create<T>( ?_on_completed:Void->Void, ?_on_error:String->Void,?_on_next:T->Void){
        if(_on_completed==null)_on_completed=function(){};
        if(_on_error==null)_on_error=function(e:String) { throw e;};
        if(_on_next==null) throw "_on_next null error ";
        return new Observer(_on_completed,_on_error,_on_next);
    } 

    inline static public function  checked<T>(observer:IObserver<T>){
        return CheckedObserver.create(observer); 
    } 
    
    inline static public function  synchronize<T>(observer:IObserver<T>){ 
        return SynchronizedObserver.create(observer); 
    } 
    
    inline static public function  synchronize_async_lock<T>(observer:IObserver<T>){  
        return AsyncLockObserver.create(observer); 
    } 
 
}
 