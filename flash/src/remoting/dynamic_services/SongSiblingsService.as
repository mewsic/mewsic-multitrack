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
	import remoting.events.SongSiblingsEvent;	

	
	
	/**
	 * Song siblings service.
	 * 
	 * @author Vaclav Vancura (http://vaclav.vancura.org)
	 * @since Jul 4, 2008
	 */
	public class SongSiblingsService extends ServiceCommon implements IService {

		
		
		private var _directList:Array;
		private var _indirectList:Array;

		
		
		/**
		 * Constructor.
		 */
		public function SongSiblingsService() {
			super();
			
			$serviceID = sprintf('songSiblings.%u.%u', uint(new Date()), Rnd.integer(1000, 9999));
			$requestID = $serviceID + '.request';
			$responseHandler = _onResponse;
			$errorHandler = _onError;
		}

		
		
		/**
		 * Request service.
		 * Parameters could contain:
		 * params.songID - requested song ID
		 * @param params Parameters
		 */
		override public function request(params:Object = null):void {
			if(params == null) params = new Object();
			
			var rp:RegExp = /{:song_id}/g;
			
			if(params.songID != undefined) params.url = url.replace(rp, escape(params.songID));
			else throw new Error(sprintf('Service %s: No songID specified.', $serviceID));
			
			super.request(params);
		}

		
		
		/**
		 * Dump song siblings.
		 * @return Song siblings dump
		 */
		override public function toString():String {
			var o:String = '';
			var idx:uint = 0;
			
			if(_directList.length == 0) o += 'No direct song siblings items\n';
			else {
				for each(var sd1:SongData in _directList) {
					idx++;
					o += sprintf('Direct song sibling item #%u data:\n%s', idx, sd1);
					var tidx1:uint = 0;
					for each(var td1:TrackData in sd1.songTracks) {
						tidx1++;
						o += sprintf('Direct song sibling item #%u track data #%u\n%s', idx, tidx1, td1);
					}
				}
			}
			
			if(_indirectList.length == 0) o += 'No indirect song siblings items\n';
			else {
				for each(var sd2:SongData in _indirectList) {
					idx++;
					o += sprintf('Indirect song sibling item #%u data:\n%s', idx, sd2);
					var tidx2:uint = 0;
					for each(var td2:TrackData in sd2.songTracks) {
						tidx2++;
						o += sprintf('Indirect song sibling item #%u track data #%u\n%s', idx, tidx2, td2);
					}
				}
			}
			
			return(o);
		}

		
		
		/**
		 * Response event handler.
		 */
		private function _onResponse():void {
			try {
				_directList = new Array();
				_indirectList = new Array();
				
				for each(var mx:XML in $responseData.*) {
					if(mx.@type == 'direct') for each(var nx1:XML in mx.song) _directList.push($xml2SongData(nx1));
					if(mx.@type == 'indirect') for each(var nx2:XML in mx.song) _indirectList.push($xml2SongData(nx2));
				}
					
				if(Settings.isServiceDumpEnabled) Logger.debug(sprintf('Service %s: Song siblings dump:\n%s', $serviceID, this.toString()));
				
				dispatchEvent(new SongSiblingsEvent(SongSiblingsEvent.REQUEST_DONE, false, false, _directList, _indirectList));
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
