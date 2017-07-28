package rx;
import rx.observers.IObserver;
import rx.disposables.ISubscription; 
import rx.Subscription; 
import cpp.vm.Thread;
class Utils
{

    static public function try_finally<T>(thunk:Void->T,finally:Void->Void):T
    {
        try
        {
            var result = thunk () ;
            finally ();
            return result;
        }catch(e:String){
            finally ();
            throw e;
        }
        return null;
    
    }
    inline static public function unsubscribe_observer<T>(_observer:IObserver<T>, _observers:Array<IObserver<T>>):Array<IObserver<T>>
    {
        return _observers.filter(function( o ) return o != _observer); 
    }

    
    inline static public function create_sleeping_action( action:Void->ISubscription, exec_time:Float ,now:Void->Float )
    {
        return function(){ 
            if (exec_time > now ()) 
            {
                var delay = exec_time - (now ());
                if (delay > 0.0)   
                    Sys.sleep(delay);
            }           
           return action(); 
        }; 
    }
    inline static public function current_thread_id():Thread
    {
         
        return Thread.current();
    
    }
        static public function pred (i) return i-1;
     static public function succ(i) return i+1;
      static public  function incr(i) return  i+1;
    
}