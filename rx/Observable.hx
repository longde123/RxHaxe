package rx;
import rx.Core.RxObserver;
import rx.Core.RxSubscription;
import rx.observables.Empty;
import rx.observables.Error;
import rx.observables.Never;
import rx.observables.Return;

import rx.observables.Append;

import rx.observables.Dematerialize;
import rx.observables.Drop;
import rx.observables.Length;
import rx.observables.Map;
import rx.observables.Materialize;
import rx.observables.Merge;
import rx.observables.Single;
import rx.observables.Take;
import rx.observables.TakeLast;
//7-31 
import rx.observables.Average;
import rx.observables.Amb;
import rx.observables.Buffer;
import rx.observables.Catch;
import rx.observables.CombineLatest;
import rx.observables.Concat;
import rx.observables.Contains;
//8-1
import rx.observables.Defer;
import rx.observables.Create;
import rx.observables.Throttle;
import rx.observables.DefaultIfEmpty;
import rx.observables.Timestamp;
import rx.observables.Delay;
import rx.observables.Distinct;
import rx.observables.DistinctUntilChanged;
import rx.observables.Filter;
import rx.observables.Find;
import rx.observables.ElementAt;


import rx.observables.MakeScheduled;
import rx.observables.Blocking;

import rx.observables.CurrentThread;
import rx.observables.Immediate;
import rx.observables.NewThread;
import rx.observables.Test;




import rx.observables.IObservable;
import rx.disposables.ISubscription; 
import rx.observers.IObserver;
import rx.notifiers.Notification; 
import rx.schedulers.IScheduler;

//type +'a observable = 'a observer -> subscription
/* Internal module. (see Rx.Observable)
 *
 * Implementation based on:
 * https://github.com/Netflix/RxJava/blob/master/rxjava-core/src/main/java/rx/Observable.java
 */
 

class Observable<T>  implements IObservable<T>
{    
      public function new(){

      }
      public function subscribe( observer:IObserver<T>):ISubscription{
            return Subscription.empty();
      }
    public static  var currentThread:CurrentThread=new CurrentThread();
    public static  var newThread:NewThread=new NewThread();
    public static  var immediate:Immediate=new Immediate(); 
    public static  var test:Test=new Test(); 
    static public function empty() return new Empty();
    static public function error(e:String ) return new Error(e);
    static public function never() return new Never();
    static public function of_return<T>( v:T) return new Return(v);
    static public function create<T>( f:IObserver<T>->ISubscription ){ 
        return new Create(f);
    } 
    static public function defer<T>(_observableFactory:Void->Observable<T>){ 
        return  new Defer(_observableFactory);
    }
    static public function of<T>(__args:T ):Observable<T> {
        return  new Create(function(observer:IObserver<T>){                                   
                                    observer.on_next(__args);
                                    observer.on_completed();
                                    return Subscription.empty();
                                });
    }
    static public function of_enum<T>(__args:Array<T> ):Observable<T> {
        return  new Create(function(observer:IObserver<T>){
                                    for(i in 0...__args.length) {
                                        observer.on_next(__args[i]);
                                    }
                                    observer.on_completed();
                                    return Subscription.empty();
                                });
    }
 
    static public function  fromRange(?initial:Null<Int>, ?limit:Null<Int>,?step:Null<Int>){
        if(limit==null &&  step==null){
            initial=0;
            limit =1;
        } 
        if(step==null){
            step=1;
        }
        return Observable.create(function(observer:IObserver<Int>){
                                    var i=initial;
                                    while(i<limit) {
                                        observer.on_next(i);
                                        i+=step;
                                    }
                                    observer.on_completed();
                                     return Subscription.empty();
                                }); 
    }
    static public function find<T>(observable:Observable<T>,comparer:Null<T->Bool>){ 
        return new Find( observable ,comparer); 
    }
    static public function filter<T>(observable:Observable<T>,comparer:Null<T->Bool>){ 
        return new Filter( observable ,comparer); 
    }
    static public function distinctUntilChanged<T>(observable:Observable<T>,?comparer:Null<T->T->Bool>){ 
        if(comparer==null) comparer=function (a,b)return a==b;
        return new DistinctUntilChanged( observable ,comparer); 
    }
    static public function distinct<T>(observable:Observable<T>,?comparer:Null<T->T->Bool>){ 
         if(comparer==null) comparer=function (a,b)return a==b;
        return new Distinct( observable ,comparer); 
    }
    
