package test;
import rx.AtomicData;
import cpp.vm.Thread; 
import cpp.Lib;
import rx.Subscription; 
import rx.Observer;
using rx.Observable; 
import rx.observables.IObservable;
import rx.observables.Merge;
import rx.observables.Blocking;
import rx.disposables.ISubscription; 
import rx.observers.IObserver;
import rx.notifiers.Notification;
import rx.Scheduler;
import rx.Utils;
import rx.schedulers.IScheduler;
import rx.observables.MakeScheduled;
import rx.Subject;
class SchedulerBase implements IScheduler {
    public var schedule_count:Int;
    public function new(){
        schedule_count=0;
    } 
    public function now():Float{ return 0.0;}
    
    public function  schedule_absolute (due_time:Null<Float>, action:Void->ISubscription ):ISubscription
    {
        schedule_count=Utils.incr( schedule_count);
        return Scheduler.immediate.schedule_absolute(due_time, action);
    }
    public  function  schedule_relative( delay: Null<Float> ,action:Void->ISubscription   ): ISubscription{
        return Subscription.empty();
    }
    public  function  schedule_recursive( action:(Void->ISubscription)->ISubscription):ISubscription{
        return Subscription.empty();
    }
    public  function  schedule_periodically( initial_delay:Null<Float> , period: Null<Float> ,action:Void-> ISubscription  ): ISubscription{
        return Subscription.empty();
    }
}
class ScheduledObservable extends  MakeScheduled
{   
    public function new (){
        super();
        scheduler=new SchedulerBase();
    }
}


   

