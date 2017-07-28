package rx.subjects;
import rx.observables.IObservable;
import rx.observers.IObserver;
interface ISubject<T> extends IObservable<T> extends  IObserver<T>
{ 
   
}