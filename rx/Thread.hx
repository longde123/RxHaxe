package rx;


#if cpp
    typedef Thread=cpp.vm.Thread;
#else

typedef ThreadHandle = Dynamic;

class Thread {

    public var handle(default, null):ThreadHandle;

    function new(h) {
        handle = h;
    }

    /**
		Send a message to the thread queue. This message can be read by using `readMessage`.
	**/
    public function sendMessage(msg:Dynamic) {

    }


    /**
		Returns the current thread.
	**/
    public static function current() {
        return null;
    }

    /**
		Creates a new thread that will execute the `callb` function, then exit.
	**/
    public static function create(callb:Void -> Void) {
        return callb();
    }

    /**
		Reads a message from the thread queue. If `block` is true, the function
		blocks until a message is available. If `block` is false, the function
		returns `null` if no message is available.
	**/
    public static function readMessage(block:Bool):Dynamic {
        return null;
    }


}

#end
