

package rx.schedulers;
import rx.disposables.ISubscription; 
import rx.Core;
import cpp.vm.Thread;


class ImmediateBase implements Base {
    public function new(){
      
    } 
    public function now():Float{

        return Sys.time();

    }
 
    public function  schedule_absolute (due_time:Null<Float>, action:Void->ISubscription ):ISubscription
    {
        if(due_time==null){
            due_time=now();
        } 

        var action1=Utils.create_sleeping_action(  action,due_time ,now );
      
        return action1();

    }
}
  
 class Immediate  extends  MakeScheduler    {
     public function new(){
            super();
            baseScheduler=new ImmediateBase();

     }

 } 