package rx.schedulers;
import rx.disposables.ISubscription; 
import rx.Core;
interface Base {
    public  function  now():Float  ;
    //绝对的
    public  function  schedule_absolute(due_time:Null<Float>, action:Void-> ISubscription ): ISubscription;
}

