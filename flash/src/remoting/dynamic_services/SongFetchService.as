package remoting.dynamic_services {
	import com.gskinner.utils.Rnd;
	
	import config.Settings;
	
	import de.popforge.utils.sprintf;
	
	import org.osflash.thunderbolt.Logger;
	
	import remoting.IService;
	import remoting.ServiceCommon;
	import remoting.data.SongData;
	import remoting.events.RemotingEvent;
	import remoting.events.SongFetchEvent;	

	
	
	/**
	 * Song fetch service.
	 * 
	 * @author Vaclav Vancura (http://vaclav.vancura.org)
	 * @since Jul 15, 2008
	 */
	public class SongFetchService extends ServiceCommon implements IService {

		
		
		private var _songData:SongData;
		private var _songID:uint;

		
		
		/**
		 * Constructor.
		 */
		public function SongFetchService() {
			super();
			
			$serviceID = sprintf('songFetch.%u.%u', uint(new Date()), Rnd.integer(1000, 9999));
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
			
			if(params.songID != undefined) params.url = url.replace(/{:song_id}/g, escape(params.songID));
			else throw new Error(sprintf('Service %s: No songID specified.', $serviceID));
			
			_songID = params.songID;
			super.request(params);
		}

		
		
		/**
		 * Dump song fetch results.
		 * @return Song fetch dump
		 */
		override public function toString():String {
			return _songData.toString();
		}

		
		
		/**
		 * Response event handler.
		 */
		private function _onResponse():void {
			try {
				_songData = $xml2SongData($responseData);
				
				if(Settings.isServiceDumpEnabled)
					Logger.debug(sprintf('Service %s: Song fetch song info dump:\n%s', $serviceID, _songData.toString()));
				
				dispatchEvent(new RemotingEvent(RemotingEvent.REQUEST_DONE));
				dispatchEvent(new SongFetchEvent(SongFetchEvent.REQUEST_DONE, false, false, {songData:_songData}));
			}
			catch(err:Error) {
				dispatchEvent(new SongFetchEvent(SongFetchEvent.REQUEST_FAILED, false, false, {songID:_songID}));
			}
		}

		
		
		/**
		 * Error event handler.
		 */
		private function _onError():void {
			dispatchEvent(new SongFetchEvent(SongFetchEvent.REQUEST_FAILED, false, false, {songID:_songID}));
		}
	}
}
