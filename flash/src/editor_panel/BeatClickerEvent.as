package editor_panel {
	import flash.events.Event;			

	
	
	/**
	 * Application event.
	 * BEAT - beat passed
	 * 
	 * @author Vaclav Vancura (http://vaclav.vancura.org)
	 * @since Aug 2, 2008
	 */
	public class BeatClickerEvent extends Event {

		
		
		public static const BEAT:String = 'onBeat';
		public var polarity:Boolean;
		public var bpm:uint;

		
		
		/**
		 * Constructor.
		 * @param type Event type
		 * @param bubbles Bubbling flag
		 * @param cancelable Cancelable flag
		 * @param description Description what exactly happened
		 * @param b Current BPM
		 * @param p Polarity
		 */
		public function BeatClickerEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false, b:uint = undefined, p:Boolean = undefined) {
			polarity = p;
			bpm = b;
			super(type, bubbles, cancelable);
		}

		
		
		/**
		 * Clone event.
		 * @return Cloned event
		 */
		public override function clone():Event {
			return new BeatClickerEvent(type, bubbles, cancelable, bpm, polarity);
		}

		
		
		/**
		 * Describe event.
		 * @return Event description
		 */
		public override function toString():String {
			return formatToString('BeatClickerEvent', 'type', 'bubbles', 'cancelable', 'bpm', 'polarity');
		}
	}
}
