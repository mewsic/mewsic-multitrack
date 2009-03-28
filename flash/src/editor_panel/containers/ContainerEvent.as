package editor_panel.containers {
	import flash.events.Event;			

	
	
	/**
	 * Container event.
	 * Currently these events are available:
	 * CONTENT_HEIGHT_CHANGE - content height changed
	 * TRACK_ADDED - track was added
	 * TRACK_FETCH_FAILED - track load failed
	 * TRACK_KILL - track killed
	 * SONG_FETCH_FAILED - song load failed
	 * 
	 * @author Vaclav Vancura (http://vaclav.vancura.org)
	 * @since Jun 20, 2008
	 */
	public class ContainerEvent extends Event {

		
		
		public static const CONTENT_HEIGHT_CHANGE:String = 'onContentHeightChange';
		public static const RECORD_TRACK_READY:String = 'onRecordTrackReady';
		public static const TRACK_ADDED:String = 'onTrackAdded';
		public static const SONG_FETCH_FAILED:String = 'onSongFetchFailed';
		public static const TRACK_FETCH_FAILED:String = 'onTrackFetchFailed';
		public static const TRACK_KILL:String = 'onTrackKill';
		public var data:Object;

		
		
		/**
		 * Constructor.
		 * @param bubbles Bubbling flag
		 * @param cancelable Cancelable flag
		 * @param d Data
		 * @param type Type
		 */
		public function ContainerEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false, d:Object = null) {
			data = d;
			super(type, bubbles, cancelable);
		}

		
		
		/**
		 * Clone event.
		 * @return Cloned event
		 */
		public override function clone():Event {
			return new ContainerEvent(type, bubbles, cancelable, data);
		}

		
		
		/**
		 * Describe event.
		 * @return Event description
		 */
		public override function toString():String {
			return formatToString('ContainerEvent', 'type', 'bubbles', 'cancelable', 'data');
		}
	}
}
