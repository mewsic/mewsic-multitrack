package remoting.events {
	import flash.events.Event;		

	
	
	/**
	 * Song siblings event. 
	 * 
	 * @author Vaclav Vancura (http://vaclav.vancura.org)
	 * @since Jul 25, 2008
	 */
	public class TrackSiblingsEvent extends Event {

		
		
		public static const REQUEST_DONE:String = 'requestDone';
		public var directList:Array;
		public var indirectList:Array;

		
		
		/**
		 * Constructor.
		 * @param type Event type
		 * @param bubbles Bubbling flag
		 * @param cancelable Cancelable flag
		 * @param dl Direct list
		 * @param il Indirect list
		 */
		public function TrackSiblingsEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false, dl:Array = null, il:Array = null) {
			directList = dl;
			indirectList = il;
			super(type, bubbles, cancelable);
		}

		
		
		/**
		 * Clone event.
		 * @return Cloned event
		 */
		public override function clone():Event {
			return new TrackSiblingsEvent(type, bubbles, cancelable, directList, indirectList);
		}

		
		
		/**
		 * Describe event.
		 * @return Event description
		 */
		public override function toString():String {
			return formatToString('TrackSiblingsEvent', 'type', 'bubbles', 'cancelable', 'directList', 'indirectList');
		}
	}
}
