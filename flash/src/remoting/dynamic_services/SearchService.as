package remoting.dynamic_services {
	import org.osflash.thunderbolt.Logger;
	
	import com.gskinner.utils.Rnd;
	
	import de.popforge.utils.sprintf;
	
	import config.Settings;
	
	import remoting.IService;
	import remoting.ServiceCommon;
	import remoting.data.SongData;
	import remoting.data.TrackData;
	import remoting.events.RemotingEvent;
	import remoting.events.SearchEvent;	

	
	
	/**
	 * Search service.
	 * 
	 * @author Vaclav Vancura (http://vaclav.vancura.org)
	 * @since Jul 4, 2008
	 */
	public class SearchService extends ServiceCommon implements IService {

		
		
		private var _trackList:Array;
		private var _songList:Array;

		
		
		/**
		 * Constructor.
		 */
		public function SearchService() {
			super();
			
			$serviceID = sprintf('search.%u.%u', uint(new Date()), Rnd.integer(1000, 9999));
			$requestID = $serviceID + '.request';
			$responseHandler = _onResponse;
			$errorHandler = _onError;
		}

		
		
		/**
		 * Request service.
		 * Parameters could contain:
		 * params.keyword - Keyword
		 * params.instrumentID - Instrument ID
		 * params.genreID - Genre ID
		 * params.country - Country
		 * params.author - Author
		 * params.title - Title
		 * @param params Parameters
		 */
		override public function request(params:Object = null):void {
			if(params == null) params = new Object();
			
			var query:String = '?';
			
			if(params.keyword != '' && params.keyword != undefined) query += '&q=' + escape(params.keyword);
			
			if(params.instrument != '' && params.instrument != undefined) query += '&instrument=' + escape(params.instrument);
			if(params.genre != '' && params.genre != undefined) query += '&genre=' + escape(params.genre);
			if(params.country != '' && params.country != undefined) query += '&country=' + escape(params.country);
			if(params.author != '' && params.author != undefined) query += '&author=' + escape(params.author);
			if(params.title != '' && params.title != undefined) query += '&title=' + escape(params.title);
			if(params.bpm != '' && params.bpm != undefined) query += '&bpm=' + escape(params.bpm);
			if(params.key != '' && params.key != undefined) query += '&key=' + escape(params.key);
			
			if(query == '?') query = '?q=';
			 
			super.request({suffix:query});
		}

		
		
		/**
		 * Dump search results.
		 * @return Search results dump
		 */
		override public function toString():String {
			var o:String = '';
			var sidx:uint = 0;
			var tidx:uint = 0;
			
			if(_songList.length == 0) o += 'No song items\n';
			for each(var sd1:SongData in _songList) {
				sidx++;
				o += sprintf('Song item #%u data:\n%s', sidx, sd1);
				var mtidx:uint = 0;
				for each(var td1:TrackData in sd1.songTracks) {
					mtidx++;
					o += sprintf('Song item #%u track data #%u\n%s', sidx, mtidx, td1);
				}
				o += '------------------------------------------------------------------------------------------\n\n';
			}
			
			if(_trackList.length == 0) o += 'No track items\n';
			for each(var td2:TrackData in _trackList) {
				tidx++;
				o += sprintf('Global track item data #%u\n%s', tidx, td2);
			}
			
			return(o);
		}

		
		
		/**
		 * Response event handler.
		 */
		private function _onResponse():void {
			try {
				_songList = new Array();
				_trackList = new Array();
				
				for each(var sx:XML in $responseData.songs.*) _songList.push($xml2SongData(sx));
				for each(var tx:XML in $responseData.tracks.*) _trackList.push($xml2TrackData(tx));
				
				if(Settings.isServiceDumpEnabled) Logger.debug(sprintf('Service %s: Search dump:\n%s', this.toString()));
				
				dispatchEvent(new SearchEvent(SearchEvent.REQUEST_DONE, false, false, _songList, _trackList));
				dispatchEvent(new RemotingEvent(RemotingEvent.REQUEST_DONE));
			}
			catch(err:Error) {
				dispatchEvent(new RemotingEvent(RemotingEvent.REQUEST_FAILED, false, false, sprintf('Service %s: Search failed.\n%s', $serviceID, err.message)));
			}
		}

		
		
		/**
		 * Error event handler.
		 */
		private function _onError():void {
			dispatchEvent(new RemotingEvent(RemotingEvent.REQUEST_FAILED, false, false, sprintf('Service %s: Search failed.', $serviceID)));
		}
	}
}
