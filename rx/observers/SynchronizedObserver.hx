package rx.observers;
import rx.Utils;
import rx.Core.RxObserver;  
import cpp.vm.Mutex;  
class SynchronizedObserver<T> implements IObserver<T>{
   /* Original implementation:
   * https://rx.codeplex.com/SourceControl/latest#Rx.NET/Source/System.Reactive.Core/Reactive/Internal/SynchronizedObserver.cs
   */
    var mutex : Mutex ; 
    var observer:RxObserver<T>;
    public function new(?on_completed:Void->Void, ?on_error:String->Void, on_next:T->Void){
        mutex = new Mutex();
        observer={ onCompleted:on_completed,
                    onError:on_error,
                    onNext:on_next };

    }
    function  with_lock<T>( f:T->Void, ?a:T)
    {
        mutex.acquire();
        f(a);
        mutex.release();
    } 
    public function on_error(e:String) {
        with_lock(observer.onError,e);
    }
    public function  on_next( x:T ){
        with_lock(observer.onNext,x);
    } 
    public function  on_completed(){
        mutex.acquire();
            observer.onCompleted();
        mutex.release(); 
    }

    inline static public function  create<T>(observer:IObserver<T>){
        return new SynchronizedObserver<T>(observer.on_completed,observer.on_error,observer.on_next);
    } 
}