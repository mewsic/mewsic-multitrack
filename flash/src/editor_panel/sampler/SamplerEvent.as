package editor_panel.sampler {
	import flash.events.Event;		

	
	
	/**
	 * Sampler event
	 * Currently these events are available:
	 * PLAYBACK_COMPLETE - playback complete
	 * PLAYBACK_OPEN - playback open (can start playback without skipping)
	 * SAMPLE_ERROR - sample error
	 * SAMPLE_PROGRESS - sample download progress
	 * SAMPLE_DOWNLOADED - sample fully downloaded
	 * 
	 * @author Vaclav Vancura (http://vaclav.vancura.org)
	 * @since Jun 20, 2008
	 */
	public class SamplerEvent extends Event {

		
		
		public static const PLAYBACK_COMPLETE:String = 'onPlaybackComplete';
		public static const PLAYBACK_OPEN:String = 'onPlaybackOpen';
		public static const SAMPLE_ERROR:String = 'onSampleError';
		public static const SAMPLE_PROGRESS:String = 'onSampleProgress';
		public static const SAMPLE_DOWNLOADED:String = 'onSampleDownloaded';
		public var data:Object;

		
		
		/**
		 * Constructor.
		 * @param bubbles Bubbling flag
		 * @param cancelable Cancelable flag
		 * @param d Data
		 * @param type Type
		 */
		public function SamplerEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false, d:Object = null) {
			this.data = d;
			super(type, bubbles, cancelable);
		}

		
		
		/**
		 * Clone event.
		 * @return Cloned event
		 */
		public override function clone():Event {
			return new SamplerEvent(type, bubbles, cancelable, data);
		}

		
		
		/**
		 * Describe event.
		 * @return Event description
		 */
		public override function toString():String {
			return formatToString('SamplerEvent', 'type', 'bubbles', 'cancelable', 'data');
		}
	}
}
