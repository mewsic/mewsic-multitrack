package controls {
	import flash.events.Event;		

	
	
	/**
	 * Input event.
	 * 
	 * @author Vaclav Vancura (http://vaclav.vancura.org)
	 * @since Jul 23, 2008
	 */
	public class InputEvent extends Event {

		
		
		public static const CHANGE:String = 'onChange';
		public static const FOCUS_IN:String = 'onFocusIn';
		public static const FOCUS_OUT:String = 'onFocusOut';
		public var text:String;

		
		
		/**
		 * Constructor.
		 * @param type Event type
		 * @param bubbles Bubbling flag
		 * @param cancelable Cancelable flag
		 * @param t Text
		 */
		public function InputEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false, t:String = '') {
			text = t;
			super(type, bubbles, cancelable);
		}

		
		
		/**
		 * Clone event.
		 * @return Cloned event
		 */
		public override function clone():Event {
			return new InputEvent(type, bubbles, cancelable, text);
		}

		
		
		/**
		 * Describe event.
		 * @return Event description
		 */
		public override function toString():String {
			return formatToString('InputEvent', 'type', 'bubbles', 'cancelable', 'text');
		}
	}
}
