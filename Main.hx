package;

import rx.AtomicData;
import rx.AsyncLock;
import rx.notifiers.Notification;
import rx.Observable;
import rx.Observer;
import rx.observers.ObserverBase;
import rx.Subject;
import rx.Subscription;
import rx.Scheduler;
import rx.Core;
import rx.disposables.Boolean;
import rx.disposables.Composite;
import rx.disposables.ISubscription; 
import rx.subjects.Replay;
import rx.subjects.Behavior;
import rx.subjects.Async;
import test.TestAtomicData;
import test.TestAsyncLock;
import test.TestSubscription;
import test.TestObserver;
import test.TestSubject;
import test.TestScheduler;
import test.TestHelper;
import test.TestObservable;
class Main 
{
	static function main(  ){	  
        var r = new haxe.unit.TestRunner();
       	r.add(new TestAtomicData());
       	r.add(new TestAsyncLock());
		r.add(new TestSubscription());
		r.add(new TestObserver());
		r.add(new TestSubject());
		r.add(new TestScheduler());
		r.add(new TestObservable());
        // add other TestCases here

        // finally, run the tests
        r.run();

  
    }
}
