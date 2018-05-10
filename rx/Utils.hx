package rx;
import haxe.Timer;
import rx.observers.IObserver;
import rx.disposables.ISubscription;
import rx.Subscription;
import rx.Thread;
class Utils {

    static public function try_finally<T>(thunk:Void -> T, finally:Void -> Void):T {
        try {
            var result = thunk() ;
            finally();
            return result;
        } catch (e:String) {
            finally();
            throw e;
        }
        return null;

    }

    inline static public function unsubscribe_observer<T>(_observer:IObserver<T>, _observers:Array<IObserver<T>>):Array<IObserver<T>> {
        return _observers.filter(function(o) return o != _observer);
    }


      static public function create_sleeping_action(action:Void -> Void, exec_time:Float, now:Void -> Float):Void -> ISubscription {

            #if cpp
              return function () {
                var delay:Int = Math.floor((exec_time - now()));
                if (delay > 0 ){
                   Sys.sleep(delay);
                }
                return Subscription.create(function(){
                        action();
                });
            }
            #else

            return function () {
                var t:Null<Timer>=null;
                var delay:Int = Math.floor((exec_time - now()));
                if (delay > 0 ){
                    t= Timer.delay(action,delay *1000);
                }else {
                    action();
                }
                return Subscription.create(function(){
                    if(t!=null) t.stop();
                });
            }
          #end
    }

    inline static public function current_thread_id() {
        return Thread.current();
    }

    static public function pred(i) return i - 1;

    static public function succ(i) return i + 1;

    static public function incr(i) return i + 1;

}