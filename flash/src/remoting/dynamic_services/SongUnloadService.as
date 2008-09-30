package remoting.dynamic_services {
	import org.osflash.thunderbolt.Logger;
	
	import com.gskinner.utils.Rnd;
	
	import de.popforge.utils.sprintf;
	
	import config.Settings;
	
	import remoting.IService;
	import remoting.ServiceCommon;
	import remoting.data.SongData;
	import remoting.events.RemotingEvent;	

	
	
	/**
	 * Song unload service.
	 * 
	 * @author Vaclav Vancura (http://vaclav.vancura.org)
	 * @since Aug 06, 2008
	 */
	public class SongUnloadService extends ServiceCommon implements IService {

		
		
		private var _songData:SongData;

		
		
		/**
		 * Constructor.
		 */
		public function SongUnloadService() {
			super();
			
			$serviceID = sprintf('songUnload.%u.%u', uint(new Date()), Rnd.integer(1000, 9999));
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
			
			var query:String = '';
			var rp:RegExp = /{:song_id}/g;
			
			if(params.songID != undefined) params.url = url.replace(rp, escape(params.songID));
			else throw new Error(sprintf('Service %s: No songID specified.', $serviceID));
			
			if(params.trackID == undefined) throw new Error(sprintf('Service %s: No trackID specified.', $serviceID));
			
			query += '_method=put&track_id=' + params.trackID;
			
			params.method = METHOD_POST;
			params.suffix = query;
			
			super.request(params);
		}

		
		
		/**
		 * Dump song unload results.
		 * @return Song unload dump
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
				
				if(Settings.isServiceDumpEnabled) Logger.debug(sprintf('Service %s: Song unload info dump:\n%s', $serviceID, _songData.toString()));
				
				dispatchEvent(new RemotingEvent(RemotingEvent.REQUEST_DONE));
			}
			catch(err:Error) {
				dispatchEvent(new RemotingEvent(RemotingEvent.REQUEST_FAILED, false, false, sprintf('Service %s: Search failed.\n%s', $serviceID, err.message)));
			}
		}

		
		
		/**
		 * Error event handler.
		 */
		private function _onError():void {
			dispatchEvent(new RemotingEvent(RemotingEvent.REQUEST_FAILED, false, false, sprintf('Service %s: Search failed.', $serviceID)));
		}
	}
}
