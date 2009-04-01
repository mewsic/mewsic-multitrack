package remoting.events {
	import flash.events.Event;
	
	import remoting.data.TrackData;	

	
	
	/**
	 * Track fetch event. 
	 * 
	 * @author Vaclav Vancura (http://vaclav.vancura.org)
	 * @since Jul 15, 2008
	 */
	public class TrackFetchEvent extends Event {

		
		
		public static const REQUEST_DONE:String = 'onTrackRequestDone';
		public static const REQUEST_FAILED:String = 'onTrackRequestFailed';
		
		public var trackData:TrackData;
		public var trackID:uint;



		/**
		 * Constructor.
		 * @param type Event type
		 * @param bubbles Bubbling flag
		 * @param cancelable Cancelable flag
		 * @param d User data object
		 */
		public function TrackFetchEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false, data:Object = null) {
			if(data.trackData) trackData = data.trackData;
			if(data.trackID) trackID = data.trackID;

			super(type, bubbles, cancelable);
		}

		
		
		/**
		 * Clone event.
		 * @return Cloned event
		 */
		public override function clone():Event {
			return new TrackFetchEvent(type, bubbles, cancelable, {trackData:trackData, trackID:trackID});
		}

		
		
		/**
		 * Describe event.
		 * @return Event description
		 */
		public override function toString():String {
			return formatToString('TrackFetchEvent', 'type', 'bubbles', 'cancelable', 'trackData', 'trackID');
		}
	}
}
