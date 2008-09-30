package remoting.events {
	import flash.events.Event;	

	
	
	/**
	 * Song export event. 
	 * 
	 * @author Vaclav Vancura (http://vaclav.vancura.org)
	 * @since Jul 24, 2008
	 */
	public class SongExportEvent extends Event {

		
		
		public static const REQUEST_DONE:String = 'requestDone';
		public var key:String;

		
		
		/**
		 * Constructor.
		 * @param type Event type
		 * @param bubbles Bubbling flag
		 * @param cancelable Cancelable flag
		 */
		public function SongExportEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false, k:String = '') {
			key = k;
			super(type, bubbles, cancelable);
		}

		
		
		/**
		 * Clone event.
		 * @return Cloned event
		 */
		public override function clone():Event {
			return new SongExportEvent(type, bubbles, cancelable, key);
		}

		
		
		/**
		 * Describe event.
		 * @return Event description
		 */
		public override function toString():String {
			return formatToString('SongExportEvent', 'type', 'bubbles', 'cancelable', 'key');
		}
	}
}
