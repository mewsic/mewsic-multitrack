package remoting.dynamic_services {
	import org.osflash.thunderbolt.Logger;

	import com.gskinner.utils.Rnd;

	import de.popforge.utils.sprintf;

	import config.Settings;

	import remoting.IService;
	import remoting.ServiceCommon;
	import remoting.data.TrackData;
	import remoting.events.RemotingEvent;
	import remoting.events.TrackFetchEvent;	

	
	
	/**
	 * Track fetch service.
	 * 
	 * @author Vaclav Vancura (http://vaclav.vancura.org)
	 * @since Jul 15, 2008
	 */
	public class TrackFetchService extends ServiceCommon implements IService {

		
		
		private var _trackData:TrackData;

		
		
		/**
		 * Constructor.
		 */
		public function TrackFetchService() {
			super();
			
			$serviceID = sprintf('trackFetch.%u.%u', uint(new Date()), Rnd.integer(1000, 9999));
			$requestID = $serviceID + '.request.';
			$responseHandler = _onResponse;
			$errorHandler = _onError;
		}

		
		
		/**
		 * Request service.
		 * Parameters could contain:
		 * params.trackID - requested track ID
		 * @param params Parameters
		 */
		override public function request(params:Object = null):void {
			if(params == null) params = new Object();
			
			var rp:RegExp = /{:track_id}/g;
			
			if(params.trackID != undefined) params.url = url.replace(rp, escape(params.trackID));
			else throw new Error(sprintf('Service %s: No trackID specified.', $serviceID));
			
			super.request(params);
		}

		
		
		/**
		 * Dump track fetch results.
		 * @return Track fetch dump
		 */
		override public function toString():String {
			return _trackData.toString();
		}

		
		
		/**
		 * Response event handler.
		 */
		private function _onResponse():void {
			try {
				_trackData = $xml2TrackData($responseData);
				
				if(Settings.isServiceDumpEnabled) Logger.debug(sprintf('Service %s: Track fetch info dump:\n%s', $serviceID, _trackData.toString()));
				
				dispatchEvent(new RemotingEvent(RemotingEvent.REQUEST_DONE));
				dispatchEvent(new TrackFetchEvent(TrackFetchEvent.REQUEST_DONE, false, false, _trackData));
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
