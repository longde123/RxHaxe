package rx.observers;
import rx.Utils;
import rx.Core.RxObserver;
enum CheckState {
    Idle;
    Busy;
    Done;
}
class CheckedObserver<T> implements IObserver<T> {

    /* In the original implementation, synchronization for the observer state
   * is obtained through CAS (compare-and-swap) primitives, but in OCaml we
   * don't have a standard/portable CAS primitive, so I'm using a mutex.
   * (see https://rx.codeplex.com/SourceControl/latest#Rx.NET/Source/System.Reactive.Core/Reactive/Internal/CheckedObserver.cs)
   */
    var state:AtomicData<CheckState>;

    var observer:RxObserver<T>;

    public function new(?_on_completed:Void -> Void, ?_on_error:String -> Void, _on_next:T -> Void) {
        state = AtomicData.create(Idle);
        observer = { onCompleted:_on_completed,
            onError:_on_error,
            onNext:_on_next };

    }

    function check_(s:CheckState) {
        var match = switch(s) {
            case Idle: return Busy;
            case Busy: throw "Reentrancy has been detected.";
            case Done: throw "Observer has already terminated.";
            // matches anything
            case _: return null;
        };
        return match;
    }

    function check_access() {
        return AtomicData.update(check_, state);
    }

    function wrap_action<T>(thunk:Void -> T, new_state:CheckState) {
        check_access();
        Utils.try_finally(thunk, (function() {
            AtomicData.set(new_state, state);
        }));
    }

    public function on_error(e:String) {
        wrap_action((function() { observer.onError(e);}), Done);
    }

    public function on_next(x:T) {
        wrap_action((function() { observer.onNext(x);}), Idle);
    }

    public function on_completed() {
        wrap_action((function() { observer.onCompleted();}), Done);
    }

    inline static public function create<T>(observer:IObserver<T>) {
        return new CheckedObserver<T>(observer.on_completed, observer.on_error, observer.on_next);
    }
}
