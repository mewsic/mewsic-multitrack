package editor_panel {
	import application.App;
	import application.PanelCommon;
	
	import caurina.transitions.Tweener;
	
	import config.Embeds;
	import config.Filters;
	import config.Formats;
	import config.Settings;
	
	import controls.Button;
	import controls.MorphSprite;
	import controls.Slider;
	import controls.Toolbar;
	import controls.VUMeter;
	
	import de.popforge.utils.sprintf;
	
	import editor_panel.containers.ContainerCommon;
	import editor_panel.containers.ContainerEvent;
	import editor_panel.sampler.SamplerEvent;
	import editor_panel.tracks.RecordTrack;
	import editor_panel.tracks.StandardTrack;
	import editor_panel.tracks.TrackCommon;
	import editor_panel.tracks.TrackEvent;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.media.SoundMixer;
	import flash.utils.ByteArray;
	
	import modals.MessageModal;
	
	import org.osflash.thunderbolt.Logger;
	import org.vancura.graphics.Drawing;
	import org.vancura.graphics.QBitmap;
	import org.vancura.graphics.QTextField;
	import org.vancura.util.addChildren;
	
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
		private static const _STATE_STOPPED:String   = 'STOPPED';
		private static const _STATE_PLAYING:String   = 'PLAYING';
		private static const _STATE_PAUSED:String    = 'PAUSED';
		private static const _STATE_WAIT_REC:String  = 'WAIT_REC';
		private static const _STATE_RECORDING:String = 'RECORDING';
		
		private static const _OFF_PLAYHEAD:uint = 112;
		private static const _OFF_STAGE:uint = 129;
		
		private var _state:String;
		
		private var _playhead:Playhead;
		private var _containersMaskSpr:MorphSprite;
		private var _playheadMaskSpr:MorphSprite;
		private var _headerSpr:MorphSprite;
		private var _containersContentSpr:MorphSprite;
		private var _footerSpr:MorphSprite;

		// Controller toolbar
		private var _controllerToolbar:Toolbar;
		private var _controllerPlayBtn:Button;
		private var _controllerPauseBtn:Button;
		private var _controllerPlayTF:QTextField;
		private var _controllerRecordBtn:Button;
		private var _controllerRecordStopBtn:Button;
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

		private var _milliseconds:uint;

		private var _completedTracksCounter:uint;
		private var _recordTrack:RecordTrack;

		//private var _beatClicker:BeatClicker;

		private var _vuMeterBytes:ByteArray;
		//private var _isVUMeterEnabled:Boolean;

		private var _isStreamDown:Boolean;
		
		private var _isMikeInited:Boolean = false;

		
		
		/**
		 * Constructor.
		 */
		public function Editor() {
			$panelID = 'panelEditor';
			_vuMeterBytes = new ByteArray();
			//_isVUMeterEnabled = (Capabilities.version.indexOf('MAC') == -1);
			
			super();
			
			setBackType(BACK_TYPE_WHITE);
		}

		
		
		/**
		 * Config is loaded, launch it.
		 */
		public function launch():void {
			// add masks
			_containersMaskSpr = new MorphSprite({y:85, morphTime:Settings.STAGE_HEIGHT_CHANGE_TIME, morphTransition:'easeInOutQuad'});
			_playheadMaskSpr = new MorphSprite({y:_OFF_PLAYHEAD, morphTime:Settings.STAGE_HEIGHT_CHANGE_TIME, morphTransition:'easeInOutQuad'});

			// add modules
			_playhead = new Playhead({x:Settings.TRACKCONTROLS_WIDTH, y:_OFF_PLAYHEAD + 5, mask:_playheadMaskSpr});
			//_beatClicker = new BeatClicker();

			// add parts
			_headerSpr = new MorphSprite(); // Header container			
			_containersContentSpr = new MorphSprite({y:_OFF_STAGE, mask:_containersMaskSpr}); // tracks container
			_footerSpr = new MorphSprite({y:124, morphTime:Settings.STAGE_HEIGHT_CHANGE_TIME, morphTransition:'easeInOutQuad'}); // footer container

			// add top panel background
			_topDivBM = new QBitmap({y:5, embed:new Embeds.backgroundTopGrey()});

			// add controller toolbar
			_controllerToolbar = new Toolbar({x:0, y:15});

			_controllerPlayBtn = new Button({width:78, height:49, iconOffset:10,
				skin:new Embeds.buttonPlayLarge(), icon:new Embeds.glyphPlayLarge()});
			_controllerPauseBtn = new Button({x:5, y:4, width:78, height:49, iconOffset:10,
				skin:new Embeds.buttonPlayLarge(), icon:new Embeds.glyphPauseLarge()})
			_controllerPauseBtn.visible = false;
				
			_controllerPlayTF = new QTextField({x:0, y:10, height:40, width:85,
				defaultTextFormat:Formats.controllerText, filters:Filters.controllerText,
				sharpness:-25, thickness:-50, text:'Play all instruments'}); 
			

			_controllerRecordBtn = new Button({width:78, height:49, iconOffset:8,
				skin:new Embeds.buttonRecordLarge(), icon:new Embeds.glyphRecordLarge()});
			_controllerRecordStopBtn = new Button({x:174, y:4, width:78, height:49, iconOffset:8,
				skin:new Embeds.buttonRecordLarge(), icon:new Embeds.glyphStopLarge()});
			_controllerRecordStopBtn.visible = false;

				
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
			_controllerToolbar.addChild(_controllerPauseBtn);
			_controllerToolbar.addChildRight(_controllerPlayTF);
			
			_controllerToolbar.addChildRight(_controllerRecordBtn);
			_controllerToolbar.addChild(_controllerRecordStopBtn);
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
			_globalVUToolbar = new Toolbar({visible:true,/*_isVUMeterEnabled,*/ x:650, y:0, width:35, height:35});
			_globalVUMeter = new VUMeter({stereo:true, spacingV:-1, spacingH: 13, skin:new Embeds.vuMeter(), leds:7}, VUMeter.DIRECTION_VERTICAL);
			_globalVUToolbar.addChildRight(_globalVUMeter);

			// add containers
			_standardContainer = new ContainerCommon(TrackCommon.STANDARD_TRACK);
			_recordContainer = new ContainerCommon(TrackCommon.RECORD_TRACK);

			Drawing.drawRect(_containersMaskSpr, 0, 0, Settings.STAGE_WIDTH, 121);
			Drawing.drawRect(_playheadMaskSpr, 0, 0, Settings.STAGE_WIDTH, 10);

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
			addChildren($canvasSpr, _headerSpr, _containersContentSpr, _playhead, _footerSpr, _containersMaskSpr, _playheadMaskSpr);
			
			// add container event listeners
			_standardContainer.addEventListener(ContainerEvent.CONTENT_HEIGHT_CHANGE, _onContainerContentHeightChange, false, 0, true);

			_standardContainer.addEventListener(ContainerEvent.TRACK_FETCH_FAILED, _onContainerTrackFetchFailed, false, 0, true);
			_standardContainer.addEventListener(ContainerEvent.SONG_FETCH_FAILED, _onContainerSongFetchFailed, false, 0, true);
			_standardContainer.addEventListener(ContainerEvent.TRACK_ADDED, _onContainerTrackAdded, false, 0, true);
			_standardContainer.addEventListener(ContainerEvent.TRACK_KILL, _onContainerTrackKilled, false, 0, true);

			_standardContainer.addEventListener(SamplerEvent.PLAYBACK_COMPLETE, _onTrackPlaybackComplete, false, 0, true);
			_standardContainer.addEventListener(SamplerEvent.SAMPLE_ERROR, _onTrackSampleError, false, 0, true);


			_recordContainer.addEventListener(ContainerEvent.CONTENT_HEIGHT_CHANGE, _onContainerContentHeightChange, false, 0, true);

			_recordContainer.addEventListener(ContainerEvent.TRACK_FETCH_FAILED, _onContainerTrackFetchFailed, false, 0, true);
			_recordContainer.addEventListener(ContainerEvent.SONG_FETCH_FAILED, _onContainerSongFetchFailed, false, 0, true);
			_recordContainer.addEventListener(ContainerEvent.TRACK_ADDED, _onContainerTrackAdded, false, 0, true);
			_recordContainer.addEventListener(ContainerEvent.TRACK_KILL, _onContainerTrackKilled, false, 0, true);

			_recordContainer.addEventListener(SamplerEvent.PLAYBACK_COMPLETE, _onTrackPlaybackComplete, false, 0, true);
			_recordContainer.addEventListener(SamplerEvent.SAMPLE_ERROR, _onTrackSampleError, false, 0, true);

			_recordContainer.addEventListener(TrackEvent.RECORD_START, _onRecordStart, false, 0, true);

			// add controller toolbar buttons event listeners
			_controllerPlayBtn.addEventListener(MouseEvent.CLICK, _onPlayButtonClick, false, 0, true);
			_controllerPauseBtn.addEventListener(MouseEvent.CLICK, _onPauseButtonClick, false, 0, true);
			_controllerRecordBtn.addEventListener(MouseEvent.CLICK, _onRecordButtonClick, false, 0, true);
			_controllerRecordStopBtn.addEventListener(MouseEvent.CLICK, _onRecordStopButtonClick, false, 0, true);
			_controllerSearchBtn.addEventListener(MouseEvent.CLICK, _onSearchButtonClick, false, 0, true);
			_controllerUploadBtn.addEventListener(MouseEvent.CLICK, _onUploadButtonClick, false, 0, true);

			// add playhead event listeners
			_playhead.addEventListener(Event.ENTER_FRAME, _onPlayheadRefresh, false, 0, true);
			
			// add global volume event listeners
			// _globalVolumeSlider.addEventListener(SliderEvent.REFRESH, _onGlobalVolumeRefresh, false, 0, true);
			
			_state = _STATE_STOPPED;
		}

		
		
		/**
		 * Refresh song data.
		 * Called from JavaScript when page information changes.
		 */
		public function refreshSongData():void {
			Logger.info('REMOVE ME');
		}

		
		
		/**
		 * Initialize core song.
		 */
		public function postInit():void {
			Logger.info(sprintf('REMOVE ME'));
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
			stop();

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
			
			if(_state == _STATE_STOPPED) play()
			else if(_state == _STATE_PAUSED) resume()
			else {
				Logger.warn('Machine error: should be in STOP, PLAY or PAUSE state, current: ' + _state);
				return;
			}

			_state = _STATE_PLAYING;
			_refreshVisual();	
		}
		
		private function _onPauseButtonClick(event:MouseEvent = null):void {
			if(_state == _STATE_PLAYING) {
				pause();
				_state = _STATE_PAUSED;

				_refreshVisual();
			} else {
				Logger.warn('Machine error: should be in PLAY state, current: ' + _state);
			}		
		}

		/**
		 * Record track button clicked event handler.
		 * If stopped, add a new track lane and initialize microphone,
		 * asking user for permission.
		 * If recording, stop.
		 */
		private function _onRecordButtonClick(event:MouseEvent = null):void {
			// only logged in users can use recording
			if(!App.connection.coreUserLoginStatus) {
				App.messageModal.show({title:'Record track',
					description:'Please log in or wait until the multitrack is fully loaded.',
					buttons:MessageModal.BUTTONS_OK});

				return;
			}
					
			if(_state == _STATE_STOPPED) {	
				_state = _STATE_WAIT_REC;
		
				try {
					grabMikeAndRecord();
					
				 } catch(e:Error) {
					App.messageModal.show({title:'Record track', description:e.message,
					   buttons:MessageModal.BUTTONS_OK, icon:MessageModal.ICON_WARNING});

					_state = _STATE_STOPPED;
				}

			} else {
				Logger.warn("Machine error: should be in STOP state, current: " + _state);
			}
			
			_refreshVisual();
		}

		private function _onRecordStopButtonClick(event:MouseEvent):void {
			if(_state == _STATE_RECORDING) {
				_state = _STATE_STOPPED;

				stopRecording();

			} else {
				Logger.warn("Machine error: should be in REC state, current: " + _state);
			}

			_refreshVisual();
		}
		
		private function grabMikeAndRecord():void {

			if(!_isMikeInited) {
				// initialize microphone for the first time. when it is ready,
				//  the UserEvent.ALLOWED_MIKE event is dispatched and record
				// begins
				App.connection.streamService.prepare();
				
				App.connection.streamService.addEventListener(UserEvent.ALLOWED_MIKE, _onMicrophoneAllowed, false, 0, true);
				App.connection.streamService.addEventListener(UserEvent.DENIED_MIKE, _onMicrophoneDenied, false, 0, true);
			} else {
				// already asked the user for permission, remove listeners and
				// start recording immediately.
				App.connection.streamService.removeEventListener(UserEvent.ALLOWED_MIKE, _onMicrophoneAllowed);
				App.connection.streamService.removeEventListener(UserEvent.DENIED_MIKE, _onMicrophoneDenied);
				
				_onMicrophoneAllowed();
			}
		}
		
		
		private function _onMicrophoneAllowed(event:UserEvent = null):void {
			_isMikeInited = true;
			
			if(_recordTrack != null)
				throw new Error("Record track should be null");
			
			_recordContainer.createRecordTrack();
			_recordContainer.addEventListener(ContainerEvent.RECORD_TRACK_READY, _onRecordTrackReady, false, 0, true);
		}
		
		private function _onRecordTrackReady(event:ContainerEvent):void {
			if(_recordTrack != null)
				throw new Error("Record track should be null");
			
			_recordTrack = event.data.track;
			_recordTrack.startRecording();

			_state = _STATE_RECORDING;			
			_refreshVisual();
		}
		
		private function _onMicrophoneDenied(event:UserEvent = null):void {
			_state = _STATE_STOPPED;
			killRecordTrack();
			
			_refreshVisual();
		}



		/**
		 * Track playback complete event handler.
		 * Counts all tracks and once all are done, sets the state to _STOPPED
		 * and calls _refreshVisual()
		 * @param event Event data
		 */
		private function _onTrackPlaybackComplete(event:SamplerEvent):void {
			_completedTracksCounter++;
			if(_state == _STATE_RECORDING) {
				//if(_completedTracksCounter == allTrackCount - 1) {
					Logger.info('Song recording completed.');
					_completedTracksCounter = 0;

					stopRecording();					
				//}
				
			} else {
				if(_completedTracksCounter == allTrackCount) {
					Logger.info('Song playback completed.');
					_completedTracksCounter = 0;
					stop();
				}
			}

			_state = _STATE_STOPPED;
			_refreshVisual();
		}


		
		private function _onRecordStart(event:TrackEvent):void {
			if(allTrackCount == 1) {
				Logger.info('Starting recording (first track recorded, so no record length limit).');
			} else {
				Logger.info(sprintf('Starting recording (record length limit = %s).', App.getTimeCode(_milliseconds)));
			}
			
			_state = _STATE_RECORDING;
			
			// Great work, Vaclav.
			// -vjt, 24/03/2009
			rewind();
			play();
		}



		private function stopRecording():void {
			var recorded:uint = _recordTrack.position;
			_recordTrack.stopRecording();
			
			if(recorded) {
				var t:StandardTrack;
				var id:uint = _recordTrack.trackID;
				
				t = _standardContainer.addStandardTrack(id);
				t.encode(App.connection.streamService.filename);
			}
			
			killRecordTrack();
		}
		

		private function _onSearchButtonClick(event:MouseEvent = null):void {
			App.messageModal.show({title:'Show search', description:'now call the lightwindow in JS'});
		}
		
		
		/**
		 * Upload track button clicked event handler.
		 * Display upload track modal.
		 * @param event Event data
		 */
		private function _onUploadButtonClick(event:MouseEvent = null):void {
			if(!App.connection.coreUserLoginStatus) {
				// user is not logged in, don't allow him to display My List
				App.messageModal.show({title:'Upload track',
					description:'Please log in or wait until the multitrack is fully loaded.',
					buttons:MessageModal.BUTTONS_OK});
				return;
			}

			App.messageModal.show({title:"UPLOAD",
				description:'Now browse for a file, create the track, and wait for upload && encoding',
				buttons:MessageModal.BUTTONS_OK});			
		}



		/**
		 * Low-level play method, XXX: make it protected
		 */
		public function play(event:Event = null):void {
			Logger.info('Play!');
			_standardContainer.play();
		}

		
		
		/**
		 * Low-level stop method.
		 */
		public function stop(event:Event = null):void {
			Logger.info('Stop playback.');
			_standardContainer.stop();
		}

		
		
		/**
		 * Pause.
		 */
		public function pause(event:Event = null):void {
			Logger.info('Pause playback.');
			_standardContainer.pause();
		}

		
		
		/**
		 * Resume.
		 */
		public function resume(event:Event = null):void {
			Logger.info('Resume playback.');
			_standardContainer.resume();
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
		}

		
		
		/**
		 * Forward the stage by _SEEK_STEP ms. 
		 */
		public function forward(event:Event = null):void {
			Logger.info('Forward playback.');
			var p:uint = currentPosition + _SEEK_STEP;
			if(p > _milliseconds) p = _milliseconds;

			_standardContainer.seek(p);
		}

		
		
		public function seek(value:uint):void {
			if(value > _milliseconds) value = _milliseconds;
			if(value < 0) value = 0;
			
			Logger.info(sprintf('Seek playback (%u ms).', value));
			
			_standardContainer.seek(value);
			
			// refresh visual
			_refreshVisual();			
		}

		
		
		public function disableStreamFunctions():void { /// XXX CHECKME
			Logger.info('Disabling stream functions.');
			
			_isStreamDown = true;
			_disableButton(_controllerRecordBtn);
		}


		
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

		
		
		public function get currentPosition():uint {
			if(_standardContainer.trackCount == 0 && _state == _STATE_RECORDING) {
				// Recording first track
				return _recordContainer.position;
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
			
			Logger.debug(sprintf('Current song length is %f ms', _milliseconds));

			// set buttons states
			switch(_state) {
				case _STATE_STOPPED:
					// Set play active only if there's already a track loaded, enable all other buttons
					_controllerPlayBtn.visible = true;
					_controllerPauseBtn.visible = false;

					_controllerRecordBtn.visible = true;
					_controllerRecordStopBtn.visible = false;

					_setButtonActive(_controllerPlayBtn, allTrackCount > 0);
					_setButtonActive(_controllerRecordBtn, !App.connection.streamService.microphoneDenied);
					_enableButton(_controllerSearchBtn);
					_enableButton(_controllerUploadBtn);

					
					break;
					
				case _STATE_PLAYING:
					// Show pause button, disable record and upload button
					_controllerPlayBtn.visible = false;
					_controllerPauseBtn.visible = true;

					_disableButton(_controllerRecordBtn);
					_enableButton(_controllerSearchBtn);
					_enableButton(_controllerUploadBtn);					

					break;
					
				case _STATE_PAUSED:
					_controllerPlayBtn.visible = true;
					_controllerPauseBtn.visible = false;

					_enableButton(_controllerRecordBtn);
					_enableButton(_controllerSearchBtn);
					_enableButton(_controllerUploadBtn);
					
					break;
				
				case _STATE_WAIT_REC:
					_disableButton(_controllerPlayBtn);
					_disableButton(_controllerRecordBtn);
					_disableButton(_controllerSearchBtn);
					_disableButton(_controllerUploadBtn);
					
					break;

				case _STATE_RECORDING:
					_controllerRecordBtn.visible = false;
					_controllerRecordStopBtn.visible = true;

					_disableButton(_controllerPlayBtn);
					_disableButton(_controllerSearchBtn);
					_disableButton(_controllerUploadBtn);
					
					break;
			}
		}

		
		
		/**
		 * Container changed it's height event handler.
		 * Animate it
		 * @param event Event data
		 */
		private function _onContainerContentHeightChange(event:ContainerEvent):void {
			_recordContainer.morph({y:_standardContainer.height});
			
			_footerSpr.morph({y:_standardContainer.height + _recordContainer.height + _containersContentSpr.y});
			
			_containersMaskSpr.morph({height:_standardContainer.height + _recordContainer.height + 40});
			
			_playheadMaskSpr.morph({height:_standardContainer.height + 10});

			$animateHeightChange(_standardContainer.height + _recordContainer.height + _containersContentSpr.y + 40); // fixed 40px bottom margin
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
				_milliseconds = _standardContainer.milliseconds;
			}
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
		 * Track sample error event handler.
		 * This usually means 404 for sample MP3.
		 * Show a message modal.
		 * @param event Event data
		 */
		private function _onTrackSampleError(event:SamplerEvent):void {
			App.messageModal.show({title:'Add track', description:'Sample error.', buttons:MessageModal.BUTTONS_OK, icon:MessageModal.ICON_WARNING});
		}

		
		/// Playhead stuff
		// 
		public function msecToStageX(m:Number):uint {
			return m / milliseconds * Settings.WAVEFORM_WIDTH;
		}
		
		public function stageXToMsec(x:int):uint {
			return x * milliseconds / Settings.WAVEFORM_WIDTH;
		}
		
		public function get playheadPosition():Number {
			var msec:int;

			if(_state == _STATE_RECORDING) {
				// recording mode
				msec = _recordTrack.position;
				
				// recount song length from core song data
				_recountSongLength();
			} else {
				// playback mode
				msec = currentPosition;
			}

			// Shift relative to waveform width
			return msecToStageX(msec);
		}
		
		/**
		 * Playhead refresh event handler.
		 * Called every ENTER_FRAME to refresh playhead.
		 * Playhead is moved and label set only when X changed since last time (to save some CPU)
		 * @param event Event data
		 */
		private function _onPlayheadRefresh(event:Event):void {
			// Shift relative to waveform width, and add left margin of right panel
			var x:int = playheadPosition + Settings.TRACKCONTROLS_WIDTH;
			
			if(_playhead.x != x) {
				// position changed  <-- All good coders smoke.
				// change position   <-- Vaclav, you too! :D -vjt
				// 
				Tweener.removeTweens(_playhead);
				Tweener.addTween(_playhead, {time:.5, x:x, rounded:true});
				
				// change label
				_playhead.label = App.getTimeCode(currentPosition);
			}
						
			SoundMixer.computeSpectrum(_vuMeterBytes, false, 256);
			_globalVUMeter.leftLevel = Math.abs(_vuMeterBytes.readFloat()) * 100;
			_globalVUMeter.rightLevel = Math.abs(_vuMeterBytes.readFloat()) * 100;
		}

		
/*		
		private function _onGlobalVolumeRefresh(event:SliderEvent):void {
			SoundMixer.soundTransform = new SoundTransform(event.thumbPos);
		}*/
	}
}
