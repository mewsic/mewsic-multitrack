package editor_panel.waveform {
	import flash.events.Event;		

	
	
	/**
	 * Waveform event
	 * 
	 * TODO: Write documentation
	 * 
	 * @author Vaclav Vancura (http://vaclav.vancura.org)
	 * @since Jun 27, 2008
	 */
	public class WaveformEvent extends Event {

		
		
		public static const WAVEFORM_DOWNLOADED:String = 'onWaveformDownloaded';
		public var data:Object;

		
		
		public function WaveformEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false, d:Object = null) {
			this.data = d;
			super(type, bubbles, cancelable);
		}

		
		
		public override function clone():Event {
			return new WaveformEvent(type, bubbles, cancelable, data);
		}

		
		
		public override function toString():String {
			return formatToString('WaveformEvent', 'type', 'bubbles', 'cancelable', 'data');
		}
	}
}
