package remoting.events {
	import flash.events.Event;
	
	import remoting.data.WorkerStatusData;		

	
	
	/**
	 * Worker event. 
	 * 
	 * @author Vaclav Vancura (http://vaclav.vancura.org)
	 * @since Jul 22, 2008
	 */
	public class WorkerEvent extends Event {

		
		
		public static const REQUEST_DONE:String = 'requestDone';
		public var workerStatusData:WorkerStatusData;

		
		
		/**
		 * Constructor.
		 * @param type Event type
		 * @param bubbles Bubbling flag
		 * @param cancelable Cancelable flag
		 * @param d Worker status data object
		 */
		public function WorkerEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false, d:WorkerStatusData = null) {
			workerStatusData = d;
			super(type, bubbles, cancelable);
		}

		
		
		/**
		 * Clone event.
		 * @return Cloned event
		 */
		public override function clone():Event {
			return new WorkerEvent(type, bubbles, cancelable, workerStatusData);
		}

		
		
		/**
		 * Describe event.
		 * @return Event description
		 */
		public override function toString():String {
			return formatToString('WorkerEvent', 'type', 'bubbles', 'cancelable', 'workerStatusData');
		}
	}
}
