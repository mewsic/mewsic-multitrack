package remoting.data {
	import de.popforge.utils.sprintf;	

	
	
	/**
	 * User data.
	 * 
	 * @author Vaclav Vancura (http://vaclav.vancura.org)
	 * @since Jul 15, 2008
	 */
	public class UserData {

		
		
		public var userID:uint;
		public var userNickname:String;
		public var userAvatarURL:String;

		
		
		/**
		 * Get genre dump.
		 * @return Genre dump
		 */
		public function toString():String {
			return(sprintf('userID=%u, userNickname=%s, userAvatarURL=%s', userID, userNickname, userAvatarURL));
		}
	}
}
