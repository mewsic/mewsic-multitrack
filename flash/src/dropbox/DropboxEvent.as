package dropbox {
	import flash.events.Event;				

	
	
	/**
	 * Dropbox event.
	 * Currently these events are available:
	 * CLICK - item clicked
	 * 
	 * @author Vaclav Vancura (http://vaclav.vancura.org)
	 * @since Jul 24, 2008
	 */
	public class DropboxEvent extends Event {

		
		
		public static const CLICK:String = 'onClick';
		public var label:String;
		public var id:String;

		
		
		/**
		 * Constructor.
		 * @param type Event type
		 * @param bubbles Bubbling flag
		 * @param cancelable Cancelable flag
		 * @param id Dropbox ID
		 * @param label Item label
		 */
		public function DropboxEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false, i:String = '', l:String = '') {
			this.id = i;
			this.label = l;
			super(type, bubbles, cancelable);
		}

		
		
		/**
		 * Clone event.
		 * @return Cloned event
		 */
		public override function clone():Event {
			return new DropboxEvent(type, bubbles, cancelable, id, label);
		}

		
		
		/**
		 * Describe event.
		 * @return Event description
		 */
		public override function toString():String {
			return formatToString('DropboxEvent', 'type', 'bubbles', 'id', 'label');
		}
	}
}
