package rx.observables;
import rx.disposables.ISubscription;
import rx.observers.IObserver;
interface IScheduled 
{ 
    public function subscribe_on_this<T>(observable:Observable<T> ):Observable<T>;
    public function  of_enum<T>(a:Array<T>):Observable<T>;
    public function  interval( val: Float):Observable<Int>;
}