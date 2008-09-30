package manager_panel.tabs {
	import flash.events.Event;						

	
	
	/**
	 * Tab Event.
	 * 
	 * TODO: Write documentation
	 * 
	 * @author Vaclav Vancura (http://vaclav.vancura.org)
	 * @since Jul 9, 2008
	 */
	public class TabEvent extends Event {

		
		
		public static const CHANGE_BACK_TYPE:String = 'onChangeBackType';
		public static const ACTIVATE:String = 'onActivate';
		public static const CHANGE_HEIGHT:String = 'onChangeHeight';
		public var data:Object;

		
		
		/**
		 * Constructor.
		 * @param type Event type
		 * @param bubbles Bubbling flag
		 * @param cancelable Cancelable flag
		 * @param data Data Object
		 */
		public function TabEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false, d:Object = null) {
			this.data = d;
			super(type, bubbles, cancelable);
		}

		
		
		/**
		 * Clone event.
		 * @return Cloned event
		 */
		public override function clone():Event {
			return new TabEvent(type, bubbles, cancelable, data);
		}

		
		
		/**
		 * Describe event.
		 * @return Event description
		 */
		public override function toString():String {
			return formatToString('RemotingEvent', 'type', 'bubbles', 'cancelable', 'data');
		}
	}
}
