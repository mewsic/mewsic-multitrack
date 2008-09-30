package remoting.events {
	import flash.events.Event;	

	
	
	/**
	 * My List event. 
	 * 
	 * @author Vaclav Vancura (http://vaclav.vancura.org)
	 * @since Jul 25, 2008
	 */
	public class MyListEvent extends Event {

		
		
		public static const REQUEST_DONE:String = 'requestDone';
		public var songList:Array;
		public var trackList:Array;

		
		
		/**
		 * Constructor.
		 * @param type Event type
		 * @param bubbles Bubbling flag
		 * @param cancelable Cancelable flag
		 * @param sl Song list
		 * @param tl Track list
		 */
		public function MyListEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false, sl:Array = null, tl:Array = null) {
			songList = sl;
			trackList = tl;
			super(type, bubbles, cancelable);
		}

		
		
		/**
		 * Clone event.
		 * @return Cloned event
		 */
		public override function clone():Event {
			return new MyListEvent(type, bubbles, cancelable, songList, trackList);
		}

		
		
		/**
		 * Describe event.
		 * @return Event description
		 */
		public override function toString():String {
			return formatToString('MyListEvent', 'type', 'bubbles', 'cancelable', 'songList', 'trackList');
		}
	}
}
