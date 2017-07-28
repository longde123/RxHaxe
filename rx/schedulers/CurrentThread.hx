

package rx.schedulers;
import rx.disposables.ISubscription; 
import rx.Core;
import cpp.vm.Thread;
import cpp.vm.Deque;

class CurrentThreadBase implements Base {
 
    var async:AsyncLock;
    public function new(){
       async=AsyncLock.create();
    }
 
    public function now():Float{

        return Sys.time();

    }
    public function  enqueue( action:Void->Void, exec_time:Float)
    {   
            try{
                async.wait(action); 
            } catch(e:String){
                async=AsyncLock.create();
                throw e;

            }
       
    }
    public function  schedule_absolute (due_time:Null<Float>, action:Void->ISubscription ):ISubscription
    {
        if(due_time==null){
            due_time=now();
        } 
        var action1=Utils.create_sleeping_action(  action,due_time ,now );
        var discardable = DiscardableAction.create(action1);
        enqueue(discardable.action,due_time);
        return discardable.unsubscribe();

     }
    
 

}
  
 class CurrentThread  extends  MakeScheduler   {
     var currentThreadBase:CurrentThreadBase;
     public function new(){
            super();
            baseScheduler=currentThreadBase=new CurrentThreadBase();

     }
    
 }