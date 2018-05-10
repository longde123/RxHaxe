package rx.disposables;

interface ISubscription {
    public function is_unsubscribed():Bool;
    public function unsubscribe():Void;
}

 