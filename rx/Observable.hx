package rx;
import rx.Core.RxObserver;
import rx.Core.RxSubscription;
//Creating Observables

import rx.observables.Create;// create an Observable from scratch by calling observer methods programmatically
import rx.observables.Defer;//  — do not create the Observable until the observer subscribes, and create a fresh Observable for each observer
import rx.observables.Empty;
import rx.observables.Never;
import rx.observables.Error;//  — create Observables that have very precise and limited behavior
//From;// — convert some other object or data structure into an Observable
//Interval;//  — create an Observable that emits a sequence of integers spaced by a particular time interval
//Just;//  — convert an object or a set of objects into an Observable that emits that or those objects
//Range;//  — create an Observable that emits a range of sequential integers
//Repeat;//  — create an Observable that emits a particular item or sequence of items repeatedly
//Start;//  — create an Observable that emits the return value of a function
//Timer;//  — create an Observable that emits a single item after a given delay


import rx.observables.Empty;
import rx.observables.Error;
import rx.observables.Never;
import rx.observables.Return;

import rx.observables.Append;

import rx.observables.Dematerialize;
import rx.observables.Skip;
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
//8-2
import rx.observables.First;
import rx.observables.Last;
import rx.observables.IgnoreElements;
import rx.observables.SkipUntil;
import rx.observables.Scan;


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
        return  new Return(__args );
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
    
    static public function scan<T,R>(observable:Observable<T>,accumulator:R->T->R,?seed:Null<R>){ 
        return new Scan(observable,accumulator ,seed);
    } 
    static public function last<T>(observable:Observable<T>,?source:Null<T>){ 
        return new Last(observable,source);
    } 
    static public function first<T>(observable:Observable<T>,?source:Null<T>){ 
        return new First(observable,source);
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
        return skip(observable,n);
    }
    static public function skip<T>(observable:Observable<T>,n:Int ){ 
        return new Skip(observable,n);
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
    static public function map<T,R>(observable:Observable<T>,f :T->R){ 
        return new Map(observable,f);
    }

    static public function merge<T>(observable:Observable<Observable<T>> ){ 
        return  new Merge(observable);
    }
  
    static public function flatMap<T,R>(observable:Observable<T>,f:T->Observable<R> ){ 
        return bind(observable,f);
    } 
  
    static public function bind<T,R>(observable:Observable<T>,f:T->Observable<R> ){ 
        return merge(map(observable,f));
    } 
}
   
 