package remoting.dynamic_services {
	import org.osflash.thunderbolt.Logger;

	import com.gskinner.utils.Rnd;

	import de.popforge.utils.sprintf;

	import config.Settings;

	import remoting.IService;
	import remoting.ServiceCommon;
	import remoting.data.WorkerStatusData;
	import remoting.events.RemotingEvent;
	import remoting.events.UserEvent;
	import remoting.events.WorkerEvent;	

	
	
	/**
	 * Encode worker service.
	 * 
	 * @author Vaclav Vancura (http://vaclav.vancura.org)
	 * @since Jul 22, 2008
	 */
	public class WorkerEncodeService extends ServiceCommon implements IService {

		
		
		private var _statusData:WorkerStatusData;

		
		
		/**
		 * Constructor.
		 */
		public function WorkerEncodeService() {
			super();
			
			$serviceID = sprintf('encodeWorker.%u.%u', uint(new Date()), Rnd.integer(1000, 9999));
			$requestID = $serviceID + '.request';
			$responseHandler = _onResponse;
			$errorHandler = _onError;
		}

		
		
		/**
		 * Request service.
		 * Parameters could contain:
		 * params.key - worker key
		 * @param params Parameters
		 */
		override public function request(params:Object = null):void {
			if(params == null) params = new Object();
			
			var rp:RegExp = /{:key}/g;
			
			if(params.key != undefined) params.url = url.replace(rp, escape(params.key));
			else throw new Error(sprintf('Service %s: No key specified.', $serviceID));
			
			super.request(params);
		}

		
		
		/**
		 * Response event handler.
		 */
		private function _onResponse():void {
			try {
				_statusData = new WorkerStatusData();
				_statusData.length = $responseData.length;
				_statusData.output = $responseData.output;
				_statusData.status = $responseData.status;
				_statusData.key = $responseData.@key;
				
				if(Settings.isServiceDumpEnabled) Logger.debug(sprintf('Service %s: Encode worker dump:\n%s', $serviceID, _statusData.toString()));
				
				dispatchEvent(new RemotingEvent(RemotingEvent.REQUEST_DONE));
				dispatchEvent(new WorkerEvent(UserEvent.REQUEST_DONE, false, false, _statusData));
			}
			catch(err:Error) {
				dispatchEvent(new RemotingEvent(RemotingEvent.REQUEST_FAILED, false, false, sprintf('Service %s: Could not parse encode worker data.\n%s', $serviceID, err.message)));
			}
		}

		
		
		/**
		 * Error event handler.
		 */
		private function _onError():void {
			dispatchEvent(new RemotingEvent(RemotingEvent.REQUEST_FAILED, false, false, sprintf('Service %s: Could not load encode worker data.', $serviceID)));
		}
	}
}
