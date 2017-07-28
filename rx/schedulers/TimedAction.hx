
package rx.schedulers;
import rx.disposables.ISubscription; 
import rx.Core; 

class  TimedAction  {
    
    public var  discardable_action : Void -> Void;
    public var  exec_time : Float; 
    public function new (discardable_action : Void -> Void, exec_time : Float ){

        this.discardable_action=discardable_action;
        this.exec_time=exec_time; 
    }

    public function compare(ta1:TimedAction,ta2:TimedAction):Bool
    {
        var result =   ta1.exec_time==ta2.exec_time; 
        return   result;
    
    }
}
