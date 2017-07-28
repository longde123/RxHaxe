package rx;
import rx.AtomicData;
import rx.AsyncLock;
import rx.notifiers.Notification;
import rx.Observable;
import rx.Observer;
import rx.Subject;
import rx.Subscription;


typedef  RxSubject<T> = RxObserver<T>->RxObservable<T>;
//type 'a subject = 'a observer * 'a observable
typedef  RxObservable<T> = RxObserver<T>->RxSubscription;
typedef  RxSubscription  = Void->Void;
typedef  RxObserver<T> ={
    //(unit -> unit) * (exn -> unit) * ('a -> unit)
    var onCompleted:Void->Void;
    var onError:String->Void;
    var onNext:T->Void; 
}
 