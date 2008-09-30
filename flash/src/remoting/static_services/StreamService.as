package remoting.static_services {
	import flash.events.AsyncErrorEvent;
	import flash.events.IOErrorEvent;
	import flash.events.NetStatusEvent;
	import flash.events.SecurityErrorEvent;
	import flash.media.Microphone;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.net.Responder;
	import flash.system.Security;
	import flash.system.SecurityPanel;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	
	import org.osflash.thunderbolt.Logger;
	
	import com.gskinner.utils.Rnd;
	
	import de.popforge.utils.sprintf;
	
	import application.App;
	
	import config.Settings;
	
	import remoting.IService;
	import remoting.ServiceCommon;
	import remoting.data.UserData;
	import remoting.events.RemotingEvent;	

	
	
	/**
	 * Stream service.
	 * 
	 * @author Vaclav Vancura (http://vaclav.vancura.org)
	 * @since Jul 3, 2008
	 */
	public class StreamService extends ServiceCommon implements IService {

		
		
		private static const _BANG_PING_INTERVAL:uint = 1000;
		private var _gateway:NetConnection;
		private var _stream:NetStream;
		private var _isMicrophoneReady:Boolean;
		private var _microphone:Microphone;
		private var _filename:String;

		
		
		/**
		 * Constructor.
		 */
		public function StreamService() {
			super();
			$serviceID = 'stream';
			$requestID = $serviceID + '.request';
		}

		
		
		/**
		 * Connect stream.
		 */
		override public function connect():void {
			if(Settings.IGNORE_FMS_CALLS) return;
			
			if($isConnecting) throw new Error(sprintf('Service %s: Already connecting.', $serviceID));
			if($isConnected) throw new Error(sprintf('Service %s: Already connected.', $serviceID));
			if(url == null) throw new Error(sprintf('Service %s: Service URL is not defined.', $serviceID));

			Logger.debug(sprintf('Service %s: Connecting (%s). Connection timeout is %u seconds.', $serviceID, url, $connectionTimeout));

			$isConnecting = true;
			$connectionTimeoutHandler = setTimeout($onConnectionTimeout, $connectionTimeout * 1000);

			// add new NetConnection
			_gateway = new NetConnection();

			// add event listeners
			_gateway.addEventListener(NetStatusEvent.NET_STATUS, _onNetStatus, false, 0, true);
			_gateway.addEventListener(SecurityErrorEvent.SECURITY_ERROR, _onSecurityError, false, 0, true);
			_gateway.addEventListener(AsyncErrorEvent.ASYNC_ERROR, _onAsyncError, false, 0, true);
			_gateway.addEventListener(IOErrorEvent.IO_ERROR, _onIOError, false, 0, true);
			
			// connect
			try {
				_gateway.connect(url);
			}
			catch(err:Error) {
				throw new Error(sprintf('Service %s: Could not connect FMS gateway.\n%s', $serviceID, err.message));
			}
		}

		
		
		/**
		 * Disconnect stream.
		 */
		override public function disconnect():void {
			if(Settings.IGNORE_FMS_CALLS) return;
			
			if(!$isConnected) throw new Error(sprintf('Service %s: Not connected', $serviceID));

			// close connection
			_gateway.close();

			// remove event listeners
			_gateway.removeEventListener(NetStatusEvent.NET_STATUS, _onNetStatus);
			_gateway.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, _onSecurityError);
			_gateway.removeEventListener(AsyncErrorEvent.ASYNC_ERROR, _onAsyncError);
			_gateway.removeEventListener(IOErrorEvent.IO_ERROR, _onIOError);

			// reset variables
			$isConnected = false;
			$isConnecting = false;
		}

		
		
		/**
		 * Request service.
		 * Not applicable here, just a placeholder.
		 */
		override public function request(params:Object = null):void {
			throw new Error(sprintf('Service %s: Not applicable.', $serviceID));
		}

		
		
		public function prepare():void {
			if(!_isMicrophoneReady) {
				Security.showSettings(SecurityPanel.MICROPHONE);
				
				_microphone = Microphone.getMicrophone();
				_microphone.rate = 44;
				_microphone.setSilenceLevel(0);
				
				if(_microphone == null) throw new Error('No microphone available.');
				else _isMicrophoneReady = true;
				
				_stream.attachAudio(_microphone);
			}
		}

		
		
		public function record():void {
			if(!$isConnected) throw new Error('Stream not connected.');
			if(!_isMicrophoneReady) throw new Error('Microphone not ready.');
			
			_filename = sprintf('%s_%u_%u', App.connection.coreUserData.userNickname, uint(new Date()), Rnd.integer(1000, 9999));
			Logger.debug(sprintf('Recording under filename %s.', _filename));
			_stream.publish(_filename, 'record');
		}

		
		
		public function stop():void {
			_stream.publish('false');
			_stream.close();
			Logger.info('Recording stopped.');
		}

		
		
		public function get recordLevel():Number {
			return _microphone.activityLevel;
		}

		
		
		public function get filename():String {
			return _filename;
		}

		
		
		/**
		 * Bang ping service.
		 */
		private function _bangPingService():void {
			_gateway.call('ping', new Responder(_onPingResponse));
			setTimeout(_bangPingService, _BANG_PING_INTERVAL);
		}

		
		
		/**
		 * NetStatus event handler.
		 * @param event Event data
		 */
		private function _onNetStatus(event:NetStatusEvent):void {
			clearTimeout($connectionTimeoutHandler);
			
			if(event.info.code == 'NetConnection.Connect.Success') {
				Logger.debug(sprintf('Service %s: Remoting connection ok, adding stream.', $serviceID));

				$isConnected = true;
				$isConnecting = false;
				_stream = new NetStream(_gateway);
				_stream.bufferTime = 2;
				
				// start ping service timeout
				setTimeout(_bangPingService, _BANG_PING_INTERVAL);
			}
			else {
				dispatchEvent(new RemotingEvent(RemotingEvent.CONNECTION_FAILED, false, false, sprintf('Service %s: Could not connect Flash Media Server.', $serviceID)));
				return;
			}

			dispatchEvent(new RemotingEvent(RemotingEvent.CONNECTION_DONE));
		}

		
		
		/**
		 * SecurityError event handler.
		 * @param event Event data
		 */
		private function _onSecurityError(event:SecurityErrorEvent):void {
			clearTimeout($connectionTimeoutHandler);
			dispatchEvent(new RemotingEvent(RemotingEvent.SECURITY_ERROR, false, false, sprintf('Service %s: Flash Media Server security error (%s)', $serviceID, event.text)));
		}

		
		
		/**
		 * AsyncError event handler.
		 * @param event Event data
		 */
		private function _onAsyncError(event:AsyncErrorEvent):void {
			clearTimeout($connectionTimeoutHandler);
			dispatchEvent(new RemotingEvent(RemotingEvent.ASYNC_ERROR, false, false, sprintf('Service %s: Flash Media Server async error (%s)', $serviceID, event.text)));
		}

		
		
		private function _onIOError(event:IOErrorEvent):void {
			clearTimeout($connectionTimeoutHandler);
			dispatchEvent(new RemotingEvent(RemotingEvent.IO_ERROR, false, false, sprintf('Service %s: Flash Media Server IO error (%s)', $serviceID, event.text)));
		}

		
		
		private function _onPingResponse(status:Boolean):void {
			_gateway.call('getStats', new Responder(_onPongResponse));
			status;
		}

		
		
		private function _onPongResponse(data:Object):void {
			var ms:int = data.ping_rtt * App.connection.configService.sync;
			if(Settings.isServiceDumpEnabled) Logger.debug(sprintf('Pong (ping_rtt = %i, ping_rtt * %.2f = %i)', data.ping_rtt, App.connection.configService.sync, ms));
			App.recordSyncDelay = ms;
		}
	}
}
