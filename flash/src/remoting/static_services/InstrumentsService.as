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
	 * Instruments service.
	 * 
	 * @author Vaclav Vancura (http://vaclav.vancura.org)
	 * @since Jul 4, 2008
	 */
	public class InstrumentsService extends ServiceCommon implements IService {

		
		
		private var _instrumentsList:Array;

		
		
		/**
		 * Constructor.
		 */
		public function InstrumentsService() {
			super();
			$serviceID = 'instruments';
			$requestID = $serviceID + '.request';
			$responseHandler = _onResponse;
			$errorHandler = _onError;
		}

		
		
		/**
		 * Dump instruments.
		 * @return Instruments dump
		 */
		override public function toString():String {
			var o:String = '';
			var sidx:uint = 0;
			
			for each(var sd:InstrumentData in _instrumentsList) {
				sidx++;
				o += sprintf('  *  Instrument item data #%u: %s\n', sidx, sd);
			}
			o += '\n';
			
			return(o);
		}

		
		
		/**
		 * Get instruments list.
		 * @return Instruments list
		 */
		public function get instrumentsList():Array {
			return _instrumentsList;
		}

		
		
		/**
		 * Get instruments name list.
		 * @return Instruments name list
		 */
		public function get instrumentsNameList():Array {
			var o:Array = new Array();
			for each(var i:InstrumentData in _instrumentsList) {
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
			for each(var gd:InstrumentData in _instrumentsList) {
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
			for each(var gd:InstrumentData in _instrumentsList) {
				if(gd.instrumentName == n) return gd;
			}
			throw new Error(sprintf('Service %s: Unknown instrument.', $serviceID));
		}
		
		
		
		/**
		 * Response event handler.
		 */
		private function _onResponse():void {
			try {
				_instrumentsList = new Array();
				
				for each(var mxml:XML in $responseData.instrument) {
					var id:InstrumentData = new InstrumentData();
					
					id.instrumentID = mxml.id;
					id.instrumentName = mxml.description;
					id.instrumentIconURL = mxml.icon;
					
					_instrumentsList.push(id);
				}
				
				if(Settings.isServiceDumpEnabled) Logger.debug(sprintf('Service %s: Instruments dump:\n%s', $serviceID, this.toString()));
				dispatchEvent(new RemotingEvent(RemotingEvent.REQUEST_DONE));
			}
			catch(err:Error) {
				dispatchEvent(new RemotingEvent(RemotingEvent.REQUEST_FAILED, false, false, sprintf('Service %s: Could not parse instruments data.\n%s', $serviceID, err.message)));
			}
		}

		
		
		/**
		 * Error event handler.
		 */
		private function _onError():void {
			dispatchEvent(new RemotingEvent(RemotingEvent.REQUEST_FAILED, false, false, sprintf('Service %s: Could not load instruments data.', $serviceID)));
		}
	}
}
