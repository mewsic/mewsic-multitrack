package remoting.static_services {
	import org.osflash.thunderbolt.Logger;
	
	import com.gskinner.utils.Rnd;
	
	import de.popforge.utils.sprintf;
	
	import config.Settings;
	
	import remoting.IService;
	import remoting.ServiceCommon;
	import remoting.data.SongData;
	import remoting.events.RemotingEvent;	

	
	
	/**
	 * Core song fetch service.
	 * 
	 * @author Vaclav Vancura (http://vaclav.vancura.org)
	 * @since Jul 16, 2008
	 */
	public class CoreSongService extends ServiceCommon implements IService {

		
		
		private var _isRefreshing:Boolean;
		
		
		
		/**
		 * Constructor.
		 */
		public function CoreSongService() {
			super();
			$serviceID = sprintf('coreSongFetch.%u.%u', uint(new Date()), Rnd.integer(1000, 9999));
			$requestID = $serviceID + '.request.';
			$responseHandler = _onResponse;
			$errorHandler = _onError;
		}

		
		
		/**
		 * Request service.
		 * Parameters could contain:
		 * params.songID - requested song ID
		 * @param params Parameters
		 */
		override public function request(params:Object = null):void {
			if(params == null) params = new Object();
			
			var rp:RegExp = /{:song_id}/g;
			
			if(params.songID != undefined) params.url = url.replace(rp, params.songID.toString());
			else throw new Error(sprintf('Service %s: No songID specified.', $serviceID));
			
			super.request(params);
		}
		
		
		
		public function refresh():void {
			_isRefreshing = true;
			request({songID:$coreSongData.songID});
		}
		
		
		
		/**
		 * Response event handler.
		 */
		private function _onResponse():void {
			try {
				if(_isRefreshing) {
					if(Settings.isServiceDumpEnabled) Logger.debug(sprintf('Service %s: Song refresh', $serviceID));
					
					var sd:SongData = $xml2SongData($responseData);
					$coreSongData.songAuthor = sd.songAuthor;
					$coreSongData.songDescription = sd.songDescription;
					$coreSongData.songGenreID = sd.songGenreID;
					$coreSongData.songKey = sd.songKey;
					$coreSongData.songTitle = sd.songTitle;
					
					dispatchEvent(new RemotingEvent(RemotingEvent.REFRESH_DONE));
				}
				else {
					$coreSongData = $xml2SongData($responseData);
					$coreSongData.songTracks = new Array();
					
					if(Settings.isServiceDumpEnabled) Logger.debug(sprintf('Service %s: Song fetch song info dump:\n%s', $serviceID, $coreSongData.toString()));
					
					dispatchEvent(new RemotingEvent(RemotingEvent.REQUEST_DONE));
				}
			}
			catch(err:Error) {
				dispatchEvent(new RemotingEvent(RemotingEvent.REQUEST_FAILED, false, false, sprintf('Service %s: Fetch failed.\n%s', $serviceID, err.message)));
			}
		}

		
		
		/**
		 * Error event handler.
		 */
		private function _onError():void {
			dispatchEvent(new RemotingEvent(RemotingEvent.REQUEST_FAILED, false, false, sprintf('Service %s: Fetch failed.', $serviceID)));
		}
	}
}
