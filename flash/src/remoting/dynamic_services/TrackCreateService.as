package remoting.dynamic_services {
	import org.osflash.thunderbolt.Logger;

	import com.gskinner.utils.Rnd;

	import de.popforge.utils.sprintf;

	import config.Settings;

	import remoting.IService;
	import remoting.ServiceCommon;
	import remoting.data.TrackData;
	import remoting.events.RemotingEvent;
	import remoting.events.TrackCreateEvent;	

	
	
	/**
	 * Create track service.
	 * 
	 * @author Vaclav Vancura (http://vaclav.vancura.org)
	 * @since Jul 23, 2008
	 */
	public class TrackCreateService extends ServiceCommon implements IService {

		
		
		private var _trackData:TrackData;

		
		
		/**
		 * Constructor.
		 */
		public function TrackCreateService() {
			super();
			
			$serviceID = sprintf('trackCreate.%u.%u', uint(new Date()), Rnd.integer(1000, 9999));
			$requestID = $serviceID + '.request';
			$responseHandler = _onResponse;
			$errorHandler = _onError;
		}

		
		
		/**
		 * Request service.
		 * Using POST method.
		 * Parameters could contain:
		 * params.title - Track title
		 * params.filename - Track filename
		 * params.description - Track description
		 * params.instrumentDescription - Instrument description
		 * params.key - Track key
		 * params.songID - Song ID
		 * params.instrumentID - Instrument ID
		 * params.milliseconds - Track milliseconds
		 * params.bpm - Track BPM
		 * params.userID - User ID
		 * @param params Parameters
		 */
		override public function request(params:Object = null):void {
			if(params == null) params = new Object();
			
			var query:String = '';
			
			if(params.title != undefined) query += 'track[title]=' + escape(params.title);
			else throw new Error(sprintf('Service %s: Title is not defined.', $serviceID));
			
			if(params.filename != undefined) query += '&track[filename]=' + escape(params.filename);
			else throw new Error(sprintf('Service %s: Filename is not defined.', $serviceID));
			
			if(params.key != undefined) query += '&track[tonality]=' + escape(params.key);
			else throw new Error(sprintf('Service %s: Key is not defined.', $serviceID));
			
			if(params.songID != undefined) query += '&track[song_id]=' + escape(params.songID);
			else throw new Error(sprintf('Service %s: Song ID is not defined.', $serviceID));
			
			if(params.instrumentID != undefined) query += '&track[instrument_id]=' + escape(params.instrumentID);
			else throw new Error(sprintf('Service %s: Instrument ID is not defined.', $serviceID));
			
			if(params.milliseconds != undefined) query += '&track[seconds]=' + (params.milliseconds / 1000);
			else throw new Error(sprintf('Service %s: Milliseconds is not defined.', $serviceID));
			
			if(params.bpm != undefined) query += '&track[bpm]=' + escape(params.bpm);
			else throw new Error(sprintf('Service %s: BPM is not defined.', $serviceID));
			
			if(params.userID != undefined) query += '&track[user_id]=' + escape(params.userID);
			else throw new Error(sprintf('Service %s: User ID is not defined.', $serviceID));
			
			if(params.isIdea != undefined) query += '&track[idea]=' + ((params.isIdea) ? 1 : 0);
			else throw new Error(sprintf('Service %s: Idea is not defined.', $serviceID));
			
			if(params.description != undefined) query += '&track[description]=' + escape(params.description);
			if(params.instrumentDescription != undefined) query += '&track[instrument_description]=' + params.instrumentDescription;
			
			super.request({suffix:query, method:METHOD_POST});
		}

		
		
		/**
		 * Dump create track results.
		 * @return Create track dump
		 */
		override public function toString():String {
			return _trackData.toString();
		}

		
		
		/**
		 * Response event handler.
		 */
		private function _onResponse():void {
			try {
				_trackData = $xml2TrackData($responseData);
				
				if(Settings.isServiceDumpEnabled) Logger.debug(sprintf('Service %s: Track create info dump:\n%s', $serviceID, _trackData.toString()));
				
				dispatchEvent(new RemotingEvent(RemotingEvent.REQUEST_DONE));
				dispatchEvent(new TrackCreateEvent(TrackCreateEvent.REQUEST_DONE, false, false, _trackData));
			}
			catch(err:Error) {
				dispatchEvent(new RemotingEvent(RemotingEvent.REQUEST_FAILED, false, false, sprintf('Service %s: Track create failed.\n%s', $serviceID, err.message)));
			}
		}

		
		
		/**
		 * Error event handler.
		 */
		private function _onError():void {
			dispatchEvent(new RemotingEvent(RemotingEvent.REQUEST_FAILED, false, false, sprintf('Service %s: Track create failed.', $serviceID)));
		}
	}
}
