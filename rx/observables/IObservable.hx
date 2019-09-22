package rx.observables;
import rx.disposables.ISubscription;
import rx.observers.IObserver;
interface IObservable<T> {
    public function subscribe(observer:IObserver<T>):ISubscription;
}