class TestObservable extends haxe.unit.TestCase {
/*
    public  function test_of_enum  (){
        var items = ["one", "two","three"] ;
        var observable = Observable.currentThread.of_enum( items) ;    
        var state = TestHelper.create (); 
        observable.subscribe(state.observer());
        assertEquals( items.toString(),state.on_next_values().toString());
        assertEquals( true,state.is_completed());
        assertEquals( false,state.is_on_error());
    }
    
    public  function  test_count(){
        var observable = Observable.create(function( observer:IObserver<String>) {
            observer.on_next( "a");
            observer.on_next( "b");
            observer.on_next( "c");
            observer.on_completed();
            return Subscription.empty();
        });
        var length_observable = observable.length();
        var state = TestHelper.create (); 
        length_observable.subscribe(state.observer());
        assertEquals( [3] .toString(),state.on_next_values().toString());
        assertEquals( true,state.is_completed());
        assertEquals( false,state.is_on_error()); 
        
    }
    public  function  test_drop(){
        var observable = Observable.create(function( observer:IObserver<String>) {
            observer.on_next( "a");
            observer.on_next( "b");
            observer.on_next( "c");
            observer.on_next( "d");
            observer.on_completed();
            return Subscription.empty();
        });
        var drop_2_observable = observable.drop(2);
        var state = TestHelper.create (); 
        drop_2_observable.subscribe(state.observer());
        assertEquals( ["c", "d"] .toString(),state.on_next_values().toString());
        assertEquals( true,state.is_completed());
        assertEquals( false,state.is_on_error()); 
        
    } 
 
    public  function  test_take(){ 
     
        var observable = Observable.create(function( observer:IObserver<String>) {
            observer.on_next( "a");
            observer.on_next( "b");
            observer.on_next( "c");
            observer.on_next( "d");
            observer.on_completed();
            return Subscription.empty();
        });
        var take_2_observable = observable.take(2);
        var state = TestHelper.create (); 
        var __subscribe=take_2_observable.subscribe(state.observer());
        
        assertEquals( ["a", "b"].toString(),state.on_next_values().toString());
        assertEquals( true,state.is_completed());
        assertEquals( false,state.is_on_error()); 
        
    } 
   
    public  function  test_take_last(){ 
     
        var observable = Observable.create(function( observer:IObserver<String>) {
            observer.on_next( "a");
            observer.on_next( "b");
            observer.on_next( "c");
            observer.on_next( "d");
            observer.on_completed();
            return Subscription.empty();
        });
        var take_last_2_observable = observable.take_last(2);
        var state = TestHelper.create (); 
        var __subscribe=take_last_2_observable.subscribe(state.observer());
        
        assertEquals( ["c", "d"].toString(),state.on_next_values().toString());
        assertEquals( true,state.is_completed());
        assertEquals( false,state.is_on_error()); 
        
    } 
    public  function  test_materialize(){ 
     
        var observable = Observable.create(function( observer:IObserver<String>) {
            observer.on_next( "a");
            observer.on_next( "b");
            observer.on_next( "c");
            observer.on_next( "d");
            observer.on_completed();
            return Subscription.empty();
        });
        var materialized_observable = observable.materialize();
        var state = TestHelper.create (); 
        var __subscribe=materialized_observable.subscribe(state.observer());
        
        assertEquals( [OnNext( "a"),OnNext( "b"),OnNext( "c"),OnNext( "d"),OnCompleted].toString(),state.on_next_values().toString());
        assertEquals( true,state.is_completed());
        assertEquals( false,state.is_on_error()); 
        
    } 

    public  function  test_materialize_error(){ 
     
        var observable = Observable.create(function( observer:IObserver<String>) {
            observer.on_next( "a");
            observer.on_next( "b");
            observer.on_next( "c");
            observer.on_next( "d");
            observer.on_error("test");
            return Subscription.empty();
        });
        var materialized_observable = observable.materialize();
        var state = TestHelper.create (); 
        var __subscribe=materialized_observable.subscribe(state.observer());
        
        assertEquals( [OnNext( "a"),OnNext( "b"),OnNext( "c"),OnNext( "d"),OnError("test")].toString(),state.on_next_values().toString());
        assertEquals( true,state.is_completed());
        assertEquals( false,state.is_on_error()); 
        
    } 
    public  function  test_dematerialize(){ 
     
        var observable = Observable.create(function( observer:IObserver<Notification<String>>) {
            observer.on_next( OnNext( "a"));
            observer.on_next( OnNext(  "b"));
            observer.on_next( OnNext( "c"));
            observer.on_next( OnNext( "d"));
            observer.on_next( OnCompleted);
            observer.on_completed();
            return Subscription.empty();
        });
        var dematerialized_observable = observable.dematerialize();
        var state = TestHelper.create (); 
        var __subscribe=dematerialized_observable.subscribe(state.observer());
        
        assertEquals( ["a", "b", "c", "d"].toString(),state.on_next_values().toString());
        assertEquals( true,state.is_completed());
        assertEquals( false,state.is_on_error()); 
        
    } 
    public  function  test_dematerialize_error(){      
        var observable = Observable.create(function( observer:IObserver<Notification<String>>) {
            observer.on_next( OnNext( "a"));
            observer.on_next( OnNext(  "b"));
            observer.on_next( OnNext( "c"));
            observer.on_next( OnNext( "d"));
            observer.on_next( OnError( "test"));
            observer.on_completed();
            return Subscription.empty();
        });
        var dematerialized_observable = observable.dematerialize();
        var state = TestHelper.create (); 
        var __subscribe=dematerialized_observable.subscribe(state.observer());        
        assertEquals( ["a", "b", "c", "d"].toString(),state.on_next_values().toString());
        assertEquals( false,state.is_completed());
        assertEquals( true,state.is_on_error()); 
        
    } 
  
    public  function   test_to_enum(){
        var observable = Observable.create(function( observer:IObserver<Int>) {
            observer.on_next(1);
            observer.on_next(2);
            observer.on_next(3);
            observer.on_next(4);
            return Subscription.empty();
        });
      
        var _enum =Blocking.to_enum(observable );
      
         var xs = [];
        while(_enum.hasNext()) xs.push(_enum.next());
       
        assertEquals( [1, 2,3, 4].toString(),xs.toString());
    }
    public  function   test_to_enum_error(){
        var    ex =  "test";
        var observable = Observable.create(function( observer:IObserver<Int>) {
            observer.on_next(1);
            observer.on_next(2);
            observer.on_next(3);
            observer.on_next(4);
            observer.on_error(ex);
            return Subscription.empty();
        });
        try{
            var _enum =Blocking.to_enum(observable );
            var xs = [];
            while(_enum.hasNext()) xs.push(_enum.next());
            trace( "Should raise an exception");
        }
        catch(e:String){
            assertEquals(e,ex);
        }
       
       
     
    }

  public  function  test_single(){ 
     
        var observable = Observable.create(function( observer:IObserver<Int>) {
            observer.on_next(1);
            observer.on_completed();
            return Subscription.empty();
        });
        var single_observable = observable.single();
        var state = TestHelper.create (); 
        single_observable.subscribe(state.observer());
        
        assertEquals( [1].toString(),state.on_next_values().toString());
        assertEquals( true,state.is_completed());
        assertEquals( false,state.is_on_error()); 
        
    } 
    public  function  test_single_too_many_elements(){ 
     
        var observable = Observable.create(function( observer:IObserver<Int>) {
            observer.on_next(1);
            observer.on_next(2);
            observer.on_completed();
            return Subscription.empty();
        });
        var single_observable = observable.single();
        var state = TestHelper.create (); 
        single_observable.subscribe(state.observer());
        
        assertEquals( [].toString(),state.on_next_values().toString());
        assertEquals( false,state.is_completed());
        assertEquals( true,state.is_on_error()); 
        
    } 
    public  function  test_single_empty(){ 
     
        var observable = Observable.create(function( observer:IObserver<Int>) { 
            observer.on_completed();
            return Subscription.empty();
        });
        var single_observable = observable.single();
        var state = TestHelper.create (); 
        single_observable.subscribe(state.observer());
        
        assertEquals( [].toString(),state.on_next_values().toString());
        assertEquals( false,state.is_completed());
        assertEquals( true,state.is_on_error()); 
        
    } 
      public  function  test_single_blocking(){ 
     
        var observable = Observable.create(function( observer:IObserver<Int>) {
            observer.on_next(1);
            observer.on_completed();
            return Subscription.empty();
        });
        var value =Blocking.single(observable); 
        
        assertEquals(1,value); 
        
    } 
    public  function  test_single_blocking_empty(){ 
     
        var observable = Observable.create(function( observer:IObserver<Int>) {
            observer.on_completed();
            return Subscription.empty();
        });
        try{
           var value =Blocking.single(observable); 
           trace("Should raise an exception");
        }
        catch(e:String){
           assertEquals (e, "Sequence contains no elements");
        }
       
    } 
    public  function  test_of_list(){       
        var items = ["one", "two","three"] ;
        var of_list = function( xs) return  Observable.currentThread.of_enum (xs);        
        assertEquals (3,Blocking.single(of_list(items).length()));
        assertEquals ("two",Blocking.single(of_list(items).drop(1).take( 1 )));
        assertEquals ( "three",Blocking.single(of_list(items).take_last( 1 ))); 
       
    } 
    public  function  test_append(){ 
     
        var o1 = Observable.create(function( observer:IObserver<Int>) {
            observer.on_next(1);
            observer.on_next(2);
            observer.on_completed();
            return Subscription.empty();
        });
         
        var o2 = Observable.create(function( observer:IObserver<Int>) {
            observer.on_next(3);
            observer.on_next(4);
            observer.on_completed();
            return Subscription.empty();
        });
        var append_observable = o1.append(o2);
        var state = TestHelper.create (); 
        append_observable.subscribe(state.observer());
        assertEquals( [1,2,3,4].toString(),state.on_next_values().toString());
        assertEquals( true,state.is_completed());
        assertEquals( false,state.is_on_error()); 
       
    } 
    public  function  test_append_error(){ 
     
        var o1 = Observable.create(function( observer:IObserver<Int>) {
            observer.on_next(1);
            observer.on_next(2);
            observer.on_error("test");
            return Subscription.empty();
        });
         
        var o2 = Observable.create(function( observer:IObserver<Int>) {
            observer.on_next(3);
            observer.on_next(4);
            observer.on_completed();
            return Subscription.empty();
        });
        var append_observable = o1.append(o2);
        var state = TestHelper.create (); 
        append_observable.subscribe(state.observer());
        assertEquals( [1,2].toString(),state.on_next_values().toString());
        assertEquals( false,state.is_completed());
        assertEquals( true,state.is_on_error()); 
       
    } 

    public  function  test_return(){ 
     
        var observable = Observable.of_return( 42);
          
        var state = TestHelper.create (); 
        observable.subscribe(state.observer());
        assertEquals( [42].toString(),state.on_next_values().toString());
        assertEquals( true,state.is_completed());
        assertEquals( false,state.is_on_error()); 
       
    } 
     
    public  function  test_merge_synchronous(){ 
     
        var o1 = Observable.create(function( observer:IObserver<Int>) {
            observer.on_next(1);
            observer.on_next(2);
            observer.on_completed();
            return Subscription.empty();
        });
         
        var o2 = Observable.create(function( observer:IObserver<Int>) {
            observer.on_next(3);
            observer.on_next(4);
            observer.on_completed();
            return Subscription.empty();
        });

         var o = Observable.create(function( observer:IObserver<Observable<Int>>) {
            observer.on_next(o1);
            observer.on_next(o2);
            observer.on_completed();
            return Subscription.empty();
        });
        var merge_observable = o.merge();
        var state = TestHelper.create (); 
        merge_observable.subscribe(state.observer());
        assertEquals( [1,2,3,4].toString(),state.on_next_values().toString());
        assertEquals( true,state.is_completed());
        assertEquals( false,state.is_on_error()); 
       
    } 
    public  function  test_merge_child_error_synchronous(){ 
     
        var o1 = Observable.create(function( observer:IObserver<Int>) {
            observer.on_next(1);
            observer.on_next(2);
            observer.on_completed();
            return Subscription.empty();
        });
         
        var o2 = Observable.create(function( observer:IObserver<Int>) {
            observer.on_next(3);
            observer.on_next(4);
            observer.on_error("test");
            return Subscription.empty();
        });

         var o = Observable.create(function( observer:IObserver<Observable<Int>>) {
            observer.on_next(o1);
            observer.on_next(o2);
            observer.on_completed();
            return Subscription.empty();
        });
        var merge_observable = o.merge();
        var state = TestHelper.create (); 
        merge_observable.subscribe(state.observer());
        assertEquals( [1,2,3,4].toString(),state.on_next_values().toString());
        assertEquals( false,state.is_completed());
        assertEquals( true,state.is_on_error()); 
       
    } 
    public  function  test_merge_parent_error_synchronous(){ 
     
        var o1 = Observable.create(function( observer:IObserver<Int>) {
            observer.on_next(1);
            observer.on_next(2);
            observer.on_completed();
            return Subscription.empty();
        });

         var o = Observable.create(function( observer:IObserver<Observable<Int>>) {
            observer.on_next(o1); 
            observer.on_error("test");
            return Subscription.empty();
        });
        var merge_observable = o.merge();
        var state = TestHelper.create (); 
        merge_observable.subscribe(state.observer());
        assertEquals( [1,2].toString(),state.on_next_values().toString());
        assertEquals( false,state.is_completed());
        assertEquals( true,state.is_on_error()); 
       
    } 

   
    public  function  test_map(){ 
     
        var observable = Observable.create(function( observer:IObserver<Int>) {
            observer.on_next(1);
            observer.on_next(2);
            observer.on_next(3);
            observer.on_completed();
            return Subscription.empty();
        });
         
        var map_observable =new rx.observables.Map(observable,function(x) return x*2);// observable.map(function(x) return x*2);
        var state = TestHelper.create (); 
        map_observable.subscribe(state.observer());
        assertEquals( [2, 4, 6].toString(),state.on_next_values().toString());
        assertEquals( true,state.is_completed());
        assertEquals( false,state.is_on_error()); 
       
    } 
    public  function  test_bind (){
        var  f =function(v:Int) return   Observable.create(function( observer:IObserver<String>) {
            if(v==42){
              observer.on_next( "42");
              observer.on_next("Answer to the Ultimate Question of Life, the Universe, and Everything");
            }else
            {
              observer.on_next( v+"");
            }
            observer.on_completed();
            return Subscription.empty();
        }); 
        var observable = Observable.create(function( observer:IObserver<Int>) {
            observer.on_next(41);
            observer.on_next(42);
            observer.on_next(43);
            observer.on_completed();
            return Subscription.empty();
        }); 
        var bind_observable =observable.bind( f);
        var state = TestHelper.create (); 
        bind_observable.subscribe(state.observer());
        assertEquals( ["41","42","Answer to the Ultimate Question of Life, the Universe, and Everything","43"].toString(),state.on_next_values().toString());
        assertEquals( true,state.is_completed());
        assertEquals( false,state.is_on_error());  

    } 
    
    public  function  test_empty(){ 
     
        var observable = Observable.empty();          
        var state = TestHelper.create (); 
        observable.subscribe(state.observer());
        assertEquals( [].toString(),state.on_next_values().toString());
        assertEquals( true,state.is_completed());
        assertEquals( false,state.is_on_error()); 
       
    } 
    public  function  test_error(){      
        var observable = Observable.error("test");          
        var state = TestHelper.create (); 
        observable.subscribe(state.observer());
        assertEquals( [].toString(),state.on_next_values().toString());
        assertEquals( false,state.is_completed());
        assertEquals( true,state.is_on_error()); 
       
    } 
     public  function  test_never(){ 
        var observable = Observable.never();
          
        var state = TestHelper.create (); 
        observable.subscribe(state.observer());
        assertEquals( [].toString(),state.on_next_values().toString());
        assertEquals( false,state.is_completed());
        assertEquals( false,state.is_on_error()); 
       
    }  
 
    public  function  test_subscribe_on_this  (){ 
        var state  = TestHelper.create ();
        var schedule =  new ScheduledObservable() ;     
        var schedulerBase     = cast(schedule.scheduler, SchedulerBase);      
        var observable = Observable.create(function( observer:IObserver<Int>) {
            observer.on_next(42);
            observer.on_completed();
            return Subscription.empty();
        });                
        var  scheduled_observable = schedule.subscribe_on_this( observable );
        var __unsubscribe = scheduled_observable.subscribe(state.observer()); 
        assertEquals(  1 ,schedulerBase.schedule_count);
        __unsubscribe.unsubscribe ();
        assertEquals(  2,schedulerBase.schedule_count);
        assertEquals(  [42].toString(),state.on_next_values().toString());
        assertEquals( true,state.is_completed());
        assertEquals( false,state.is_on_error()); 
    }

    public function   test_schedule_periodically ()
    {
         Scheduler.test.reset();
        var  counter =   0 ;
        var __unsubscribe = Scheduler.test.schedule_periodically( 0.1,0.1,function (){
              counter=Utils.incr(counter);
              return Subscription.empty();
            });
        Scheduler.test.advance_time_to(0.3);
        __unsubscribe.unsubscribe ();
        assertEquals(2 ,counter);  
    }


    public  function  test_with_test_scheduler (){ 
        Scheduler.test.reset();
        var interval = Observable.test.interval (1.0 );
        var observable = interval.take( 5 ) ;
        var state = TestHelper.create (); 
        observable.subscribe(state.observer()); 
        Scheduler.test.advance_time_to( 5.0);

        assertEquals( [0,1,2,3,4].toString(),state.on_next_values().toString());
        assertEquals( true,state.is_completed());
        assertEquals( false,state.is_on_error()); 
    } 
 //7-31
    public  function test_average1(){

        var average_observable =  Observable.fromRange(3, 9, 2).average(); 
        var state = TestHelper.create (); 
        average_observable.subscribe(state.observer());  
        assertEquals([5].toString(),state.on_next_values().toString());

        assertEquals( true,state.is_completed());
        assertEquals( false,state.is_on_error());    
    }
    public  function test_average2(){

        var average_observable =  Observable.of_enum([-1, 0, 1]).average(); 
        var state = TestHelper.create (); 
        average_observable.subscribe(state.observer());  
        assertEquals([0].toString(),state.on_next_values().toString());

        assertEquals( true,state.is_completed());
        assertEquals( false,state.is_on_error());    
    }
    public  function test_average_error(){

        var average_observable =  Observable.error("throw").average(); 
        var state = TestHelper.create (); 
        average_observable.subscribe(state.observer());   

        assertEquals( false,state.is_completed());
        assertEquals( true,state.is_on_error());    
    }
 
     public  function  test_amb_one(){ 

        var amb_observable =  Observable.fromRange(0,3).amb(null); 
        var state = TestHelper.create (); 
        amb_observable.subscribe(state.observer());  

        assertEquals([0,1,2].toString(),state.on_next_values().toString());
        assertEquals( true,state.is_completed());
        assertEquals( false,state.is_on_error());    
     }

    public  function  test_amb (){   

        var a = Subject.create();
        var b = Subject.create();   
        var amb_observable = a.amb(b); 
        var state = TestHelper.create (); 
        amb_observable.subscribe(state.observer());  


        


        b.on_next(4);
        a.on_next(1);
        b.on_next(5);
        b.on_next(6);
        b.on_completed();
        a.on_next(2);
        a.on_next(3);
        a.on_completed();

        assertEquals( [4,5,6].toString(),state.on_next_values().toString());
        assertEquals( true,state.is_completed());
        assertEquals( false,state.is_on_error()); 
    } 

    public  function  test_buffer (){   

        var buffer_observable = Observable.fromRange(0,5).buffer(2); 
        var state = TestHelper.create (); 
        buffer_observable.subscribe(state.observer());  

        assertEquals([[0,1],[2,3],[4]].toString(),state.on_next_values().toString());
        assertEquals( true,state.is_completed());
        assertEquals( false,state.is_on_error()); 
    } 
    public  function  test_buffer_error (){   

         var observable = Observable.create(function( observer:IObserver<Int>) {
            observer.on_next(1);
            observer.on_next(2);
            observer.on_next(3);
            observer.on_error("oops");
            return Subscription.empty();
        }); 
        var buffer_observable = observable.buffer(2); 
        var state = TestHelper.create (); 
        buffer_observable.subscribe(state.observer());  

        assertEquals([[1,2],[3]].toString(),state.on_next_values().toString());
        assertEquals(false,state.is_completed());
        assertEquals(true,state.is_on_error()); 
    } 

 public  function  test_catch_error (){   
  
        var observable = Observable.create(function( observer:IObserver<Int>) {
            observer.on_next(1);
            observer.on_next(2);
            observer.on_error("ohno");
           // observer.on_next(3);
            //observer.on_completed();
            return Subscription.empty();
        }); 

        var __handler= Subject.replay();
            __handler.on_next(5);
        var catch_observable = observable.of_catch(function(e:String) return __handler);

            __handler.on_next(6);
            __handler.on_next(7);

        var state = TestHelper.create (); 
        catch_observable.subscribe(state.observer());  

        assertEquals([1,2,5,6,7].toString(),state.on_next_values().toString());
        assertEquals(false,state.is_completed());
        assertEquals(true,state.is_on_error()); 
    } 
 
     public  function  test_combineLatest  (){  

        var observableA = Observable.of('a');
        var observableB = Observable.of('b');
        var observableC = Observable.of('c'); 
        var combinator:Array<String>->String=function(args:Array<String>){ 
            return args[0]+args[1]+args[2];
        };
        var combineLatest_observable = observableA.combineLatest([observableB, observableC], combinator);

        var state = TestHelper.create (); 
        combineLatest_observable.subscribe(state.observer());  

        assertEquals(["abc"].toString(),state.on_next_values().toString());
        assertEquals(true,state.is_completed());
        assertEquals(false,state.is_on_error()); 
    } 
    public  function  test_combineLatest_values_complete (){  

        var observableA = Subject.create();
        var observableB = Subject.create();
        var combinator:Array<Int>->Int=function(args:Array<Int>){ 
            trace(args);
            return args[0]+args[1];
        };
        var combineLatest_observable = observableA.combineLatest([observableB], combinator); 
      
        var state = TestHelper.create (); 
        combineLatest_observable.subscribe(state.observer());  

        observableA.on_next(1);
        observableB.on_next(2);
        observableB.on_next(3);
        observableA.on_next(4); 

        observableA.on_completed();
        observableB.on_completed();
        assertEquals([3,4,7].toString(),state.on_next_values().toString());
        assertEquals(true,state.is_completed());
        assertEquals(false,state.is_on_error()); 
    } 
    public  function  test_combineLatest_complete (){  
        var observableA = Subject.create();
        var observableB = Subject.create();
        var combinator:Array<Int>->Int=function(args:Array<Int>){ 
            trace(args);
            return args[0]+args[1];
        };
        var combineLatest_observable = observableA.combineLatest([observableB], combinator); 
        var state = TestHelper.create (); 
        combineLatest_observable.subscribe(state.observer()); 
        assertEquals(false,state.is_completed());
        observableA.on_next(1);
        assertEquals(false,state.is_completed());
        observableB.on_next(2);
        assertEquals(false,state.is_completed());
        observableB.on_completed();
        assertEquals(false,state.is_completed());
        observableA.on_completed();

        assertEquals(true,state.is_completed());
        assertEquals(false,state.is_on_error()); 

    }
    public  function  test_combineLatest_errors(){  
        var observableA = Subject.create();
        var observableB = Subject.create();
        var combinator:Array<Int>->Int=function(args:Array<Int>){ 
            trace(args);
            return args[0]+args[1];
        };
        var combineLatest_observable = observableA.combineLatest([observableB], combinator); 
        var state = TestHelper.create (); 
        combineLatest_observable.subscribe(state.observer()); 
        assertEquals(false,state.is_on_error());
        observableA.on_next(1);
        assertEquals(false,state.is_on_error());
        observableB.on_next(2);
        assertEquals(false,state.is_on_error());
        observableB.on_error("error");
   
       // observableA.on_error("error");

        assertEquals(false,state.is_completed());
        assertEquals(true,state.is_on_error());
    }

    public  function  test_concat(){  
        var subjectA = Subject.create();
        var subjectB = Subject.create();
        var concat_observable = subjectA.concat([subjectB]);     
        var state = TestHelper.create (); 
        concat_observable.subscribe(state.observer());  
        subjectA.on_next(1);
        subjectB.on_next(2);
        subjectA.on_next(3);
        subjectA.on_completed();
        subjectB.on_next(4);
        subjectB.on_next(5);
        subjectB.on_completed();
        assertEquals([1,3,4,5].toString(),state.on_next_values().toString());
        assertEquals(true,state.is_completed());
        assertEquals(false,state.is_on_error()); 
    }

    public  function  test_concat_error(){  
        var badObservable = Observable.create(function( observer:IObserver<Int>) { 
                                                observer.on_error('oh no'); 
                                                return Subscription.empty();
                                            });
        var concat_observable = Observable.of(1).concat([Observable.of(2), badObservable]);
        var state = TestHelper.create (); 
        concat_observable.subscribe(state.observer());  
        assertEquals(false,state.is_completed());
        assertEquals(true,state.is_on_error()); 
    }
 
    public  function  test_concat_completes(){  
        var subject = Subject.create(); 
        var concat_observable = Observable.fromRange(1, 5).concat([Observable.fromRange(1, 5), subject]);       
        var state = TestHelper.create (); 
        concat_observable.subscribe(state.observer());  
        assertEquals(false,state.is_completed());
        subject.on_completed();
        assertEquals(true,state.is_completed());
        assertEquals(false,state.is_on_error()); 
    }    
    

   */

