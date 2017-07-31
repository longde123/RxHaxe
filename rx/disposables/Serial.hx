package rx.disposables; 
import rx.disposables.Assignable.RxAssignableState;
import rx.disposables.Assignable.AssignableState;
import rx.disposables.Assignable;
import rx.disposables.Assignable;
import rx.Subscription; 
class Serial  extends Assignable
{
    public function new()
    {
            super();
    }
   
    static public function create ()
    {
        return new Serial();
    } 
    public function  set(subscription :ISubscription)
    {   
        var old_state=AtomicData.update_if(
            function (s:RxAssignableState) return !s.is_unsubscribed,
            function (s) { 
                    AssignableState.set(s ,subscription);  
                return s; 
            },state); 
         
        var __subscription=old_state.subscription;
        if (__subscription!=null) __subscription.unsubscribe();

        __set(old_state , subscription);
    }
} 