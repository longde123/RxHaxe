package rx;


class AtomicData<T> {
    public var data:T;
    public var mutex:Mutex ;

    public function new() {}

    public static function clone<T>(v:T):T {

        return switch(Type.typeof(v)) {
            case TNull:
                return null;
            case TInt, TFloat, TBool, TEnum(_), TFunction, TUnknown :
                return v;

            default: {
                return Reflect.copy(v);
            }
        }

    }

    static public function with_lock<T, B>(ad:AtomicData<T>, f:Void -> B):B {
        ad.mutex.acquire();
        var value = f();
        ad.mutex.release();
        return value;
    }

    static public function create<T>(initial_value:T) {

        var t:AtomicData<T> = new AtomicData<T>();
        t.data = initial_value;
        t.mutex = new Mutex();
        return t;
    }

    static public function get<T>(ad:AtomicData<T>) {
        return with_lock(ad, (function() return ad.data));
    }


    static public function unsafe_get<T>(ad:AtomicData<T>) return ad.data;

    static public function set<T>(value:T, ad:AtomicData<T>) return with_lock(ad, (function() return ad.data = value));

    static public function unsafe_set<T>(value:T, ad:AtomicData<T>) return ad.data = value;

    static public function get_and_set<T>(value:T, ad:AtomicData<T>)
    return with_lock(ad, (function() {
        var result = clone(ad.data);
        ad.data = value;
        return result;
    }));

    static public function update<T>(f:T -> T, ad:AtomicData<T>)return with_lock(ad, (function() return ad.data = f(ad.data)));

    static public function update_and_get<T>(f:T -> T, ad:AtomicData<T>)
    return with_lock(ad, (function() {
        var result = f(ad.data);
        ad.data = result;
        return result;
    }));

    static public function compare_and_set<T>(compare_value:T, set_value:T, ad:AtomicData<T>) {
        return with_lock(ad, (function() {
            var result = clone(ad.data);
            if (ad.data == compare_value) {
                ad.data = set_value;

            }
            return result;
        } ));
    }


    static public function update_if<T>(predicate:T -> Bool, update:T -> T, ad:AtomicData<T>) {
        return with_lock(ad, (function() {
            var result = clone(ad.data);
            if (predicate(ad.data)) {
                ad.data = update(ad.data);
            }
            return result;
        }));

    }


    static public function synchronize<T, B>(f:T -> B, ad:AtomicData<T>) {
        return with_lock(ad, (function() return f(ad.data)));
    }


}

 