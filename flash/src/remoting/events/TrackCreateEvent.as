package remoting.events {
	import flash.events.Event;
	
	import remoting.data.TrackData;	

	
	
	/**
	 * Track create event. 
	 * 
	 * @author Vaclav Vancura (http://vaclav.vancura.org)
	 * @since Jul 23, 2008
	 */
	public class TrackCreateEvent extends Event {

		
		
		public static const REQUEST_DONE:String = 'requestDone';
		public var trackData:TrackData;

		
		
		/**
		 * Constructor.
		 * @param type Event type
		 * @param bubbles Bubbling flag
		 * @param cancelable Cancelable flag
		 * @param d User data object
		 */
		public function TrackCreateEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false, td:TrackData = null) {
			trackData = td;
			super(type, bubbles, cancelable);
		}

		
		
		/**
		 * Clone event.
		 * @return Cloned event
		 */
		public override function clone():Event {
			return new TrackCreateEvent(type, bubbles, cancelable, trackData);
		}

		
		
		/**
		 * Describe event.
		 * @return Event description
		 */
		public override function toString():String {
			return formatToString('TrackCreateEvent', 'type', 'bubbles', 'cancelable', 'trackData');
		}
	}
}
