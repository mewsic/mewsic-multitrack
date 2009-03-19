package editor_panel.tracks {
	import application.App;
	
	import caurina.transitions.Tweener;
	
	import config.Embeds;
	import config.Filters;
	import config.Formats;
	
	import controls.Button;
	import controls.Slider;
	import controls.SliderEvent;
	import controls.VUMeter;
	
	import de.popforge.utils.sprintf;
	
	import flash.display.BlendMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.media.Sound;
	import flash.utils.Timer;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	
	import modals.MessageModal;
	
	import org.osflash.thunderbolt.Logger;
	import org.vancura.graphics.QBitmap;
	import org.vancura.graphics.QSprite;
	import org.vancura.graphics.QTextField;
	import org.vancura.util.addChildren;
	import org.vancura.util.removeChildren;	

	
	
	/**
	 * Record track.
	 * 
	 * TODO: Write documentation
	 * 
	 * @author Vaclav Vancura (http://vaclav.vancura.org)
	 * @since Jun 19, 2008
	 */
	public class RecordTrack extends TrackCommon {

		
		
		private var _vuMeter:VUMeter;
		private var _recordBtn:Button;
		private var _stopBtn:Button;
		private var _volumeSlider:Slider;
		private var _isRecording:Boolean;
		private var _precountTimer:Timer;
		private var _precountSound:Sound;
		private var _isPrecounting:Boolean;
		private var _recordOverlayBM:QBitmap;
		private var _recordOverlaySpr:QSprite;
		private var _statusTF:QTextField;
		private var _startTime:uint;
		private var _syncedRecordTimeout:int;

		
		
		/**
		 * Constructor.
		 * @param trackID Track ID
		 */
		public function RecordTrack(trackID:uint) {
			super(trackID, TrackCommon.RECORD_TRACK);

			// add components
			_vuMeter = new VUMeter({x:430, y:2, leds:9, spacingH:9, spacingV:1, skin:new Embeds.vuMeterContainerVerticalBD()}, VUMeter.DIRECTION_VERTICAL);
			_volumeSlider = new Slider({x:350, backSkin:new Embeds.sliderRecordContainerVolumeBD(), thumbSkin:new Embeds.recordContainerVolumeThumbBD, marginBegin:5, marginEnd:5, wheelRatio:.015}, Slider.DIRECTION_VERTICAL);
			_recordBtn = new Button({x:472, y:12, width:36, height:21, skin:new Embeds.buttonRedBD, icon:new Embeds.glyphRecordBD(), textOutFilters:Filters.buttonRedLabel, textOverFilters:Filters.buttonRedLabel, textPressFilters:Filters.buttonRedLabel, textOutOffsY:-1, textOverOffsY:-1, textPressOffsY:0});
			_stopBtn = new Button({visible:false, x:472, y:12, width:36, height:21, skin:new Embeds.buttonRedBD, icon:new Embeds.glyphStop2BD(), textOutFilters:Filters.buttonRedLabel, textOverFilters:Filters.buttonRedLabel, textPressFilters:Filters.buttonRedLabel, textOutOffsY:-1, textOverOffsY:-1, textPressOffsY:0});
			_recordOverlaySpr = new QSprite({alpha:0, visible:false, blendMode:BlendMode.HARDLIGHT});
			_recordOverlayBM = new QBitmap({embed:new Embeds.recordContainerRecordBD()});
			_statusTF = new QTextField({x:50, y:9, width:90, height:32, defaultTextFormat:Formats.recordTrackStatus});

			// refresh texts
			refresh();

			// add to display list
			addChildren(_recordOverlaySpr, _recordOverlayBM);
			addChildren(this, _vuMeter, _volumeSlider, _recordBtn, _recordOverlaySpr, _stopBtn, _statusTF);

			// add sampler
			$addHandlers();
			
			// add event listeners
			_volumeSlider.addEventListener(SliderEvent.REFRESH, _onVolumeSliderRefresh, false, 0, true);
			_recordBtn.addEventListener(MouseEvent.CLICK, startRecording, false, 0, true);
			_stopBtn.addEventListener(MouseEvent.CLICK, stopRecording, false, 0, true);
			this.addEventListener(Event.ENTER_FRAME, _onEnterFrame, false, 0, true);
			
			// set states and refresh
			_volumeSlider.thumbPos = 1 - .9;
		}

		
		
		/**
		 * Destructor.
		 */
		override public function destroy():void {
			// remove event listeners
			_volumeSlider.removeEventListener(SliderEvent.REFRESH, _onVolumeSliderRefresh);
			_recordBtn.removeEventListener(MouseEvent.CLICK, startRecording);
			_stopBtn.removeEventListener(MouseEvent.CLICK, stopRecording);
			this.removeEventListener(Event.ENTER_FRAME, _onEnterFrame);
			
			// remove from display list
			removeChildren(_recordOverlaySpr, _recordOverlayBM);
			removeChildren(this, _vuMeter, _volumeSlider, _recordBtn, _recordOverlaySpr, _stopBtn, _statusTF);
			
			// destroy components
			_volumeSlider.destroy();
			_vuMeter.destroy();
			_recordBtn.destroy();
			
			// remove precount timer
			_removePrecountTimer();
			
			super.destroy();
		}
		
		
		
		/**
		 * Get current sample position.
		 * @return Current sample position in ms
		 */
		override public function get position():uint {
			var p:uint = uint(new Date()) - _startTime;
			$waveform.recordPosition = p;
			return(p);
		}
		
		
		
		/**
		 * Add precount timer.
		 */
		private function _addPrecountTimer():void {
			// remove old precount timer if it is already added
			_removePrecountTimer();
			
			// add precount timer
			_precountTimer = new Timer(1000);
			_precountSound = new Embeds.soundPrecountSnd() as Sound;
			_precountTimer.addEventListener(TimerEvent.TIMER, _onPrecountTimer, false, 0, true);
			_precountTimer.addEventListener(TimerEvent.TIMER_COMPLETE, _onPrecountComplete, false, 0, true);
		}

		
		
		/**
		 * Remove precount timer.
		 */
		private function _removePrecountTimer():void {
			if(_precountTimer != null) {
				_precountTimer.removeEventListener(TimerEvent.TIMER, _onPrecountTimer);
				_precountTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, _onPrecountComplete);
				_precountTimer.stop();
				_precountTimer = null;
				clearTimeout(_syncedRecordTimeout);
			}
		}

		
		
		/**
		 * Visual tick.
		 */
		private function _recordOverlayTick():void {
			if(_precountTimer.currentCount < 7) _precountSound.play();
			_recordOverlaySpr.alpha = .25;
			_recordOverlaySpr.visible = true;
			Tweener.addTween(_recordOverlaySpr, {alpha:0, time:60 / $trackData.trackBPM, transition:'easeOutSine'});
		}

		

		/**
		 * Start recording event handler.
		 * @param event Event data
		 */		
		public function startRecording(event:Event = null):void {
			var precountDelay:uint = 60000 / $trackData.trackBPM / 2;
			var syncDelay:int = precountDelay * 7;
			
			Logger.debug(sprintf('Start precounting (%u BPM, record=%u)', $trackData.trackBPM, precountDelay));
			
			_stopBtn.visible = true;
			_recordBtn.visible = false;
			_isPrecounting = true;
			_statusTF.textColor = 0xFFFFFF;
			_statusTF.text = 'GET\nREADY';
			
			_addPrecountTimer(); 
			
			_precountTimer.delay = precountDelay;
			_precountTimer.repeatCount = 7;
			_precountTimer.start();
			
			_syncedRecordTimeout = setTimeout(_onStartSyncedRecord, syncDelay);
			
			_recordOverlayTick();
		}

		
		
		/**
		 * Stop recording event handler.
		 * @param event Event data
		 */
		public function stopRecording(event:Event = null):void {
			if(_isRecording) {
				Logger.debug('Stop recording.');
				App.connection.streamService.stop();
				_isRecording = false;
				
				dispatchEvent(new TrackEvent(TrackEvent.RECORD_STOP, true));
			}
			else if(_isPrecounting) {
				Logger.debug('Stop precounting.');
				_precountTimer.stop();
				_isPrecounting = false;
			}
			
			_stopBtn.visible = false;
			_recordBtn.visible = true;
			_statusTF.textColor = 0x485C66;
			_statusTF.text = 'ENCODING\nTRACK';
			
			Tweener.removeTweens(_recordOverlaySpr);
			_recordOverlaySpr.alpha = 0;
			_recordOverlaySpr.visible = false;
			
			_removePrecountTimer();
		}

		
		
		private function _onEnterFrame(event:Event):void {
			_vuMeter.bothLevels = App.connection.streamService.recordLevel;
		}

		
		
		private function _onVolumeSliderRefresh(event:SliderEvent):void {
			try {
				var v:Number = 1 - event.thumbPos;
				$sampler.volume = v;
				$trackData.trackVolume = v;
				dispatchEvent(new TrackEvent(TrackEvent.VOLUME_CHANGE, false, false, {volume:v}));
			}
			catch(err:Error) {
				// sampler may be not initialized
			}
		}

		
		
		private function _onPrecountTimer(event:TimerEvent):void {
			if((_precountTimer.currentCount <= 8 && _precountTimer.currentCount % 2 == 0) || _precountTimer.currentCount > 8) _recordOverlayTick();
		}
		
		
		private function _onStartSyncedRecord():void {
			try {
				Logger.info('Synced record start.');
				App.connection.streamService.record();
			}
			catch(err:Error) {
				App.messageModal.show({title:'Record track', description:sprintf('Error recording track.\n%s', err.message), buttons:MessageModal.BUTTONS_OK, icon:MessageModal.ICON_WARNING});
				return; 
			}
		}

		
		
		private function _onPrecountComplete(event:TimerEvent):void {
			_isPrecounting = false;
			clearTimeout(_syncedRecordTimeout);
			
			_isRecording = true;
			_statusTF.textColor = 0xFFFFFF;
			_statusTF.text = 'RECORDING\nTRACK';
			
			Tweener.removeTweens(_recordOverlaySpr);
			_recordOverlaySpr.alpha = .25;
			
			_startTime = uint(new Date());
				
			dispatchEvent(new TrackEvent(TrackEvent.RECORD_START, true));
		}
	}
}
