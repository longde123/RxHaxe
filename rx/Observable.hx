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

//type +'a observable = 'a observer -> subscription
/* Internal module. (see Rx.Observable)
 *
 * Implementation based on:
 * https://github.com/Netflix/RxJava/blob/master/rxjava-core/src/main/java/rx/Observable.java
 */
 

class CreateEmpty<T> extends Observable<T>
{   
      var f:IObserver<T>->ISubscription;
      public function new(f:IObserver<T>->ISubscription){
            this.f=f;
            super();
      }
      override public function subscribe( observer:IObserver<T>):ISubscription{ 
            return f(observer);
      }
}

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
    static public function next<T>( v:T) return new Return(v);
    static public function create<T>( f:IObserver<T>->ISubscription ){ 
        return new CreateEmpty(f);
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
   
 