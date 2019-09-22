package rx;
import rx.AtomicData;
typedef RxAsyncLockState = {
    var queue:List<Void -> Void>;
    var is_acquired:Bool;
    var has_faulted:Bool;
}

class AsyncLock {
    var lock:AtomicData<RxAsyncLockState>;

    public function new() {
        var async:RxAsyncLockState = {
            queue:new List<Void -> Void>(),
            is_acquired : false,
            has_faulted : false
        };
        lock = AtomicData.create(async);

    }

    static public function create() {
        return new AsyncLock();
    }


    public function dispose() {
        AtomicData.update((function(l) {
            l.queue.clear();
            l.has_faulted = true;
            return l;
        })
        , lock
        );

    }


    public function wait(action:Void -> Void) {

        var old_state = AtomicData.update_if(
            ( function(l:RxAsyncLockState) { return !l.has_faulted;}),
            (function(l:RxAsyncLockState) {
                l.queue.push(action);
                l.is_acquired = true;
                return l;
            }), lock);
        var is_owner = !old_state.is_acquired;

        if (is_owner) {

            while (true) {

                var work = AtomicData.synchronize((function(l:RxAsyncLockState) {
                    if (l.queue.isEmpty()) {

                        var value = function(l:RxAsyncLockState) { l.is_acquired = false; return l;}(lock.data);
                        AtomicData.unsafe_set(value, lock);
                        return null;
                    } else {
                        return l.queue.pop() ;
                    }
                }), lock) ;

                if (work != null) {
                    var w = work;
                    try {
                        w();
                    }
                    catch (msg:String) {

                        dispose();
                        throw msg;
                    }
                } else {
                    break;
                }

            }

        }

    }
}
