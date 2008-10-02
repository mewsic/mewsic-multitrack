package remoting.static_services {
	import config.Settings;
	
	import remoting.IService;
	import remoting.ServiceCommon;
	import remoting.events.RemotingEvent;
	
	import de.popforge.utils.sprintf;
	
	import org.osflash.thunderbolt.Logger;	

	
	
	/**
	 * Countries search service.
	 * 
	 * @author Vaclav Vancura (http://vaclav.vancura.org)
	 * @since Nov 2, 2008
	 */
	public class CountriesSearchService extends ServiceCommon implements IService {

		
		
		private var _countriesList:Array;

		
		
		/**
		 * Constructor.
		 */
		public function CountriesSearchService() {
			super();
			$serviceID = 'countriesSearch';
			$requestID = $serviceID + '.request';
			$responseHandler = _onResponse;
			$errorHandler = _onError;
		}

		
		
		/**
		 * Dump countries search.
		 * @return Countries search dump
		 */		
		override public function toString():String {
			var o:String = '';
			var sidx:uint = 0;
			
			for each(var sd:String in _countriesList) {
				sidx++;
				o += sprintf('  *  Country item #%u: %s\n', sidx, sd);
			}
			o += '\n';
			
			return(o);
		}

		
		
		/**
		 * Get countries search list.
		 * @return Countries search list
		 */
		public function get countriesList():Array {
			return _countriesList;
		}

		
		
		/**
		 * Response event handler.
		 */
		private function _onResponse():void {
			try {
				_countriesList = new Array();
				
				for each(var mxml:XML in $responseData.country) {
					_countriesList.push(mxml);
				}
				
				if(Settings.isServiceDumpEnabled) Logger.debug(sprintf('Service %s: Countries dump:\n%s', $serviceID, this.toString()));
				dispatchEvent(new RemotingEvent(RemotingEvent.REQUEST_DONE));
			}
			catch(err:Error) {
				dispatchEvent(new RemotingEvent(RemotingEvent.REQUEST_FAILED, false, false, sprintf('Service %s: Could not parse countries data.\n%s', $serviceID, err.message)));
			}
		}

		
		
		/**
		 * Error event handler.
		 */
		private function _onError():void {
			dispatchEvent(new RemotingEvent(RemotingEvent.REQUEST_FAILED, false, false, sprintf('Service %s: Could not load countries data.', $serviceID)));
		}
	}
}
