package editor_panel.tracks {
	import flash.events.Event;			

	
	
	/**
	 * Track event
	 * 
	 * TODO: Write documentation
	 * 
	 * @author Vaclav Vancura (http://vaclav.vancura.org)
	 * @since Jul 18, 2008
	 */
	public class TrackEvent extends Event {

		
		
		public static const KILL:String = 'onKill';
		public static const MUTE_ON:String = 'onMuteOn';
		public static const MUTE_OFF:String = 'onMuteOff';
		public static const SOLO_ON:String = 'onSoloOn';
		public static const SOLO_OFF:String = 'onSoloOff';
		public static const REFRESH:String = 'onRefresh';
		public static const VOLUME_CHANGE:String = 'onVolumeChange';
		public static const BALANCE_CHANGE:String = 'onBalanceChange';
		public static const RECORD_START:String = 'onRecordStart';
		public static const RECORD_STOP:String = 'onRecordStop';
		public var data:Object;

		
		
		public function TrackEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false, d:Object = null) {
			data = d;
			super(type, bubbles, cancelable);
		}

		
		
		public override function clone():Event {
			return new TrackEvent(type, bubbles, cancelable, data);
		}

		
		
		public override function toString():String {
			return formatToString('TrackEvent', 'type', 'bubbles', 'cancelable', 'data');
		}
	}
}
