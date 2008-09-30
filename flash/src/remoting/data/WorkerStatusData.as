package remoting.data {
	import de.popforge.utils.sprintf;	

	
	
	/**
	 * Worker status data.
	 * 
	 * @author Vaclav Vancura (http://vaclav.vancura.org)
	 * @since Jul 22, 2008
	 */
	public class WorkerStatusData {

		
		
		public static const STATUS_IDLE:String = 'idle';
		public static const STATUS_RUNNING:String = 'running';
		public static const STATUS_FINISHED:String = 'finished';
		public static const STATUS_ERROR:String = 'error';
		public var status:String;
		public var output:String;
		public var length:Number;
		public var key:String;

		
		
		/**
		 * Get worker status dump.
		 * @return Genre dump
		 */
		public function toString():String {
			return(sprintf('key=%s, status=%s, output=%s, length=%f', key, status, output, length));
		}
	}
}
