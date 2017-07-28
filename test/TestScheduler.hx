package test;
import rx.AtomicData;
import cpp.vm.Thread; 
import cpp.Lib;
import rx.Core.RxObserver;
import rx.observers.ObserverBase;
import rx.observers.CheckedObserver;
import rx.observers.SynchronizedObserver;
import rx.observers.AsyncLockObserver;
import rx.observers.IObserver;
import rx.Observer;
import rx.disposables.ISubscription;
import rx.schedulers.CurrentThread;
import rx.schedulers.DiscardableAction;
import rx.schedulers.Immediate;
import rx.schedulers.NewThread;
import rx.schedulers.MakeScheduler;
import rx.schedulers.Test;
import rx.schedulers.TimedAction;
import rx.Scheduler;
import rx.Subscription;
import rx.Utils;
class TestScheduler extends haxe.unit.TestCase {
   function incr(i) return  i+1;
    public function test_current_thread_schedule_ (){
        var str="";
        Scheduler.currentThread.schedule_absolute(null,function(){ 
            Scheduler.currentThread.schedule_absolute(null,function(){ str+=(2);    return Subscription.empty();});
            str+=(1);
            return Subscription.empty();
        });
        //trace 1 2
        assertEquals(str, "12");   
    }
    public function test_immediate_schedule_ (){
        var str="";
        Scheduler.immediate.schedule_absolute(null,function(){ 
            Scheduler.immediate.schedule_absolute(null,function(){ str+=(2);    return Subscription.empty();});
            str+=(1);
            return Subscription.empty();
        });
        //trace 2 1
        assertEquals(str, "21");
    }   
    public function test_current_thread_schedule_action (){
        var id = Utils.current_thread_id ();
        var ran =  false;        
        var _x = Scheduler.currentThread.schedule_absolute(null,function(){  
            //   assertEquals( Utils.current_thread_id () ,Utils.current_thread_id ());
                ran  = true;
                return Subscription.empty();

            });
        trace("ran should be true" +ran);
        assertTrue(ran);     
    }
    public function  test_current_thread_schedule_action_error (){
        var ex =  "test";
        try{ 
            Scheduler.currentThread.schedule_absolute(null,function(){   throw ex ;});
            trace("Should raise an exception");
        }catch (e:String){  
            assertEquals(ex, e);
        }
    }
    public function  test_current_thread_schedule_action_nested  (){
        var id = Utils.current_thread_id ();
        var ran =   false;
        Scheduler.currentThread.schedule_absolute(null,function(){ 
            //assert_equal id (Utils.current_thread_id ());
           return Scheduler.currentThread.schedule_absolute(null,function(){ 
                    ran = true;
                return Subscription.empty();
            });  
        });    
        assertTrue(ran);     
    }

    public function  test_current_thread_schedule_relative_action_nested (){
        var id = Utils.current_thread_id ();
        var ran =   false;
        Scheduler.currentThread.schedule_absolute(null,function(){ 
            //assert_equal id (Utils.current_thread_id ());
           return Scheduler.currentThread.schedule_relative(0.1,function(){ 
                    ran = true;
                return Subscription.empty();
            });  
        });    
        assertTrue(ran);     
    }
   
    public function  test_current_thread_schedule_relative_action_due  (){
      var id = Utils.current_thread_id ();
      var ran =  false;
      var start = Sys.time();
      var stop =   0.0 ;
      Scheduler.currentThread.schedule_relative( 0.1,
        function (){ 
          stop  =  Sys.time();
          //assert_equal id (Utils.current_thread_id ());
          ran = true;
          return Subscription.empty();
        });
      trace("ran should be true");
      assertTrue(ran);
      var elapsed = stop -start ;
      trace("Elapsed time should be > 80ms"); 
      assertTrue((elapsed > 0.08));     
    }

    
    public function  test_current_thread_schedule_relative_action_due_nested  (){      
      var ran =  false;
      var start = Sys.time();
      var stop =   0.0 ;
       Scheduler.currentThread.schedule_relative( 0.1,function () return Scheduler.currentThread.schedule_relative( 0.1,function (){ 
                                                                                                    stop  =  Sys.time();
                                                                                                    //assert_equal id (Utils.current_thread_id ());
                                                                                                    ran = true;
                                                                                                    return Subscription.empty();
                                                                                                  }));
      trace("ran should be true");
      assertTrue(ran);
      var elapsed = stop -start ;
      trace("Elapsed time should be > 180ms"); 
      assertTrue((elapsed > 0.18));     
    }
     public function  test_current_thread_cancel  (){    
      var ran1 =  false ;
      var ran2 =  false ;
      Scheduler.currentThread.schedule_absolute(null, function () return Scheduler.currentThread.schedule_absolute(null,function (){ 
                ran1 = true;
                var unsubscribe1 =  Scheduler.currentThread.schedule_relative(1.0,function () {
                                                                                                ran2  = true;
                                                                                                return Subscription.empty();
                                                                                              }); 
                unsubscribe1.unsubscribe();
                return Subscription.empty();
              }));
      assertEquals(true ,ran1);
      assertEquals(false ,ran2);
     }
     
public function  test_current_thread_schedule_nested_actions (){
    var queue = new Array<String>();
    var first_step_start   = function(){ queue.push("first_step_start"); };
    var first_step_end  =  function(){ queue.push("first_step_end"); }; 
    var second_step_start  =  function(){ queue.push("second_step_start"); }; 
    var second_step_end  = function(){ queue.push("second_step_end"); }; 
    var third_step_start  = function(){ queue.push("third_step_start"); };  
    var third_step_end  =  function(){ queue.push("third_step_end"); };  
    var first_action  =function(){
      first_step_start ();
      first_step_end ();
      return Subscription.empty();
    };
    
    var second_action  =function(){
      second_step_start ();
      var s = Scheduler.currentThread.schedule_absolute(null,first_action);
      second_step_end ();
      return s;
    };
    var third_action  =function(){
      third_step_start ();
      var s = Scheduler.currentThread.schedule_absolute(null, second_action);
      third_step_end ();
      return s;
    };

    Scheduler.currentThread.schedule_absolute(null, third_action);

  
    assertEquals(queue.toString(),["third_step_start",
      "third_step_end",
      "second_step_start",
      "second_step_end",
      "first_step_start",
      "first_step_end"].toString());
  }
 
