package remoting.events {
	import flash.events.Event;			

	
	
	/**
	 * Remoting event.
	 * 
	 * @author Vaclav Vancura (http://vaclav.vancura.org)
	 * @since Jul 1, 2008
	 */
	public class RemotingEvent extends Event {

		
		
		public static const TIMEOUT:String = 'onRemotingTimeout';
		public static const SECURITY_ERROR:String = 'onRemotingSecurityError';
		public static const ASYNC_ERROR:String = 'onRemotingAsyncError';
		public static const IO_ERROR:String = 'onRemotingIOError';
		public static const REQUEST_DONE:String = 'onRemotingRequestDone';
		public static const REFRESH_DONE:String = 'onRemotingRefreshDone';
		public static const REQUEST_FAILED:String = 'onRemotingRequestFailed';
		public static const CONNECTION_DONE:String = 'onRemotingConnectionDone';
		public static const CONNECTION_FAILED:String = 'onRemotingConnectionFailed';
		public static const CONFIG_REQUEST_DONE:String = 'onRemotingConfigRequestDone';
		public static const INSTRUMENTS_REQUEST_DONE:String = 'onRemotingInstrumentsRequestDone';
		public static const CORE_USER_REQUEST_DONE:String = 'onRemotingCoreUserRequestDone';
		public var description:String;
		public var dataXML:XML;

		
		
		/**
		 * Constructor.
		 * @param type Event type
		 * @param bubbles Bubbling flag
		 * @param cancelable Cancelable flag
		 * @param desc Event description (if not specified, 'No description given' used instead)
		 * @param dxml Data XML
		 */
		public function RemotingEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false, desc:String = 'No description given', dxml:XML = null) {
			this.description = desc;
			this.dataXML = dxml;
			super(type, bubbles, cancelable);
		}

		
		
		/**
		 * Clone event.
		 * @return Cloned event
		 */
		public override function clone():Event {
			return new RemotingEvent(type, bubbles, cancelable, description, dataXML);
		}

		
		
		/**
		 * Describe event.
		 * @return Event description
		 */
		public override function toString():String {
			return formatToString('RemotingEvent', 'type', 'bubbles', 'cancelable', 'description', 'dataXML');
		}
	}
}
