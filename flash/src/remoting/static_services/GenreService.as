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
	 * Genre service.
	 * 
	 * @author Vaclav Vancura (http://vaclav.vancura.org)
	 * @since Jul 4, 2008
	 */
	public class GenreService extends ServiceCommon implements IService {

		
		
		private var _genreList:Array;

		
		
		/**
		 * Constructor.
		 */
		public function GenreService() {
			super();
			$serviceID = 'genre';
			$requestID = $serviceID + '.request';
			$responseHandler = _onResponse;
			$errorHandler = _onError;
		}

		
		
		/**
		 * Dump genres.
		 * @return Genres dump
		 */		
		override public function toString():String {
			var o:String = '';
			var sidx:uint = 0;
			
			for each(var sd:GenreData in _genreList) {
				sidx++;
				o += sprintf('  *  Genre item #%u: %s\n', sidx, sd);
			}
			o += '\n';
			
			return(o);
		}

		
		
		/**
		 * Get genre list.
		 * @return Genre list
		 */
		public function get genreList():Array {
			return _genreList;
		}

		
		
		/**
		 * Get genre name list.
		 * @return Genre name list
		 */
		public function get genreNameList():Array {
			var o:Array = new Array();
			for each(var i:GenreData in _genreList) {
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
			for each(var gd:GenreData in _genreList) {
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
			for each(var gd:GenreData in _genreList) {
				if(gd.genreName == n) return gd;
			}
			throw new Error(sprintf('Service %s: Unknown genre.', $serviceID));
		}

		
		
		/**
		 * Response event handler.
		 */
		private function _onResponse():void {
			try {
				_genreList = new Array();
				
				for each(var mxml:XML in $responseData.genre) {
					var gd:GenreData = new GenreData();
					gd.genreID = mxml.id;
					gd.genreName = mxml.name;
					_genreList.push(gd);
				}
				
				if(Settings.isServiceDumpEnabled) Logger.debug(sprintf('Service %s: Genre dump:\n%s', $serviceID, this.toString()));
				dispatchEvent(new RemotingEvent(RemotingEvent.REQUEST_DONE));
			}
			catch(err:Error) {
				dispatchEvent(new RemotingEvent(RemotingEvent.REQUEST_FAILED, false, false, sprintf('Service %s: Could not parse genre data.\n%s', $serviceID, err.message)));
			}
		}

		
		
		/**
		 * Error event handler.
		 */
		private function _onError():void {
			dispatchEvent(new RemotingEvent(RemotingEvent.REQUEST_FAILED, false, false, sprintf('Service %s: Could not load genre data.', $serviceID)));
		}
	}
}
