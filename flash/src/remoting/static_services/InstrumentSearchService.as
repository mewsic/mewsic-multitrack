package remoting.static_services {
	import com.gskinner.utils.StringUtils;	
	
	import org.osflash.thunderbolt.Logger;
	
	import de.popforge.utils.sprintf;
	
	import config.Settings;
	
	import remoting.IService;
	import remoting.data.InstrumentData;
	import remoting.events.RemotingEvent;
	import remoting.ServiceCommon;	

	
	
	/**
	 * Instrument search service.
	 * 
	 * @author Vaclav Vancura (http://vaclav.vancura.org)
	 * @since Nov 2, 2008
	 */
	public class InstrumentSearchService extends ServiceCommon implements IService {

		
		
		private var _instrumentList:Array;

		
		
		/**
		 * Constructor.
		 */
		public function InstrumentSearchService() {
			super();
			$serviceID = 'instrumentSearch';
			$requestID = $serviceID + '.request';
			$responseHandler = _onResponse;
			$errorHandler = _onError;
		}

		
		
		/**
		 * Dump instruments search.
		 * @return Instruments search dump
		 */
		override public function toString():String {
			var o:String = '';
			var sidx:uint = 0;
			
			for each(var sd:InstrumentData in _instrumentList) {
				sidx++;
				o += sprintf('  *  Instrument search item data #%u: %s\n', sidx, sd);
			}
			o += '\n';
			
			return(o);
		}

		
		
		/**
		 * Get instrument search list.
		 * @return Instrument search list
		 */
		public function get instrumentList():Array {
			return _instrumentList;
		}

		
		
		/**
		 * Get instrument search name list.
		 * @return Instrument search name list
		 */
		public function get instrumentNameList():Array {
			var o:Array = new Array();
			for each(var i:InstrumentData in _instrumentList) {
				o.push(i.instrumentName);
			}
			return o;
		}

		
		
		/**
		 * Get instrument data by instrument ID.
		 * @param id Instrument ID
		 * @return Instrument data
		 */
		public function byID(id:uint):InstrumentData {
			for each(var gd:InstrumentData in _instrumentList) {
				if(gd.instrumentID == id) return gd;
			}
			throw new Error(sprintf('Service %s: Unknown instrument.', $serviceID));
		}
		
		
		
		/**
		 * Get instrument data by instrument name.
		 * @param id Instrument name
		 * @return Instrument data
		 */
		public function byName(name:String):InstrumentData {
			var n:String = StringUtils.removeExtraWhitespace(name);
			for each(var gd:InstrumentData in _instrumentList) {
				if(gd.instrumentName == n) return gd;
			}
			throw new Error(sprintf('Service %s: Unknown instrument.', $serviceID));
		}
		
		
		
		/**
		 * Response event handler.
		 */
		private function _onResponse():void {
			try {
				_instrumentList = new Array();
				
				for each(var mxml:XML in $responseData.instrument) {
					var id:InstrumentData = new InstrumentData();
					
					id.instrumentID = mxml.id;
					id.instrumentName = mxml.description;
					id.instrumentIconURL = mxml.icon;
					
					_instrumentList.push(id);
				}
				
				if(Settings.isServiceDumpEnabled) Logger.debug(sprintf('Service %s: Instrument dump:\n%s', $serviceID, this.toString()));
				dispatchEvent(new RemotingEvent(RemotingEvent.REQUEST_DONE));
			}
			catch(err:Error) {
				dispatchEvent(new RemotingEvent(RemotingEvent.REQUEST_FAILED, false, false, sprintf('Service %s: Could not parse instrument data.\n%s', $serviceID, err.message)));
			}
		}

		
		
		/**
		 * Error event handler.
		 */
		private function _onError():void {
			dispatchEvent(new RemotingEvent(RemotingEvent.REQUEST_FAILED, false, false, sprintf('Service %s: Could not load instrument data.', $serviceID)));
		}
	}
}