    public  function  test_contains(){  

        var observable = Observable.fromRange(0,5);  
        var contains_observable = observable.contains(3);     
        var state = TestHelper.create (); 
        contains_observable.subscribe(state.observer());   
        assertEquals([true].toString(),state.on_next_values().toString());
        assertEquals(true,state.is_completed());
        assertEquals(false,state.is_on_error()); 
    }
 

    public  function  test_contains_no_values(){  

        var observable = Observable.empty();
        var contains_observable = observable.contains(3);     
        var state = TestHelper.create (); 
        contains_observable.subscribe(state.observer());   
        assertEquals([false].toString(),state.on_next_values().toString());
        assertEquals(true,state.is_completed());
        assertEquals(false,state.is_on_error()); 
    }
    public  function  test_contains_errors(){  

        var observable_error = Observable.error("oh ");
        var contains_observable = observable_error.contains(3);     
        var state = TestHelper.create (); 
        contains_observable.subscribe(state.observer());   
        assertEquals([].toString(),state.on_next_values().toString());
        assertEquals(false,state.is_completed());
        assertEquals(true,state.is_on_error()); 
    } 
    public  function  test_contains_null(){  
  
        var contains_observable =    Observable.create(function( observer:IObserver<Null<Int>>) {
            observer.on_next(null); 
            observer.on_completed();
            return Subscription.empty();
        });

        var state = TestHelper.create (); 
        contains_observable.subscribe(state.observer());   
        assertEquals([null].toString(),state.on_next_values().toString());
        assertEquals(true,state.is_completed());
        assertEquals(false,state.is_on_error()); 
    }


