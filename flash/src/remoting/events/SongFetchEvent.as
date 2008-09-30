package remoting.events {
	import flash.events.Event;
	
	import remoting.data.SongData;	

	
	
	/**
	 * Song fetch event. 
	 * 
	 * @author Vaclav Vancura (http://vaclav.vancura.org)
	 * @since Jul 15, 2008
	 */
	public class SongFetchEvent extends Event {

		
		
		public static const REQUEST_DONE:String = 'requestDone';
		public var songData:SongData;
		public var trackList:Array;

		
		
		/**
		 * Constructor.
		 * @param type Event type
		 * @param bubbles Bubbling flag
		 * @param cancelable Cancelable flag
		 * @param d User data object
		 */
		public function SongFetchEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false, sd:SongData = null, tl:Array = null) {
			songData = sd;
			trackList = tl;
			super(type, bubbles, cancelable);
		}

		
		
		/**
		 * Clone event.
		 * @return Cloned event
		 */
		public override function clone():Event {
			return new SongFetchEvent(type, bubbles, cancelable, songData, trackList);
		}

		
		
		/**
		 * Describe event.
		 * @return Event description
		 */
		public override function toString():String {
			return formatToString('SongFetchEvent', 'type', 'bubbles', 'cancelable', 'songData', 'trackList');
		}
	}
}
