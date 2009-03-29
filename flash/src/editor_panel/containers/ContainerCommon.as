package editor_panel.containers {
	import application.App;
	import application.AppEvent;
	
	import caurina.transitions.Tweener;
	
	import config.Settings;
	
	import controls.MorphSprite;
	
	import de.popforge.utils.sprintf;
	
	import editor_panel.tracks.RecordTrack;
	import editor_panel.tracks.StandardTrack;
	import editor_panel.tracks.TrackCommon;
	import editor_panel.tracks.TrackEvent;
	
	import flash.events.Event;
	import flash.net.FileReference;
	
	import modals.MessageModal;
	
	import org.osflash.thunderbolt.Logger;
	import org.vancura.graphics.QSprite;
	import org.vancura.util.addChildren;
	
	import remoting.data.TrackData;
	import remoting.dynamic_services.SongFetchService;
	import remoting.dynamic_services.TrackCreateService;
	import remoting.dynamic_services.TrackFetchService;
	import remoting.events.RemotingEvent;
	import remoting.events.SongFetchEvent;
	import remoting.events.TrackCreateEvent;
	import remoting.events.TrackFetchEvent;

	
	
	/**
	 * Container
	 * 
	 * @author Vaclav Vancura (http://vaclav.vancura.org)
	 * @since Jun 20, 2008
	 */
	public class ContainerCommon extends MorphSprite {


		private var _trackSpr:QSprite;
		private var _contentHeight:Number = 0;

		private var _type:String;
		private var _trackList:Array = new Array();
		private var _songQueue:Array = new Array();
		private var _trackQueue:Array = new Array();

		private var _trackCreateService:TrackCreateService;
		

		
		/**
		 * Constructor.
		 * @param t Container type (TrackCommon.STANDARD_TRACK or TrackCommon.RECORD_TRACK)
		 * @throws TypeError if container type is not TrackCommon.STANDARD_TRACK or TrackCommon.RECORD_TRACK
		 */
		public function ContainerCommon(t:String) {
			super();

			// check for type validity
			if(t != TrackCommon.STANDARD_TRACK && t != TrackCommon.RECORD_TRACK) {
				throw new TypeError('Container type has to be TrackCommon.RECORD_TRACK or TrackCommon.STANDARD_TRACK.');
			}
			else _type = t;

			// add graphics
			_trackSpr = new QSprite({y:2});

			// set visual properties
			$morphTime = Settings.STAGE_HEIGHT_CHANGE_TIME;
			$morphTransition = 'easeInOutQuad';

			// morph settings
			$isChangeWidthEnabled = false;
			$isChangeHeightEnabled = false;
			$isMorphWidthEnabled = false;
			$isMorphHeightEnabled = false;

			// intro animation
			Tweener.addTween(this, {delay:.05, onComplete:function():void {
				addChildren(this, _trackSpr);
				_recountHeight();
			}});
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
					App.messageModal.show({title:'Add song', description:'Song already loaded.', buttons:MessageModal.BUTTONS_OK, icon:MessageModal.ICON_WARNING});
					return;
				}
			}
			
			// song is not duped
			// so let's continue
			Logger.info(sprintf('Adding song (songID=%u)', id));
			
			// try to add track
			// edit parameter is on
			try {
				// add song fetch service
				var service:SongFetchService = new SongFetchService();
				
				// add to the song queue
				_songQueue.push({songID:id, service:service});

				// load song
				service.url = App.connection.serverPath + App.connection.configService.songFetchRequestURL;
				service.addEventListener(SongFetchEvent.REQUEST_DONE, _onSongFetchDone, false, 0, true);
				service.addEventListener(RemotingEvent.REQUEST_FAILED, _onSongFetchFailed, false, 0, true);
				service.request({songID:id});
			}
			catch(err:Error) {
				// something went wrong
				// show alert window
				App.messageModal.show({title:'Add song', description:sprintf('Could not add song.\n%s', err.message), buttons:MessageModal.BUTTONS_OK, icon:MessageModal.ICON_WARNING});
			}
		}

		
		
		/**
		 * Add standard track.
		 * @param id Track ID
		 */
		public function addStandardTrack(id:uint):StandardTrack {
			var ret:StandardTrack = null;
			
			if(_type != TrackCommon.STANDARD_TRACK) {
				App.messageModal.show({title:'Add track', description:'Could not add standard track to record track container.', buttons:MessageModal.BUTTONS_OK, icon:MessageModal.ICON_WARNING});
				return null;
			}
				
			// check for track dupe
			for each(var t:Object in _trackQueue) {
				// crawl through all tracks in the queue
				if(t.trackID == id) {
					// track is duped,
					// show alert window
					App.messageModal.show({title:'Add track', description:'Track already loaded',
						buttons:MessageModal.BUTTONS_OK, icon:MessageModal.ICON_WARNING});
					return ret;
				}
			}
				
			// track is not duped
			// so let's continue
			Logger.info(sprintf('Adding standard track (trackID=%u)', id));
				
			// create track
			ret = createTrack(id) as StandardTrack;
				
			// request track info
			try {
				// add track fetch service
				var service:TrackFetchService = new TrackFetchService();
					
				// add to track queue to prevent dupes
				_trackQueue.push({trackID:id, service:service});
				
				// load track
				service.url = App.connection.serverPath + App.connection.configService.trackFetchRequestURL;

				service.addEventListener(TrackFetchEvent.REQUEST_DONE, _onTrackFetchDone, false, 0, true);
				service.addEventListener(RemotingEvent.REQUEST_FAILED, _onTrackFetchFailed, false, 0, true);
				service.request({trackID:id});
					
				return ret;
			}
			catch(err:Error) {
				// something went wrong
				// show alert window
				App.messageModal.show({title:'Add track', description:sprintf('Could not add track.\n%s', err.message),
					buttons:MessageModal.BUTTONS_OK, icon:MessageModal.ICON_WARNING});
			}
			
			return null;
		}

		
		
		/**
		 * Add standard track by its track data. Used by song fetch done handler
		 * @dispatches ContainerEvent.TRACK_ADDED, AppEvent.REFRESH_TOP_PANE
		 * @param td Track data
		 * @throws Error if track is already in the queue.
		 */
		public function addStandardTrackByTD(td:TrackData):void {
			// check for track dupe
			if(_type != TrackCommon.STANDARD_TRACK) {
				throw new Error("Cannot add standard track to record track container");
			}

			for each(var t:Object in _trackQueue) {
				// crawl through all tracks in the queue
				if(t.trackID == td.trackID) {
					// track is duped, throw error
					throw new Error('Track already loaded.');
				}
			}
				
			// it's not duped.
			// so let's continue
			Logger.info(sprintf('Adding track from track data (trackID=%u, balance=%.2f, volume=%.2f)', td.trackID, td.trackBalance, td.trackVolume));
				
			// add to track queue to prevent dupes
			_trackQueue.push({trackID:td.trackID});
				
			// check for record or standard and create tracks
			createTrack(td.trackID);
				
			// update core song
			for each(var p:TrackCommon in _trackList) if(p.trackID == td.trackID) {
				p.trackData = td;
				p.load();
			}
				
			// dispatch events
			dispatchEvent(new ContainerEvent(ContainerEvent.TRACK_ADDED, true, false, {trackData:td}));
			dispatchEvent(new AppEvent(AppEvent.REFRESH_TOP_PANE, true));
		}

		
		
		/**
		 * Create new track.
		 * @param id Track ID
		 * @return New track
		 */
		private function createTrack(id:uint):TrackCommon {
			var t:TrackCommon;
			
			// check for record or standard and create tracks
			try {
				if(_type == TrackCommon.STANDARD_TRACK) t = new StandardTrack(id);
				else t = new RecordTrack(id);
			}
			catch(err1:Error) {
				throw new Error(sprintf('Could not create track.\n%s', err1.message));
			}

			// set visual properties
			t.y = Settings.TRACK_CONTAINER_HEADER_HEIGHT + _trackList.length * Settings.TRACK_HEIGHT;
			//t.alpha = 0;
			
			// add to the lists
			_trackSpr.addChild(t);
			_trackList.push(t);
			_recountHeight();
			
			// add event listeners
			t.addEventListener(TrackEvent.KILL, _onTrackKill, false, 0, true);
			t.addEventListener(TrackEvent.REFRESH, _onTrackRefresh, false, 0, true);
			
			// animate
			//Tweener.addTween(t, {alpha:1, time:Settings.STAGE_HEIGHT_CHANGE_TIME});
			
			return t;
		}

		
		
		public function createUploadTrack():void {
			if(_type != TrackCommon.STANDARD_TRACK) {
				throw new Error('Could not add upload track to record track container.');
			}
			Logger.info('Creating upload track');
			
			// create this track on the server
			_trackCreateService = new TrackCreateService();
			_trackCreateService.url = App.connection.serverPath + App.connection.configService.trackCreateRequestURL; /// XXX REMOVE ME
			_trackCreateService.addEventListener(RemotingEvent.REQUEST_FAILED, _onTrackCreateFailed, false, 0, true);
			_trackCreateService.addEventListener(TrackCreateEvent.REQUEST_DONE, _onUploadTrackCreateDone, false, 0, true);
			_trackCreateService.request();
		}
		
		
		
		private function _onUploadTrackCreateDone(event:TrackCreateEvent):void {
			Logger.info(sprintf("Track %u created on the server", event.trackData.trackID));

			// create track
			var t:StandardTrack = createTrack(event.trackData.trackID) as StandardTrack;
			t.trackData = event.trackData;
			t.load();
				
			// dispatch
			dispatchEvent(new ContainerEvent(ContainerEvent.UPLOAD_TRACK_READY, true, false, {track:t}));
			dispatchEvent(new ContainerEvent(ContainerEvent.TRACK_ADDED, true, false, {trackData:event.trackData}));
			
			dispatchEvent(new AppEvent(AppEvent.REFRESH_TOP_PANE, true, false));
		}		

		
		
		/**
		 * Create new record track.
		 * @return New track
		 * @throws Error if could not add record track
		 */
		public function createRecordTrack():void {
			if(_type != TrackCommon.RECORD_TRACK) {				
				throw new Error('Could not add record track to standard track container.');
			}
			Logger.info('Creating record track');

			// create this track on the server
			_trackCreateService = new TrackCreateService();
			_trackCreateService.url = App.connection.serverPath + App.connection.configService.trackCreateRequestURL; /// XXX REMOVE ME
			_trackCreateService.addEventListener(RemotingEvent.REQUEST_FAILED, _onTrackCreateFailed, false, 0, true);
			_trackCreateService.addEventListener(TrackCreateEvent.REQUEST_DONE, _onRecordTrackCreateDone, false, 0, true);
			_trackCreateService.request();
		}
				
		
		
		private function _onRecordTrackCreateDone(event:TrackCreateEvent):void {
			Logger.info(sprintf("Track %u created on the server", event.trackData.trackID));

			// create track
			var t:RecordTrack = createTrack(event.trackData.trackID) as RecordTrack;
			t.trackData = event.trackData;
			t.load();
				
			// dispatch
			dispatchEvent(new ContainerEvent(ContainerEvent.RECORD_TRACK_READY, true, false, {track:t}));
			dispatchEvent(new ContainerEvent(ContainerEvent.TRACK_ADDED, true, false, {trackData:event.trackData}));
			
			dispatchEvent(new AppEvent(AppEvent.REFRESH_TOP_PANE, true, false));
		}
		
		
		
		private function _onTrackCreateFailed(event:Event):void {
			App.messageModal.show({title:"Something is wrong", description:"Track create service failed",
				buttons:MessageModal.BUTTONS_RELOAD, icon:MessageModal.ICON_ERROR});
		}



		/**
		 * Kill track by it's ID.
		 * @param id Track ID to be killed
		 */
		public function killTrack(id:uint):void {
			var t:TrackCommon;
			// remove track
			var i:int = 0;
			var j:int = -1;
			for each(t in _trackList) {
				if(t.trackID == id && t.isEnabled) {
					try {
						j = i;
						t.removeEventListener(TrackEvent.KILL, _onTrackKill);
						t.destroy();
					}
					catch(err1:Error) {
						Logger.error(sprintf('Error removing track #%u:\n%s', i, err1.message));
					}
				}
				i++;
			}
			if(j != -1) _trackList.splice(j, 1);
			
			// remove from queue
			var k:int = 0;
			var l:int = -1;

			for each(var q:Object in _trackQueue) {
				if(q.trackID == id) {
					l = k;
					if(q.service) {
						q.service.removeEventListener(TrackFetchEvent.REQUEST_DONE, _onTrackFetchDone);
						q.service.removeEventListener(RemotingEvent.REQUEST_FAILED, _onTrackFetchFailed);
					}
				}
				k++;
			}
			if(l != -1) _trackQueue.splice(l, 1);
			
			// reposition
			var idx:uint = 0;
			for each(t in _trackList) {
				if(t.isEnabled) {
					var my:uint = Settings.TRACK_CONTAINER_HEADER_HEIGHT + idx * Settings.TRACK_HEIGHT;
					Tweener.addTween(t, {y:my, time:$morphTime, rounded:true, transition:'easeInOutQuad'});
					idx++;
				}
			}
			
			// recount current height
			_recountHeight();
			
			// dispatch			
			dispatchEvent(new ContainerEvent(ContainerEvent.TRACK_KILL, true));
		}

		
		
		/**
		 * Morph.
		 * @param c Morph config Object
		 */
		override public function morph(c:Object):void {
			cacheAsBitmap = true;
			Tweener.addTween(this, {time:$morphTime, onComplete:function():void {
				cacheAsBitmap = false;
			}});
			super.morph(c);
		}

		
		
		/**
		 * Refresh container.
		 * @param sd Song data
		 */
		private function _refreshWaveforms():void {
			var max:uint = this.milliseconds;
			var t:TrackCommon;

			for each(t in _trackList) {
				t.rescale(max);
			}
		}
		
		
		
		/**
		 * Play container.
		 */
		public function play():void {
			for each(var t:TrackCommon in _trackList) {
				// play all tracks in the container
				try {
					if(t.isEnabled) t.play();
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
			for each(var t:TrackCommon in _trackList) {
				// stop all tracks in the container
				try {
					if(t.isEnabled) t.stop();
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
			for each(var t:TrackCommon in _trackList) {
				// pause all tracks in the container
				try {
					if(t.isEnabled) t.pause();
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
			for each(var t:TrackCommon in _trackList) {
				// resume all tracks in the container
				try {
					if(t.isEnabled) t.resume();
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
		public function seek(position:uint):void {
			for each(var t:TrackCommon in _trackList) {
				// seek all tracks in the container
				try {
					if(t.isEnabled) t.seek(position);
				}
				catch(err:Error) {
					// something went wrong, grr
					Logger.warn(sprintf('Problem trying to seek playback of %s:\n%s', t.toString(), err.message));
				}
			}
		}
		
		
		
		public function getTrack(idx:uint):StandardTrack {
			try {
				var tr:StandardTrack = _trackList[idx] as StandardTrack;
			}
			catch(err:Error) {
				return null;
			}
			
			return tr;
		}

		
		
		/**
		 * Get container type.
		 * @return Container type (TrackCommon.STANDARD_TRACK or TrackCommon.RECORD_TRACK)
		 */
		public function get type():String {
			return _type;
		}

		
		
		/**
		 * Get content height.
		 * @return Content height
		 */
		public function get contentHeight():Number {
			return _contentHeight;
		}

		
		
		/**
		 * Get height.
		 * @return Height
		 */
		override public function get height():Number {
			return _contentHeight;
		}

		
		
		/**
		 * Get track count.
		 * @return Track count
		 */
		public function get trackCount():uint {
			var c:uint = 0;
			for each(var t:TrackCommon in _trackList) if(t.isEnabled) c++;
			return c;
		}

		
		
		/**
		 * Get current sample position.
		 * @author Shimray Current sample position.
		 */
		public function get position():uint {
			var c:uint = 0;
			for each(var t:TrackCommon in _trackList) if(t.isEnabled) c = Math.max(c, t.position);
			return c;
		}


		
		public function get milliseconds():uint {
			var max:uint = 0;
			var t:TrackCommon;

			for each(t in _trackList) {
				if(t.trackData)
					max = Math.max(max, t.trackData.trackMilliseconds); 
			}			
			return max;
		}

		
		
		/**
		 * Recount height.
		 */
		private function _recountHeight():void {
			var h:Number = Settings.TRACK_CONTAINER_HEADER_HEIGHT;

			for each(var t:TrackCommon in _trackList) {
				try {
					if(t.isEnabled) h += Settings.TRACK_HEIGHT + Settings.TRACK_MARGIN;
				}
				catch(err:Error) {
					Logger.warn(sprintf('Problem trying to recount height of %s:\n%s', t.toString(), err.message));
				}
			}
			
			_contentHeight = h;

			dispatchEvent(new ContainerEvent(ContainerEvent.CONTENT_HEIGHT_CHANGE, true));
		}
		
		

		/**
		 * Song fetch done event handler.
		 * @param event Event data
		 */
		private function _onSongFetchDone(event:SongFetchEvent):void {
			for each(var s:Object in _songQueue) {
				if(s.songID == event.songData.songID) {
					Logger.debug(sprintf('Song info of songID %u loaded, adding all %u tracks', event.songData.songID, event.songData.songTracks.length));
					
					// add tracks
					for each(var td:TrackData in event.songData.songTracks) {
						try {
							addStandardTrackByTD(td);
						}
						catch(err:Error) {
							App.messageModal.show({title:'Add song', description:err.message, buttons:MessageModal.BUTTONS_OK, icon:MessageModal.ICON_WARNING}); 
						}
					}
					
					_refreshWaveforms();
				}
			}
		}

		
		
		/**
		 * Track fetch done event handler.
		 * @param event Event data
		 */
		private function _onTrackFetchDone(event:TrackFetchEvent):void {
			// set track loaded flag
			//for each(var t:Object in _trackQueue) {
			//	if(t.trackID == event.trackData.trackID) {
			//		event.trackData.trackVolume = (t.volume == undefined) ? .9 : t.volume;
			//		event.trackData.trackBalance = (t.balance == undefined) ? 0 : t.balance;
			//	}
			//}
			
			// crawl all track in the container
			for each(var p:TrackCommon in _trackList) {
				// check for the current track
				if(p.trackID == event.trackData.trackID) {
					// it's found, update it
					// set track data
					p.trackData = event.trackData;

					// load sample and waveform
					p.load();
					
					_refreshWaveforms();
					
					// dispatch events
					dispatchEvent(new ContainerEvent(ContainerEvent.TRACK_ADDED, true, false, {trackData:event.trackData}));					
				}
			}
		}

		
		
		/**
		 * Song fetch failed event handler.
		 * @param event Event data
		 */
		private function _onSongFetchFailed(event:RemotingEvent):void {
			dispatchEvent(new ContainerEvent(ContainerEvent.SONG_FETCH_FAILED, false, false, {description:event.description}));
		}

		
		
		/**
		 * Track fetch failed event handler.
		 * @param event Event data
		 */
		private function _onTrackFetchFailed(event:RemotingEvent):void {
			dispatchEvent(new ContainerEvent(ContainerEvent.TRACK_FETCH_FAILED, false, false, {description:event.description}));
		}

		
		
		/**
		 * Track kill event handler.
		 * @param event Event data
		 */
		private function _onTrackKill(event:TrackEvent):void {
			var t:TrackCommon = event.target as TrackCommon;
			killTrack(t.trackID);
			_refreshWaveforms();
		}
		
		
		
		private function _onTrackRefresh(event:TrackEvent):void {
			_refreshWaveforms();
		}
		
		
		
		/**
		 * Top HTML pane was updated.
		 */
		private function _onRefreshTopPane(event:Event = null):void {
			dispatchEvent(new AppEvent(AppEvent.REFRESH_TOP_PANE, true));
		}
	}
}
