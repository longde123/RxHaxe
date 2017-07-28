package test;
import rx.AsyncLock;
import cpp.vm.Thread; 
import cpp.Lib;
import rx.Observer;



typedef RxAObserverState<T>={
    var  on_next_queue: Array<T>;
    var completed:Bool;
    @:optional var  error: String;
} 
class ObserverState<T> {
    
    public var s:RxAObserverState<T>;
    var debug=false;
    public  function new() {
        s={
            completed :false,
            error : null,
            on_next_queue :new Array<T>()
        };
    }
    public  function on_completed (){
        if (s.completed) throw "on_completed should be called only once";      
        if (s.error!=null) throw "on_completed should not be called after on_error";
        s.completed = true;

         if(debug)  trace("on_completed");
    }
   

    public  function on_error(e:String){
        if(s.completed) throw "on_error should not be called after on_completed"; 
        if (s.error!=null) throw"on_error should be called only once";
        s.error =  e;
        
        if(debug) trace("on_error");
    }
    public  function on_next( v:T)
    {
         if (s.completed) throw "on_next should not be called after on_completed";   
         if (s.error!=null) throw "on_next should not be called after on_error";
         s.on_next_queue.push(v);
         if(debug)   trace("on_next "+v);
    }
      

}
 
  
class TestHelper<T>  {
  
    
    static public function create<T>() { 
        return new TestHelper<T>();
    }

    public var s:RxAObserverState<T>;
    public var o:ObserverState<T>;
    public  function new() {
        o= new ObserverState<T>();        
        s=o.s;
    }

  
    public function observer() { 
        return Observer.synchronize(Observer.create(o.on_completed,o.on_error,o.on_next));
    }
    public  function  is_completed(){
        return s.completed;
    } 


    public  function  is_on_error(){
        return  s.error!=null;
    }  

    public  function  get_error(){
        return  s.error;
    }  


    public  function  on_next_values(){
        return  s.on_next_queue;
    }

} 