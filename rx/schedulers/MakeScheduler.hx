 

package rx.schedulers;
import rx.disposables.ISubscription; 
import rx.disposables.MultipleAssignment;
import rx.disposables.Composite;
import rx.Subscription;
import rx.Core;
class  MakeScheduler   implements IScheduler  {
    public var baseScheduler:Base;
    public function new ()
    {
      
    }   
    public function now():Float{

        return Sys.time();

    }
 
    public function  schedule_absolute (due_time:Null<Float>, action:Void->ISubscription ):ISubscription
    {
    
       return baseScheduler.schedule_absolute (due_time, action);
    }    
    public function schedule_relative(delay:Null<Float>, action:Void->ISubscription): ISubscription
    {
       
            var due_time = baseScheduler.now () + delay; 
            return baseScheduler.schedule_absolute(due_time,action);
    }
   
    function schedule_k(child_subscription:MultipleAssignment,parent_subscription:Composite,k:(Void->ISubscription)->ISubscription):ISubscription{
        var k_subscription = 
            if (parent_subscription.is_unsubscribed()){
                return Subscription.empty();
            }else{
                return baseScheduler.schedule_absolute(null,function (){
                    return k(function () return  schedule_k(child_subscription,parent_subscription,k));
                });
            };

        child_subscription.set(k_subscription);
        return child_subscription;
    }
    public function  schedule_recursive (cont:(Void->ISubscription)->ISubscription){
            var child_subscription=MultipleAssignment.create(Subscription.empty());
            var parent_subscription =Composite.create([child_subscription]);
            var scheduled_subscription = baseScheduler.schedule_absolute(null,function () return schedule_k(child_subscription,parent_subscription,cont));    
            parent_subscription.add( scheduled_subscription );
            return parent_subscription;
    }
    function loop (completed:AtomicData<Bool>, period:Null<Float>, action:Void-> ISubscription ): ISubscription { 
        if   ( !AtomicData.unsafe_get(completed)){
            var started_at = now ();
            var unsubscribe1 = action () ;
            var time_taken = (now ()) -started_at;
            var delay = period -  time_taken; 
            var unsubscribe2 = schedule_relative(delay,function() return loop(completed,period,action));
            return Subscription.create (function () {   
                                unsubscribe1.unsubscribe();
                                unsubscribe2.unsubscribe();
                            });
        }     
        return   Subscription.empty();
    }
 
  
// initial_delay:Float , due_time: Float ,action:Void-> ISubscription 
  public function  schedule_periodically (initial_delay:Null<Float>, period:Null<Float>, action:Void-> ISubscription ): ISubscription{ 
        var completed = AtomicData.create (false );            
        var delay:Null<Float> =0;
        if(initial_delay!=null)delay=initial_delay;
        var unsubscribe1 = schedule_relative(delay,function() return loop(completed,period,action));
        return  Subscription.create(function () {   
                AtomicData.set(true,completed);
                unsubscribe1.unsubscribe();
            });
  }

  

}

