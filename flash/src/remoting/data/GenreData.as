package remoting.data {
	import de.popforge.utils.sprintf;

	
	
	/**
	 * Genre data.
	 * 
	 * @author Vaclav Vancura (http://vaclav.vancura.org)
	 * @since Jul 4, 2008
	 */
	public class GenreData {

		
		
		public var genreID:uint;
		public var genreName:String;

		
		
		/**
		 * Get genre dump.
		 * @return Genre dump
		 */
		public function toString():String {
			return(sprintf('genreID=%u, genreName=%s', genreID, genreName));
		}
	}
}
