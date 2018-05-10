package rx.observables;
import rx.observables.IObservable;
import rx.disposables.ISubscription;
import rx.disposables.Binary;
import rx.disposables.Composite;
import rx.Subscription;
import rx.observers.IObserver;
import rx.notifiers.Notification;
import rx.Observer;
import rx.schedulers.IScheduler;

import rx.Subscription;
//todo test
class Delay<T> extends Observable<T> {
    var _source:IObservable<T>;
    var _scheduler:IScheduler;
    var _dueTime:Float;

    public function new(source:IObservable<T>, dueTime:Float, scheduler:IScheduler) {
        super();
        _source = source;
        _dueTime = dueTime;
        _scheduler = scheduler;
    }

    override public function subscribe(observer:IObserver<T>):ISubscription {

        var cancelable = Composite.create();
        var delay_observer = Observer.create(
            function() {

            },
            function(error:String) {

            },
            function(notification:Notification<T>) {
                var d = _scheduler.schedule_absolute(_dueTime, function() {
                    switch( notification ) {
                        case OnCompleted:{
                            observer.on_completed();
                        }
                        case OnError(e):{
                            observer.on_error(e);
                        }
                        case OnNext(v) :{
                            observer.on_next(v);
                        }
                        default: {

                        }
                    }
                } );

                cancelable.add(d);
            }
        );
        var __source = new Materialize(_source);
        var __subscription = __source.subscribe(delay_observer);
        return new Binary(__subscription, cancelable);

    }
}
 