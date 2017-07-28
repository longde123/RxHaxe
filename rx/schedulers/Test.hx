
package rx.schedulers;
import rx.disposables.ISubscription; 
import rx.Core;
import cpp.vm.Thread; 

class TestBase implements Base {
    /* Implementation based on:
   * /usr/local/src/RxJava/rxjava-core/src/main/java/rx/schedulers/TestScheduler.java
   */
    
    var  queue :List<TimedAction>;
    var  time:Float; 
    public function new(){
        queue =new List<TimedAction>();
        time=0;  
    }
    

    public function now():Float return time;

    public function  schedule_absolute (due_time:Null<Float>, action:Void->ISubscription ):ISubscription{
     
        if(due_time==null) due_time=now();
        var exec_time =due_time;
        var discardable_action  = DiscardableAction.create( action);
        queue.add(new TimedAction(discardable_action.action ,exec_time)); 
        return discardable_action.unsubscribe();
    }
   

    public function trigger_actions (target_time:Float){ 
      
        while(!queue.isEmpty() ){ 
             var timed_action= queue.first();  
            if( timed_action.exec_time < target_time){
                    queue.pop();
                    time = timed_action.exec_time== 0 ? time : timed_action.exec_time;
                    timed_action.discardable_action ();                    
                   
            }else
            {
                break;
            }    
        }
        time = target_time;
       
    }  

    public function  trigger_actions_until_now(){   
        trigger_actions(time);
    }

    public function   advance_time_to (delay:Float) {  
       
        trigger_actions(delay);
    }

    public function   advance_time_by( delay:Float ){
        var target_time = time + delay;
        trigger_actions( target_time);
    }
    public function reset(){

        queue.clear();
        time=0;  
    }
}

class  Test  extends MakeScheduler {
    var testScheduler:TestBase;
    public function new(){
            super();
            testScheduler=new TestBase();
            baseScheduler=testScheduler;

    }
 
    public function trigger_actions (target_time){
         testScheduler.trigger_actions (target_time);
    }  

    public function  trigger_actions_until_now(){   
         testScheduler.trigger_actions_until_now();
    }

    public function   advance_time_to (delay) {  
         testScheduler.advance_time_to (delay) ;
    }

    public function   advance_time_by( delay ){
         testScheduler.advance_time_by( delay );
    } 
    public function reset(){

        testScheduler.reset();  
    }
}