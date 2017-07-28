package rx.observers;

interface IObserver<T>
{ 
    public function on_completed ():Void;   
    public function on_error(e:String):Void;
    public function on_next( x:T ):Void;
    
}