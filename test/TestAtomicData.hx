package test;
import rx.AtomicData;
import rx.Thread;
class TestAtomicData extends haxe.unit.TestCase {

public  function test_unsafe_get (){
    var v = AtomicData.create(0)  ;
    assertEquals( 0, AtomicData.unsafe_get(v));
}

public  function test_get (){
    var v = AtomicData.create( 0) ;
    assertEquals( 0, AtomicData.get(v));
}
public  function test_set (){
  var v = AtomicData.create( 0) ;
  AtomicData.set(1, v);
     assertEquals(  1, AtomicData.get( v));
}
public  function test_get_and_set (){
  var v = AtomicData.create( 0) ;
  var v1 = AtomicData.get_and_set(1 ,v);
   assertEquals( 1, AtomicData.get (v));
   assertEquals( 0 ,v1);
}
function succ(i) return i+1;
public  function test_update (){
  var v = AtomicData.create( 0) ;
  AtomicData.update( succ, v);
   assertEquals(  1, AtomicData.get( v));
}
public  function test_update_and_get(){
  var v = AtomicData.create( 0) ;
  var v1 = AtomicData.update_and_get (succ, v) ;
  assertEquals( 1, v1);
}
public  function test_compare_and_set(){
  var v = AtomicData.create ( 0) ;
  var old_content = AtomicData.compare_and_set( 0 ,1 ,v );
  assertEquals( 0 ,old_content);
  assertEquals( 1, AtomicData.get(v));
}
#if cpp
public  function test_concurrent_update(){
    var v = AtomicData.create( 0 );
    var count = 10;
   
    var f = function () {
                         
                        AtomicData.update((function( value){
                            var value1 = succ(value);
                             Sys.sleep(0.1*Math.random());
                            return value1;
                        }) ,v);};
    for (i in 0...count){
        Thread.create(f);
    }
    

  Sys.sleep( 0.1);
  assertEquals( count ,AtomicData.get(v)); 
}

#end

}