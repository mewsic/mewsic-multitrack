package application {
	import flash.events.Event;				

	
	
	/**
	 * Application event.
	 * Currently these events are available:
	 * TIMEOUT - service timeout
	 * FATAL_ERROR - fatal error, show system modalWindow (pink bar on top)
	 * CALL_STAGE_RESIZE - call for stage resize (not used here as stage does not resize)
	 * HEIGHT_CHANGE - height of a panel changed, resize Flash object container
	 * //REFRESH_TOP_PANE - call to JavaScript to refresh top HTML pane
	 * RELOAD_PAGE - reload page via javascript (destroys everything)
	 * 
	 * @author Vaclav Vancura (http://vaclav.vancura.org)
	 * @since Jun 13, 2008
	 */
	public class AppEvent extends Event {

		
		
		public static const TIMEOUT:String = 'onTimeout';
		public static const FATAL_ERROR:String = 'onFatalError';
		public static const CALL_STAGE_RESIZE:String = 'onCallStageResize';
		public static const HEIGHT_CHANGE:String = 'onHeightChange';
		//public static const REFRESH_TOP_PANE:String = 'onRefreshTopPane';
		public static const RELOAD_PAGE:String = 'onReloadPage';
		public var description:String;

		
		
		/**
		 * Constructor.
		 * @param type Event type
		 * @param bubbles Bubbling flag
		 * @param cancelable Cancelable flag
		 * @param description Description what exactly happened
		 */
		public function AppEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false, desc:String = 'No description given') {
			this.description = desc;
			super(type, bubbles, cancelable);
		}

		
		
		/**
		 * Clone event.
		 * @return Cloned event
		 */
		public override function clone():Event {
			return new AppEvent(type, bubbles, cancelable, description);
		}

		
		
		/**
		 * Describe event.
		 * @return Event description
		 */
		public override function toString():String {
			return formatToString('AppEvent', 'type', 'bubbles', 'cancelable', 'description');
		}
	}
}
