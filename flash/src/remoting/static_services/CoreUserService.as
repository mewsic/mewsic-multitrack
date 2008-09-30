package remoting.static_services {
	import org.osflash.thunderbolt.Logger;
	
	import com.gskinner.utils.Rnd;
	
	import de.popforge.utils.sprintf;
	
	import config.Settings;
	
	import remoting.IService;
	import remoting.ServiceCommon;
	import remoting.data.UserData;
	import remoting.events.RemotingEvent;	

	
	
	/**
	 * Core user service.
	 * Holds data for logged or unlogged user.
	 * If user is logged in, it fills data with remoting response.
	 * If not, it fills data with guest information (avatarURL is taken from config)
	 * 
	 * @author Vaclav Vancura (http://vaclav.vancura.org)
	 * @since Jul 16, 2008
	 */
	public class CoreUserService extends ServiceCommon implements IService {

		
		
		/**
		 * Constructor.
		 */
		public function CoreUserService() {
			super();
			
			$serviceID = sprintf('coreUser.%u.%u', uint(new Date()), Rnd.integer(1000, 9999));
			$requestID = $serviceID + '.request';
			$responseHandler = _onResponse;
			$errorHandler = _onError;
		}

		
		
		/**
		 * Request service.
		 * Parameters could contain:
		 * params.userNickname - requested user nickname
		 * params.userID - requested user ID
		 * @param params Parameters
		 */
		override public function request(params:Object = null):void {
			if(params == null) params = new Object();
			
			if(!$coreUserLoginStatus) throw new Error(sprintf('Service $s: Could not request core user data, as the user is currently not logged in.', $serviceID));
			else {
				var rp:RegExp = /{:id}/g;
				
				if(params.userNickname != undefined) params.url = url.replace(rp, params.userNickname.toString());
				else if(params.userID != undefined) params.url = url.replace(rp, params.userID.toString());
				else throw new Error(sprintf('Service %s: No userNickname or userID specified.', $serviceID));
				
				super.request(params);
			}
		}

		
		
		/**
		 * Set guest data.
		 */
		public function setGuest():void {
			if($coreUserLoginStatus) throw new Error(sprintf('Service %s: Could not set guest data, as the user is currently logged in.', $serviceID));
			else {
				$coreUserData.userAvatarURL = $defaultAvatarURL;
				$coreUserData.userNickname = 'Guest';
				$coreUserData.userID = 0;
				
				if(Settings.isServiceDumpEnabled) Logger.debug(sprintf('Service %s: User dump:\n%s', $serviceID, $coreUserData.toString()));
				
				dispatchEvent(new RemotingEvent(RemotingEvent.REQUEST_DONE));
			}
		}

		
		
		/**
		 * Response event handler.
		 * Only for logged in user.
		 */
		private function _onResponse():void {
			try {
				$coreUserData.userAvatarURL = $responseData.avatar;
				$coreUserData.userNickname = $responseData.nickname;
				$coreUserData.userID = $responseData.id;
				
				if(Settings.isServiceDumpEnabled) Logger.debug(sprintf('Service %s: User dump:\n%s', $serviceID, $coreUserData.toString()));
				
				dispatchEvent(new RemotingEvent(RemotingEvent.REQUEST_DONE));
			}
			catch(err:Error) {
				dispatchEvent(new RemotingEvent(RemotingEvent.REQUEST_FAILED, false, false, sprintf('Service %s: Could not parse user data.\n%s', $serviceID, err.message)));
			}
		}

		
		
		/**
		 * Error event handler.
		 */
		private function _onError():void {
			dispatchEvent(new RemotingEvent(RemotingEvent.REQUEST_FAILED, false, false, sprintf('Service %s: Could not load user data.', $serviceID)));
		}
	}
}
