package remoting.dynamic_services {
	import config.Settings;	

	import org.osflash.thunderbolt.Logger;	

	import com.gskinner.utils.Rnd;

	import de.popforge.utils.sprintf;

	import remoting.IService;
	import remoting.ServiceCommon;
	import remoting.data.SongData;
	import remoting.data.TrackData;
	import remoting.events.RemotingEvent;
	import remoting.events.SongExportEvent;		

	
	
	/**
	 * Export song service.
	 * 
	 * @author Vaclav Vancura (http://vaclav.vancura.org)
	 * @since Jul 24, 2008
	 */
	public class SongExportService extends ServiceCommon implements IService {

		
		
		private var _key:String;

		
		
		/**
		 * Constructor.
		 */
		public function SongExportService() {
			super();
			
			$serviceID = sprintf('songExport.%u.%u', uint(new Date()), Rnd.integer(1000, 9999));
			$requestID = $serviceID + '.request';
			$responseHandler = _onResponse;
			$errorHandler = _onError;
		}

		
		
		/**
		 * Request service.
		 * Using POST method.
		 * @param params Parameters
		 */
		override public function request(params:Object = null):void {
			if(params == null) params = new Object();
			
			var query:String = '';
			var i:uint = 0;
			var sd:SongData = params.songData as SongData;
			
			if(params.isSave) query += sprintf('song_id=%s&', sd.songID);
			
			for each(var td:TrackData in sd.songTracks) {
				query += sprintf('tracks[%u][volume]=%f', i, td.trackVolume);
				query += sprintf('&tracks[%u][balance]=%f', i, td.trackBalance);
				query += sprintf('&tracks[%u][filename]=%s', i, td.trackSampleURL);
				query += sprintf('&tracks[%u][id]=%u', i, td.trackID);
				query += '&';
				i++;
			}
			
			query = query.substr(0, query.length - 1); // no & on the end
			
			super.request({suffix:query, method:METHOD_POST});
		}

		
		
		/**
		 * Dump song export results.
		 * @return Song export dump
		 */
		override public function toString():String {
			return sprintf('Song export key=%s', _key);
		}

		
		
		/**
		 * Response event handler.
		 */
		private function _onResponse():void {
			try {
				_key = $responseData.@key;
				
				if(Settings.isServiceDumpEnabled) Logger.debug(sprintf('Service %s: Song export service dump:\n%s', $serviceID, this.toString()));
				
				dispatchEvent(new SongExportEvent(SongExportEvent.REQUEST_DONE, false, false, _key));
				dispatchEvent(new RemotingEvent(RemotingEvent.REQUEST_DONE));
			}
			catch(err:Error) {
				dispatchEvent(new RemotingEvent(RemotingEvent.REQUEST_FAILED, false, false, sprintf('Service %s: Song export failed.\n%s', $serviceID, err.message)));
			}
		}

		
		
		/**
		 * Error event handler.
		 */
		private function _onError():void {
			dispatchEvent(new RemotingEvent(RemotingEvent.REQUEST_FAILED, false, false, sprintf('Service %s: Song export failed.', $serviceID)));
		}
	}
}
