package remoting {

	
	
	/**
	 * Remoting data interface.
	 * 
	 * @author Vaclav Vancura (http://vaclav.vancura.org)
	 * @since Jul 3, 2008
	 */
	public interface IService {

		
		
		function connect():void;		

		
		
		function disconnect():void;

		
		
		function request(params:Object = null):void;

		
		
		function toString():String;
		
		
		
		function get isConnected():Boolean;

		
		
		function get isConnecting():Boolean;
	}
}
