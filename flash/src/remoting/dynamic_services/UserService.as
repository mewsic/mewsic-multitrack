package remoting.dynamic_services {
	import org.osflash.thunderbolt.Logger;

	import com.gskinner.utils.Rnd;

	import de.popforge.utils.sprintf;

	import config.Settings;

	import remoting.IService;
	import remoting.ServiceCommon;
	import remoting.data.UserData;
	import remoting.events.RemotingEvent;
	import remoting.events.UserEvent;	

	
	
	/**
	 * User service.
	 * 
	 * @author Vaclav Vancura (http://vaclav.vancura.org)
	 * @since Jul 4, 2008
	 */
	public class UserService extends ServiceCommon implements IService {

		
		
		private var _userData:UserData;

		
		
		/**
		 * Constructor.
		 */
		public function UserService() {
			super();
			
			$serviceID = sprintf('user.%u.%u', uint(new Date()), Rnd.integer(1000, 9999));
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
			
			var rp:RegExp = /{:id}/g;
			
			if(params.userNickname != undefined) params.url = url.replace(rp, escape(params.userNickname));
			else if(params.userID != undefined) params.url = url.replace(rp, escape(params.userID));
			else throw new Error(sprintf('Service %s: No userNickname or userID specified.', $serviceID));
			
			super.request(params);
		}

		
		
		/**
		 * Dump track siblings results.
		 * @return Track siblings dump
		 */
		override public function toString():String {
			return _userData.toString();
		}

		
		
		/**
		 * Response event handler.
		 */
		private function _onResponse():void {
			try {
				_userData = new UserData();
				_userData.userAvatarURL = $responseData.avatar;
				_userData.userNickname = $responseData.nickname;
				_userData.userID = $responseData.id;
				
				if(Settings.isServiceDumpEnabled) Logger.debug(sprintf('Service %s: User dump:\n%s', $serviceID, _userData.toString()));
				
				dispatchEvent(new RemotingEvent(RemotingEvent.REQUEST_DONE));
				dispatchEvent(new UserEvent(UserEvent.REQUEST_DONE, false, false, _userData));
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
