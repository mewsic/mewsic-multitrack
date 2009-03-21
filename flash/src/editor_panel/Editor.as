package editor_panel {
	import application.App;
	import application.AppEvent;
	import application.PanelCommon;
	
	import caurina.transitions.Tweener;
	
	import config.Embeds;
	import config.Filters;
	import config.Settings;
	
	import controls.Button;
	import controls.Input;
	import controls.InputEvent;
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
	import editor_panel.tracks.StandardTrack;
	import editor_panel.tracks.TrackCommon;
	import editor_panel.tracks.TrackEvent;
	
	import flash.display.Bitmap;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.media.SoundMixer;
	import flash.media.SoundTransform;
	import flash.system.Capabilities;
	import flash.utils.ByteArray;
	import flash.utils.clearInterval;
	import flash.utils.clearTimeout;
	import flash.utils.setInterval;
	import flash.utils.setTimeout;
	
	import modals.MessageModal;
	
	import org.osflash.thunderbolt.Logger;
	import org.vancura.graphics.Drawing;
	import org.vancura.graphics.QBitmap;
	import org.vancura.util.addChildren;
	
	import remoting.data.TrackData;	

	
	
	/**
	 * Editor panel.
	 * 
	 * TODO: Write documentation
	 * 
	 * @author Vaclav Vancura (http://vaclav.vancura.org)
	 * @since Jun 14, 2008
	 */
	public class Editor extends PanelCommon {

		
		
		private static const _SEEK_STEP:uint = 10000;
		private static const _VIEWPORT_MOVE_INTERVAL:uint = 250;
		private static const _STILL_SEEK_TIMEOUT:uint = 600;
		private static const _STILL_SEEK_INTERVAL:uint = 300;
		private static const _STILL_SEEK_STEP:uint = 10000;
		private var _scroller:Scroller;
		private var _ruler:Ruler;
		private var _playhead:Playhead;
		private var _containersMaskSpr:MorphSprite;
		private var _playheadMaskSpr:MorphSprite;
		private var _headerSpr:MorphSprite;
		private var _containersContentSpr:MorphSprite;
		private var _footerSpr:MorphSprite;
		private var _topToolbar:Toolbar;
		private var _botToolbar:Toolbar;
		private var _controllerToolbar:Toolbar;
		private var _globalVUToolbar:Toolbar;
		private var _globalVolumeToolbar:Toolbar;
		private var _bpmToolbar:Toolbar;
		private var _topRecordBtn:Button;
		private var _topUploadBtn:Button;
		private var _botExportBtn:Button;
		private var _botSaveBtn:Button;
		private var _controllerRewindBtn:Button;
		private var _controllerPlayBtn:Button;
		private var _controllerPauseBtn:Button;
		private var _controllerStopBtn:Button;
		private var _controllerForwardBtn:Button;
		private var _bpmOffBtn:Button;
		private var _bpmOnBtn:Button;
		private var _bpmInput:Input;
		private var _globalVolumeSlider:Slider;
		private var _globalVUMeter:VUMeter;
		private var _topDivBM:QBitmap;
		private var _botDivBM:QBitmap;
		private var _standardContainer:ContainerCommon;
		private var _recordContainer:ContainerCommon;
		private var _width:uint;
		private var _isPlaying:Boolean;
		private var _isPaused:Boolean;
		private var _currentScrollPos:int;
		private var _milliseconds:uint;
		private var _completedTracksCounter:uint;
		private var _recordTrack:RecordTrack;
		private var _beatClicker:BeatClicker;
		private var _isRecording:Boolean;
		private var _metronomeIcon1:Bitmap;
		private var _metronomeIcon2:Bitmap;
		private var _lastViewportBang:int;
		private var _isStillSeekBtnPressed:Boolean;
		private var _stillSeekTimeout:uint;
		private var _stillSeekInterval:uint;
		private var _vuMeterBytes:ByteArray;
		private var _isVUMeterEnabled:Boolean;
		private var _recordLimit:uint;
		private var _isCoreBPMSet:Boolean;
		private var _isStreamDown:Boolean;

		
		
		/**
		 * Constructor.
		 */
		public function Editor() {
			$panelID = 'panelEditor';
			_vuMeterBytes = new ByteArray();
			_isVUMeterEnabled = (Capabilities.version.indexOf('MAC') == -1);
			
			super();
			
			setBackType(BACK_TYPE_LIGHT);
		}

		
		
		/**
		 * Config is loaded, launch it.
		 */
		public function launch():void {
			// add metronome icons
			_metronomeIcon1 = new Embeds.glyphMetronome1BD() as Bitmap;
			_metronomeIcon2 = new Embeds.glyphMetronome2BD() as Bitmap;
			
			// add masks
			_containersMaskSpr = new MorphSprite({y:85, morphTime:Settings.STAGE_HEIGHT_CHANGE_TIME, morphTransition:'easeInOutQuad'});
			_playheadMaskSpr = new MorphSprite({y:53, morphTime:Settings.STAGE_HEIGHT_CHANGE_TIME, morphTransition:'easeInOutQuad'});

			// add modules
			_ruler = new Ruler({y:61});
			_playhead = new Playhead({x:521, y:53, mask:_playheadMaskSpr});
			_scroller = new Scroller({y:204, morphTime:Settings.STAGE_HEIGHT_CHANGE_TIME, morphTransition:'easeInOutQuad'});
			_beatClicker = new BeatClicker();

			// add parts
			_headerSpr = new MorphSprite();
			_containersContentSpr = new MorphSprite({y:85, mask:_containersMaskSpr});
			_footerSpr = new MorphSprite({y:224, morphTime:Settings.STAGE_HEIGHT_CHANGE_TIME, morphTransition:'easeInOutQuad'});

			// add other graphics
			_topDivBM = new QBitmap({y:55, embed:new Embeds.panelLightDivBD()});
			_botDivBM = new QBitmap({y:-6, embed:new Embeds.panelLightDivBD()});

			// add controller toolbar
			_controllerToolbar = new Toolbar({x:14, y:15});
			_controllerRewindBtn = new Button({width:29, height:24, skin:new Embeds.buttonBeigeMiniBD(), icon:new Embeds.glyphRewindBD(), textOutFilters:Filters.buttonBeigeLabel, textOverFilters:Filters.buttonBeigeLabel, textPressFilters:Filters.buttonBeigeLabel});
			//_controllerPlayBtn = new Button({width:88, height:24, text:'Play', icon:new Embeds.glyphPlayBD(), skin:new Embeds.buttonGreenMiniBD(), textOutFilters:Filters.buttonGreenLabel, textOverFilters:Filters.buttonGreenLabel, textPressFilters:Filters.buttonGreenLabel});
			_controllerPlayBtn = new Button({width:80, height:41, skin:new Embeds.skinPlay(), icon:new Embeds.iconPlay(), textOutFilters:Filters.buttonGreenLabel, textOverFilters:Filters.buttonGreenLabel, textPressFilters:Filters.buttonGreenLabel});
			_controllerPauseBtn = new Button({width:29, height:24, skin:new Embeds.buttonBlueMiniBD(), icon:new Embeds.glyphPauseBD(), textOutFilters:Filters.buttonBlueLabel, textOverFilters:Filters.buttonBlueLabel, textPressFilters:Filters.buttonBlueLabel});
			_controllerStopBtn = new Button({width:29, height:24, skin:new Embeds.buttonBlueMiniBD(), icon:new Embeds.glyphStopBD(), textOutFilters:Filters.buttonBlueLabel, textOverFilters:Filters.buttonBlueLabel, textPressFilters:Filters.buttonBlueLabel});
			_controllerForwardBtn = new Button({width:29, height:24, skin:new Embeds.buttonBeigeMiniBD(), icon:new Embeds.glyphForwardBD(), textOutFilters:Filters.buttonBeigeLabel, textOverFilters:Filters.buttonBeigeLabel, textPressFilters:Filters.buttonBeigeLabel});
			_controllerToolbar.addChildRight(_controllerRewindBtn);
			_controllerToolbar.addChildRight(_controllerPlayBtn);
			_controllerToolbar.addChildRight(_controllerPauseBtn);
			_controllerToolbar.addChildRight(_controllerStopBtn);
			_controllerToolbar.addChildRight(_controllerForwardBtn);

			// add global volume toolbar
			_globalVolumeToolbar = new Toolbar({x:249, y:15, paddingH:0, paddingV:0, skin:new Embeds.toolbarPlainBD()});
			_globalVolumeSlider = new Slider({width:169, slideTime:1, marginBegin:19, marginEnd:19, backSkin:new Embeds.sliderVolumeHorizontalBD(), thumbSkin:new Embeds.buttonGlobalVolumeThumbBD});
			_globalVolumeToolbar.addChildRight(_globalVolumeSlider);

			// add top toolbar
			_topToolbar = new Toolbar({skin:new Embeds.toolbarPlainBD(), y:15, paddingH:0, paddingV:0});
			_topRecordBtn = new Button({width:135, text:'Record track live', icon:new Embeds.glyphMicBD()});
			_topUploadBtn = new Button({width:120, text:'Upload track', icon:new Embeds.glyphUploadBD()});
			_topToolbar.addChildRight(_topRecordBtn);
			_topToolbar.addChildRight(_topUploadBtn);

			// add bot toolbar
			_botToolbar = new Toolbar({y:12, paddingH:0, paddingV:0, skin:new Embeds.toolbarPlainBD()});
			_botExportBtn = new Button({width:110, text:'Export song', skin:new Embeds.buttonGreenBD(), icon:new Embeds.glyphSaveBD(), textOutFilters:Filters.buttonGreenLabel, textOverFilters:Filters.buttonGreenLabel, textPressFilters:Filters.buttonGreenLabel});
			_botSaveBtn = new Button({width:165, text:'Save Myousica project', icon:new Embeds.glyphMyousicaBD()});
			_botToolbar.addChildRight(_botExportBtn);
			_botToolbar.addChildRight(_botSaveBtn);

			// add global vu meter toolbar
			_globalVUToolbar = new Toolbar({visible:_isVUMeterEnabled, x:130, y:12, width:255, height:32});
			_globalVUMeter = new VUMeter({x:8, y:8, skin:new Embeds.vuMeterHorizontalBD(), leds:30});
			_globalVUToolbar.addChild(_globalVUMeter);

			// add bpm toolbar
			_bpmToolbar = new Toolbar({x:14, y:12, icon:_metronomeIcon1});
			_bpmOffBtn = new Button({width:29, height:24, skin:new Embeds.buttonGrayMiniBD(), icon:new Embeds.glyphVolume1WhiteBD(), textOutFilters:Filters.buttonGrayLabel, textOverFilters:Filters.buttonGrayLabel, textPressFilters:Filters.buttonGrayLabel});
			_bpmOnBtn = new Button({visible:false, width:29, height:24, skin:new Embeds.buttonActiveMiniBD(), icon:new Embeds.glyphVolume1WhiteBD(), textOutFilters:Filters.buttonActiveLabel, textOverFilters:Filters.buttonActiveLabel, textPressFilters:Filters.buttonActiveLabel});
			_bpmInput = new Input({width:40, maxChars:3});
			_bpmToolbar.addChildRight(_bpmInput);
			_bpmToolbar.addChildRight(_bpmOffBtn);
			_bpmToolbar.addChild(_bpmOnBtn);
			_bpmOnBtn.x = 74;
			_bpmOnBtn.y = 4;

			// add containers
			_standardContainer = new ContainerCommon(TrackCommon.STANDARD_TRACK);
			_recordContainer = new ContainerCommon(TrackCommon.RECORD_TRACK);
			_recordContainer.y = 60;
			Drawing.drawRect(_containersMaskSpr, 0, 0, Settings.STAGE_WIDTH, 121);
			Drawing.drawRect(_playheadMaskSpr, 0, 0, Settings.STAGE_WIDTH, 170);

			// align some toolbars right
			_topToolbar.x = $canvasSpr.width - _topToolbar.width - 14;
			_botToolbar.x = $canvasSpr.width - _botToolbar.width - 14;
			
			// deactivate some buttons
			_controllerRewindBtn.areEventsEnabled = false;
			_controllerPlayBtn.areEventsEnabled = false;
			_controllerPauseBtn.areEventsEnabled = false;
			_controllerStopBtn.areEventsEnabled = false;
			_controllerForwardBtn.areEventsEnabled = false;
			_botExportBtn.areEventsEnabled = false;
			_botSaveBtn.areEventsEnabled = false;
			_bpmOffBtn.areEventsEnabled = false;
			_controllerRewindBtn.alpha = .4;
			_controllerPlayBtn.alpha = .4;
			_controllerPauseBtn.alpha = .4;
			_controllerStopBtn.alpha = .4;
			_controllerForwardBtn.alpha = .4;
			_botExportBtn.alpha = .4;
			_botSaveBtn.alpha = .4;
			_bpmOffBtn.alpha = .4;
			
			// set default volume
			_globalVolumeSlider.thumbPos = .9;
			
			// add to display list
			addChildren(_headerSpr, _topDivBM, _controllerToolbar, _globalVolumeToolbar, _topToolbar);
			addChildren(_containersContentSpr, _standardContainer, _recordContainer);
			addChildren(_footerSpr, _botDivBM, _globalVUToolbar, _bpmToolbar, _botToolbar);
			addChildren($canvasSpr, _ruler, _headerSpr, _containersContentSpr, _playhead, _footerSpr, _scroller, _containersMaskSpr, _playheadMaskSpr);
			
			// add container event listeners
			_standardContainer.addEventListener(ContainerEvent.CONTENT_HEIGHT_CHANGE, _onContainerContentHeightChange, false, 0, true);
			_standardContainer.addEventListener(ContainerEvent.SET_GLOBAL_TEMPO, _onSetGlobalTempo, false, 0, true);
			_standardContainer.addEventListener(ContainerEvent.SONG_FETCH_FAILED, _onContainerSongFetchFailed, false, 0, true);
			_standardContainer.addEventListener(ContainerEvent.TRACK_FETCH_FAILED, _onContainerTrackFetchFailed, false, 0, true);
			_standardContainer.addEventListener(ContainerEvent.SONG_FETCH_FAILED, _onContainerSongFetchFailed, false, 0, true);
			_standardContainer.addEventListener(ContainerEvent.TRACK_ADDED, _onContainerTrackAdded, false, 0, true);
			_standardContainer.addEventListener(ContainerEvent.TRACK_KILL, _onContainerTrackKilled, false, 0, true);
			_standardContainer.addEventListener(SamplerEvent.PLAYBACK_COMPLETE, _onTrackPlaybackComplete, false, 0, true);
			_standardContainer.addEventListener(SamplerEvent.SAMPLE_ERROR, _onTrackSampleError, false, 0, true);
			_recordContainer.addEventListener(ContainerEvent.CONTENT_HEIGHT_CHANGE, _onContainerContentHeightChange, false, 0, true);
			_recordContainer.addEventListener(ContainerEvent.SET_GLOBAL_TEMPO, _onSetGlobalTempo, false, 0, true);
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
			
			// add buttons event listeners
			_controllerPlayBtn.addEventListener(MouseEvent.CLICK, play, false, 0, true);
			_controllerRewindBtn.addEventListener(MouseEvent.CLICK, rewind, false, 0, true);
			_controllerRewindBtn.addEventListener(MouseEvent.MOUSE_DOWN, _onRewindDown, false, 0, true);
			_controllerRewindBtn.addEventListener(MouseEvent.MOUSE_UP, _onRewindUp, false, 0, true);
			_controllerPauseBtn.addEventListener(MouseEvent.CLICK, pause, false, 0, true);
			_controllerStopBtn.addEventListener(MouseEvent.CLICK, stop, false, 0, true);
			_controllerForwardBtn.addEventListener(MouseEvent.CLICK, forward, false, 0, true);
			_controllerForwardBtn.addEventListener(MouseEvent.MOUSE_DOWN, _onForwardDown, false, 0, true);
			_controllerForwardBtn.addEventListener(MouseEvent.MOUSE_UP, _onForwardUp, false, 0, true);
			_topRecordBtn.addEventListener(MouseEvent.CLICK, _onRecordTrackBtnClick, false, 0, true);
			_topUploadBtn.addEventListener(MouseEvent.CLICK, _onUploadTrackBtnClick, false, 0, true);
			_botExportBtn.addEventListener(MouseEvent.CLICK, _onExportSongBtnClick, false, 0, true);
			_botSaveBtn.addEventListener(MouseEvent.CLICK, _onSaveSongBtnClick, false, 0, true);
			_bpmOffBtn.addEventListener(MouseEvent.CLICK, _onBPMBtnClick, false, 0, true);
			_bpmOnBtn.addEventListener(MouseEvent.CLICK, _onBPMBtnClick, false, 0, true);
			
			// add playhead event listeners
			_playhead.addEventListener(Event.ENTER_FRAME, _onPlayheadRefresh, false, 0, true);
			
			// add global volume event listeners
			_globalVolumeSlider.addEventListener(SliderEvent.REFRESH, _onGlobalVolumeRefresh, false, 0, true);
			
			// add bpm input events
			_bpmInput.addEventListener(InputEvent.CHANGE, _onBPMInputChanged, false, 0, true);
			
			// add beat clicker events
			_beatClicker.addEventListener(BeatClickerEvent.BEAT, _onBeatClickerBeat, false, 0, true);
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
			_recordContainer.killTrack(_recordTrack.trackID);
			_recordTrack = null;
			
			// refresh buttons states
			_refreshVisual();
		}

		
		
		/**
		 * Play.
		 */
		public function play(event:Event = null):void {
			if(_isPlaying && !_isPaused) {
				Logger.warn('Playing, could not play playback.');
				return;
			}
			
			if(_isPaused) {
				resume();
			} else {
				Logger.info('Play playback.');
				_isPlaying = true;
				_standardContainer.play();
				_beatClicker.play();
			}
			
			// refresh visual
			_refreshVisual();
		}

		
		
		/**
		 * Stop.
		 */
		public function stop(event:Event = null):void {
			if(_isRecording) {
				_recordTrack.stopRecording();
			}
			
			Logger.info('Stop playback.');
			_isPlaying = false;
			_isPaused = false;
			_standardContainer.stop();
			_recordContainer.stop();
			_beatClicker.stop();
			_scroller.position = 0;
			
			// refresh visual
			_refreshVisual();
		}

		
		
		/**
		 * Pause.
		 */
		public function pause(event:Event = null):void {
			if(_isRecording) {
				Logger.warn('Recording, could not pause playback.');
				return; 
			}
			
			if(!_isPlaying) {
				Logger.warn('Not playing, could not pause playback.');
				return;
			}
			
			else if(_isPaused) {
				Logger.warn('Paused, could not pause playback.');
				return;
			}
			
			Logger.info('Pause playback.');
			_isPaused = true;
			_standardContainer.pause();
			_beatClicker.pause();
			
			// refresh visual
			_refreshVisual();
		}

		
		
		/**
		 * Resume.
		 */
		public function resume(event:Event = null):void {
			if(_isRecording) {
				Logger.warn('Recording, could not resume playback.');
				return;
			}
			
			if(!_isPlaying) {
				Logger.warn('Not playing, could not resume playback.');
				return;
			}
			
			else if(!_isPaused) {
				Logger.warn('Paused, could not resume playback.');
				return;
			}
			
			Logger.info('Resume playback.');
			_isPaused = false;
			_standardContainer.resume();
			_beatClicker.resume();
			
			// refresh visual
			_refreshVisual();
		}

		
		
		public function alterPlaybackState():void {
			if(allTrackCount == 0) return;
			if(_isRecording) stop();
			else if(_recordTrack != null) return;
			else if(_isPlaying && _isPaused) resume();
			else if(_isPlaying && !_isPaused) pause();
			else play();
		}

		
		
		/**
		 * Rewind.
		 */
		public function rewind(event:Event = null):void {
			Logger.info('Rewind playback.');
			var p:uint = currentPosition - _SEEK_STEP;
			if(p < 0) p = 0;
			if(p > _milliseconds) p = 0;
			
			_standardContainer.seek(p);
			_beatClicker.seek(p);
			
			// refresh visual
			_refreshVisual();
		}

		
		
		/**
		 * Forward.
		 */
		public function forward(event:Event = null):void {
			if(_isRecording) {
				Logger.warn('Recording, could not forward playback.');
				return;
			}
			
			Logger.info('Forward playback.');
			var p:uint = currentPosition + _SEEK_STEP;
			if(p > _milliseconds) p = _milliseconds;
			_standardContainer.seek(p);
			_beatClicker.seek(p);
			
			// refresh visual
			_refreshVisual();
		}

		
		
		public function seek(value:uint):void {
			if(_isRecording) {
				Logger.warn('Recording, could not forward playback.');
				return;
			}
			
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
			
			_topRecordBtn.alpha = .4;
			_topRecordBtn.areEventsEnabled = false;
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

		
		
		public function createAndRecord():void {
			if(_isRecording) return;
			if(_isPlaying) stop();
			if(_recordTrack == null) _onRecordTrackBtnClick();
			else _recordTrack.startRecording(); 
		}

		
		
		public function toggleMetronome():void {
			_onBPMBtnClick();
		}

		
		
		public function upload():void {
			_onUploadTrackBtnClick();
		}

		
		
		public function export():void {
			if(allTrackCount > 0 && !_isPlaying && !_isRecording) _onExportSongBtnClick();
		}

		
		
		public function save():void {
			if(allTrackCount > 0 && !_isPlaying && !_isRecording) _onSaveSongBtnClick();
		}

		
		
		public function toggleTrackMute(track:uint):void {
			try {
				var tr:StandardTrack = _standardContainer.getTrack(track);
				if(tr != null) tr.toggleMute();
			}
			catch(err:Error) {
			}
		}

		
		
		public function toggleTrackSolo(track:uint):void {
			try {
				var tr:StandardTrack = _standardContainer.getTrack(track);
				if(tr != null) tr.toggleSolo();
			}
			catch(err:Error) {
			}
		}

		
		
		public function alterTrackVolume(track:uint, step:Number):void {
			try {
				var tr:StandardTrack = _standardContainer.getTrack(track);
				if(tr != null) tr.alterVolume(step);
			}
			catch(err:Error) {
			}
		}

		
		
		public function alterTrackBalance(track:uint, step:Number):void {
			try {
				var tr:StandardTrack = _standardContainer.getTrack(track);
				if(tr != null) tr.alterBalance(step);
			}
			catch(err:Error) {
			}
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

		
		
		public function get currentScrollPos():int {
			return _currentScrollPos;
		}

		
		
		public function get currentPosition():uint {
			if(_recordContainer.trackCount > 0) {
				// recording first track
				if(_isPlaying) return _recordContainer.position;
				return 0;
			} else {
				// standard track
				return _standardContainer.position;
			}
		}

		
		
		public function set bpm(value:uint):void {
			if(value != 0) {
				// check margins
				if(value > 300) value = 300;
				
				Logger.info(sprintf('Set global tempo to %u BPM', value));
				
				// set song bpm settings
				App.connection.coreSongData.songBPM = value;
				
				// set input text
				_bpmInput.text = String(value);
				
				// set record track bpm
				if(_recordTrack) {
					_recordTrack.trackData.trackBPM = value;
					_recordTrack.refresh();
				}
				
				// set beat clicker
				_beatClicker.bpm = App.connection.coreSongData.songBPM;
				
				// enable click button
				_bpmOffBtn.areEventsEnabled = true;
				_bpmOffBtn.alpha = 1;
			}
			else if(allTrackCount == 0) {
				// reset bpm
				Logger.info('Resetting global tempo');
				
				// set song bpm settings
				App.connection.coreSongData.songBPM = 0;
				
				// set input text
				_bpmInput.text = '';
				
				// disable click button
				_bpmOffBtn.areEventsEnabled = false;
				_bpmOffBtn.alpha = .4;
			}
		}

		
		
		private function _refreshVisual():void {
			// recound song length from core song data
			_recountSongLength();
			
			// set visual properties
			_ruler.info.label = App.getTimeCode(_milliseconds);
			_scroller.isEnabled = (allTrackCount > 0 && _milliseconds > 44700);
			
			Logger.debug(sprintf('Current maximal waveform width is %d px', _width));
			Logger.debug(sprintf('Current song length is %f ms', _milliseconds));
			
			// set buttons states
			var isf:Boolean = (allTrackCount > 0);
			var isplay:Boolean = (isf && (!_isPlaying || (_isPlaying && _isPaused)) && !_isRecording && (_recordContainer.trackCount == 0));
			var ispause:Boolean = (isf && _isPlaying && !_isRecording && !_isPaused);
			var isstop:Boolean = (isf && _isPlaying);
			var isrewind:Boolean = (isf && !_isRecording && (_recordContainer.trackCount == 0));
			var isforward:Boolean = (isf && !_isRecording && (_recordContainer.trackCount == 0));
			var isbot:Boolean = (isf && !_isPlaying && !_isRecording);
			var isbpm:Boolean = (!_isPlaying && !_isRecording);
			
			_controllerPlayBtn.areEventsEnabled = isplay;
			_controllerPauseBtn.areEventsEnabled = ispause;
			_controllerStopBtn.areEventsEnabled = isstop;
			_controllerRewindBtn.areEventsEnabled = isrewind;
			_controllerForwardBtn.areEventsEnabled = isforward;
			_botExportBtn.areEventsEnabled = isbot;
			_botSaveBtn.areEventsEnabled = isbot;
			_bpmInput.areEventsEnabled = isbpm;
			
			_controllerPlayBtn.alpha = (isplay) ? 1 : .4;
			_controllerPauseBtn.alpha = (ispause) ? 1 : .4;
			_controllerStopBtn.alpha = (isstop) ? 1 : .4;
			_controllerRewindBtn.alpha = (isrewind) ? 1 : .4;
			_controllerForwardBtn.alpha = (isforward) ? 1 : .4;
			_botExportBtn.alpha = (isbot) ? 1 : .4;
			_botSaveBtn.alpha = (isbot) ? 1 : .4;
			_bpmInput.alpha = (isbpm) ? 1 : .4;
			
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

			$animateHeightChange(_standardContainer.height + _recordContainer.height + _containersContentSpr.y + 79);
		}

		
		
		/**
		 * Container tries to change global BPM event handler.
		 * If it's already set, show a message modal.
		 * @param event Event data
		 */
		private function _onSetGlobalTempo(event:ContainerEvent):void {
			if(!_isCoreBPMSet) {
				// set global bpm
				_isCoreBPMSet = true;
				bpm = event.data.tempo;
			}
			if(App.connection.coreSongData.songBPM != event.data.tempo) {
				// bpm is already set,
				// inform user about out of sync
				App.messageModal.show({title:'Tempo', description:sprintf('You just added track with different tempo.\nThe song global tempo is %u BPM, but the track tempo is %u BPM.\nPlease keep in mind that playback can become out of sync!', App.connection.coreSongData.songBPM, event.data.tempo), buttons:MessageModal.BUTTONS_OK, icon:MessageModal.ICON_WARNING});
			}
			
			// refresh visual
			_refreshVisual();
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
				_ruler.scroller.scrollTo(_currentScrollPos);
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
			if(_isRecording && _standardContainer.trackCount == 0) {
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
			
			// if there's no track, reset some values
			if(allTrackCount == 0) bpm = 0;
			
			// refresh buttons states
			_refreshVisual();
		}

		
		
		/**
		 * Record track button clicked event handler.
		 * Display record track modal.
		 * @param event Event data
		 */
		private function _onRecordTrackBtnClick(event:MouseEvent = null):void {
			// only logged in user can use recording
			//if(!App.connection.coreUserLoginStatus) {
			//	App.messageModal.show({title:'Record track', description:'Please log in or wait until the multitrack is fully loaded.', buttons:MessageModal.BUTTONS_OK});
			//	return;
			//}
			
			// test if a record track is already present
			if(_recordTrack != null) {
				// record track is already present
				App.messageModal.show({title:'Record track', description:'Please save the current recorded track first.', buttons:MessageModal.BUTTONS_OK});
				return;
			}
			
			// test if bpm is already set
			if(App.connection.coreSongData.songBPM == 0) {
				// bpm is not set
				App.messageModal.show({title:'Record track', description:'Please set tempo first.', buttons:MessageModal.BUTTONS_OK});
				return;
			}
			
			// prepare recording
			// initialize microphone
			try {
				App.connection.streamService.prepare();
			}
			catch(err1:Error) {
				// something is wrong
				App.messageModal.show({title:'Record track', description:err1.message, buttons:MessageModal.BUTTONS_OK, icon:MessageModal.ICON_WARNING});
				return;
			}
			
			// add recording track
			_recordTrack = _recordContainer.createRecordTrack();
			
			// dispatch
			dispatchEvent(new AppEvent(AppEvent.HIDE_DROPBOX, true));
		}

		
		
		/**
		 * Upload track button clicked event handler.
		 * Display upload trac modal.
		 * @param event Event data
		 */
		private function _onUploadTrackBtnClick(event:MouseEvent = null):void {
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
		 * Export song button clicked event handler.
		 * Display export song modal.
		 * @param event Event data
		 */
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

		
		
		/**
		 * Track playback complete event handler.
		 * Counts all tracks and once all are done, invokes stop()
		 * @param event Event data
		 */
		private function _onTrackPlaybackComplete(event:SamplerEvent):void {
			_completedTracksCounter++;
			if(_isRecording) {
				if(_completedTracksCounter == allTrackCount - 1) {
					Logger.info('Song recording completed.');
					_completedTracksCounter = 0;
					stop();
				}
			} else {
				if(_completedTracksCounter == allTrackCount) {
					Logger.info('Song playback completed.');
					_completedTracksCounter = 0;
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
			
			if(_isRecording) {
				// recording mode
				x = _recordTrack.position / 100;
				
				// recound song length from core song data
				_recountSongLength();
				
				// set visual properties
				_ruler.info.label = App.getTimeCode(_milliseconds);
				_scroller.isEnabled = (_milliseconds > 44700);
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

		
		
		private function _onBPMBtnClick(event:MouseEvent = null):void {
			_beatClicker.isEnabled = !_beatClicker.isEnabled;
			_bpmOffBtn.visible = !_beatClicker.isEnabled;
			_bpmOnBtn.visible = _beatClicker.isEnabled;
			
			// dispatch
			dispatchEvent(new AppEvent(AppEvent.HIDE_DROPBOX, true));
		}

		
		
		private function _onBPMInputChanged(event:InputEvent):void {
			bpm = uint(_bpmInput.text);
		}

		
		
		private function _onRecordStart(event:TrackEvent):void {
			if(allTrackCount == 1) {
				Logger.info('Starting recording (first track recorded, so no record length limit).');
				_recordLimit = 0;
			} else {
				Logger.info(sprintf('Starting recording (record length limit = %s).', App.getTimeCode(_milliseconds)));
				_recordLimit = _milliseconds;
			}
			
			_isRecording = true;
			rewind();
			play();
		}

		
		
		private function _onRecordStop(event:TrackEvent):void {
			_isRecording = false;
			stop();
			
			App.saveTrackModal.show();
		}

		
		
		private function _onBeatClickerBeat(event:BeatClickerEvent):void {
			_bpmToolbar.icon = (event.polarity) ? _metronomeIcon2 : _metronomeIcon1; 
		}

		
		
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
	}
}
