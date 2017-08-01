package rx;
import rx.Core.RxObserver;
import rx.observers.ObserverBase;
import rx.observers.CheckedObserver;
import rx.observers.SynchronizedObserver;
import rx.observers.AsyncLockObserver;
import rx.observers.IObserver;

import rx.schedulers.CurrentThread;
import rx.schedulers.DiscardableAction;
import rx.schedulers.Immediate;
import rx.schedulers.NewThread;
import rx.schedulers.MakeScheduler;
import rx.schedulers.Test;
import rx.schedulers.IScheduler;
import rx.schedulers.TimedAction;
import rx.Subscription;
import rx.disposables.Composite; 
class Scheduler{
    
    public static  var currentThread:CurrentThread=new CurrentThread();
    public static  var newThread:NewThread=new NewThread();
    public static  var immediate:Immediate=new Immediate();
    public static  var test:Test=new Test(); 
    public static var timeBasedOperations(get, set):IScheduler;
    static var __timeBasedOperations:IScheduler;
    static function get_timeBasedOperations() {
        if(__timeBasedOperations == null ) 
            __timeBasedOperations=Scheduler.currentThread;
        return __timeBasedOperations ;
    }
    static function set_timeBasedOperations(x) {
        return __timeBasedOperations = x;
    } 

}