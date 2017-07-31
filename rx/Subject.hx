package rx;
import rx.observables.IObservable;
import rx.observers.IObserver;
import rx.subjects.ISubject;
import rx.subjects.Async;
import rx.subjects.Replay;
import rx.subjects.Behavior;
import rx.AtomicData;
import rx.disposables.ISubscription;
import rx.Subscription;
import rx.Utils;
import rx.Observable;
class  Subject<T> extends Observable<T>  implements  ISubject<T>
{ 
   

    var  observers:AtomicData<Array<IObserver<T>>>  ;
 
  /* Implementation based on:
   * https://rx.codeplex.com/SourceControl/latest#Rx.NET/Source/System.Reactive.Linq/Reactive/Subjects/Subject.cs
   */
 
     static public function  create<T>(  ){
         
        return new Subject<T>();
    } 
    static public function  async<T>(  ){
         
        return Async.create();
    } 
    static public function  replay<T>(  ){
         
        return Replay.create();
    } 
    static public function  behavior<T>( default_value:T  ){
         
        return Behavior.create(default_value);
    } 


    public function new(){
        super();
        observers = AtomicData.create([]);

    }
    
    inline function update(f:Array<IObserver<T>>->Array<IObserver<T>>) return  AtomicData.update(f, observers);
    inline function sync(f:Array<IObserver<T>>->Array<IObserver<T>>) return  AtomicData.synchronize(f,observers);
    inline function iter(f:IObserver<T>->IObserver<T>) return   sync(function(os :Array<IObserver<T>> ) return os.map(f));

    override public function subscribe( _observer:IObserver<T>):ISubscription{
        update (function(os:Array<IObserver<T>>) {os.push(_observer); return os;});
        return  Subscription.create(function() { update(Utils.unsubscribe_observer.bind(_observer)); });
    }
    public function  unsubscribe () {
        AtomicData.set([] ,observers);
    } 
    
    public function  on_completed (){
        iter ( function(observer:IObserver<T>) {observer.on_completed();  return observer;});
    }

    public function on_error(e:String) {
        iter ( function(observer:IObserver<T>) {observer.on_error(e); return observer;});
    }
    public function  on_next( v:T ){ 
        iter ( function(observer:IObserver<T>) {observer.on_next(v); return observer;});
    }
}