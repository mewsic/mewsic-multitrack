package editor_panel.containers
{
	import application.App;

	import de.popforge.utils.sprintf;

	import editor_panel.tracks.RecordTrack;
	
	import flash.events.Event;
	
	import modals.MessageModal;
	
	import org.osflash.thunderbolt.Logger;
	
	import remoting.dynamic_services.TrackCreateService;
	import remoting.events.TrackCreateEvent;
	import remoting.events.RemotingEvent;

	public class RecordContainer extends ContainerCommon
	{

		private var _trackCreateService:TrackCreateService;


		public function RecordContainer()
		{
			_trackCreateService = new TrackCreateService();
			super();
		}
		
		
		/**
		 * Create new record track.
		 * @return New track
		 * @throws Error if could not add record track
		 */
		public function createTrack():void {
			Logger.info('Creating record track');

			// create this track on the server
			_trackCreateService.url = App.connection.serverPath + App.connection.configService.trackCreateRequestURL; /// XXX REMOVE ME
			_trackCreateService.addEventListener(RemotingEvent.REQUEST_FAILED, _onTrackCreateFailed, false, 0, true);
			_trackCreateService.addEventListener(TrackCreateEvent.REQUEST_DONE, _onTrackCreateDone, false, 0, true);
			_trackCreateService.request({title:App.connection.coreUserData.userNickname + " performance"});
		}
				
		
		
		private function _onTrackCreateDone(event:TrackCreateEvent):void {
			Logger.info(sprintf("Track %u created on the server", event.trackData.trackID));

			// create track instance
			var t:RecordTrack = new RecordTrack(event.trackData.trackID);
			t.trackData = event.trackData;
			t.load();
			
			displayTrack(t);
				
			// dispatch
			dispatchEvent(new ContainerEvent(ContainerEvent.RECORD_TRACK_READY, true, false, {track:t}));
			dispatchEvent(new ContainerEvent(ContainerEvent.TRACK_ADDED, true, false, {track:t}));			
		}
		
		
		
		private function _onTrackCreateFailed(event:Event):void {
			App.messageModal.show({title:"Something is wrong", description:"Track create service failed",
				buttons:MessageModal.BUTTONS_RELOAD, icon:MessageModal.ICON_ERROR});
		}

	}
}