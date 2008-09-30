package remoting.events {
	import flash.events.Event;	

	
	
	/**
	 * Song save event. 
	 * 
	 * @author Vaclav Vancura (http://vaclav.vancura.org)
	 * @since Jul 25, 2008
	 */
	public class SongSaveEvent extends Event {

		
		
		public static const REQUEST_DONE:String = 'requestDone';
		public var key:String;

		
		
		/**
		 * Constructor.
		 * @param type Event type
		 * @param bubbles Bubbling flag
		 * @param cancelable Cancelable flag
		 */
		public function SongSaveEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false, k:String = '') {
			key = k;
			super(type, bubbles, cancelable);
		}

		
		
		/**
		 * Clone event.
		 * @return Cloned event
		 */
		public override function clone():Event {
			return new SongSaveEvent(type, bubbles, cancelable, key);
		}

		
		
		/**
		 * Describe event.
		 * @return Event description
		 */
		public override function toString():String {
			return formatToString('SongSaveEvent', 'type', 'bubbles', 'cancelable', 'key');
		}
	}
}
