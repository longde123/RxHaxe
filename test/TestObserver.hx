package test;
import rx.AtomicData;
import rx.Core.RxObserver;
import rx.observers.ObserverBase;
import rx.observers.CheckedObserver;
import rx.observers.SynchronizedObserver;
import rx.observers.AsyncLockObserver;
import rx.observers.IObserver;
import rx.Observer;
class TestObserver extends haxe.unit.TestCase {
   function incr(i) return  i+1;
public  function test_create_on_next (){
    var v = AtomicData.create(0);
    var next =   false ;
    var observer = Observer.create(null,null,function(x:Int){
        assertEquals(42, x); 
        next = true;
    }) ;
    observer.on_next(42);
    assertEquals( true, next);
    observer.on_completed (); 
}
public  function test_create_on_next_has_errors (){
    var failure =  "error";
    var next =  false;
    var observer = Observer.create (null,null,function(x:Int){
        assertEquals(42, x); 
        next = true;
    }) ;
    observer.on_next(42);
    assertEquals( true, next);
    try{
         trace( "Should raise the exception");
        observer.on_error(failure);
       
    }
    catch(e :String){
        assertEquals(failure, e); 
    }

}

public  function  test_create_on_next_on_completed (){
  var next =  false ;
  var completed =  false ;
  var observer = Observer.create(function(){
         completed = true;
    },
    null,
    function(x:Int){
        assertEquals(42, x); 
        next = true;
    }
    );

 
    observer.on_next(42);
    assertEquals( true, next);
    assertEquals(false,completed);
    observer.on_completed ();
    assertEquals(true,completed);
}
public function  test_create_on_next_on_completed_has_errors(){

    var failure =  "error";
    var next =  false;
    var completed =  false;
    var observer = Observer.create(function(){
         completed = true;
    },
    null,
    function(x:Int){
        assertEquals(42, x); 
        next = true;
    });

 
    observer.on_next(42);
    assertEquals( true, next);
    assertEquals(false,completed);
    try{   
        observer.on_error(failure);
        trace("Should raise the exception");
    }
    catch(e :String){
        assertEquals(failure, e);  
    }  
    assertEquals(false,completed);

}
public function   test_create_on_next_on_error(){
    var failure =  "error";
    var next =  false;
    var error =   false;
    var observer = Observer.create(
    null,
    function(e){
        assertEquals(failure, e); 
        error = true;
    },
    function(x:Int){
        assertEquals(42, x); 
        next = true;
    }
    );
    observer.on_next(42);
    assertEquals( true, next);
    assertEquals(false,error);
    observer.on_error(failure);
    assertEquals(true,error); 
}
public function   test_create_on_next_on_error_hit_completed(){
    var failure =  "error";
    var next =  false;
    var error =   false;
    var observer = Observer.create(
    null,
    function(e){
        assertEquals(failure, e); 
        error = true;
    },
    function(x:Int){
        assertEquals(42, x); 
        next = true;
    }
    );
    observer.on_next(42);
    assertEquals( true, next);
    assertEquals(false,error);
    observer.on_completed();
    assertEquals(false,error); 
}
public function   test_create_on_next_on_error_on_completed_1(){
    var failure =  "error";
    var next =  false;
    var error =   false;
    var completed =   false;
    var observer = Observer.create(
    function(){ 
        completed = true;
    },
    function(e){
        assertEquals(failure, e); 
        error = true;
    },
    function(x:Int){
        assertEquals(42, x); 
        next = true;
    }
    );
    observer.on_next(42);
    assertEquals( true, next);
    assertEquals(false,error);
    assertEquals(false,completed);
    observer.on_completed ();
    assertEquals(true,completed);
    assertEquals(false,error);
}

public function   test_create_on_next_on_error_on_completed_2(){
    var failure =  "error";
    var next =  false;
    var error =   false;
    var completed =   false;
    var observer = Observer.create(
    function(){ 
        completed = true;
    },
    function(e){
        assertEquals(failure, e); 
        error = true;
    },
    function(x:Int){
        assertEquals(42, x); 
        next = true;
    }
    );
    observer.on_next(42);
    assertEquals( true, next);
    assertEquals(false,error);
    assertEquals(false,completed);
    observer.on_error(failure);
    assertEquals(true,error);
    assertEquals(false,completed);
} 
public function   test_checked_observer_already_terminated_completed ()
{  
    var m =   0;
    var n =   0;
    var observer_base =Observer.create(
        function(){n= incr(n);},
        function(e){ trace("Should not call on_error");},
        function(v:Int){m= incr(m);}        
    );
    var observer=Observer.checked(observer_base);
 
    observer.on_next(1);
    observer.on_next(2);
    observer.on_completed ();
   
   // (Failure "Observer has already terminated.")
   try{
        observer.on_completed (); 
   }catch(e:String){
           assertEquals(e, "Observer has already terminated.");
   }
  
    //(Failure "Observer has already terminated.")
    try{
        observer.on_error ( "test");
   }catch(e:String){
           assertEquals(e, "Observer has already terminated.");
   }
    assertEquals(2, m);
    assertEquals(1 ,n);
  }

public function   test_checked_observer_already_terminated_error ()
{  
    var m =   0;
    var n =   0;
    var observer_base =Observer.create(
        function(){ trace("Should not call on_completed");},
        function(e){n= incr(n);},
        function(v:Int){m= incr(m);}        
    );
    var observer=Observer.checked(observer_base);
 
    observer.on_next(1);
    observer.on_next(2);
    observer.on_error ("test");
   
   // (Failure "Observer has already terminated.")
   try{
        observer.on_completed (); 
   }catch(e:String){
           assertEquals(e, "Observer has already terminated.");
   }
  
    //(Failure "Observer has already terminated.")
    try{
        observer.on_error ( "test2");
   }catch(e:String){
           assertEquals(e, "Observer has already terminated.");
   }
    assertEquals(2, m);
    assertEquals(1,n); 
  }

  
public function test_checked_observer_reentrant_next(){

    var n =   0;

    var reentrant_thunk:Void->Void;
    var observer = Observer.checked(Observer.create(
        function () {trace("Should not call on_completed");},
        function (e) {trace("Should not call on_error");},
        function (v:Int) {n=incr(n); reentrant_thunk();}
    )); 

  reentrant_thunk =  function(){
    //assert_raises ~msg:"on_next"
    //  (Failure "Reentrancy has been detected.")
        try{
                observer.on_next (9); 
        }catch(e:String){
                assertEquals(e, "Reentrancy has been detected."); 
        }
    //assert_raises ~msg:"on_error"
    //  (Failure "Reentrancy has been detected.")
        try{
                observer.on_error ("test"); 
        }catch(e:String){
                assertEquals(e, "Reentrancy has been detected.");
        } 
    //assert_raises ~msg:"on_completed"
    //  (Failure "Reentrancy has been detected.")
       try{
                observer.on_completed (); 
        }catch(e:String){
                assertEquals(e, "Reentrancy has been detected.");
        } };
   observer.on_next(1);
   assertEquals( 1 ,n);
} 
  
public function  test_checked_observer_reentrant_error (){
  var n =   0;
  var reentrant_thunk:Void->Void;

  var observer = Observer.checked(Observer.create(
      function(){ trace("Should not call on_completed");},
      function(e){n=incr(n); reentrant_thunk ();},
      function(v:Int){ trace("Should not call on_next");}
  ));
     
  reentrant_thunk  =function (){
    //assert_raises ~msg:"on_next"
    //  (Failure "Reentrancy has been detected.")
        try{
                observer.on_next (9); 
        }catch(e:String){
                assertEquals(e, "Reentrancy has been detected."); 
        }
    //assert_raises ~msg:"on_error"
   //   (Failure "Reentrancy has been detected.")
        try{
                observer.on_error ("test"); 
        }catch(e:String){
                assertEquals(e, "Reentrancy has been detected.");
        } 
   // assert_raises ~msg:"on_completed"
   //   (Failure "Reentrancy has been detected.")
        try{
                observer.on_completed (); 
        }catch(e:String){
                assertEquals(e, "Reentrancy has been detected.");
        }
  };

 
  observer.on_error("test");
  assertEquals( 1 ,n);
}

public function  test_checked_observer_reentrant_completed (){
  var n =   0;
  var reentrant_thunk:Void->Void;

  var observer = Observer.checked(Observer.create(
      function(){ n=incr(n); reentrant_thunk ();},
      function(e){trace("Should not call on_error");},
      function(v:Int){ trace("Should not call on_next");}
  ));
     
  reentrant_thunk  =function (){
    //assert_raises ~msg:"on_next"
    //  (Failure "Reentrancy has been detected.")
        try{
                observer.on_next (9); 
        }catch(e:String){
                assertEquals(e, "Reentrancy has been detected."); 
        }
    //assert_raises ~msg:"on_error"
   //   (Failure "Reentrancy has been detected.")
        try{
                observer.on_error ("test"); 
        }catch(e:String){
                assertEquals(e, "Reentrancy has been detected.");
        } 
   // assert_raises ~msg:"on_completed"
   //   (Failure "Reentrancy has been detected.")
        try{
                observer.on_completed (); 
        }catch(e:String){
                assertEquals(e, "Reentrancy has been detected.");
        }
  };

 
  observer.on_completed();
  assertEquals( 1 ,n);
}




public function   test_observer_synchronize_monitor_reentrant(){
  var res =   false;
  var inOne =   false;
  var on_next_ref :Int->Void;

  var o =Observer.synchronize( Observer.create(null,null,
       function (x){ 
            if (x == 1 ){
                inOne = true;
                on_next_ref(2);
                inOne = false;
            } else if (x ==2){
                res  =  inOne;
            } 
        }
      ));
 
    on_next_ref = o.on_next;
    o.on_next(1);
    assertTrue(res);
    trace("res should be true");
}
public function  test_observer_synchronize_async_lock_non_reentrant (){
  var res =   false;
  var inOne =   false;
  var on_next_ref :Int->Void;

  var o =Observer.synchronize_async_lock( Observer.create(null,null,
       function (x){ 
            if (x == 1 ){
                inOne = true;
                on_next_ref(2);
                inOne = false;
            } else if (x ==2){
                res  =  !inOne;
            } 
        }
      ));
    on_next_ref = o.on_next;
    o.on_next(1);
    assertTrue(res);
    trace("res should be true");
} 
public function  test_observer_synchronize_async_lock_on_next (){
    var res =   false;    
    var o =Observer.synchronize_async_lock( Observer.create(function(){trace("Should not call on_completed");},
        function(e){ trace("Should not call on_error");},
        function (x){ 
            res = x == 1;
        }
      ));

    o.on_next(1);
    assertTrue(res);
    trace("res should be true");
}
public function  test_observer_synchronize_async_lock_on_error (){
    var res :String;
    var err =  "test";
    var o =Observer.synchronize_async_lock( Observer.create(function(){trace("Should not call on_completed");},
        function(e){ res=e;},
        function (x:Int){ 
             trace("Should not call on_next");
        }
      ));

    o.on_error(err);
    assertEquals(err ,res); 
}

public function  test_observer_synchronize_async_lock_on_completed (){
    var res =   false;    
    var o =Observer.synchronize_async_lock( Observer.create(function(){ res=true;},
        function(e){ trace("Should not call on_error");},
        function (x){ 
          trace("Should not call on_next");
        }
      ));

    o.on_completed();
    assertTrue(res);
    trace("res should be true");
}

}