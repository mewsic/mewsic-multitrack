package remoting.static_services {
	import org.osflash.thunderbolt.Logger;
	
	import de.popforge.utils.sprintf;
	
	import config.Settings;
	
	import remoting.IService;
	import remoting.ServiceCommon;
	import remoting.data.UserData;
	import remoting.events.RemotingEvent;	

	
	
	/**
	 * Config service.
	 * 
	 * @author Vaclav Vancura (http://vaclav.vancura.org)
	 * @since Jul 1, 2008
	 */
	public class ConfigService extends ServiceCommon implements IService {
		
		private var _streamGatewayURL:String; // e.g. 'rtmp://fms.myousica.com/live/'
		
		private var _myListRequestURL:String; // My List service (e.g. '/users/{:id}/mlabs')
		private var _mySongsRequestURL:String; // My Songs service (e.g. '/users/{:id}/songs.xml')
		private var _searchRequestURL:String; // Search service (e.g. '/search/new.xml')
		private var _instrumentsRequestURL:String; // Instruments service (e.g. '/instruments.xml')
		private var _userRequestURL:String; // User service (e.g. '/user/{:id}.xml')
		
		private var _songFetchRequestURL:String; // Song service: fetch request (e.g. '/songs/{:id}.xml')
		private var _songSiblingsRequestURL:String; // Song service: siblings request (e.g. '/songs/{:id}.xml?siblings=true')
		private var _songEditRequestURL:String; // Song service: edit request (e.g. '/songs/{:id}.xml?edit=true')
		private var _songExportRequestURL:String; // Song service: export request (e.g. '/songs/{:id}/mix.xml')
		private var _songUpdateRequestURL:String; // Song service: update request (e.g. '/songs/{:id}.xml')
		private var _songLoadRequestURL:String; // Song service: load request (e.g. '/songs/{:id}/load_track.xml')
		private var _songUnloadRequestURL:String; // Song service: unload request (e.g. '/songs/{:id}/unload_track.xml')
		
		private var _trackFetchRequestURL:String; // Track service: fetch request (e.g. '/tracks/{:id}.xml')
		private var _trackSiblingsRequestURL:String; // Track service: siblings request (e.g. '/tracks/{:id}.xml?siblings=true')
		private var _trackCreateRequestURL:String; // Track service: create request (e.g. '/tracks/{:id}.xml')
		private var _trackDownloadRequestURL:String; // Track service: download request (e.g. '/tracks/{:track_id}/download')
		
		private var _mediaExportRequestURL:String; // Media service: export request (e.g. '/mix')
		private var _mediaEncodeRequestURL:String; // Media service: encode request (e.g. '/encode_flv')
		private var _mediaUploadRequestURL:String; // Media service: upload request (e.g. '/upload')
		
		private var _workerExportRequestURL:String; // Worker service: export request (e.g. '/mix/status/{:key}')
		private var _workerEncodeRequestURL:String; // Worker service: encode request (e.g. '/encode_flv/status/{:key}')
		private var _workerUploadRequestURL:String; // Worker service: upload request (e.g. '/upload/status/{:key}')
		
		private var _sync:Number; // Sync value (e.g. 5)

		
		
		/**
		 * Constructor.
		 */
		public function ConfigService() {
			super();
			$serviceID = 'config';
			$requestID = $serviceID + '.request';
			$responseHandler = _onResponse;
			$errorHandler = _onError;
		}

		
		
		/**
		 * Dump config.
		 * @return Config dump
		 */
		override public function toString():String {
			return(
				'  *  coreUserData.userID = ' + coreUserData.userID + '\n' +
				'  *  coreUserAuthenticityToken = ' + coreUserAuthenticityToken + '\n' +
				'  *  coreUserLoginStatus = ' + coreUserLoginStatus + '\n' +
				'  *  connectionTimeout = ' + connectionTimeout + '\n\n' +
				
				'  *  serverPath = ' + serverPath + '\n' +
				'  *  mediaPath = ' + mediaPath + '\n' +
				'  *  streamGatewayURL = ' + streamGatewayURL + '\n' +
				'  *  defaultAvatarURL = ' + defaultAvatarURL + '\n' +
				'  *  sync = ' + sync + '\n\n' +
				
				'  *  myListRequestURL = ' + myListRequestURL + '\n' +
				'  *  mySongsRequestURL = ' + mySongsRequestURL + '\n' +
				'  *  searchRequestURL = ' + searchRequestURL + '\n' +
				'  *  instrumentsRequestURL = ' + instrumentsRequestURL + '\n' +
				'  *  userRequestURL = ' + userRequestURL + '\n' +
				
				'  *  songFetchRequestURL = ' + songFetchRequestURL + '\n' +
				'  *  songSiblingsRequestURL = ' + songSiblingsRequestURL + '\n' +
				'  *  songEditRequestURL = ' + songEditRequestURL + '\n' +
				'  *  songExportRequestURL = ' + songExportRequestURL + '\n' +
				'  *  songUpdateRequestURL = ' + songUpdateRequestURL + '\n' +
				'  *  songLoadRequestURL = ' + songLoadRequestURL + '\n' +
				'  *  songUnloadRequestURL = ' + songUnloadRequestURL + '\n' +
				
				'  *  trackFetchRequestURL = ' + trackFetchRequestURL + '\n' +
				'  *  trackSiblingsRequestURL = ' + trackSiblingsRequestURL + '\n' +
				'  *  trackCreateRequestURL = ' + trackCreateRequestURL + '\n' +
				'  *  trackDownloadRequestURL = ' + trackDownloadRequestURL + '\n' +
				
				'  *  mediaExportRequestURL = ' + mediaExportRequestURL + '\n' +
				'  *  mediaEncodeRequestURL = ' + mediaEncodeRequestURL + '\n' +
				'  *  mediaUploadRequestURL = ' + mediaUploadRequestURL + '\n' +
				
				'  *  workerExportRequestURL = ' + workerExportRequestURL + '\n' +
				'  *  workerEncodeRequestURL = ' + workerEncodeRequestURL + '\n' +
				'  *  workerUploadRequestURL = ' + workerUploadRequestURL + '\n\n'
			);
		}

		
		
		/**
		 * Response event handler.
		 */
		private function _onResponse():void {
			try {
				_streamGatewayURL = $responseData.fms;
				$mediaPath = $responseData.media;
				$defaultAvatarURL = $responseData.default_avatar;
				
				$coreUserAuthenticityToken = $responseData.authenticity_token;
				$coreUserData.userID = $responseData.current_user;
				$coreUserLoginStatus = ($coreUserData.userID != 0);
				$connectionTimeout = $responseData.connection_timeout;

				_myListRequestURL = $responseData.url_request.mylist;
				_mySongsRequestURL = $responseData.url_request.mysongs;
				_searchRequestURL = $responseData.url_request.search;
				_instrumentsRequestURL = $responseData.url_request.instruments;
				_userRequestURL = $responseData.url_request.user; // !
				
				_songFetchRequestURL = $responseData.url_request.songs.fetch;
				_songSiblingsRequestURL = $responseData.url_request.songs.siblings;
				_songEditRequestURL = $responseData.url_request.songs.edit;
				_songExportRequestURL = $responseData.url_request.songs.mix;
				_songUpdateRequestURL = $responseData.url_request.songs.update;
				_songLoadRequestURL = $responseData.url_request.songs.load;
				_songUnloadRequestURL = $responseData.url_request.songs.unload;
				
				_trackFetchRequestURL = $responseData.url_request.tracks.fetch;
				_trackSiblingsRequestURL = $responseData.url_request.tracks.siblings;
				_trackCreateRequestURL = $responseData.url_request.tracks.create;
				_trackDownloadRequestURL = $responseData.url_request.tracks.download;
				
				_mediaExportRequestURL = $responseData.url_request.media.mix;
				_mediaEncodeRequestURL = $responseData.url_request.media.encode;
				_mediaUploadRequestURL = $responseData.url_request.media.upload;
				
				_workerExportRequestURL = $responseData.url_request.workers.mixer;
				_workerEncodeRequestURL = $responseData.url_request.workers.encoder;
				_workerUploadRequestURL = $responseData.url_request.workers.uploader;
				
				_sync = $responseData.sync; 
				
				if(Settings.isServiceDumpEnabled) Logger.debug(sprintf('Service %s: Config dump:\n%s', $serviceID, this.toString()));
				dispatchEvent(new RemotingEvent(RemotingEvent.REQUEST_DONE));
			}
			catch(err:Error) {
				dispatchEvent(new RemotingEvent(RemotingEvent.REQUEST_FAILED, false, false, sprintf('Service %s: Could not parse user settings.\n%s', $serviceID, err.message)));
				return;
			}
		}
		
		
		
		/**
		 * Error event handler.
		 */
		private function _onError():void {
			dispatchEvent(new RemotingEvent(RemotingEvent.REQUEST_FAILED, false, false, sprintf('Service %s: Could not load config.', $serviceID)));
		}
		
		
		
		/**
		 * Get default avatar URL.
		 * @return Default avatar URL
		 */
		public function get defaultAvatarURL():String {
			return $defaultAvatarURL;
		}

		
		
		/**
		 * Get stream gateway URL.
		 * @return Stream gateway URL
		 */
		public function get streamGatewayURL():String {
			return _streamGatewayURL;
		}

		
		
		/**
		 * Get My List request URL.
		 * @return My List request URL
		 */
		public function get myListRequestURL():String {
			return _myListRequestURL;
		}

		
		
		/**
		 * Get My Songs request URL.
		 * @return My Songs request URL 
		 */
		public function get mySongsRequestURL():String {
			return _mySongsRequestURL;
		}

		
		
		/**
		 * Get search request URL.
		 * @return Search request URL
		 */
		public function get searchRequestURL():String {
			return _searchRequestURL;
		}
		
		
		
		/**
		 * Get instruments request URL.
		 * @return Instruments request URL
		 */
		public function get instrumentsRequestURL():String {
			return _instrumentsRequestURL;
		}

		
		
		/**
		 * Get user request URL.
		 * @return User request URL
		 */
		public function get userRequestURL():String {
			return _userRequestURL;
		}

		
		
		/**
		 * Get song fetch request URL.
		 * @return Song fetch request URL
		 */
		public function get songFetchRequestURL():String {
			return _songFetchRequestURL;
		}
		
		
		
		/**
		 * Get song siblings request URL.
		 * @return Song siblings request URL
		 */
		public function get songSiblingsRequestURL():String {
			return _songSiblingsRequestURL;
		}
		
		
		
		/**
		 * Get song edit request URL.
		 * @return Song edit request URL
		 */
		public function get songEditRequestURL():String {
			return _songEditRequestURL;
		}
		
		
		
		/**
		 * Get song export request URL.
		 * @return Song export request URL
		 */
		public function get songExportRequestURL():String {
			return _songExportRequestURL;
		}
		
		
		
		/**
		 * Get song update request URL.
		 * @return Song update request URL
		 */
		public function get songUpdateRequestURL():String {
			return _songUpdateRequestURL;
		}
		
		
		
		/**
		 * Get song load request URL.
		 * @return Song load request URL
		 */
		public function get songLoadRequestURL():String {
			return _songLoadRequestURL;
		}
		
		
		
		/**
		 * Get song unload request URL.
		 * @return Song unload request URL
		 */
		public function get songUnloadRequestURL():String {
			return _songUnloadRequestURL;
		}
		
		
		
		/**
		 * Get track fetch request URL.
		 * @return Track fetch request URL
		 */
		public function get trackFetchRequestURL():String {
			return _trackFetchRequestURL;
		}
		
		
		
		/**
		 * Get track siblings request URL.
		 * @return Track siblings request URL
		 */
		public function get trackSiblingsRequestURL():String {
			return _trackSiblingsRequestURL;
		}
		
		
		
		/**
		 * Get track create request URL.
		 * @return Track create request URL
		 */
		public function get trackCreateRequestURL():String {
			return _trackCreateRequestURL;
		}
		
		
		
		/**
		 * Get track download request URL.
		 * @return Track download request URL
		 */
		public function get trackDownloadRequestURL():String {
			return _trackDownloadRequestURL;
		}
		
		
		
		/**
		 * Get media export request URL.
		 * @return Media export request URL
		 */
		public function get mediaExportRequestURL():String {
			return _mediaExportRequestURL;
		}
		
		
		
		/**
		 * Get media encode request URL.
		 * @return Media encode request URL
		 */
		public function get mediaEncodeRequestURL():String {
			return _mediaEncodeRequestURL;
		}
		
		
		
		/**
		 * Get media upload request URL.
		 * @return Media upload request URL
		 */
		public function get mediaUploadRequestURL():String {
			return _mediaUploadRequestURL;
		}
		
		
		
		/**
		 * Get worker expor request URL.
		 * @return Worker export request URL
		 */
		public function get workerExportRequestURL():String {
			return _workerExportRequestURL;
		}
		
		
		
		/**
		 * Get worker encode request URL.
		 * @return Worker encode request URL
		 */
		public function get workerEncodeRequestURL():String {
			return _workerEncodeRequestURL;
		}
		
		
		
		/**
		 * Get worker upload request URL.
		 * @return Worker upload request URL
		 */
		public function get workerUploadRequestURL():String {
			return _workerUploadRequestURL;
		}
		
		
		
		/**
		 * Get sync.
		 * @return Sync
		 */
		public function get sync():Number {
			return _sync;
		}
	}
}
