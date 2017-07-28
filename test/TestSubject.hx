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
import rx.Subject;
import rx.subjects.Replay;
import rx.subjects.Behavior;
import rx.subjects.Async;
class TestSubject extends haxe.unit.TestCase {
   function incr(i) return  i+1;

   public  function test_create_subject (){
        var c1 =   0;
        var c2 =   0;
        var subject:Subject<Int> =  Subject.create(); 
        var observer1 =  Observer.create (null, null, function (v:Int) return c1= incr(c1)); 
        var unsubscribe1 = subject.subscribe(observer1);
        var observer2 =  Observer.create (null, null, function (v:Int) return c2= incr(c2)); 
        var unsubscribe2 = subject.subscribe(observer2);
        subject.on_next(1);
        subject.on_next(2);
        assertEquals(  2 ,c1);
        assertEquals(  2 ,c2);
        unsubscribe2.unsubscribe();
        subject.on_next(3);
        assertEquals( 3 ,c1);
        assertEquals( 2 ,c2);
        unsubscribe1.unsubscribe();
        subject.on_next( 4);
        assertEquals(  3 ,c1);
        assertEquals(  2 ,c2); 
    }
    public  function  test_subject_unsubscribe (){
        var c1 =   0;
        var c2 =   0;
        var subject:Subject<Int> =  Subject.create(); 
        var observer1 =  Observer.create (null, null, function (v:Int) return c1= incr(c1)); 
        var unsubscribe1 = subject.subscribe(observer1);
        var observer2 =  Observer.create (null, null, function (v:Int) return c2= incr(c2)); 
        var unsubscribe2 = subject.subscribe(observer2);
        subject.on_next(1);
        subject.on_next(2);
        assertEquals(  2 ,c1);
        assertEquals(  2 ,c2);
        subject.unsubscribe();
        subject.on_next(3);
        assertEquals( 2 ,c1);
        assertEquals( 2 ,c2); 
    }


    public  function  test_subject_on_completed (){
        var on_completed1 =   false;
        var on_completed2 =   false;
        var subject:Subject<Bool> =  Subject.create(); 
        var observer1 =  Observer.create (function()  return on_completed1= true, null, function (v:Bool){} ); 
        var unsubscribe1 = subject.subscribe(observer1);
        var observer2 =  Observer.create (function()   return on_completed2= true, null, function (v:Bool){}); 
        var unsubscribe2 = subject.subscribe(observer2);
 
        subject.on_completed(); 
        assertEquals( true,on_completed1);
        assertEquals( true,on_completed1); 
    }
     public  function  test_subject_on_error (){
        var on_error1 =   false;
        var on_error2 =   false;
        var subject:Subject<Bool> =  Subject.create(); 
        var observer1 =  Observer.create (null,function(e:String){  
            assertEquals (e,"test");
             on_error1= true;
             },  function (v:Bool){} ); 
        var unsubscribe1 = subject.subscribe(observer1);
        var observer2 =  Observer.create (null,function(e:String){  
            assertEquals (e,"test");
             on_error2= true;
             },  function (v:Bool){}); 
        var unsubscribe2 = subject.subscribe(observer2);
 
        subject.on_error("test"); 
        assertEquals( true,on_error1);
        assertEquals( true,on_error2); 
    }


     public  function  test_create_replay_subject (){
        var c1 =   0;
        var c2 =   0;
        var subject:Replay<Int> =    Replay.create(); 
        subject.on_next(1);
        subject.on_next(2);
        var observer1 =  Observer.create (null, null, function (v:Int) return c1= incr(c1)); 
        var unsubscribe1 = subject.subscribe(observer1);
        var observer2 =  Observer.create (null, null, function (v:Int) return c2= incr(c2)); 
        var unsubscribe2 = subject.subscribe(observer2);
  
        assertEquals(  2 ,c1);
        assertEquals(  2 ,c2);
        subject.on_next(3);
        assertEquals( 3 ,c1);
        assertEquals( 3 ,c2); 
        
        subject.unsubscribe();
        subject.on_next(4);
        assertEquals( 3 ,c1);
        assertEquals( 3 ,c2); 
    }

    
    public  function  test_replay_subject_on_completed (){
        var on_completed1 =   false;
        var on_completed2 =   false; 
        var subject:Replay<Int> =    Replay.create(); 
        subject.on_completed(); 

        var observer1 =  Observer.create (function()  return on_completed1= true, null,  function (v:Int){trace("on_next should not be called");} ); 
        var unsubscribe1 = subject.subscribe(observer1);
        var observer2 =  Observer.create (function()   return on_completed2= true, null, function (v:Int){trace("on_next should not be called");}); 
        var unsubscribe2 = subject.subscribe(observer2);
 
 
        assertEquals( true,on_completed1);
        assertEquals( true,on_completed1); 
        subject.on_next(1);
    }

