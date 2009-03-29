package remoting.dynamic_services {
	import org.osflash.thunderbolt.Logger;

	import com.gskinner.utils.Rnd;

	import de.popforge.utils.sprintf;

	import config.Settings;

	import remoting.IService;
	import remoting.ServiceCommon;
	import remoting.data.TrackData;
	import remoting.events.RemotingEvent;
	import remoting.events.TrackCreateEvent;	

	
	
	/**
	 * Create track service.
	 * 
	 * @author Vaclav Vancura (http://vaclav.vancura.org)
	 * @since Jul 23, 2008
	 */
	public class TrackCreateService extends ServiceCommon implements IService {

		
		
		private var _trackData:TrackData;

		
		
		/**
		 * Constructor.
		 */
		public function TrackCreateService() {
			super();
			
			$serviceID = sprintf('trackCreate.%u.%u', uint(new Date()), Rnd.integer(1000, 9999));
			$requestID = $serviceID + '.request';
			$responseHandler = _onResponse;
			$errorHandler = _onError;
		}

		
		
		/**
		 * Request service.
		 * Using POST method.
		 * Parameters could contain:
		 *   params.title - Track title
		 *   params.filename - Track filename
		 *   params.instrumentID - Instrument ID
		 *   params.milliseconds - Track milliseconds
		 * 
		 * @param params Query Parameters
		 */
		override public function request(params:Object = null):void {
			if(params == null) params = new Object();
			
			var query:String = 'flashStinks=true&';
			
			if(params.title != undefined) query += 'track[title]=' + escape(params.title);
			if(params.filename != undefined) query += '&track[filename]=' + escape(params.filename);
			if(params.instrumentID != undefined) query += '&track[instrument_id]=' + escape(params.instrumentID);
			if(params.milliseconds != undefined) query += '&track[seconds]=' + (params.milliseconds / 1000);
			
			super.request({suffix:query, method:METHOD_POST});
		}

		
		
		/**
		 * Dump create track results.
		 * @return Create track dump
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
				
				if(Settings.isServiceDumpEnabled) Logger.debug(sprintf('Service %s: Track create info dump:\n%s', $serviceID, _trackData.toString()));
				
				dispatchEvent(new RemotingEvent(RemotingEvent.REQUEST_DONE));
				dispatchEvent(new TrackCreateEvent(TrackCreateEvent.REQUEST_DONE, false, false, _trackData));
			}
			catch(err:Error) {
				dispatchEvent(new RemotingEvent(RemotingEvent.REQUEST_FAILED, false, false, sprintf('Service %s: Track create failed.\n%s', $serviceID, err.message)));
			}
		}

		
		
		/**
		 * Error event handler.
		 */
		private function _onError():void {
			dispatchEvent(new RemotingEvent(RemotingEvent.REQUEST_FAILED, false, false, sprintf('Service %s: Track create failed.', $serviceID)));
		}
	}
}
