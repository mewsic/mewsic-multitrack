package editor_panel {
	import application.App;
	import application.AppEvent;
	import application.PanelCommon;
	
	import caurina.transitions.Tweener;
	
	import config.Embeds;
	import config.Settings;
	import config.Formats;
	import config.Filters;
	
	import controls.Button;
	import controls.MorphSprite;
	import controls.Slider;
	import controls.SliderEvent;
	import controls.Toolbar;
	import controls.VUMeter;
	
	import de.popforge.utils.sprintf;
	
	import editor_panel.containers.ContainerCommon;
	import editor_panel.containers.ContainerEvent;
	import editor_panel.ruler.Playhead;
	import editor_panel.ruler.Ruler;
	import editor_panel.sampler.SamplerEvent;
	import editor_panel.tracks.RecordTrack;
	import editor_panel.tracks.TrackCommon;
	import editor_panel.tracks.TrackEvent;
	
	import flash.display.Bitmap;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.media.SoundMixer;
	import flash.media.SoundTransform;
	import flash.system.Capabilities;
	import flash.utils.ByteArray;
	import flash.utils.setTimeout;
	
	import modals.MessageModal;
	
	import org.osflash.thunderbolt.Logger;
	import org.vancura.graphics.Drawing;
	import org.vancura.graphics.QBitmap;
	import org.vancura.graphics.QTextField;
	import org.vancura.util.addChildren;
	
	import remoting.data.TrackData;
	import remoting.events.UserEvent;	

	
	
	/**
	 * Editor panel.
	 * 
	 * TODO: Write documentation
	 * 
	 * @author Vaclav Vancura (http://vaclav.vancura.org)
	 * @since Jun 14, 2008
	 */
	public class Editor extends PanelCommon {

		
		
		// playback machine consts
		private static const _SEEK_STEP:uint = 10000;
		private static const _VIEWPORT_MOVE_INTERVAL:uint = 250;
		
		private static const _STILL_SEEK_TIMEOUT:uint = 600;
		private static const _STILL_SEEK_INTERVAL:uint = 300;
		private static const _STILL_SEEK_STEP:uint = 10000;
		
		// editor machine state definitions
		private static const _STATE_STOPPED:uint   = 0x0;
		private static const _STATE_PLAYING:uint   = 0x2;
		private static const _STATE_PAUSED:uint    = 0x3;
		private static const _STATE_WAIT_REC:uint  = 0x4;
		private static const _STATE_RECORDING:uint = 0x5;
		
		private var _state:uint;
		
		private var _scroller:Scroller;
		private var _playhead:Playhead;
		private var _containersMaskSpr:MorphSprite;
		private var _playheadMaskSpr:MorphSprite;
		private var _headerSpr:MorphSprite;
		private var _containersContentSpr:MorphSprite;
		private var _footerSpr:MorphSprite;

		// Controller toolbar
		private var _controllerToolbar:Toolbar;
		private var _controllerPlayBtn:Button;
		private var _controllerPlayTF:QTextField;
		private var _controllerRecordBtn:Button;
		private var _controllerRecordTF:QTextField;
		private var _controllerSearchBtn:Button;
		private var _controllerSearchTF:QTextField;
		private var _controllerUploadBtn:Button;
		private var _controllerUploadTF:QTextField;

		// Vu meter
		private var _globalVUToolbar:Toolbar;
		
		// Volume toolbar - remove me
		private var _globalVolumeToolbar:Toolbar;

		private var _globalVolumeSlider:Slider;
		private var _globalVUMeter:VUMeter;

		private var _topDivBM:QBitmap;

		private var _standardContainer:ContainerCommon;
		private var _recordContainer:ContainerCommon;

		private var _width:uint;
		private var _currentScrollPos:int;
		private var _milliseconds:uint;

		private var _completedTracksCounter:uint;
		private var _recordTrack:RecordTrack;

		private var _beatClicker:BeatClicker;

		private var _lastViewportBang:int;
		private var _isStillSeekBtnPressed:Boolean;
		private var _stillSeekTimeout:uint;
		private var _stillSeekInterval:uint;

		private var _vuMeterBytes:ByteArray;
		private var _isVUMeterEnabled:Boolean;

		private var _recordLimit:uint;
		private var _isStreamDown:Boolean;

		
		
		/**
		 * Constructor.
		 */
		public function Editor() {
			$panelID = 'panelEditor';
			_vuMeterBytes = new ByteArray();
			_isVUMeterEnabled = (Capabilities.version.indexOf('MAC') == -1);
			
			super();
			
			setBackType(BACK_TYPE_WHITE);
		}

		
		
		/**
		 * Config is loaded, launch it.
		 */
		public function launch():void {
			// add masks
			_containersMaskSpr = new MorphSprite({y:85, morphTime:Settings.STAGE_HEIGHT_CHANGE_TIME, morphTransition:'easeInOutQuad'});
			_playheadMaskSpr = new MorphSprite({y:53, morphTime:Settings.STAGE_HEIGHT_CHANGE_TIME, morphTransition:'easeInOutQuad'});

			// add modules
			_playhead = new Playhead({x:521, y:53, mask:_playheadMaskSpr});
			_scroller = new Scroller({y:204, morphTime:Settings.STAGE_HEIGHT_CHANGE_TIME, morphTransition:'easeInOutQuad'});
			_beatClicker = new BeatClicker();

			// add parts
			_headerSpr = new MorphSprite();
			_containersContentSpr = new MorphSprite({y:129, mask:_containersMaskSpr});
			_footerSpr = new MorphSprite({y:224, morphTime:Settings.STAGE_HEIGHT_CHANGE_TIME, morphTransition:'easeInOutQuad'});

			// add top panel background
			_topDivBM = new QBitmap({y:5, embed:new Embeds.backgroundTopGrey()});

			// add controller toolbar
			_controllerToolbar = new Toolbar({x:0, y:15});

			_controllerPlayBtn = new Button({width:78, height:49, iconOffset:10,
				skin:new Embeds.buttonPlayLarge(), icon:new Embeds.glyphPlayLarge()});
				
			_controllerPlayTF = new QTextField({x:0, y:10, height:40, width:85,
				defaultTextFormat:Formats.controllerText, filters:Filters.controllerText,
				sharpness:-25, thickness:-50, text:'Play all instruments'}); 
			

			_controllerRecordBtn = new Button({width:78, height:49, iconOffset:8,
				skin:new Embeds.buttonRecordLarge(), icon:new Embeds.glyphRecordLarge()});
				
			_controllerRecordTF = new QTextField({x:0, y:5, height:50, width:85,
				defaultTextFormat:Formats.controllerText, filters:Filters.controllerText,
				sharpness:-25, thickness:-50, text:'Record your voice or instrument'}); 
			
		
			_controllerSearchBtn = new Button({width:78, height:49, iconOffset:8,
				skin:new Embeds.buttonSearchLarge(), icon:new Embeds.glyphSearchLarge()});

			_controllerSearchTF = new QTextField({x:0, y:5, height:50, width:85,
				defaultTextFormat:Formats.controllerText, filters:Filters.controllerText,
				sharpness:-25, thickness:-50, text:'Search mixable instruments'}); 

				
			_controllerUploadBtn = new Button({width:78, height:49, iconOffset:8,
				skin:new Embeds.buttonUploadLarge(), icon:new Embeds.glyphUploadLarge()});

			_controllerUploadTF = new QTextField({x:0, y:10, height:40, width:85,
				defaultTextFormat:Formats.controllerText, filters:Filters.controllerText,
				sharpness:-25, thickness:-50, text:'Upload your instrument'}); 

			_controllerToolbar.addChildRight(_controllerPlayBtn);
			_controllerToolbar.addChildRight(_controllerPlayTF);
			_controllerToolbar.addChildRight(_controllerRecordBtn);
			_controllerToolbar.addChildRight(_controllerRecordTF);
			_controllerToolbar.addChildRight(_controllerSearchBtn);
			_controllerToolbar.addChildRight(_controllerSearchTF);
			_controllerToolbar.addChildRight(_controllerUploadBtn);
			_controllerToolbar.addChildRight(_controllerUploadTF);

			// add global volume toolbar
			//_globalVolumeToolbar = new Toolbar({x:249, y:15, paddingH:0, paddingV:0, skin:new Embeds.toolbarPlainBD()});
			//_globalVolumeSlider = new Slider({width:169, slideTime:1, marginBegin:19, marginEnd:19, backSkin:new Embeds.sliderVolumeHorizontalBD(), thumbSkin:new Embeds.buttonGlobalVolumeThumbBD});
			//_globalVolumeToolbar.addChildRight(_globalVolumeSlider);

			// add global vu meter toolbar
			_globalVUToolbar = new Toolbar({visible:_isVUMeterEnabled, x:130, y:12, width:255, height:32});
			_globalVUMeter = new VUMeter({x:8, y:8, skin:new Embeds.vuMeterHorizontalBD(), leds:30});
			_globalVUToolbar.addChild(_globalVUMeter);

			// add containers
			_standardContainer = new ContainerCommon(TrackCommon.STANDARD_TRACK);
			_recordContainer = new ContainerCommon(TrackCommon.RECORD_TRACK);
			_recordContainer.y = 60;
			Drawing.drawRect(_containersMaskSpr, 0, 0, Settings.STAGE_WIDTH, 121);
			Drawing.drawRect(_playheadMaskSpr, 0, 0, Settings.STAGE_WIDTH, 170);

			// align some toolbars right
			//_topToolbar.x = $canvasSpr.width - _topToolbar.width - 14;
			//_botToolbar.x = $canvasSpr.width - _botToolbar.width - 14;
			
			// deactivate the play button, it'll be enabled in _refreshVisual() after a
			// track is being added, via the _onContainerTrackAdded listener
			// 
			_disableButton(_controllerPlayBtn);
			
			// set default volume
			//_globalVolumeSlider.thumbPos = .9;
			
			// add to display list
			addChildren(_headerSpr, _topDivBM, _controllerToolbar/*, _globalVolumeToolbar*/);
			addChildren(_containersContentSpr, _standardContainer, _recordContainer);
			addChildren(_footerSpr, _globalVUToolbar);
			addChildren($canvasSpr, _headerSpr, _containersContentSpr, _playhead, _footerSpr, _scroller, _containersMaskSpr, _playheadMaskSpr);
			
			// add container event listeners
			_standardContainer.addEventListener(ContainerEvent.CONTENT_HEIGHT_CHANGE, _onContainerContentHeightChange, false, 0, true);
			_standardContainer.addEventListener(ContainerEvent.SONG_FETCH_FAILED, _onContainerSongFetchFailed, false, 0, true);
			_standardContainer.addEventListener(ContainerEvent.TRACK_FETCH_FAILED, _onContainerTrackFetchFailed, false, 0, true);
			_standardContainer.addEventListener(ContainerEvent.SONG_FETCH_FAILED, _onContainerSongFetchFailed, false, 0, true);
			_standardContainer.addEventListener(ContainerEvent.TRACK_ADDED, _onContainerTrackAdded, false, 0, true);
			_standardContainer.addEventListener(ContainerEvent.TRACK_KILL, _onContainerTrackKilled, false, 0, true);
			_standardContainer.addEventListener(SamplerEvent.PLAYBACK_COMPLETE, _onTrackPlaybackComplete, false, 0, true);
			_standardContainer.addEventListener(SamplerEvent.SAMPLE_ERROR, _onTrackSampleError, false, 0, true);
			_recordContainer.addEventListener(ContainerEvent.CONTENT_HEIGHT_CHANGE, _onContainerContentHeightChange, false, 0, true);
			_recordContainer.addEventListener(ContainerEvent.SONG_FETCH_FAILED, _onContainerSongFetchFailed, false, 0, true);
			_recordContainer.addEventListener(ContainerEvent.TRACK_FETCH_FAILED, _onContainerTrackFetchFailed, false, 0, true);
			_recordContainer.addEventListener(ContainerEvent.SONG_FETCH_FAILED, _onContainerSongFetchFailed, false, 0, true);
			_recordContainer.addEventListener(ContainerEvent.TRACK_ADDED, _onContainerTrackAdded, false, 0, true);
			_recordContainer.addEventListener(ContainerEvent.TRACK_KILL, _onContainerTrackKilled, false, 0, true);
			_recordContainer.addEventListener(SamplerEvent.PLAYBACK_COMPLETE, _onTrackPlaybackComplete, false, 0, true);
			_recordContainer.addEventListener(SamplerEvent.SAMPLE_ERROR, _onTrackSampleError, false, 0, true);
			_recordContainer.addEventListener(TrackEvent.RECORD_START, _onRecordStart, false, 0, true);
			_recordContainer.addEventListener(TrackEvent.RECORD_STOP, _onRecordStop, false, 0, true);
			
			// add scroller event listeners
			_scroller.addEventListener(SliderEvent.REFRESH, _onScrollerRefresh, false, 0, true);
			
			// add controller toolbar buttons event listeners
			_controllerPlayBtn.addEventListener(MouseEvent.CLICK, _onPlayButtonClick, false, 0, true);
			_controllerSearchBtn.addEventListener(MouseEvent.CLICK, _onSearchButtonClick, false, 0, true);
			_controllerRecordBtn.addEventListener(MouseEvent.CLICK, _onRecordButtonClick, false, 0, true);
			_controllerUploadBtn.addEventListener(MouseEvent.CLICK, _onUploadButtonClick, false, 0, true);

			// add playhead event listeners
			_playhead.addEventListener(Event.ENTER_FRAME, _onPlayheadRefresh, false, 0, true);
			
			// add global volume event listeners
			// _globalVolumeSlider.addEventListener(SliderEvent.REFRESH, _onGlobalVolumeRefresh, false, 0, true);
		}

		
		
		/**
		 * Refresh song data.
		 * Called from JavaScript when page information changes.
		 */
		public function refreshSongData():void {
			Logger.info('Refreshing song');
			_standardContainer.refresh(App.connection.coreSongData);
			_recordContainer.refresh(App.connection.coreSongData);
		}

		
		
		/**
		 * Initialize core song.
		 */
		public function postInit():void {
			Logger.info(sprintf('Initializing song (songID=%u)', App.connection.coreSongData.songID));
			_standardContainer.header.setData(App.connection.coreSongData);
			_recordContainer.header.setData(App.connection.coreSongData);
		}

		
		
		/**
		 * Add track.
		 * @param trackID Track ID
		 */
		public function addTrack(trackID:uint):void {
			// add standard track
			_standardContainer.addStandardTrack(trackID); 
			
			// refresh visual
			_refreshVisual();
		}

		
		
		/**
		 * Add song.
		 * @param songID Song ID
		 */
		public function addSong(songID:uint):void {
			// add song
			_standardContainer.addSong(songID); 
			
			// refresh visual
			_refreshVisual();
		}

		
		
		public function killRecordTrack():void {
			// kill track
			_state = _STATE_STOPPED;

			_recordContainer.killTrack(_recordTrack.trackID);
			_recordTrack = null;
			
			// refresh buttons states
			_refreshVisual();
		}

		
		
		/**
		 *  Behavioural callback for the Play button: plays if stopped,
		 *  sets pause if playing.
		 */
		private function _onPlayButtonClick(event:MouseEvent = null):void {
			if(allTrackCount == 0) {
				Logger.warn("Machine error: editor is empty");
				return;
			}
			
			switch(_state) {
				case _STATE_STOPPED:
					_state = _STATE_PLAYING;
					play();
					break;
					
				case _STATE_PLAYING:
					_state = _STATE_PAUSED;
					pause();
					break;
					
				case _STATE_PAUSED:
					_state = _STATE_PLAYING;
					resume();
					break;
					
				default:
					Logger.warn('Machine error: should be in STOP, PLAY or PAUSE state');
					return;
			}
		}

		/**
		 * Record track button clicked event handler.
		 * If stopped, add a new track lane and initialize microphone,
		 * asking user for permission.
		 * If recording, stop.
		 */
		private function _onRecordButtonClick(event:MouseEvent = null):void {
			// only logged in user can use recording
			//if(!App.connection.coreUserLoginStatus) {
			//	App.messageModal.show({title:'Record track', description:'Please log in or wait until the multitrack is fully loaded.', buttons:MessageModal.BUTTONS_OK});
			//	return;
			//}
						
			switch (_state) {
				case _STATE_STOPPED:
					// initialize microphone, when it is ready, the UserEvent.ALLOWED_MIKE
					// event is dispatched
					try {
						App.connection.streamService.prepare();
						App.connection.streamService.addEventListener(UserEvent.ALLOWED_MIKE, _onMicrophoneAllowed, false, 0, true);
						App.connection.streamService.addEventListener(UserEvent.DENIED_MIKE, _onMicrophoneDenied, false, 0, true);
	
						if(_recordTrack == null)
							_recordTrack = _recordContainer.createRecordTrack();

					}
					catch(err1:Error) {
						// something is blatantly wrong
						App.messageModal.show({title:'Record track', description:err1.message, buttons:MessageModal.BUTTONS_OK, icon:MessageModal.ICON_WARNING});
						return;
					}

					_state = _STATE_WAIT_REC;
					break;
					
				case _STATE_RECORDING:
					_state = _STATE_STOPPED;
					stop();
					
					break;
			}

			//dispatchEvent(new AppEvent(AppEvent.HIDE_DROPBOX, true));

			// refresh visual
			_refreshVisual();
		}
		
		private function _onMicrophoneAllowed(event:UserEvent = null):void {
			_state = _STATE_RECORDING;
			_recordTrack.startRecording();
			
			_refreshVisual();
		}
		
		private function _onMicrophoneDenied(event:UserEvent = null):void {
			_state = _STATE_STOPPED;
			this.killRecordTrack();
			
			_refreshVisual();
		}
		

		private function _onSearchButtonClick(event:MouseEvent = null):void {
			App.messageModal.show({title:'Show search', description:'now call the lightwindow in JS'});
		}
		
		
		/**
		 * Upload track button clicked event handler.
		 * Display upload trac modal.
		 * @param event Event data
		 */
		private function _onUploadButtonClick(event:MouseEvent = null):void {
			if(!App.connection.coreUserLoginStatus) {
				// user is not logged in, don't allow him to display My List
				App.messageModal.show({title:'Upload track', description:'Please log in or wait until the multitrack is fully loaded.', buttons:MessageModal.BUTTONS_OK});
				return;
			}
			App.uploadTrackModal.show();
			
			// dispatch
			dispatchEvent(new AppEvent(AppEvent.HIDE_DROPBOX, true));
		}

		
		
		/**
		 * Save song button clicked event handler.
		 * Display save song modal.
		 * @param event Event data
		 */
		private function _onSaveSongBtnClick(event:MouseEvent = null):void {
			if(!App.connection.coreUserLoginStatus) {
				// user is not logged in, don't allow him to display My List
				App.messageModal.show({title:'Save song', description:'Please log in or wait until the multitrack is fully loaded.', buttons:MessageModal.BUTTONS_OK});
				return;
			}
			App.saveSongModal.show();
			
			// dispatch
			dispatchEvent(new AppEvent(AppEvent.HIDE_DROPBOX, true));
		}



				
		
		/**
		 * Low-level play method, XXX: make it protected
		 */
		public function play(event:Event = null):void {
			Logger.info('Play!');

			_standardContainer.play();
			_beatClicker.play(); // XXX REMOVE ME
		}

		
		
		/**
		 * Low-level stop method.
		 */
		public function stop(event:Event = null):void {
			Logger.info('Stop playback.');
	
			_standardContainer.stop();
			_recordContainer.stop();
			_beatClicker.stop(); // XXX
			_scroller.position = 0;
		}

		
		
		/**
		 * Pause.
		 */
		public function pause(event:Event = null):void {
			Logger.info('Pause playback.');

			_standardContainer.pause();
			_beatClicker.pause();
		}

		
		
		/**
		 * Resume.
		 */
		public function resume(event:Event = null):void {
			Logger.info('Resume playback.');
			_standardContainer.resume();
			_beatClicker.resume();
		}

		
		
		/**
		 * Rewind the stage by _SEEK_STEP ms.
		 */
		public function rewind(event:Event = null):void {
			Logger.info('Rewind playback.');
			var p:uint = currentPosition - _SEEK_STEP;
			if(p < 0) p = 0;
			if(p > _milliseconds) p = 0;
			
			_standardContainer.seek(p);
			_beatClicker.seek(p);
		}

		
		
		/**
		 * Forward the stage by _SEEK_STEP ms. 
		 */
		public function forward(event:Event = null):void {
			Logger.info('Forward playback.');
			var p:uint = currentPosition + _SEEK_STEP;
			if(p > _milliseconds) p = _milliseconds;
			_standardContainer.seek(p);
			_beatClicker.seek(p);
		}

		
		
		public function seek(value:uint):void {
			if(value > _milliseconds) value = _milliseconds;
			if(value < 0) value = 0;
			
			Logger.info(sprintf('Seek playback (%u ms).', value));
			
			_standardContainer.seek(value);
			_beatClicker.seek(value);
			
			// refresh visual
			_refreshVisual();
			
			// autoscroll
			// after a while so the playhead has time to tween
			setTimeout(_autoScroll, 500 + 100);
		}

		
		
		public function disableStreamFunctions():void {
			Logger.info('Disabling stream functions.');
			
			_isStreamDown = true;
			_disableButton(_controllerRecordBtn);
		}

		
		
		public function alterMasterVolume(step:Number):void {
			_globalVolumeSlider.thumbPos += step;
		}

		
		
		public function alterPosition(step:Number):void {
			var p:uint = currentPosition + step * 1000;
			if(p < 0) p = 0;
			if(p > _milliseconds) p = 0;
			
			_standardContainer.seek(p);
			_beatClicker.seek(p);
			
			// refresh visual
			_refreshVisual();
		}

		

		/*		
		public function createAndRecord():void {
			if(_isRecording) return;
			if(_isPlaying) stop();
			if(_recordTrack == null) _onRecordTrackBtnClick();
			else _recordTrack.startRecording(); 
		}
		*/

		
		
		/*		
		public function export():void {
			if(allTrackCount > 0 && !_isPlaying && !_isRecording) _onExportSongBtnClick();
		}

		
		
		public function save():void {
			if(allTrackCount > 0 && !_isPlaying && !_isRecording) _onSaveSongBtnClick();
		}
		*/



		/**
		 * Get count of all tracks.
		 * @return All tracks count
		 */
		public function get allTrackCount():uint {
			return _standardContainer.trackCount + _recordContainer.trackCount;
		}

		
		
		public function get milliseconds():uint {
			return _milliseconds;
		}

		
		
		public function get currentScrollPos():int {
			return _currentScrollPos;
		}

		
		
		public function get currentPosition():uint {
			if(_recordContainer.trackCount > 0) {
				// recording first track
				if(_state == _STATE_PLAYING) return _recordContainer.position;
				return 0;
			} else {
				// standard track
				return _standardContainer.position;
			}
		}

		
		
		private function _setButtonActive(button:Button, active:Boolean):void {
			button.areEventsEnabled = active;
			button.alpha = active ? 1 : .4;
		}
		
		private function _enableButton(button:Button):void {
			_setButtonActive(button, true);
		} 
		
		private function _disableButton(button:Button):void {
			_setButtonActive(button, false);
		}
		
		private function _refreshVisual():void {
			// recound song length from core song data
			_recountSongLength();
			
			// set visual properties
			_scroller.isEnabled = (allTrackCount > 0 && _milliseconds > 44700);
			
			Logger.debug(sprintf('Current maximal waveform width is %d px', _width));
			Logger.debug(sprintf('Current song length is %f ms', _milliseconds));
			
			// set buttons states
			switch(_state) {
				case _STATE_STOPPED:
					// Set play active only if there's already a track loaded, enable all other buttons
					_setButtonActive(_controllerPlayBtn, allTrackCount > 0);
					_setButtonActive(_controllerRecordBtn, !App.connection.streamService.microphoneDenied);
					_enableButton(_controllerSearchBtn);
					_enableButton(_controllerUploadBtn);
					
					break;
					
				case _STATE_PLAYING:
					// Set pause glyph on play button, disable record and upload button
					// _setPauseGlyph()
					_disableButton(_controllerRecordBtn);
					_enableButton(_controllerSearchBtn);
					_enableButton(_controllerUploadBtn);
					
					break;
					
				case _STATE_PAUSED:
					// _setPayGlyph()
					_enableButton(_controllerRecordBtn);
					_enableButton(_controllerSearchBtn);
					_enableButton(_controllerUploadBtn);
					
					break;
				
				case _STATE_RECORDING:
					// _setStopGlyph()
					_disableButton(_controllerPlayBtn);
					_disableButton(_controllerSearchBtn);
					_disableButton(_controllerUploadBtn);
					
					break;
			}
			
			// dispatch
			dispatchEvent(new AppEvent(AppEvent.HIDE_DROPBOX, true));
		}

		
		
		private function _autoScroll():void {
			if((currentPosition - 40000 > currentScrollPos * -100) || (currentPosition + 40000 < currentScrollPos * -100)) {
				Logger.debug('Autoscrolling.');
				_scroller.position = 1 / ((_milliseconds - 44700) / (currentPosition - 6000));
			}
		}

		
		
		/**
		 * Container changed it's height event handler.
		 * Animate it
		 * @param event Event data
		 */
		private function _onContainerContentHeightChange(event:ContainerEvent):void {
			_recordContainer.morph({y:_standardContainer.height});
			_scroller.morph({y:_standardContainer.height + _recordContainer.height + _containersContentSpr.y});
			_footerSpr.morph({y:_standardContainer.height + _recordContainer.height + _containersContentSpr.y + 20});
			_containersMaskSpr.morph({height:_standardContainer.height + _recordContainer.height + 1});
			_playheadMaskSpr.morph({height:_standardContainer.height + _recordContainer.height + 50});

			$animateHeightChange(_standardContainer.height + _recordContainer.height + _containersContentSpr.y + 119);
		}

		
		
		/**
		 * Scroller moved event handler.
		 * @param event Event data
		 */
		private function _onScrollerRefresh(event:SliderEvent):void {
			if(_milliseconds > 44700) {
				_currentScrollPos = event.thumbPos * (_width - 447) * -1; 
				_standardContainer.scrollTo(_currentScrollPos);
				_recordContainer.scrollTo(_currentScrollPos);
			}
		}

		
		
		/**
		 * Container song fetch failed event handler.
		 * @param event Event data
		 */
		private function _onContainerSongFetchFailed(event:ContainerEvent):void {
			App.messageModal.show({title:'Add song', description:sprintf('Song fetch failed.\n%s', event.data.description), buttons:MessageModal.BUTTONS_OK, icon:MessageModal.ICON_WARNING});
			
			// refresh visual
			_refreshVisual();
		}

		
		
		/**
		 * Container track fetch failed event handler.
		 * @param event Event data
		 */
		private function _onContainerTrackFetchFailed(event:ContainerEvent):void {
			App.messageModal.show({title:'Add track', description:sprintf('Track fetch failed.\n%s', event.data.description), buttons:MessageModal.BUTTONS_OK, icon:MessageModal.ICON_WARNING});
			
			// refresh visual
			_refreshVisual();
		}

		
		
		private function _recountSongLength():void {
			if((_state == _STATE_RECORDING) && _standardContainer.trackCount == 0) {
				_milliseconds = _recordTrack.position;
			} else {
				_milliseconds = 0;
				for each(var td:TrackData in App.connection.coreSongData.songTracks) {
					_milliseconds = Math.max(_milliseconds, td.trackMilliseconds);
				}
			}
			_width = _milliseconds / 100;
		}

		
		
		/**
		 * Container track added event handler.
		 * @param event Event data
		 */
		private function _onContainerTrackAdded(event:ContainerEvent):void {
			// stop playback
			stop();
			
			// refresh buttons states
			_refreshVisual();
		}

		
		
		private function _onContainerTrackKilled(event:ContainerEvent):void {
			// stop playback
			stop();
			
			// refresh buttons states
			_refreshVisual();
		}

		
				
		/**
		 * Export song button clicked event handler.
		 * Display export song modal.
		 * @param event Event data
		 *
		private function _onExportSongBtnClick(event:MouseEvent = null):void {
			if(!App.connection.coreUserLoginStatus) {
				// user is not logged in, don't allow him to display My List
				App.messageModal.show({title:'Export song', description:'Please log in or wait until the multitrack is fully loaded.', buttons:MessageModal.BUTTONS_OK});
				return;
			}
			App.exportSongModal.show();
			
			// dispatch
			dispatchEvent(new AppEvent(AppEvent.HIDE_DROPBOX, true));
		}
		 */

		
		
		/**
		 * Track playback complete event handler.
		 * Counts all tracks and once all are done, invokes stop()
		 * @param event Event data
		 */
		private function _onTrackPlaybackComplete(event:SamplerEvent):void {
			_completedTracksCounter++;
			if(_state == _STATE_RECORDING) {
				if(_completedTracksCounter == allTrackCount - 1) {
					Logger.info('Song recording completed.');
					_completedTracksCounter = 0;
					_state = _STATE_STOPPED;
					stop();
				}
			} else {
				if(_completedTracksCounter == allTrackCount) {
					Logger.info('Song playback completed.');
					_completedTracksCounter = 0;
					_state = _STATE_STOPPED;
					stop();
				}
			}
		}

		
		
		/**
		 * Track sample error event handler.
		 * This usually means 404 for sample MP3.
		 * Show a message modal.
		 * @param event Event data
		 */
		private function _onTrackSampleError(event:SamplerEvent):void {
			App.messageModal.show({title:'Add track', description:'Sample error.', buttons:MessageModal.BUTTONS_OK, icon:MessageModal.ICON_WARNING});
			
			// dispatch
			dispatchEvent(new AppEvent(AppEvent.HIDE_DROPBOX, true));
		}

		
		
		/**
		 * Playhead refresh event handler.
		 * Called every ENTER_FRAME to refresh playhead.
		 * Playhead is moved and label set only when X changed since last time (to save some CPU)
		 * @param event Event data
		 */
		private function _onPlayheadRefresh(event:Event):void {
			var x:int;
			
			if(_state == _STATE_RECORDING) {
				// recording mode
				x = _recordTrack.position / 100;
				
				// recound song length from core song data
				_recountSongLength();
				
				// set visual properties
				_scroller.isEnabled = (_milliseconds > 44700); // WTF? -vjt
			} else {
				// playback mode
				x = currentPosition / 100;
			}
			 
			x += 521; 
			// left margin of right panel
			x += currentScrollPos; 
			// so we can scroll around
			if(_playhead.x != x) {
				// position changed
				// change position
				Tweener.removeTweens(_playhead);
				Tweener.addTween(_playhead, {time:.5, x:x, rounded:true});
				
				// change label
				_playhead.label = App.getTimeCode(currentPosition);
			}
			
			// if playhead is above left area, make it transparent
			_playhead.alpha = (x < 521) ? .2 : 1;
			
			// autoscroll viewport
			var sx:int = Math.round((currentPosition - 300) / _VIEWPORT_MOVE_INTERVAL);
			if(sx % 10 == 0 && _lastViewportBang != sx) {
				// scroll only once in a while
				// and don't scroll when on 0 (stopped)
				Logger.debug(sprintf('Autoscroll check (position=%u, scrollpos=%u).', currentPosition, currentScrollPos * -100));
				_lastViewportBang = sx;
				// don't check more than once (round gives true more often than needed)
				_autoScroll();				
			}
			
			if(_isVUMeterEnabled) {
				SoundMixer.computeSpectrum(_vuMeterBytes, false, 256);
				_globalVUMeter.leftLevel = Math.abs(_vuMeterBytes.readFloat()) * 100;
				_globalVUMeter.rightLevel = Math.abs(_vuMeterBytes.readFloat()) * 100;
			}
		}

		
		
		private function _onGlobalVolumeRefresh(event:SliderEvent):void {
			SoundMixer.soundTransform = new SoundTransform(event.thumbPos);
		}

		
		
		private function _onRecordStart(event:TrackEvent):void {
			if(allTrackCount == 1) {
				Logger.info('Starting recording (first track recorded, so no record length limit).');
				_recordLimit = 0;
			} else {
				Logger.info(sprintf('Starting recording (record length limit = %s).', App.getTimeCode(_milliseconds)));
				_recordLimit = _milliseconds;
			}
			
			_state = _STATE_RECORDING;
			
			// Great work, Vaclav.
			// -vjt, 24/03/2009
			rewind();
			play();
		}

		
		
		private function _onRecordStop(event:TrackEvent):void {
			_state = _STATE_STOPPED;
			stop();
			
			_refreshVisual();
			
			// start encoding the track and reset the "add new track" tab 
			// App.saveTrackModal.show();
		}

		
		
		/*
		
		private function _onRewindDown(event:MouseEvent):void {
			if(!_isStillSeekBtnPressed) {
				_isStillSeekBtnPressed = true;
				_stillSeekTimeout = setTimeout(function():void {
					_stillSeekInterval = setInterval(function():void {
						seek(currentPosition - _STILL_SEEK_STEP);
					}, _STILL_SEEK_INTERVAL);
				}, _STILL_SEEK_TIMEOUT);
			}
		}

		
		
		private function _onForwardDown(event:MouseEvent):void {
			if(!_isStillSeekBtnPressed) {
				_isStillSeekBtnPressed = true;
				_stillSeekTimeout = setTimeout(function():void {
					_stillSeekInterval = setInterval(function():void {
						seek(currentPosition + _STILL_SEEK_STEP);
					}, _STILL_SEEK_INTERVAL);
				}, _STILL_SEEK_TIMEOUT);
			}
		}

		
		
		private function _onRewindUp(event:MouseEvent):void {
			if(_isStillSeekBtnPressed) {
				_isStillSeekBtnPressed = false;
				clearTimeout(_stillSeekTimeout);
				clearInterval(_stillSeekInterval);
			}
		}

		
		
		private function _onForwardUp(event:MouseEvent):void {
			if(_isStillSeekBtnPressed) {
				_isStillSeekBtnPressed = false;
				clearTimeout(_stillSeekTimeout);
				clearInterval(_stillSeekInterval);
			}
		}
		*/
	}
}
