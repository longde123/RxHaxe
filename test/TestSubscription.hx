package test;

import rx.disposables.Boolean;

import rx.disposables.Assignable;

import rx.disposables.Composite;
import rx.disposables.MultipleAssignment;
import rx.disposables.SingleAssignment;
import rx.disposables.ISubscription;

import rx.Subscription;
import rx.Thread;
class TestSubscription extends haxe.unit.TestCase {

    function incr(i) return  i+1;
    public function test_unsubscribe_only_once(){ 
        var counter =   0 ;
        var unsubscribe =Subscription.create (function() return counter= incr(counter));
        unsubscribe.unsubscribe ();
        unsubscribe.unsubscribe ();
        assertEquals(1,counter);            
    }
    public function  test_boolean_subscription(){ 
        var counter =   0 ;
        var boolean_subscription=Boolean.create(function() return counter= incr(counter));

        assertEquals(false, (boolean_subscription.is_unsubscribed()));
        boolean_subscription.unsubscribe();
        assertEquals(true ,(boolean_subscription.is_unsubscribed()));
        boolean_subscription.unsubscribe();
        assertEquals(true ,(boolean_subscription.is_unsubscribed()));
        assertEquals(1,counter);  
    }
    public function   test_composite_subscription_success (){
        var counter =   0 ;
        var composite_subscription = Composite.create([] );
        composite_subscription.add(Subscription.create (function() return counter= incr(counter)));
        composite_subscription.add(Subscription.create (function() return counter= incr(counter)));
        composite_subscription.unsubscribe();
        assertEquals(2,counter);  
    }

#if cpp
    public function  test_composite_subscription_unsubscribe_all (){
        var counter =   0 ;
        var composite_subscription = Composite.create([] );
        var count = 10;    
        var f=    function(){
            composite_subscription.add(Subscription.create (function(){
                 Sys.sleep(0.1*Math.random());
                 return counter= incr(counter);}));
            };
        for(i in 0...count) 
        {
            Thread.create(f);
        }
        composite_subscription.unsubscribe();                    
        Sys.sleep( 0.1);
        assertEquals(count,counter);   
  }
#end
  public function   test_composite_subscription_exception (){
    var counter =  0 ;
    var ex =  "failed on first one";
    var composite_subscription  =  Composite.create([] );
    //todo
  //  composite_subscription.add(function () {throw ex;} );
    composite_subscription.add(Subscription.create (function() return counter= incr(counter)));
    try{
        composite_subscription.unsubscribe();                
        trace( "Expecting an exception");
    } catch (es:String)
    {
          trace(es);
            assertEquals(es,ex);  
    } 
  //(* we should still have unsubscribed to the second one *)
     assertEquals(1,counter);   
  }
  public function   test_composite_subscription_remove ()
  {
    var s1  = Boolean.create(function(){});
    var s2  = Boolean.create(function(){});
    var s  =  Composite.create([] );
    s.add( s1 );
    s.add( s2 );
    s.remove( s1 ); 
    assertEquals(true,s1.is_unsubscribed());   
    assertEquals(false,s2.is_unsubscribed());    
  }

    public function  test_composite_subscription_clear (){
        var s1  = Boolean.create(function(){});
        var s2  = Boolean.create(function(){});
        var s  =  Composite.create([] );
        s.add( s1 );
        s.add( s2 );
        assertEquals(false,s1.is_unsubscribed());   
        assertEquals(false,s2.is_unsubscribed());   
        s.clear();
        assertEquals(true,s1.is_unsubscribed());   
        assertEquals(true,s2.is_unsubscribed());   
        assertEquals(false,s.is_unsubscribed());  

        var s3  = Boolean.create(function(){});
        s.add( s3 );
        s.unsubscribe();
        assertEquals(true,s3.is_unsubscribed());   
        assertEquals(true,s.is_unsubscribed());  
   }
   
    public function test_composite_subscription_unsubscribe_idempotence (){
        var counter =  0 ;
        var s  =  Composite.create([] );
        s.add(Subscription.create (function() return counter= incr(counter)));
        s.unsubscribe();
        s.unsubscribe();
        s.unsubscribe();
 // (* We should have only unsubscribed once *)
  
        assertEquals(1,counter);  
    }

    #if cpp
 public function test_composite_subscription_unsubscribe_idempotence_concurrently(){
    var counter =  0 ;
    var s  =  Composite.create([] );
    s.add(Subscription.create (function() return counter= incr(counter)));
    var count = 10 ;    

    for(i in 0...count) 
    {
        Thread.create(s.unsubscribe);
    }

// (* We should have only unsubscribed once *)
    Sys.sleep( 0.1);
    assertEquals(1,counter);   
}
  #end
public function  test_multiple_assignment_subscription(){
    var m =MultipleAssignment.create(Subscription.empty());
    var unsub1 =  false;
    var s1 = Subscription.create (function () return unsub1 = true);
    m.set(s1);
    assertEquals( false,m.is_unsubscribed());
    var unsub2 =   false;
    var s2 = Subscription.create (function () return unsub2 = true);
    m.set(s2);
    assertEquals(  false, m.is_unsubscribed());
    assertEquals(  false, unsub1);
    m.unsubscribe();
    assertEquals( true ,unsub2);
    assertEquals( true ,m.is_unsubscribed());
    var unsub3 =   false;
    var s3 = Subscription.create (function () return unsub3 = true);
    m.set(s3);
    assertEquals( true ,unsub3);
    assertEquals( true ,m.is_unsubscribed());
}

public function  test_single_assignment_subscription(){
    var m = SingleAssignment.create();
    var unsub1 =   false;
    var s1 = Subscription.create (function () return unsub1 = true) ;
    m.set(s1);

    assertEquals( false,m.is_unsubscribed());
    var unsub2 =   false;
    var s2 = Subscription.create (function () return unsub2 = true);
    try{
        m.set(s2);
        trace( "Should raise an exception");
    }catch(e:String){
        assertEquals (e, "SingleAssignment");
    }
    
    assertEquals(  false ,m.is_unsubscribed());
    assertEquals(  false ,unsub1);
    m.unsubscribe();
    assertEquals(  true ,unsub1);
    assertEquals(  false ,unsub2);
    assertEquals(  true ,m.is_unsubscribed());
}

}