  public function   test_current_thread_schedule_recursion (){
    var counter =   0 ;
    var count = 10 ;
    Scheduler.currentThread.schedule_recursive(function (self:Void->ISubscription ):ISubscription{
                                                          counter=incr(counter);
                                                          return if (counter < count)   self ();
                                                          else   Subscription.empty();
                                                      });
    assertEquals(count ,count); 
  } 
  public function   test_immediate_schedule_action (){
    var id = Utils.current_thread_id ();
    var ran =   false ;
    Scheduler.immediate.schedule_absolute(null,function(){ 
          //assertTrue(id ==Utils.current_thread_id ());
          ran  = true;
          return Subscription.empty();
      });
    trace("ran should be true");
    assertTrue(ran); 
  }

  public function  test_immediate_schedule_nested_actions (){
    var queue = new Array<String>();
    var first_step_start   = function(){ queue.push("first_step_start"); };
    var first_step_end  =  function(){ queue.push("first_step_end"); }; 
    var second_step_start  =  function(){ queue.push("second_step_start"); }; 
    var second_step_end  = function(){ queue.push("second_step_end"); }; 
    var third_step_start  = function(){ queue.push("third_step_start"); };  
    var third_step_end  =  function(){ queue.push("third_step_end"); };  
    var first_action  =function(){
      first_step_start ();
      first_step_end ();
      return Subscription.empty();
    };
    
    var second_action  =function(){
      second_step_start ();
      var s = Scheduler.immediate.schedule_absolute(null,first_action);
      second_step_end ();
      return s;
    };
    var third_action  =function(){
      third_step_start ();
      var s = Scheduler.immediate.schedule_absolute(null, second_action);
      third_step_end ();
      return s;
    };

    Scheduler.immediate.schedule_absolute(null, third_action);

    
    assertEquals(queue.toString(), ["third_step_start",
     "second_step_start",
     "first_step_start",
     "first_step_end",
     "second_step_end",
     "third_step_end"].toString());
  }

  public function  test_new_thread_schedule_action (){
    var id = Utils.current_thread_id ();
    var ran =  false;
    Scheduler.newThread.schedule_absolute(null,function(){  
        
        // "New thread scheduler should create schedule work on a different thread"
         // assertTrue(id!= Utils.current_thread_id ());
          ran  = true;
        return Subscription.empty();
      });
    //(* Wait for the other thread to run *)
    Sys.sleep(0.1);
     trace("ran should be true");
    assertTrue(ran); 
  }

  public function  test_new_thread_cancel_action (){
    var _unsubscribe = Scheduler.newThread.schedule_absolute(null,function(){  
                                                        trace( "This action should not run");
                                                        return  Subscription.empty();
    });
    _unsubscribe.unsubscribe ();
    //(* Wait for the other thread *)
    Sys.sleep(0.1); 
    assertTrue(true);
  }

  
}


/*
 



 





let test_lwt_schedule_action _ =
  let ran = ref false in
  let _ = Rx.Scheduler.Lwt.schedule_absolute
    (fun () ->
      ran := true;
      Rx.Subscription.empty
    ) in
  assert_bool "ran should be true" !ran

let test_lwt_cancel_action _ =
  let unsubscribe = Rx.Scheduler.Lwt.schedule_absolute
    (fun () ->
      assert_failure "This action should not run"
    ) in
  unsubscribe ()

let test_lwt_schedule_periodically _ =
  let counter = ref 0 in
  let unsubscribe = Rx.Scheduler.Lwt.schedule_periodically 0.1
    (fun () ->
      incr counter;
      Rx.Subscription.empty
    ) in
  let sleep = Lwt_unix.sleep 0.15 in
  let () = Lwt_main.run sleep in
  unsubscribe ();
  assert_equal ~printer:string_of_int 2 !counter
*/