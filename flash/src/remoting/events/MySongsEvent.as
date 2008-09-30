package remoting.events {
	import flash.events.Event;	

	
	
	/**
	 * My Songs event. 
	 * 
	 * @author Vaclav Vancura (http://vaclav.vancura.org)
	 * @since Jul 25, 2008
	 */
	public class MySongsEvent extends Event {

		
		
		public static const REQUEST_DONE:String = 'requestDone';
		public var songList:Array;

		
		
		/**
		 * Constructor.
		 * @param type Event type
		 * @param bubbles Bubbling flag
		 * @param cancelable Cancelable flag
		 * @param sl Song list
		 */
		public function MySongsEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false, sl:Array = null) {
			songList = sl;
			super(type, bubbles, cancelable);
		}

		
		
		/**
		 * Clone event.
		 * @return Cloned event
		 */
		public override function clone():Event {
			return new MySongsEvent(type, bubbles, cancelable, songList);
		}

		
		
		/**
		 * Describe event.
		 * @return Event description
		 */
		public override function toString():String {
			return formatToString('MySongsEvent', 'type', 'bubbles', 'cancelable', 'songList');
		}
	}
}
