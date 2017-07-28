package rx.observers;

import rx.Core.RxObserver; 
 
class ObserverBase<T> implements IObserver<T>{

 /* Original implementation:
   * https://rx.codeplex.com/SourceControl/latest#Rx.NET/Source/System.Reactive.Core/Reactive/ObserverBase.cs
   */
    var observer:RxObserver<T>;
    var state:AtomicData<Bool>;
    public function  on_completed (){
        var was_stopped = stop ();
        if (! was_stopped ) observer.onCompleted();
    }
    public function stop(){
        return AtomicData.compare_and_set(false, true, state);  
    }
    public function on_error(e:String) {
        var was_stopped = stop () ;
        if (! was_stopped ) observer.onError(e) ;
    }
    public function  on_next( x:T ){
        if (! AtomicData.unsafe_get(state) )
        observer.onNext(x);
    }
    
    public function new(?_on_completed:Void->Void, ?_on_error:String->Void, _on_next:T->Void){
        state = AtomicData.create(false);
        observer={ onCompleted:_on_completed,
                    onError:_on_error,
                    onNext:_on_next };

    } 
    inline static public function  create<T>(observer:IObserver<T>){
        return new ObserverBase<T>(observer.on_completed,observer.on_error,observer.on_next);
    } 
}
