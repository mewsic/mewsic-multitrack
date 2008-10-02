package remoting.static_services {
	import org.osflash.thunderbolt.Logger;
	
	import com.gskinner.utils.StringUtils;
	
	import de.popforge.utils.sprintf;
	
	import config.Settings;
	
	import remoting.IService;
	import remoting.ServiceCommon;
	import remoting.data.GenreData;
	import remoting.events.RemotingEvent;	

	
	
	/**
	 * Genres search service.
	 * 
	 * @author Vaclav Vancura (http://vaclav.vancura.org)
	 * @since Nov 2, 2008
	 */
	public class GenresSearchService extends ServiceCommon implements IService {

		
		
		private var _genresList:Array;

		
		
		/**
		 * Constructor.
		 */
		public function GenresSearchService() {
			super();
			$serviceID = 'genresSearch';
			$requestID = $serviceID + '.request';
			$responseHandler = _onResponse;
			$errorHandler = _onError;
		}

		
		
		/**
		 * Dump genres search.
		 * @return Genres search dump
		 */		
		override public function toString():String {
			var o:String = '';
			var sidx:uint = 0;
			
			for each(var sd:GenreData in _genresList) {
				sidx++;
				o += sprintf('  *  Genre item #%u: %s\n', sidx, sd);
			}
			o += '\n';
			
			return(o);
		}

		
		
		/**
		 * Get genres search list.
		 * @return Genres search list
		 */
		public function get genresList():Array {
			return _genresList;
		}

		
		
		/**
		 * Get genres search name list.
		 * @return Genres search name list
		 */
		public function get genresNameList():Array {
			var o:Array = new Array();
			for each(var i:GenreData in _genresList) {
				o.push(i.genreName);
			}
			return o;
		}

		
		
		/**
		 * Get genre data by genre ID.
		 * @param id Genre ID
		 * @return Genre data
		 */
		public function byID(id:uint):GenreData {
			for each(var gd:GenreData in _genresList) {
				if(gd.genreID == id) return gd;
			}
			throw new Error(sprintf('Service %s: Unknown genre.', $serviceID));
		}

		
		
		/**
		 * Get genre data by genre name.
		 * @param id Genre name
		 * @return Genre data
		 */
		public function byName(name:String):GenreData {
			var n:String = StringUtils.removeExtraWhitespace(name);
			for each(var gd:GenreData in _genresList) {
				if(gd.genreName == n) return gd;
			}
			throw new Error(sprintf('Service %s: Unknown genre.', $serviceID));
		}

		
		
		/**
		 * Response event handler.
		 */
		private function _onResponse():void {
			try {
				_genresList = new Array();
				
				for each(var mxml:XML in $responseData.genre) {
					var gd:GenreData = new GenreData();
					gd.genreID = mxml.id;
					gd.genreName = mxml.name;
					_genresList.push(gd);
				}
				
				if(Settings.isServiceDumpEnabled) Logger.debug(sprintf('Service %s: Genres dump:\n%s', $serviceID, this.toString()));
				dispatchEvent(new RemotingEvent(RemotingEvent.REQUEST_DONE));
			}
			catch(err:Error) {
				dispatchEvent(new RemotingEvent(RemotingEvent.REQUEST_FAILED, false, false, sprintf('Service %s: Could not parse genres data.\n%s', $serviceID, err.message)));
			}
		}

		
		
		/**
		 * Error event handler.
		 */
		private function _onError():void {
			dispatchEvent(new RemotingEvent(RemotingEvent.REQUEST_FAILED, false, false, sprintf('Service %s: Could not load genres data.', $serviceID)));
		}
	}
}
