package editor_panel.tracks {
	import application.App;
	
	import caurina.transitions.Tweener;
	
	import config.Embeds;
	import config.Filters;
	import config.Formats;
	import config.Settings;
	
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
		private var _isRecording:Boolean;
		private var _precountTimer:Timer;
		private var _precountSound:Sound;
		private var _isPrecounting:Boolean;
		private var _recordOverlaySpr:QSprite;
		private var _startTime:uint;
		private var _syncedRecordTimeout:uint;

		
		
		/**
		 * Constructor.
		 * @param trackID Track ID
		 */
		public function RecordTrack(trackID:uint) {
			super(trackID, TrackCommon.RECORD_TRACK);

			// add components
			_vuMeter = new VUMeter({x:9, y:2, leds:10, spacingV:0, stereo:false, skin:new Embeds.vuMeter()}, VUMeter.DIRECTION_VERTICAL);
			_recordOverlaySpr = new QSprite({alpha:0, visible:false, blendMode:BlendMode.HARDLIGHT});

			// refresh texts
			refresh();

			// add to display list
			addChildren(this, _vuMeter, _recordOverlaySpr);

			// add sampler
			$addHandlers();
			
			// add event listeners
			this.addEventListener(Event.ENTER_FRAME, _onEnterFrame, false, 0, true);
		}

		
		
		/**
		 * Destructor.
		 */
		override public function destroy():void {
			// remove event listeners
			this.removeEventListener(Event.ENTER_FRAME, _onEnterFrame);
			
			// remove from display list
			removeChildren(this, _vuMeter, _recordOverlaySpr);
			
			// destroy components
			_vuMeter.destroy();
			
			// remove precount timer
			_removePrecountTimer();
			
			super.destroy();
		}
		
		
		
		/**
		 * Get current sample position.
		 * @return Current sample position in ms
		 */
		override public function get position():uint {
			var pos:uint = _startTime ?  uint(new Date()) - _startTime : 0;
			$waveform.recordPosition = App.editor.msecToStageX(pos); // UGLY, a getter should not have side effects!
			return(pos);
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
			Tweener.addTween(_recordOverlaySpr, {alpha:0, time:0.5, transition:'easeOutSine'});
		}

		

		/**
		 * Start recording event handler.
		 * @param event Event data
		 */		
		public function startRecording(event:Event = null):void {
			var precountDelay:uint = 60000 / Settings.BPM / 2;
			var syncDelay:int = precountDelay * 7;
			
			Logger.debug(sprintf('Start precounting (%u BPM, record=%u)', Settings.BPM, precountDelay));
			
			_isPrecounting = true;
			
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
			
			_startTime = 0;

			Tweener.removeTweens(_recordOverlaySpr);
			_recordOverlaySpr.alpha = 0;
			_recordOverlaySpr.visible = false;
			
			_removePrecountTimer();
		}

		
		
		private function _onEnterFrame(event:Event):void {
			_vuMeter.level = App.connection.streamService.recordLevel;
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
			
			Tweener.removeTweens(_recordOverlaySpr);
			_recordOverlaySpr.alpha = .25;
			
			_startTime = uint(new Date());
				
			dispatchEvent(new TrackEvent(TrackEvent.RECORD_START, true));
		}
	}
}
