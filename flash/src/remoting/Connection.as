package remoting {
	import remoting.ServiceCommon;
	import remoting.data.SongData;
	import remoting.data.UserData;
	import remoting.events.RemotingEvent;
	import remoting.static_services.ConfigService;
	import remoting.static_services.CoreSongService;
	import remoting.static_services.CoreUserService;
	import remoting.static_services.InstrumentsService;
	import remoting.static_services.StreamService;
	
	import flash.events.EventDispatcher;	

	
	
	/**
	 * Remoting connection.
	 * 
	 * @author Vaclav Vancura (http://vaclav.vancura.org)
	 * @since Jun 30, 2008
	 */
	public class Connection extends EventDispatcher {

		
		
		private var _streamService:StreamService;
		private var _configService:ConfigService;
		private var _instrumentsService:InstrumentsService;
		private var _coreSongService:CoreSongService;
		private var _coreUserService:CoreUserService;

		
		
		/**
		 * Constructor.
		 */
		public function Connection() {
			// add service handlers
			_configService = new ConfigService();
			_streamService = new StreamService();
			_instrumentsService = new InstrumentsService();
			_coreSongService = new CoreSongService();
			_coreUserService = new CoreUserService();
			
			// add config event listeners
			_configService.addEventListener(RemotingEvent.TIMEOUT, _onTimeout, false, 0, true);
			_configService.addEventListener(RemotingEvent.REQUEST_DONE, _onConfigRequestDone, false, 0, true);
			_configService.addEventListener(RemotingEvent.REQUEST_FAILED, _onFailed, false, 0, true);
			
			// add stream event listeners
			_streamService.addEventListener(RemotingEvent.TIMEOUT, _onTimeout, false, 0, true);
			_streamService.addEventListener(RemotingEvent.ASYNC_ERROR, _onFailed, false, 0, true);
			_streamService.addEventListener(RemotingEvent.SECURITY_ERROR, _onFailed, false, 0, true);
			_streamService.addEventListener(RemotingEvent.CONNECTION_FAILED, _onFailed, false, 0, true);
			_streamService.addEventListener(RemotingEvent.IO_ERROR, _onFailed, false, 0, true);
			
			// add instruments event listener
			_instrumentsService.addEventListener(RemotingEvent.TIMEOUT, _onTimeout, false, 0, true);
			_instrumentsService.addEventListener(RemotingEvent.REQUEST_DONE, _onInstrumentsRequestDone, false, 0, true);
			_instrumentsService.addEventListener(RemotingEvent.REQUEST_FAILED, _onFailed, false, 0, true);
						
			// add core song event listeners
			_coreSongService.addEventListener(RemotingEvent.TIMEOUT, _onTimeout, false, 0, true);
			_coreSongService.addEventListener(RemotingEvent.REQUEST_DONE, _onCoreSongRequestDone, false, 0, true);
			_coreSongService.addEventListener(RemotingEvent.REQUEST_FAILED, _onFailed, false, 0, true);
		
			// add core user event listener			
			_coreUserService.addEventListener(RemotingEvent.TIMEOUT, _onTimeout, false, 0, true);
			_coreUserService.addEventListener(RemotingEvent.REQUEST_DONE, _onCoreUserRequestDone, false, 0, true);
			_coreUserService.addEventListener(RemotingEvent.REQUEST_FAILED, _onFailed, false, 0, true);
		}

		/**
		 * Get Config service.
		 * @return Config service
		 */
		public function get configService():ConfigService {
			return _configService;
		}

		
		
		/**
		 * Get Stream service.
		 * @return Stream service
		 */
		public function get streamService():StreamService {
			return _streamService;
		}

				
		
		/**
		 * Get Instruments service.
		 * @return Instruments service
		 */
		public function get instrumentsService():InstrumentsService {
			return _instrumentsService;
		}
		

		
		/**
		 * Get Core song service.
		 * @return Core song service
		 */
		public function get coreSongService():CoreSongService {
			return _coreSongService;
		}

		
		
		/**
		 * Get Core song data.
		 * @return Core song data
		 */
		public function get coreSongData():SongData {
			return ServiceCommon.coreSongData;
		}

		
		
		/**
		 * Get Core user service.
		 * @return Core user service
		 */
		public function get coreUserService():CoreUserService {
			return _coreUserService;
		}

		
		
		/**
		 * Get Core user data.
		 * @return Core user data
		 */
		public function get coreUserData():UserData {
			return ServiceCommon.coreUserData;
		}

		
		
		/**
		 * Set server path.
		 * Usually set from FlashVars.
		 * @param value Server path
		 */
		public function set serverPath(value:String):void {
			ServiceCommon.serverPath = value;
		}

		
		
		/**
		 * Get server path.
		 * @return Server path
		 */
		public function get serverPath():String {
			return ServiceCommon.serverPath;
		}

		
		
		/**
		 * Get media path.
		 * @return Server path
		 */
		public function get mediaPath():String {
			return ServiceCommon.mediaPath;
		}

		
		
		/**
		 * Get core user login status.
		 * @return Core user login status
		 */
		public function get coreUserLoginStatus():Boolean {
			return ServiceCommon.coreUserLoginStatus;
		}

		
		
		/**
		 * Get core user authenticity token.
		 * @return Core user authenticity token
		 */
		public function get coreUserAuthenticityToken():String {
			return ServiceCommon.coreUserAuthenticityToken;
		}

		
		
		/**
		 * Config request done, config information loaded.
		 * @param e Event data
		 */
		private function _onConfigRequestDone(event:RemotingEvent):void {
			dispatchEvent(new RemotingEvent(RemotingEvent.CONFIG_REQUEST_DONE));
		}

		
		
		/**
		 * Instruments request done.
		 * @param e Event data
		 */
		private function _onInstrumentsRequestDone(event:RemotingEvent):void {
			dispatchEvent(new RemotingEvent(RemotingEvent.INSTRUMENTS_REQUEST_DONE));
		}

		
		
		/**
		 * Instruments search request done.
		 * @param e Event data
		 */
		private function _onInstrumentsSearchRequestDone(event:RemotingEvent):void {
			dispatchEvent(new RemotingEvent(RemotingEvent.INSTRUMENTS_SEARCH_REQUEST_DONE));
		}

		
		
		/**
		 * Countries search request done.
		 * @param e Event data
		 */
		private function _onCountriesSearchRequestDone(event:RemotingEvent):void {
			dispatchEvent(new RemotingEvent(RemotingEvent.COUNTRIES_SEARCH_REQUEST_DONE));
		}

		
		
		/**
		 * Core song request done.
		 */
		private function _onCoreSongRequestDone(event:RemotingEvent):void {
			dispatchEvent(new RemotingEvent(RemotingEvent.CORE_SONG_REQUEST_DONE));
		}

		
		
		/**
		 * Core user request done.
		 */
		private function _onCoreUserRequestDone(event:RemotingEvent):void {
			dispatchEvent(new RemotingEvent(RemotingEvent.CORE_USER_REQUEST_DONE));
		}

		
		
		/**
		 * Timeout happened while connecting service.
		 * @param e Event data
		 */
		private function _onTimeout(event:RemotingEvent):void {
			dispatchEvent(event);
		}

		
		
		/**
		 * Service connection failed.
		 * @param e Event data
		 */
		private function _onFailed(event:RemotingEvent):void {
			dispatchEvent(event);
		}
	}
}
