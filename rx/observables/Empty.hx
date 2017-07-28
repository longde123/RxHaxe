package rx.observables; 
import rx.observables.IObservable;
import rx.disposables.ISubscription; 
import rx.observers.IObserver;
class Empty<T> extends Observable<T>
{
      public function new(){
            super();
      }
      override public function subscribe( observer:IObserver<T>):ISubscription{
            observer.on_completed ();
            return Subscription.empty();
      }
}