   //8-1
    public  function  test_defaultIfEmpty(){  

        var observable = Observable.fromRange(0,5);  
        var defaultIfEmpty_observable = observable.defaultIfEmpty(3);     
        var state = TestHelper.create (); 
        defaultIfEmpty_observable.subscribe(state.observer());   
        assertEquals([0,1,2,3,4].toString(),state.on_next_values().toString());
        assertEquals(true,state.is_completed());
        assertEquals(false,state.is_on_error()); 
    }

    public  function  test_defaultIfEmpty_no_values(){  

        var observable = Observable.empty();  
        var defaultIfEmpty_observable = observable.defaultIfEmpty(3);     
        var state = TestHelper.create (); 
        defaultIfEmpty_observable.subscribe(state.observer());   
        assertEquals([3].toString(),state.on_next_values().toString());
        assertEquals(true,state.is_completed());
        assertEquals(false,state.is_on_error()); 
    }

    public  function  test_delay(){  

        var observable = Observable.fromRange(0,5);  
        var defaultIfEmpty_observable = observable.delay(3);     
        var state = TestHelper.create (); 
        //Sys.sleep(3.1);
        defaultIfEmpty_observable.subscribe(state.observer());   
        assertEquals([0,1,2,3,4].toString(),state.on_next_values().toString());
        assertEquals(true,state.is_completed());
        assertEquals(false,state.is_on_error()); 
    }
}

 