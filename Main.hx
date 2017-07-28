package;

import rx.AtomicData;
import rx.AsyncLock;
import rx.notifiers.Notification;
import rx.Observable;
import rx.Observer;
import rx.observers.ObserverBase;
import rx.Subject;
import rx.Subscription;
import rx.Scheduler;
import rx.Core;
import rx.disposables.Boolean;
import rx.disposables.Composite;
import rx.disposables.ISubscription; 
import rx.subjects.Replay;
import rx.subjects.Behavior;
import rx.subjects.Async;
import test.TestAtomicData;
import test.TestAsyncLock;
import test.TestSubscription;
import test.TestObserver;
import test.TestSubject;
import test.TestScheduler;
import test.TestHelper;
import test.TestObservable;
class Main 
{
	static function main(  ){	  
        var r = new haxe.unit.TestRunner();
       	r.add(new TestAtomicData());
       	r.add(new TestAsyncLock());
		r.add(new TestSubscription());
		r.add(new TestObserver());
		r.add(new TestSubject());
		r.add(new TestScheduler());
		r.add(new TestObservable());
        // add other TestCases here

        // finally, run the tests
        r.run();

  
    }
}


/*


class Main implements Savable{

	@:save var gravity:Float = 9.81;
	@:save var player:Player;
	@:save var player2:Main.SubClassOfPlayer;
	@:save var thing:SomethingThatDoesntImplementSavable;
	var dontSave = 'this string';

	function new(){
		player = new Player();
		player2 = new SubClassOfPlayer();
		thing = new SomethingThatDoesntImplementSavable();
	}

	static function main(){
		var m = new Main();
		trace(m.getSavedData());
	}

}

class Player implements Savable{

	@:save var health:Float = 100;

	var unwantedField = [
		"some data" => "that we don't want to save"
	];

	public function new(){}

}

class SubClassOfPlayer extends Player{

	@:save var ammo:Float = 999;

}

class SomethingThatDoesntImplementSavable {

	var a:Float = 3;
	var b:Float = 4;

	public function new(){}

}
*/