package remoting.dynamic_services {
	import org.osflash.thunderbolt.Logger;
	
	import com.gskinner.utils.Rnd;
	
	import de.popforge.utils.sprintf;
	
	import config.Settings;
	
	import remoting.IService;
	import remoting.ServiceCommon;
	import remoting.data.SongData;
	import remoting.data.TrackData;
	import remoting.events.MyListEvent;
	import remoting.events.RemotingEvent;	

	
	
	/**
	 * My List service.
	 * 
	 * @author Vaclav Vancura (http://vaclav.vancura.org)
	 * @since Jul 14, 2008
	 */
	public class MyListService extends ServiceCommon implements IService {

		
		
		private var _songList:Array;
		private var _trackList:Array;

		
		
		/**
		 * Constructor.
		 */
		public function MyListService() {
			super();
			
			$serviceID = sprintf('myList.%u.%u', uint(new Date()), Rnd.integer(1000, 9999));
			$requestID = $serviceID + '.request';
			$responseHandler = _onResponse;
			$errorHandler = _onError;
		}

		
		
		/**
		 * Dump My List.
		 * @return My List dump
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
				_trackList = new Array();
				
				for each(var sx:XML in $responseData.songs.*) _songList.push($xml2SongData(sx));
				for each(var tx:XML in $responseData.tracks.*) _trackList.push($xml2TrackData(tx));
				
				if(Settings.isServiceDumpEnabled) Logger.debug(sprintf('Service %s: My List dump:\n%s', $serviceID, this.toString()));
				
				dispatchEvent(new MyListEvent(MyListEvent.REQUEST_DONE, false, false, _songList, _trackList));
				dispatchEvent(new RemotingEvent(RemotingEvent.REQUEST_DONE));
			}
			catch(err:Error) {
				dispatchEvent(new RemotingEvent(RemotingEvent.REQUEST_FAILED, false, false, sprintf('Service %s: Could not parse My List data.\n%s', $serviceID, err.message)));
			}
		}

		
		
		/**
		 * Error event handler.
		 */
		private function _onError():void {
			dispatchEvent(new RemotingEvent(RemotingEvent.REQUEST_FAILED, false, false, sprintf('Service %s: Could not load My List data.', $serviceID)));
		}
	}
}