    static public function  delay<T>(source:Observable<T>,dueTime:Float, ?scheduler:Null<IScheduler>)
    {
        if(scheduler==null)scheduler=Scheduler.timeBasedOperations;
        return new Delay<T>(source,Sys.time()+dueTime, scheduler );
    }
    static public function  timestamp<T>(source:Observable<T>,?scheduler:Null<IScheduler>)
    {
        if(scheduler==null)scheduler=Scheduler.timeBasedOperations;
        return new Timestamp<T>(source,scheduler );
    }
    static public function defaultIfEmpty<T>(observable:Observable<T>,source:T){ 
        return new DefaultIfEmpty( observable ,source); 
    }
    static public function contains<T>(observable:Observable<T>,source:T){ 
        return new Contains( observable ,function (v )return v==source); 
    }
    static public function concat<T>(observable:Observable<T>,source:Array<Observable<T>> ){ 
        return new Concat([observable].concat(source)); 
    }
    static public function combineLatest<T>(observable:Observable<T>,source:Array<Observable<T>>,combinator:Array<T>->T){ 
        return new CombineLatest([observable].concat(source),combinator); 
    }
    static public function of_catch<T>(observable:Observable<T>,errorHandler:String->Observable<T>){ 
        return new Catch(observable,errorHandler); 
    }
    static public function buffer<T>(observable:Observable<T>,count:Int ){ 
        return new Buffer(observable,count); 
    }
    static public function observer<T>(observable:Observable<T> , fun:T->Void ){ 
        return observable.subscribe(Observer.create(null,null,fun));
    }
    static public function amb<T>(observable1:Observable<T>, observable2:Observable<T>){ 
        return new Amb(observable1,observable2); 
    }
    static public function average<T>(observable:Observable<T> ){ 
        return new Average(observable); 
    }
    static public function materialize<T>(observable:Observable<T> ){ 
        return new Materialize(observable);
    }
    static public function dematerialize<T>(observable:Observable<Notification<T>> ){ 
        return new Dematerialize(observable);
    }
    static public function length<T>(observable:Observable<T> ){ 
        return new Length(observable);
    }
    static public function drop<T>(observable:Observable<T>,n:Int ){ 
        return new Drop(observable,n);
    }
    static public function take<T>(observable:Observable<T>,n:Int ){ 
        return new Take(observable,n);
    }
    static public function take_last<T>(observable:Observable<T>,n:Int ){ 
        return new TakeLast(observable,n);
    }
    static public function single<T>(observable:Observable<T> ){ 
        return new Single(observable);
    }
    static public function append<T>(observable1:Observable<T> ,observable2:Observable<T> ){ 
        return new Append(observable1,observable2);
    }
    static public function map<T>(observable:Observable<T>,f :T->T){ 
        return new Map(observable,f);
    }

    static public function merge<T>(observable:Observable<Observable<T>> ){ 
        return  new Merge(observable);
    }
  
    static public function bind<T,R>(observable:Observable<T>,f:T->Observable<R> ){ 
        
            // o = map(observable,f)
         var o = Observable.create(function( observer:IObserver<Observable<R>>) {
            observable.subscribe(Observer.create(
                                                  null,
                                                  null,
                                                  function(v:T){
                                                          observer.on_next(f(v)); 
                                                  })
                                );
           
            observer.on_completed();
            return Subscription.empty();
        });
        return merge(o);
    } 
}
   
 