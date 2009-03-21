package remoting.dynamic_services {
	import org.osflash.thunderbolt.Logger;

	import com.gskinner.utils.Rnd;

	import de.popforge.utils.sprintf;

	import config.Settings;

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
			
			var rp:RegExp = /{:song_id}/g;
			
			if(params.songID != undefined) params.url = url.replace(rp, escape(params.songID));
			else throw new Error(sprintf('Service %s: No songID specified.', $serviceID));
			
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
				
				if(Settings.isServiceDumpEnabled) Logger.debug(sprintf('Service %s: Song fetch song info dump:\n%s', $serviceID, _songData.toString()));
				
				dispatchEvent(new RemotingEvent(RemotingEvent.REQUEST_DONE));
				dispatchEvent(new SongFetchEvent(SongFetchEvent.REQUEST_DONE, false, false, _songData));
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
