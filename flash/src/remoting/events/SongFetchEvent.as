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

		
		
		public static const REQUEST_DONE:String = 'onSongFetchRequestDone';
		public static const REQUEST_FAILED:String = 'onSongFetchRequestFailed';

		public var songData:SongData;
		public var songID:uint;

		
		
		/**
		 * Constructor.
		 * @param type Event type
		 * @param bubbles Bubbling flag
		 * @param cancelable Cancelable flag
		 * @param d User data object
		 */
		public function SongFetchEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false, data:Object = null) {
			
			if(data.songData) songData = data.songData;
			if(data.songID) songID = data.songID;

			super(type, bubbles, cancelable);
		}

		
		
		/**
		 * Clone event.
		 * @return Cloned event
		 */
		public override function clone():Event {
			return new SongFetchEvent(type, bubbles, cancelable, {songData:songData, songID:songID});
		}

		
		
		/**
		 * Describe event.
		 * @return Event description
		 */
		public override function toString():String {
			return formatToString('SongFetchEvent', 'type', 'bubbles', 'cancelable', 'songData', 'songID');
		}
	}
}
