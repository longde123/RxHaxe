package rx.disposables; 

import rx.disposables.ISubscription;
import rx.Subscription;

 
class Boolean  implements ISubscription
{
 
    /* Implementation based on:
    * https://github.com/Netflix/RxJava/blob/master/rxjava-core/src/main/java/rx/subscriptions/ISubscription.java
    */
    var state :AtomicData<Bool>;
    var _unsubscribe:Void->Void;
    public function unsubscribe(){
   
        var was_unsubscribed = AtomicData.compare_and_set(false ,true, state);
        if  (!was_unsubscribed) _unsubscribe (); 
    }

  static public function create (unsubscribe:Void->Void)
  {
      return new Boolean(unsubscribe);
  } 
    public function new (unsubscribe:Void->Void){
        _unsubscribe=unsubscribe;
        state= AtomicData.create(false); 
    }

    

   public function  is_unsubscribed():Bool  return  AtomicData.unsafe_get(state);

}