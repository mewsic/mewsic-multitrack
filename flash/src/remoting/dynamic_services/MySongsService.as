package remoting.dynamic_services {
	import org.osflash.thunderbolt.Logger;
	
	import com.gskinner.utils.Rnd;
	
	import de.popforge.utils.sprintf;
	
	import config.Settings;
	
	import remoting.IService;
	import remoting.ServiceCommon;
	import remoting.data.SongData;
	import remoting.data.TrackData;
	import remoting.events.MySongsEvent;
	import remoting.events.RemotingEvent;	

	
	
	/**
	 * My Songs service.
	 * 
	 * @author Vaclav Vancura (http://vaclav.vancura.org)
	 * @since Jul 11, 2008
	 */
	public class MySongsService extends ServiceCommon implements IService {

		
		
		private var _songList:Array;

		
		
		/**
		 * Constructor.
		 */
		public function MySongsService() {
			super();
			
			$serviceID = sprintf('mySongs.%u.%u', uint(new Date()), Rnd.integer(1000, 9999));
			$requestID = $serviceID + '.request';
			$responseHandler = _onResponse;
			$errorHandler = _onError;
		}

		
		
		/**
		 * Dump My Songs.
		 * @return My Songs dump
		 */
		override public function toString():String {
			var o:String = '';
			var sidx:uint = 0;
			
			if(_songList.length == 0) o += 'No song items\n';
			for each(var sd1:SongData in _songList) {
				sidx++;
				o += sprintf('Song item #%u data:\n%s', sidx, sd1);
					
				var mtidx:uint = 0;
				for each(var td1:TrackData in sd1.songTracks) {
					mtidx++;
					o += sprintf('Song item #%u track data #%u\n%s', sidx, mtidx, td1);
				}
			}
			
			return(o);
		}

		
		
		/**
		 * Request service.
		 * @param params Parameters
		 */
		override public function request(params:Object = null):void {
			if(params == null) params = new Object();
			
			if($coreUserLoginStatus) super.request(params);
			else Logger.debug(sprintf('Service %s: Request (%s) not available (user is not logged in).', $serviceID, url));
		}

		
		
		/**
		 * Response event handler.
		 */
		private function _onResponse():void {
			try {
				_songList = new Array();
				
				for each(var sx:XML in $responseData.song) _songList.push($xml2SongData(sx));
				
				if(Settings.isServiceDumpEnabled) Logger.debug(sprintf('Service %s: My Songs dump:\n%s', $serviceID, this.toString()));
				
				dispatchEvent(new MySongsEvent(MySongsEvent.REQUEST_DONE, false, false, _songList));
				dispatchEvent(new RemotingEvent(RemotingEvent.REQUEST_DONE));
			}
			catch(err:Error) {
				dispatchEvent(new RemotingEvent(RemotingEvent.REQUEST_FAILED, false, false, sprintf('Service %s: Could not parse My Songs data.\n%s', $serviceID, err.message)));
			}
		}

		
		
		/**
		 * Error event handler.
		 */
		private function _onError():void {
			dispatchEvent(new RemotingEvent(RemotingEvent.REQUEST_FAILED, false, false, sprintf('Service %s: Could not load My Songs data.', $serviceID)));
		}
	}
}
