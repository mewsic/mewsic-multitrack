package editor_panel.containers
{
	import application.App;
	
	import de.popforge.utils.sprintf;
	
	import editor_panel.tracks.StandardTrack;
	import editor_panel.tracks.TrackCommon;
	import editor_panel.tracks.TrackEvent;
	
	import modals.MessageModal;
	
	import org.osflash.thunderbolt.Logger;
	
	import remoting.data.TrackData;
	import remoting.dynamic_services.SongFetchService;
	import remoting.dynamic_services.TrackCreateService;
	import remoting.dynamic_services.TrackFetchService;
	import remoting.events.RemotingEvent;
	import remoting.events.SongFetchEvent;
	import remoting.events.TrackCreateEvent;
	import remoting.events.TrackFetchEvent;
	
	public class StandardContainer extends ContainerCommon
	{

		private var _songQueue:Array = new Array();
		private var _trackQueue:Array = new Array();
		
		private var _trackCreateService:TrackCreateService = null;

		
		public function StandardContainer()
		{
			//TODO: implement function
			super();
		}



		/**
		 * Add song.
		 * @param id Song ID
		 */
		public function addSong(id:uint):void {
			// check for song dupe
			for each(var s:Object in _songQueue) {
				// crawl through all songs in the queue
				if(s.songID == id) {
					// song is duped,
					// show alert window
					App.messageModal.show({title:'Add song', description:'Song already loaded.',
						buttons:MessageModal.BUTTONS_OK, icon:MessageModal.ICON_WARNING});
					return;
				}
			}
			
			// song is not duped
			// so let's continue
			Logger.info(sprintf('Adding song (songID=%u)', id));
			
			try {				
				var service:SongFetchService = new SongFetchService();

				// add to the song queue
				_songQueue.push({songID:id, service:service});

				// load song
				service.url = App.connection.serverPath + App.connection.configService.songFetchRequestURL;
				service.addEventListener(SongFetchEvent.REQUEST_DONE, _onSongFetchDone, false, 0, true);
				service.addEventListener(SongFetchEvent.REQUEST_FAILED, _onSongFetchFailed, false, 0, true);
				service.request({songID:id});
			}
			catch(err:Error) {
				// something went wrong
				// show alert window
				App.messageModal.show({title:'Add song', description:sprintf('Could not add song.\n%s', err.message),
					buttons:MessageModal.BUTTONS_OK, icon:MessageModal.ICON_WARNING});
			}
		}



		/**
		 * Song fetch done event handler.
		 * @param event Event data
		 */
		private function _onSongFetchDone(event:SongFetchEvent):void {
			_songQueue = _songQueue.filter(function(s:Object, idx:uint, ary:Array):Boolean {

				if(s.songID != event.songData.songID)
					return true; // keep in the queue
				
				Logger.debug(sprintf('Song info of songID %u loaded, adding all %u tracks',
					event.songData.songID, event.songData.songTracks.length));
						
				s.service.removeEventListener(SongFetchEvent.REQUEST_DONE, _onSongFetchDone);
				s.service.removeEventListener(SongFetchEvent.REQUEST_FAILED, _onSongFetchFailed);
				
				for each(var td:TrackData in event.songData.songTracks) {
					try {
						// If already loaded, skip it
						if(_trackQueue.some(function(t:Object, idx:uint, ary:Array):Boolean { return t.trackID == td.trackID; }))
							continue;
				
						Logger.info(sprintf('Adding song track from track data (trackID=%u, balance=%.2f, volume=%.2f)',
							td.trackID, td.trackBalance, td.trackVolume));
				
						// add to track queue to prevent dupes
						_trackQueue.push({trackID:td.trackID});

						var t:StandardTrack = new StandardTrack(td.trackID);
						t.trackData = td;
						t.load();
						
						displayTrack(t);

						// add event listeners
						t.addEventListener(TrackEvent.KILL, _onTrackKill, false, 0, true);
						t.addEventListener(TrackEvent.REFRESH, _onTrackRefresh, false, 0, true);

						// dispatch events
						dispatchEvent(new ContainerEvent(ContainerEvent.TRACK_ADDED, true, false, {track:t}));
						
					}
					catch(err:Error) {
						App.messageModal.show({title:'Add song', description:err.message,
						  buttons:MessageModal.BUTTONS_OK, icon:MessageModal.ICON_WARNING});
							 
					}
				}
				
				// remove from the queue
				return false;

			});
					
			//_refreshWaveforms();
		}



		/**
		 * Song fetch failed event handler.
		 * @param event Event data
		 */
		private function _onSongFetchFailed(event:SongFetchEvent):void {
			// Remove from queue
			_songQueue = _songQueue.filter(function(s:Object, idx:uint, ary:Array):Boolean {
				return(s.songID != event.songID);				
			});

			dispatchEvent(new ContainerEvent(ContainerEvent.SONG_FETCH_FAILED, false, false,
				{description:"Failed to fetch song " + event.songID}));
		}

		
		
		/**
		 * Add standard track.
		 * @param id Track ID
		 */
		public function addTrack(id:uint, options:Object = null):Boolean {							
			// check for track dupe
			if(_trackQueue.some(function(t:Object, idx:uint, ary:Array):Boolean { return(t.trackID == id); })) {
				// track is duped,
				// show alert window
				App.messageModal.show({title:'Add track', description:'Track already loaded',
					buttons:MessageModal.BUTTONS_OK, icon:MessageModal.ICON_WARNING});
				return false;
			}

			// track is not duped
			// so let's continue
			Logger.info(sprintf('Fetching standard track (trackID=%u)', id));

			// request track info // XXX MOVE THIS INTO THE TRACK CLASS
			try {
				// add track fetch service
				var service:TrackFetchService = new TrackFetchService();
				var callback:Function = options ? options.onComplete : null;

				// add to track queue to prevent dupes
				_trackQueue.push({trackID:id, service:service, callback:callback});

				// load track
				service.url = App.connection.serverPath + App.connection.configService.trackFetchRequestURL;

				service.addEventListener(TrackFetchEvent.REQUEST_DONE, _onTrackFetchDone, false, 0, true);
				service.addEventListener(TrackFetchEvent.REQUEST_FAILED, _onTrackFetchFailed, false, 0, true);
				service.request({trackID:id});
					
				return true;
			}
			catch(err:Error) {
				App.messageModal.show({title:'Add track', description:sprintf('Could not add track.\n%s', err.message),
					buttons:MessageModal.BUTTONS_OK, icon:MessageModal.ICON_WARNING});
			}

			return false;
		}		


		
		/**
		 * Track fetch done event handler.
		 * @param event Event data
		 */
		private function _onTrackFetchDone(event:TrackFetchEvent):void {
			// create track
			var ret:StandardTrack = new StandardTrack(event.trackData.trackID);
			// set track data
			ret.trackData = event.trackData;
			
			// load sample and waveform
			ret.load();
					
			// add to display list
			displayTrack(ret);
			
			_refreshWaveforms();
			
			// call callback if defined and uninit service
			_trackQueue.forEach(function(t:Object, idx:uint, ary:Array):void {
				if(t.trackID != ret.trackData.trackID)
					return;

				if(t.service) {
					t.service.removeEventListener(TrackFetchEvent.REQUEST_DONE, _onTrackFetchDone);
					t.service.removeEventListener(TrackFetchEvent.REQUEST_FAILED, _onTrackFetchFailed);
					t.service = null;
				}
					
				if(t.callback) {
					t.callback(ret);
					t.callback = null;
				}
			});

			// add event listeners
			ret.addEventListener(TrackEvent.KILL, _onTrackKill, false, 0, true);
			ret.addEventListener(TrackEvent.REFRESH, _onTrackRefresh, false, 0, true);

			// dispatch events
			dispatchEvent(new ContainerEvent(ContainerEvent.TRACK_ADDED, true, false, {track:ret}));					
		}



		/**
		 * Track fetch failed event handler.
		 * @param event Event data
		 */
		private function _onTrackFetchFailed(event:TrackFetchEvent):void {
			// remove from queue
			_trackQueue = _trackQueue.filter(function(t:Object, idx:uint, ary:Array):Boolean {
				return(t.trackID != event.trackID);
			});

			dispatchEvent(new ContainerEvent(ContainerEvent.TRACK_FETCH_FAILED, false, false, {description:"please try again"}));
		}



		public function uploadTrack(name:String):void {
			Logger.info('Creating upload track "' + name + '"');
			
			if(_trackCreateService != null) throw new Error("Already uploading, WTF?!");
			
			// create this track on the server
			_trackCreateService = new TrackCreateService();
			_trackCreateService.url = App.connection.serverPath + App.connection.configService.trackCreateRequestURL; /// XXX REMOVE ME
			_trackCreateService.addEventListener(TrackCreateEvent.REQUEST_DONE, _onUploadCreateDone, false, 0, true);
			_trackCreateService.addEventListener(RemotingEvent.REQUEST_FAILED, _onUploadCreateFailed, false, 0, true);
			_trackCreateService.request({title:name});

		}
		
		private function _onUploadCreateDone(event:TrackCreateEvent):void {
			Logger.info('Upload track created on the server, ID: ' + event.trackData.trackID);
			
			var upload:StandardTrack = new StandardTrack(event.trackData.trackID);
			upload.trackData = event.trackData;
			upload.load();
			
			displayTrack(upload);

			upload.addEventListener(TrackEvent.KILL, _onTrackKill, false, 0, true);
			upload.addEventListener(TrackEvent.REFRESH, _onTrackRefresh, false, 0, true);

			_trackQueue.push({trackID:upload.trackID});
			
			dispatchEvent(new ContainerEvent(ContainerEvent.UPLOAD_TRACK_READY, true, false, {track:upload}));
			dispatchEvent(new ContainerEvent(ContainerEvent.TRACK_ADDED, true, false, {track:upload}));
			
			_removeUploadService();
		}
		
		private function _onUploadCreateFailed(event:RemotingEvent):void {
			App.messageModal.show({title:"Upload failed", description:"Cannot create track on the server, please try again."});

			_removeUploadService();
		}
		
		private function _removeUploadService():void {
			_trackCreateService.removeEventListener(RemotingEvent.REQUEST_FAILED, _onUploadCreateFailed);
			_trackCreateService.removeEventListener(TrackCreateEvent.REQUEST_DONE, _onUploadCreateDone);
			_trackCreateService = null;
		}



		override public function killTrack(killed:TrackCommon):void {
			// remove from queue
			_trackQueue = _trackQueue.filter(function(queued:Object, idx:uint, ary:Array):Boolean {
				if(killed.trackID != queued.trackID)
					return true; // keep in the queue

				if(queued.service) {
					queued.service.removeEventListener(TrackFetchEvent.REQUEST_DONE, _onTrackFetchDone);
					queued.service.removeEventListener(TrackFetchEvent.REQUEST_FAILED, _onTrackFetchFailed);
				}

				return false; // remove from the queue
			});

			killed.removeEventListener(TrackEvent.KILL, _onTrackKill);
			killed.removeEventListener(TrackEvent.REFRESH, _onTrackRefresh);

			_refreshWaveforms();

			// Remove from display list and dispatch
			super.killTrack(killed);	
		}



		/**
		 * Track kill event handler.
		 * @param event Event data
		 */
		private function _onTrackKill(event:TrackEvent):void {
			killTrack(event.target as StandardTrack);
		}
		
		
		
		private function _onTrackRefresh(event:TrackEvent):void {
			_refreshWaveforms();
		}



		/**
		 * Refresh waveforms.
		 */
		private function _refreshWaveforms():void {
			var max:uint = this.milliseconds;
			var t:TrackCommon;

			for each(t in $trackList) {
				t.rescale(max);
			}
		}



		/**
		 * Play container.
		 */
		public function play():void {
			for each(var t:TrackCommon in $trackList) {
				// play all tracks in the container
				try {
					t.play();
				}
				catch(err:Error) {
					// something went wrong, grr
					Logger.warn(sprintf('Problem trying to start playback of %s:\n%s', t.toString(), err.message));
				}
			}
		}

		
		
		/**
		 * Stop container.
		 */
		public function stop():void {
			for each(var t:TrackCommon in $trackList) {
				// stop all tracks in the container
				try {
					t.stop();
				}
				catch(err:Error) {
					// something went wrong, grr
					Logger.warn(sprintf('Problem trying to stop playback of %s:\n%s', t.toString(), err.message));
				}
			}
		}

		
		
		/**
		 * Pause container.
		 */
		public function pause():void {
			for each(var t:TrackCommon in $trackList) {
				// pause all tracks in the container
				try {
					t.pause();
				}
				catch(err:Error) {
					// something went wrong, grr
					Logger.warn(sprintf('Problem trying to pause playback of %s:\n%s', t.toString(), err.message));
				}
			}
		}

		
		
		/**
		 * Resume container.
		 */
		public function resume():void {
			for each(var t:StandardTrack in $trackList) {
				
				// resume all tracks in the container
				try {
					if(position < t.milliseconds) {
						Logger.info("Resuming playback of stopped track " + t.trackData.trackTitle);
						t.resume();
					}
				}
				catch(err:Error) {
					// something went wrong, grr
					Logger.warn(sprintf('Problem trying to resume playback of %s:\n%s', t.toString(), err.message));
				}
			}
		}

		
		
		/**
		 * Seek container.
		 * @param position Seek position
		 */
		public function seek(position:uint, isPlaying:Boolean = false):void {
			for each(var t:StandardTrack in $trackList) {

				// seek all tracks in the container
				try {
					if(position < t.milliseconds) {
						// seeked inside this track timeframe
						// 
						t.seek(position);

						if(isPlaying && !t.isPlaying) {
							Logger.info("Resuming playback of stopped track " + t.trackData.trackTitle);
							t.resume();
						}			
					} else {
						// seeked outside the track timeframe rewind to 0
						t.seek(0);
						
						if(t.isPlaying) {
							Logger.info("Stopped playback of playing track " + t.trackData.trackTitle);
							t.stop();
						}
							
					}
					
				}
				catch(err:Error) {
					// something went wrong, grr
					Logger.warn(sprintf('Problem trying to seek playback of %s:\n%s', t.toString(), err.message));
				}
			}
		}
		
		
		
		public function get playingTracksCount():uint {
			return $trackList.filter(function(t:StandardTrack, idx:uint, ary:Array):Boolean { return t.isPlaying; }).length;
		}



		/// XXX UNUSED AS OF NOW
		public function getTrack(idx:uint):StandardTrack {
			try {
				return($trackList[idx] as StandardTrack);
			}
			catch(err:Error) { }

			return null;
		}
	}
}