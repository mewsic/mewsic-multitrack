package manager_panel.search {
	import flash.events.Event;					

	
	
	/**
	 * Panel event.
	 * 
	 * TODO: Write documentation
	 * 
	 * @author Vaclav Vancura (http://vaclav.vancura.org)
	 * @since Jul 1, 2008
	 */
	public class SubpanelEvent extends Event {

		
		
		public static const ROW_SELECT:String = 'RowSelect';
		public static const RESET:String = 'onReset';
		public var data:Object;

		
		
		/**
		 * Constructor.
		 * @param type Event type
		 * @param bubbles Bubbling flag
		 * @param cancelable Cancelable flag
		 * @param d Data Object
		 */
		public function SubpanelEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false, d:Object = null) {
			this.data = d;
			super(type, bubbles, cancelable);
		}

		
		
		/**
		 * Clone event.
		 * @return Cloned event
		 */
		public override function clone():Event {
			return new SubpanelEvent(type, bubbles, cancelable, data);
		}

		
		
		/**
		 * Describe event.
		 * @return Event description
		 */
		public override function toString():String {
			return formatToString('SubpanelEvent', 'type', 'bubbles', 'cancelable', 'data');
		}
	}
}
