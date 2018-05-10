package rx;
#if cpp
    typedef Mutex=cpp.vm.Mutex;
#else

class Mutex {

    public function new() {

    }

    public function acquire() {
    }

    public function tryAcquire():Bool {
        return true;
    }

    public function release() {
    }
}
#end