package remoting.events {
	import flash.events.Event;

	import remoting.data.UserData;	

	
	
	/**
	 * User event. 
	 * 
	 * @author Vaclav Vancura (http://vaclav.vancura.org)
	 * @since Jul 15, 2008
	 */
	public class UserEvent extends Event {

		
		
		public static const REQUEST_DONE:String = 'requestDone';
		public var userData:UserData;

		
		
		/**
		 * Constructor.
		 * @param type Event type
		 * @param bubbles Bubbling flag
		 * @param cancelable Cancelable flag
		 * @param d User data object
		 */
		public function UserEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false, d:UserData = null) {
			userData = d;
			super(type, bubbles, cancelable);
		}

		
		
		/**
		 * Clone event.
		 * @return Cloned event
		 */
		public override function clone():Event {
			return new UserEvent(type, bubbles, cancelable, userData);
		}

		
		
		/**
		 * Describe event.
		 * @return Event description
		 */
		public override function toString():String {
			return formatToString('UserEvent', 'type', 'bubbles', 'cancelable', 'userData');
		}
	}
}
