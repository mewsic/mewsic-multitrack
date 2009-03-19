package remoting {
	import application.App;
	
	import br.com.stimuli.loading.BulkErrorEvent;
	import br.com.stimuli.loading.BulkLoader;
	
	import config.Settings;
	
	import de.popforge.utils.sprintf;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.net.URLRequest;
	import flash.net.URLVariables;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	
	import org.osflash.thunderbolt.Logger;
	
	import remoting.data.SongData;
	import remoting.data.TrackData;
	import remoting.data.UserData;
	import remoting.events.RemotingEvent;		

	
	
	/**
	 * Common service functions.
	 * 
	 * @author Vaclav Vancura (http://vaclav.vancura.org)
	 * @since Jul 3, 2008
	 */
	public class ServiceCommon extends EventDispatcher {

		
		
		public static const METHOD_GET:String = 'GET';
		public static const METHOD_POST:String = 'POST';
		protected static var $serverPath:String;
		protected static var $mediaPath:String;
		protected static var $connectionTimeout:Number = Settings.DEFAULT_CONNECTION_TIMEOUT;
		protected static var $coreUserAuthenticityToken:String;
		protected static var $coreUserLoginStatus:Boolean;
		protected static var $coreUserData:UserData = new UserData();
		protected static var $coreSongData:SongData = new SongData();
		protected static var $defaultAvatarURL:String;
		public var url:String;
		protected var $serviceID:String;
		protected var $requestID:String;
		protected var $isConnected:Boolean;
		protected var $isConnecting:Boolean;
		protected var $responseHandler:Function;
		protected var $responseData:XML;
		protected var $errorHandler:Function;
		protected var $connectionTimeoutHandler:int;

		
		
		/**
		 * Connect service.
		 * Not applicable here - just a placeholder to be overriden by subclasses.
		 */
		public function connect():void {
			throw new Error(sprintf('Service %s: Not applicable.', $serviceID));
		}

		
		
		/**
		 * Disconnect service.
		 * Not applicable here - just a placeholder to be overriden by subclasses.
		 */
		public function disconnect():void {
			throw new Error(sprintf('Service %s: Not applicable.', $serviceID));
		}

		
		
		/**
		 * Request service.
		 * Parameters could contain:
		 * params.suffix - additional URL parameters
		 * params.url - override URL
		 * params.method - method (METHOD_POST or METHOD_GET by default)
		 * @param params Parameters (not required)
		 * @throws Error if service is already connecting
		 * @throws Error if service URL is not defined
		 * @throws Error if service response handler is not defined
		 * @throws Error if service error handler is not defined
		 */
		public function request(params:Object = null):void {
			if($isConnecting) throw new Error(sprintf('Service %s: Service already connecting.', $serviceID));
			if(url == null) throw new Error(sprintf('Service %s: Service URL not defined.', $serviceID));
			if($responseHandler == null) throw new Error(sprintf('Service %s: Service response handler not defined.', $serviceID));
			if($errorHandler == null) throw new Error(sprintf('Service %s: Service error handler not defined.', $serviceID));
			
			$isConnecting = true;
			$responseData = null;
			$connectionTimeoutHandler = setTimeout($onConnectionTimeout, $connectionTimeout * 1000);
			
			if(params == null) params = new Object();
			if(params.suffix == undefined) params.suffix = '';
			
			if(params.url == undefined) {
				// url in parameters is undefined, create it first
				if($coreUserData.userID != 0) {
					// user is logged in, we will have to replace {:id} with user id
					params.url = url;
					params.url = params.url.replace(/{:id}/g, $coreUserData.userID);
					params.url = params.url.replace(/{:song_id}/g, $coreSongData.songID);
				}
				else {
					// user is not logged in, use the whole url variable
					params.url = url;
				}
			}
			
			if(params.method == METHOD_POST) {
				Logger.debug(sprintf('Service %s POST request (%s). Connection timeout is %u seconds.', $serviceID, url, $connectionTimeout));
				
				var postRequest:URLRequest = new URLRequest(params.url);
				postRequest.method = METHOD_POST;
				postRequest.data = new URLVariables(params.suffix);
				
				with(App.bulkLoader.add(postRequest, {
					id:$requestID, type:BulkLoader.TYPE_XML, preventCache:Settings.PREVENT_CACHING})) {
					addEventListener(Event.COMPLETE, _onRequestDone, false, 0, true);
					addEventListener(BulkLoader.ERROR, _onRequestError, false, 0, true);
				}
				App.bulkLoader.start();
			}
			else {
				Logger.debug(sprintf('Service %s GET request (%s). Connection timeout is %u seconds.', $serviceID, url, $connectionTimeout));
					
				with(App.bulkLoader.add(params.url + params.suffix, {
					id:$requestID, type:BulkLoader.TYPE_XML, preventCache:Settings.PREVENT_CACHING})) {
					addEventListener(Event.COMPLETE, _onRequestDone, false, 0, true);
					addEventListener(BulkLoader.ERROR, _onRequestError, false, 0, true);
				}
				App.bulkLoader.start();
			}
		}

		
		
		/**
		 * Convert XML to SongData (with nested tracks if available)
		 * @param x Input XML
		 * @return Output SongData
		 */
		protected function $xml2SongData(x:XML):SongData {
			var d:SongData = new SongData();
			
			d.songGenreID = x.genre;
			d.songID = x.id;
			d.songInstrumentsCount = x.instruments;
			d.songSiblingsCount = x.siblings_count;
			d.songBPM = x.bpm;
			d.songSampleURL = x.filename;
			d.songWaveformURL = x.waveform;
			d.songUserNickname = x.user;
			d.songAuthor = x.author;
			d.songTitle = x.title;
			d.songKey = x.tone;
			d.songDescription = x.description;
			d.songRating = x.rating;
			d.songMilliseconds = x.seconds * 1000;
			
			for each(var mx:XML in x.tracks.*) d.songTracks.push($xml2TrackData(mx));
			
			return d;
		}

		
		
		/**
		 * Convert XML to TrackData.
		 * @param x Input XML
		 * @return Output TrackData
		 */
		protected function $xml2TrackData(x:XML):TrackData {
			var d:TrackData = new TrackData();
			
			d.trackGenreID = x.genre;
			d.trackInstrumentID = x.instrument;
			d.trackID = x.id;
			d.trackBPM = x.bpm;
			d.trackSongsCount = x.song_count;
			d.trackSampleURL = x.filename;
			d.trackWaveformURL = x.waveform;
			d.trackUserNickname = x.user;
			d.trackAuthor = x.author;
			d.trackTitle = x.title;
			d.trackKey = x.tone;
			d.trackDescription = x.description;
			d.trackRating = x.rating;
			d.trackVolume = x.volume;
			d.trackBalance = x.balance;
			d.trackMilliseconds = x.seconds * 1000;
			
			return d;
		}		

		
		
		/**
		 * Get connected flag.
		 * @return Connected flag
		 */
		public function get isConnected():Boolean {
			return $isConnected;
		}

		
		
		/**
		 * Get connecting flag.
		 * @return Connecting flag
		 */
		public function get isConnecting():Boolean {
			return $isConnecting;
		}

		
		
		/**
		 * Get core user login status flag.
		 * @return Core user login status flag
		 */
		public static function get coreUserLoginStatus():Boolean {
			return $coreUserLoginStatus;
		}

		
		
		/**
		 * Get core user authenticity token.
		 * @return Core user authenticity token
		 */
		public static function get coreUserAuthenticityToken():String {
			return $coreUserAuthenticityToken;
		}

		
		
		/**
		 * Get core user data.
		 * @return Core user data
		 */
		public static function get coreUserData():UserData {
			return $coreUserData;
		}

		
		
		/**
		 * Get core song data.
		 * @return Core user data
		 */
		public static function get coreSongData():SongData {
			return $coreSongData;
		}

		
		
		/**
		 * Get connection timeout.
		 * @return Connection timeout
		 */
		public static function get connectionTimeout():uint {
			return $connectionTimeout;
		}

		
		
		/**
		 * Get server path.
		 * @return Server path
		 */
		public static function get serverPath():String {
			return $serverPath;
		}

		
		
		/**
		 * Set server path.
		 * @param value Server path
		 */
		public static function set serverPath(value:String):void {
			$serverPath = value;
		}

		
		
		/**
		 * Get media path.
		 * @return Server path
		 */
		public static function get mediaPath():String {
			return $mediaPath;
		}

		
		
		/**
		 * Get this service ID.
		 * @return serviceID
		 */
		public function get serviceID():String {
			return $serviceID;
		}

		
		
		/**
		 * Connection timeout event handler.
		 */
		protected function $onConnectionTimeout():void {
			$isConnecting = false;
			_removeLoader();
			dispatchEvent(new RemotingEvent(RemotingEvent.TIMEOUT, true));
		}

		
		
		/**
		 * Remove bulkLoader.
		 */
		private function _removeLoader():void {
			with(App.bulkLoader.get($requestID)) {
				removeEventListener(Event.COMPLETE, _onRequestDone);
				removeEventListener(BulkLoader.ERROR, _onRequestError);
			}
			App.bulkLoader.remove($requestID);
		}

		
		
		/**
		 * Request done event handler.
		 * @param event Event data
		 */
		private function _onRequestDone(event:Event):void {
			clearTimeout($connectionTimeoutHandler);
			$isConnecting = false;
			$responseData = App.bulkLoader.getXML($requestID);
			_removeLoader();
			$responseHandler();
		}

		
		
		/**
		 * Request error event handler.
		 * @param event Event data
		 */
		private function _onRequestError(event:BulkErrorEvent):void {
			clearTimeout($connectionTimeoutHandler);
			$isConnecting = false;
			_removeLoader();
			$errorHandler();
		}
	}
}
