package test;
import rx.AsyncLock;
import cpp.vm.Thread; 
import cpp.Lib;
class TestAsyncLock extends haxe.unit.TestCase {

    public function test_wait_graceful(){
        var ok =   false;
        var async_lock = AsyncLock.create () ;

        async_lock.wait((function() ok = true));
      
        trace("ok should be true "+ ok);
        assertTrue(ok); 
    }
    public function test_wait_fail(){
        var l = AsyncLock.create ();
        var ex = "Failure test"; 
        try{
            l.wait( (function () {
                   throw  ex; //todo
            }
                ));
            trace("should raise an exception");
        }
        catch( e : String ){
            trace("l has faulted; should not run");
             assertEquals( ex ,e);
        }
        l.wait( (function () trace("l has faulted; should not run")));
        assertTrue(true); 
    }
    public function test_wait_queues_work(){
        var l = AsyncLock.create () ;
        var l1 =  false ;
        var l2 =  false ;
        l.wait(
            (function (){ 
            l.wait( 
                (function () {
                trace( "l1 should be true "+l1);
                    assertTrue(l1); 
                l2 = true;
                }));
            l1 = true;
            }));
        trace( "l2 should be true " +l2);
        assertTrue(l2); 
    }

    public function test_dispose(){
  var l = AsyncLock.create ();
  var l1 =   false;
  var l2 =   false;
  var l3 =   false;
  var l4 =   false;
  l.wait( (function (){
                    l.wait( (function () {
                                                l.wait( 
                                                (function () return
                                                    l3 = true
                                                ));
                                                l2 = true;
                                                l.dispose() ;
                                                l.wait( 
                                                (function () return
                                                    l4 = true
                                                ));
                                    }
                        ));
                    l1 = true;
                    }));
  trace("l1 should be true " +l1);
  trace("l2 should be true " +l2);
    assertTrue(l1);
    assertTrue(l2);
    assertFalse(l3);
    assertFalse(l4);
    }
}