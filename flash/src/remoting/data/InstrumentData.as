package remoting.data {
	import de.popforge.utils.sprintf;

	
	
	/**
	 * Instrument data.
	 * 
	 * @author Vaclav Vancura (http://vaclav.vancura.org)
	 * @since Jul 4, 2008
	 */
	public class InstrumentData {

		
		
		public var instrumentID:uint;
		public var instrumentName:String;
		public var instrumentIconURL:String;

		
		
		/**
		 * Get instrument dump.
		 * @return Instruments dump
		 */
		public function toString():String {
			return(sprintf('instrumentID=%u, instrumentName=%s, instrumentIconURL=%s', instrumentID, instrumentName, instrumentIconURL));
		}
	}
}
