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
import rx.schedulers.TimedAction;

class Scheduler{
    
    public static  var currentThread:CurrentThread=new CurrentThread();
    public static  var newThread:NewThread=new NewThread();
    public static  var immediate:Immediate=new Immediate();
    public static  var test:Test=new Test();

}