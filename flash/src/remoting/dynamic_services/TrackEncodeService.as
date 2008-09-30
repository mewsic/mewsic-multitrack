package remoting.dynamic_services {
	import org.osflash.thunderbolt.Logger;
	
	import com.gskinner.utils.Rnd;
	
	import de.popforge.utils.sprintf;
	
	import config.Settings;
	
	import remoting.IService;
	import remoting.ServiceCommon;
	import remoting.events.RemotingEvent;
	import remoting.events.TrackEncodeEvent;	

	
	
	/**
	 * Encode track service.
	 * 
	 * @author Vaclav Vancura (http://vaclav.vancura.org)
	 * @since Jul 28, 2008
	 */
	public class TrackEncodeService extends ServiceCommon implements IService {

		
		
		private var _key:String;

		
		
		/**
		 * Constructor.
		 */
		public function TrackEncodeService() {
			super();
			
			$serviceID = sprintf('trackEncode.%u.%u', uint(new Date()), Rnd.integer(1000, 9999));
			$requestID = $serviceID + '.request';
			$responseHandler = _onResponse;
			$errorHandler = _onError;
		}

		
		
		/**
		 * Request service.
		 * Using POST method.
		 * Parameters could contain:
		 * params.filename - Track filename
		 * @param params Parameters
		 */
		override public function request(params:Object = null):void {
			if(params == null) params = new Object();
			
			var query:String = '';
			
			if(params.filename != undefined) query += 'filename=' + escape(params.filename);
			else throw new Error(sprintf('Service %s: Filename is not defined.', $serviceID));
			
			super.request({suffix:query, method:METHOD_POST});
		}

		
		
		/**
		 * Dump create track results.
		 * @return Create track dump
		 */
		override public function toString():String {
			return sprintf('Song save key=%s', _key);
		}

		
		
		/**
		 * Response event handler.
		 */
		private function _onResponse():void {
			try {
				_key = $responseData.@key;
				
				if(Settings.isServiceDumpEnabled) Logger.debug(sprintf('Service %s: Song save service dump:\n%s', $serviceID, this.toString()));
				
				dispatchEvent(new RemotingEvent(RemotingEvent.REQUEST_DONE));
				dispatchEvent(new TrackEncodeEvent(TrackEncodeEvent.REQUEST_DONE, false, false, _key));
			}
			catch(err:Error) {
				dispatchEvent(new RemotingEvent(RemotingEvent.REQUEST_FAILED, false, false, sprintf('Service %s: Track encode failed.\n%s', $serviceID, err.message)));
			}
		}

		
		
		/**
		 * Error event handler.
		 */
		private function _onError():void {
			dispatchEvent(new RemotingEvent(RemotingEvent.REQUEST_FAILED, false, false, sprintf('Service %s: Track encode failed.', $serviceID)));
		}
	}
}
