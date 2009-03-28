package controls {
	import flash.events.Event;		

	
	
	/**
	 * Knob event.
	 * 
	 * TODO: Write documentation
	 * 
	 * @author Vaclav Vancura (http://vaclav.vancura.org)
	 * @since Jul 20, 2008
	 */
	public class KnobEvent extends Event {

		
		
		public static const REFRESH:String = 'onKnobRefresh';
		public var thumbAngle:Number;

		
		
		public function KnobEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false, tp:Number = 0) {
			thumbAngle = tp;
			super(type, bubbles, cancelable);
		}

		
		
		public override function clone():Event {
			return new KnobEvent(type, bubbles, cancelable, thumbAngle);
		}

		
		
		public override function toString():String {
			return formatToString('KnobEvent', 'type', 'bubbles', 'cancelable', 'thumbAngle');
		}
	}
}
