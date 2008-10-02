package remoting.events {
	import flash.events.Event;			

	
	
	/**
	 * Remoting event.
	 * 
	 * @author Vaclav Vancura (http://vaclav.vancura.org)
	 * @since Jul 1, 2008
	 */
	public class RemotingEvent extends Event {

		
		
		public static const TIMEOUT:String = 'onTimeout';
		public static const SECURITY_ERROR:String = 'onSecurityError';
		public static const ASYNC_ERROR:String = 'onAsyncError';
		public static const IO_ERROR:String = 'onIOError';
		public static const REQUEST_DONE:String = 'onRequestDone';
		public static const REFRESH_DONE:String = 'onRefreshDone';
		public static const REQUEST_FAILED:String = 'onRequestFailed';
		public static const CONNECTION_DONE:String = 'onConnectionDone';
		public static const CONNECTION_FAILED:String = 'onConnectionFailed';
		public static const MY_LIST_REQUEST_DONE:String = 'onMyListRequestDone';
		public static const MY_SONGS_REQUEST_DONE:String = 'onMySongsRequestDone';
		public static const CONFIG_REQUEST_DONE:String = 'onConfigRequestDone';
		public static const GENRES_REQUEST_DONE:String = 'onGenresRequestDone';		public static const GENRES_SEARCH_REQUEST_DONE:String = 'onGenresSearchRequestDone';
		public static const USER_REQUEST_DONE:String = 'onUserRequestDone';
		public static const INSTRUMENTS_REQUEST_DONE:String = 'onInstrumentsRequestDone';
		public static const INSTRUMENTS_SEARCH_REQUEST_DONE:String = 'onInstrumentsSearchRequestDone';		public static const COUNTRIES_SEARCH_REQUEST_DONE:String = 'onCountriesSearchRequestDone';
		public static const SONG_SIBLINGS_REQUEST_DONE:String = 'onSongSiblingsRequestDone';
		public static const SONG_EDIT_REQUEST_DONE:String = 'onSongEditRequestDone';
		public static const TRACK_SIBLINGS_REQUEST_DONE:String = 'onTrackSiblingsRequestDone';
		public static const TRACK_CREATE_REQUEST_DONE:String = 'onTrackCreateRequestDone';
		public static const SONG_FETCH_REQUEST_DONE:String = 'onSongFetchRequestDone';
		public static const CORE_SONG_REQUEST_DONE:String = 'onCoreSongRequestDone';
		public static const CORE_USER_REQUEST_DONE:String = 'onCoreUserRequestDone';
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