     public  function  test_replay_subject_on_error (){
        var on_error1 =   false;
        var on_error2 =   false;
        var subject:Replay<Int> =  Replay.create(); 
            subject.on_error("test"); 
        var observer1 =  Observer.create (null,function(e:String){  
            assertEquals (e,"test");
             on_error1= true;
             },  function (v:Int){trace("on_next should not be called");} ); 
        var unsubscribe1 = subject.subscribe(observer1);
        var observer2 =  Observer.create (null,function(e:String){  
            assertEquals (e,"test");
             on_error2= true;
             },  function (v:Int){trace("on_next should not be called");}); 
        var unsubscribe2 = subject.subscribe(observer2);
 

        assertEquals( true,on_error1);
        assertEquals( true,on_error2); 
        subject.on_next(1);
    }

    
    public  function   test_create_behavior_subject (){
        var v1 =  "";
        var v2 =  "";
        var subject:Behavior<String>=Behavior.create("default"); 


        var  observer1 =  Observer.create (null,null,function (v ) return v1  = v) ;
        var unsubscribe1 = subject.subscribe(observer1);
        assertEquals ( "default", v1);
        assertEquals ( "" ,v2);
        subject.on_next("one");
        assertEquals ( "one" ,v1);
        assertEquals ( "" ,v2);
        subject.on_next("two");
        var observer2 = Observer.create  (null,null,function (v ) return v2  = v) ;
        var unsubscribe2 = subject.subscribe(observer2);
        assertEquals ( "two" ,v1);
        assertEquals ( "two",v2);
        subject.unsubscribe ();
        subject.on_next( "three");
        assertEquals ( "two" ,v1);
        assertEquals ( "two" ,v2);
    }

    public  function  test_behavior_subject_on_completed (){
        var on_completed  =   false; 
        var subject:Behavior<Int> =    Behavior.create(0); 
        subject.on_next( 1);
        subject.on_completed(); 

        var observer1 =  Observer.create (function()  return on_completed = true, null,  function (v:Int){trace("on_next should not be called");} ); 
        var unsubscribe1 = subject.subscribe(observer1);
      
 
 
        assertEquals( true,on_completed ); 
         
    }

     public  function  test_behavior_subject_on_error (){
        var on_error =   false;
         
        var subject:Behavior<Int> =  Behavior.create(0); 
            subject.on_next( 1);
            subject.on_error("test"); 
        var observer1 =  Observer.create (null,function(e:String){  
                assertEquals (e,"test");
                on_error= true;
             },  function (v:Int){trace("on_next should not be called");} ); 
        var unsubscribe1 = subject.subscribe(observer1);
         

        assertEquals( true,on_error);  
    }
    public  function   test_create_async_subject (){
        var v1 =  "";
        var v2 =  "";
        var subject:Async<String>=Async.create(); 


        var  observer1 =  Observer.create (null,null,function (v ) return v1  = v) ;
        var unsubscribe1 = subject.subscribe(observer1);
        assertEquals ( "", v1);
        assertEquals ( "" ,v2);
        subject.on_next("one");
        assertEquals ( "" ,v1);
        assertEquals ( "" ,v2);
        subject.on_next("two");
        subject.on_completed ();
        assertEquals ( "two" ,v1);
        assertEquals ( "",v2);
        var observer2 = Observer.create  (null,null,function (v ) return v2  = v) ;
        var unsubscribe2 = subject.subscribe(observer2); 
        assertEquals ( "two" ,v1);
        assertEquals ( "two" ,v2);
    }
    public  function  test_async_subject_on_error (){
        var on_error =   false;
         
        var subject:Async<Int> =  Async.create(); 
        
        var observer1 =  Observer.create (null,function(e:String){  
                assertEquals (e,"test");
                on_error= true;
             },  function (v:Int){trace("on_next should not be called");} ); 
        var unsubscribe1 = subject.subscribe(observer1);
            subject.on_next( 1);
            subject.on_error("test"); 

        assertEquals( true,on_error);  
    }
}