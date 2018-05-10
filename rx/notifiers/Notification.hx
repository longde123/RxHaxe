package rx.notifiers;


enum Notification<T> {
    OnCompleted();
    OnError(msg:String);
    OnNext( a:T);
}