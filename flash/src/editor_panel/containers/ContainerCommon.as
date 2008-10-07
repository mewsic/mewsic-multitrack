package editor_panel.containers {
	import application.App;
	import application.AppEvent;
	
	import caurina.transitions.Tweener;
	
	import config.Embeds;
	import config.Settings;
	
	import editor_panel.tracks.RecordTrack;
	import editor_panel.tracks.StandardTrack;
	import editor_panel.tracks.TrackCommon;
	import editor_panel.tracks.TrackEvent;
	
	import modals.MessageModal;
	
	import remoting.data.SongData;
	import remoting.data.TrackData;
	import remoting.data.UserData;
	import remoting.dynamic_services.SongFetchService;
	import remoting.dynamic_services.SongLoadService;
	import remoting.dynamic_services.SongUnloadService;
	import remoting.dynamic_services.TrackFetchService;
	import remoting.events.RemotingEvent;
	import remoting.events.SongFetchEvent;
	import remoting.events.TrackFetchEvent;
	
	import de.popforge.utils.sprintf;
	
	import com.gskinner.utils.Rnd;
	
	import org.osflash.thunderbolt.Logger;
	import org.vancura.graphics.MorphSprite;
	import org.vancura.graphics.QBitmap;
	import org.vancura.graphics.QSprite;
	import org.vancura.util.addChildren;
	
	import flash.events.Event;	

	
	
	/**
	 * Container
	 * 
	 * @author Vaclav Vancura (http://vaclav.vancura.org)
	 * @since Jun 20, 2008
	 */
	public class ContainerCommon extends MorphSprite {

		
		
		private var _trackSpr:QSprite;
		private var _viewportBackBM:QBitmap;
		private var _viewportGradsBM:QBitmap;
		private var _trackList:Array = new Array();
		private var _contentHeight:Number = 0;
		private var _type:String;
		private var _header:ContainerHeaderCommon;
		private var _songQueue:Array = new Array();
		private var _trackQueue:Array = new Array();

		
		
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
			if(_type == TrackCommon.STANDARD_TRACK) _header = new StandardContainerHeader(_type);
			else _header = new RecordContainerHeader(_type);
			
			_trackSpr = new QSprite();
			_viewportBackBM = new QBitmap({x:520, height:1200, embed:new Embeds.viewportBackBD()});
			_viewportGradsBM = new QBitmap({x:520, height:1200, embed:new Embeds.viewportGradsBD()});

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
				addChildren(this, _viewportBackBM, _viewportGradsBM, _trackSpr, _header);
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
				_songQueue.push({songID:id, isLoaded:false, service:service});

				// load song
				service.url = App.connection.serverPath + App.connection.configService.songEditRequestURL;
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
		public function addStandardTrack(id:uint):void {
			if(_type == TrackCommon.STANDARD_TRACK) {
				// check for track dupe
				for each(var t:Object in _trackQueue) {
					// crawl through all tracks in the queue
					if(t.trackID == id) {
						// track is duped,
						// show alert window
						App.messageModal.show({title:'Add track', description:'Track already loaded', buttons:MessageModal.BUTTONS_OK, icon:MessageModal.ICON_WARNING});
						return;
					}
				}
				
				// track is not duped
				// so let's continue
				Logger.info(sprintf('Adding standard track (trackID=%u)', id));
				
				// create track
				createTrack(id);
				
				// request track info
				try {
					// add track fetch service
					var service:TrackFetchService = new TrackFetchService();
					
					// add to track queue to prevent dupes
					_trackQueue.push({trackID:id, isLoaded:false, service:service});
				
					// load track
					service.url = App.connection.serverPath + App.connection.configService.trackFetchRequestURL;
					service.addEventListener(TrackFetchEvent.REQUEST_DONE, _onTrackFetchDone, false, 0, true);
					service.addEventListener(RemotingEvent.REQUEST_FAILED, _onTrackFetchFailed, false, 0, true);
					service.request({trackID:id});
				}
				catch(err:Error) {
					// something went wrong
					// show alert window
					App.messageModal.show({title:'Add track', description:sprintf('Could not add track.\n%s', err.message), buttons:MessageModal.BUTTONS_OK, icon:MessageModal.ICON_WARNING});
				}
			}
			else {
				App.messageModal.show({title:'Add track', description:'Could not add standard track to record track container.', buttons:MessageModal.BUTTONS_OK, icon:MessageModal.ICON_WARNING});
			}
		}

		
		
		/**
		 * Add standard track by it's track data.
		 * @param td Track data
		 * @throws Error if track is already in the queue.
		 */
		public function addStandardTrackByTD(td:TrackData):void {
			if(_type == TrackCommon.STANDARD_TRACK) {
				// check for track dupe
				for each(var t:Object in _trackQueue) {
					// crawl through all tracks in the queue
					if(t.trackID == td.trackID) {
						// track is duped
						// throw error
						throw new Error('Track already loaded.');
					}
				}
				
				// it's not duped.
				// so let's continue
				Logger.info(sprintf('Adding track from track data (trackID=%u, balance=%.2f, volume=%.2f)', td.trackID, td.trackBalance, td.trackVolume));
				
				// add to track queue to prevent dupes
				_trackQueue.push({trackID:td.trackID, isLoaded:true, balance:td.trackBalance, volume:td.trackVolume});
				
				// check for record or standard and create tracks
				createTrack(td.trackID);
				
				// update core song
				var i:uint = App.connection.coreSongData.songTracks.push(td);
				for each(var p:TrackCommon in _trackList) if(p.trackID == td.trackID) {
					p.trackData = App.connection.coreSongData.songTracks[i - 1];
					p.load();
				}
				
				// dispatch events
				dispatchEvent(new ContainerEvent(ContainerEvent.SET_GLOBAL_TEMPO, false, false, {tempo:td.trackBPM}));
				dispatchEvent(new ContainerEvent(ContainerEvent.TRACK_ADDED, true, false, {trackData:td}));
				dispatchEvent(new AppEvent(AppEvent.REFRESH_TOP_PANE, true));
			}
		}

		
		
		/**
		 * Create new track.
		 * @param id Track ID
		 * @return New track
		 */
		public function createTrack(id:uint):TrackCommon {
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
			t.y = 46 + _trackList.length * 52;
			t.alpha = 0;
			
			// add to the lists
			_trackSpr.addChild(t);
			_trackList.push(t);
			_recountHeight();
			
			// add event listeners
			t.addEventListener(TrackEvent.KILL, _onTrackKill, false, 0, true);
			t.addEventListener(TrackEvent.MUTE_OFF, _onTrackMuteOff, false, 0, true);
			t.addEventListener(TrackEvent.MUTE_ON, _onTrackMuteOn, false, 0, true);
			t.addEventListener(TrackEvent.SOLO_OFF, _onTrackSoloOff, false, 0, true);
			t.addEventListener(TrackEvent.SOLO_ON, _onTrackSoloOn, false, 0, true);
			
			// animate
			Tweener.addTween(t, {alpha:1, time:Settings.STAGE_HEIGHT_CHANGE_TIME * 1.5, delay:Settings.STAGE_HEIGHT_CHANGE_TIME * .5});
			
			return t;
		}

		
		
		/**
		 * Create new record track.
		 * @return New track
		 * @throws Error if could not add record track
		 */
		public function createRecordTrack():RecordTrack {
			if(_type == TrackCommon.RECORD_TRACK) {
				var t:RecordTrack;
				
				Logger.info('Adding record track');
				
				// create track data
				var td:TrackData = new TrackData();
				td.trackAuthor = App.connection.coreUserData.userNickname;
				td.trackBalance = 0;
				td.trackBPM = App.connection.coreSongData.songBPM;
				td.trackDescription = '';
				td.trackGenreID = 0;
				td.trackID = Rnd.integer(10000, 99999);
				td.trackInstrumentID = 0;
				td.trackKey = '';
				td.trackRating = 0;
				td.trackSampleURL = '';
				td.trackMilliseconds = 0;
				td.trackSongsCount = 0;
				td.trackSongsCount = 0;
				td.trackTitle = 'Untitled';
				td.trackUserNickname = App.connection.coreUserData.userNickname;
				td.trackVolume = .9;
				td.trackWaveformURL = '';
				
				// create track
				createTrack(td.trackID);
				
				// update core song
				var i:uint = App.connection.coreSongData.songTracks.push(td);
				for each(var p:RecordTrack in _trackList) if(p.trackID == td.trackID) {
					t = p;
					p.trackData = App.connection.coreSongData.songTracks[i - 1];
					p.load();
				}
				
				// dispatch
				dispatchEvent(new ContainerEvent(ContainerEvent.TRACK_ADDED, true, false, {trackData:td}));
				dispatchEvent(new AppEvent(AppEvent.REFRESH_TOP_PANE, true, false));
				
				return t;
			}
			else {
				throw new Error('Could not add record track to standard track container.');
			}
		}

		
		
		/**
		 * Kill track by it's ID.
		 * @param id Track ID to be killed
		 */
		public function killTrack(id:uint):void {
			// call song unload service
			try {
				var service:SongUnloadService = new SongUnloadService();
				service.url = App.connection.serverPath + App.connection.configService.songUnloadRequestURL;
				service.addEventListener(RemotingEvent.REQUEST_DONE, _onRefreshTopPane, false, 0, true);
				service.request({songID:App.connection.coreSongData.songID, trackID:id});
			}
			catch(err:Error) {
				// something went wrong
				Logger.warn(sprintf('Error unloading track:\n%s', err.message));
			}

			// remove track
			var i:int = 0;
			var j:int = -1;
			for each(var t:TrackCommon in _trackList) {
				if(t.trackID == id && t.isEnabled) {
					try {
						j = i;
						t.removeEventListener(TrackEvent.KILL, _onTrackKill);
						t.removeEventListener(TrackEvent.MUTE_OFF, _onTrackMuteOff);
						t.removeEventListener(TrackEvent.MUTE_ON, _onTrackMuteOn);
						t.removeEventListener(TrackEvent.SOLO_OFF, _onTrackSoloOff);
						t.removeEventListener(TrackEvent.SOLO_ON, _onTrackSoloOn);
						t.destroy();
					}
					catch(err1:Error) {
						Logger.error(sprintf('Error removing track #%u:\n%s', i, err1.message));
					}
				}
				i++;
			}
			if(j != -1) _trackList.splice(j, 1);
			
			// remove fron core song
			for(var m:uint = 0;m < App.connection.coreSongData.songTracks.length; m++) {
				if(App.connection.coreSongData.songTracks[m].trackID == id) App.connection.coreSongData.songTracks.splice(m, 1);
			}
			
			// remove from queue
			var k:int = 0;
			var l:int = -1;
			for each(var q:Object in _trackQueue) {
				if(q.trackID == id) {
					try {
						l = k;
						q.service.removeEventListener(TrackFetchEvent.REQUEST_DONE, _onTrackFetchDone);
						q.service.removeEventListener(RemotingEvent.REQUEST_FAILED, _onTrackFetchFailed);
						q.service.destroy();
					}
					catch(err2:Error) {
						Logger.error(sprintf('Error removing track #%u from the queue:\n', k, err2.message));
					}
				}
				k++;
			}
			if(l != -1) _trackQueue.splice(l, 1);
			
			// reposition
			var idx:uint = 0;
			for each(var s:TrackCommon in _trackList) {
				if(s.isEnabled) {
					var my:uint = 46 + idx * 52;
					Tweener.addTween(s, {y:my, time:$morphTime, rounded:true, transition:'easeInOutQuad'});
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
		public function refresh(sd:SongData):void {
			_header.setData(sd);
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
			return _contentHeight + 14;
		}

		
		
		/**
		 * Get header.
		 * @return Header
		 */
		public function get header():ContainerHeaderCommon {
			return _header;
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

		
		
		/**
		 * Scroll to.
		 * @param px Scroll position
		 */
		public function scrollTo(px:int):void {
			for each(var t:TrackCommon in _trackList) {
				try { 
					if(t.isEnabled) t.scrollTo(px); 
				}
				catch(err:Error) {
					Logger.warn(sprintf('Problem trying to set scrolling position of %s:\n%s', t.toString(), err.message));
				}
			}
		}

		
		
		/**
		 * Recount height.
		 */
		private function _recountHeight():void {
			var h:Number = 46;

			for each(var t:TrackCommon in _trackList) {
				try {
					if(t.isEnabled) if(t) h += 52;
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
					
					s.isLoaded = true;
				}
			}
		}

		
		
		/**
		 * Track fetch done event handler.
		 * @param event Event data
		 */
		private function _onTrackFetchDone(event:TrackFetchEvent):void {
			// set track loaded flag
			for each(var t:Object in _trackQueue) {
				if(t.trackID == event.trackData.trackID) {
					t.isLoaded = true;
					event.trackData.trackVolume = (t.volume == undefined) ? .9 : t.volume;
					event.trackData.trackBalance = (t.balance == undefined) ? 0 : t.balance;
				}
			}
			
			// update core song
			App.connection.coreSongData.songTracks.push(event.trackData);
			
			// crawl all track in the container
			for each(var p:TrackCommon in _trackList) {
				// check for the current track
				if(p.trackID == event.trackData.trackID) {
					// it's found, update it
					// set track data
					p.trackData = App.connection.coreSongData.songTracks[App.connection.coreSongData.songTracks.length - 1];
					
					// load sample and waveform
					p.load();
					
					// dispatch events
					dispatchEvent(new ContainerEvent(ContainerEvent.SET_GLOBAL_TEMPO, false, false, {tempo:event.trackData.trackBPM}));
					dispatchEvent(new ContainerEvent(ContainerEvent.TRACK_ADDED, true, false, {trackData:event.trackData}));
					
					// call song load service
					try {
						var service:SongLoadService = new SongLoadService();
						service.url = App.connection.serverPath + App.connection.configService.songLoadRequestURL;
						service.addEventListener(RemotingEvent.REQUEST_DONE, _onRefreshTopPane, false, 0, true);
						service.request({songID:App.connection.coreSongData.songID, trackID:event.trackData.trackID});
					}
					catch(err:Error) {
						// something went wrong
						Logger.warn(sprintf('Error loading track:\n%s', err.message));
					}
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
		}

		
		
		/**
		 * Track mute off event handler.
		 * Unused right now.
		 * @param event Event data
		 */
		private function _onTrackMuteOff(event:TrackEvent):void {
			for each(var t:TrackCommon in _trackList) {
				if(t.isEnabled) {
					if(t == event.target) {
						t.isMuted = false;
					}
				}
			}
		}

		
		
		/**
		 * Track mute on event handler.
		 * @param event Event data
		 */
		private function _onTrackMuteOn(event:TrackEvent):void {
			for each(var t:TrackCommon in _trackList) {
				if(t.isEnabled) {
					if(!t.isMuted) t.isSolo = false;
					if(t == event.target) t.isMuted = true;
				}
			}
		}

		
		
		/**
		 * Track solo off event handler.
		 * Unused right now
		 * @param event Event data
		 */
		private function _onTrackSoloOff(event:TrackEvent):void {
			for each(var t:TrackCommon in _trackList) {
				if(t.isEnabled) {
					t.isSolo = false;
				}
			}
		}

		
		
		/**
		 * Track solo on event handler.
		 * @param event Event data
		 */
		private function _onTrackSoloOn(event:TrackEvent):void {
			for each(var t:TrackCommon in _trackList) {
				if(t.isEnabled) {
					t.isSolo = (t == event.target);
					if(t != event.target) t.isMuted = true;
				}
			}
		}

		
		
		/**
		 * Top HTML pane was updated.
		 */
		private function _onRefreshTopPane(event:Event = null):void {
			dispatchEvent(new AppEvent(AppEvent.REFRESH_TOP_PANE, true));
		}
	}
}
