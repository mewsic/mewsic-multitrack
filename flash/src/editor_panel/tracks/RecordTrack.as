package editor_panel.tracks {
	import application.App;
	
	import caurina.transitions.Tweener;
	
	import config.Embeds;
	import config.Settings;
	
	import controls.ProgressBar;
	import controls.VUMeter;
	
	import de.popforge.utils.sprintf;
	
	import editor_panel.sampler.SamplerEvent;
	
	import flash.display.BlendMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.geom.Rectangle;
	import flash.media.Sound;
	import flash.utils.Timer;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	
	import modals.MessageModal;
	
	import org.osflash.thunderbolt.Logger;
	import org.vancura.graphics.Drawing;
	import org.vancura.graphics.QSprite;
	import org.vancura.util.addChildren;
	import org.vancura.util.removeChildren;
	
	import remoting.dynamic_services.TrackCreateService;
	import remoting.events.TrackCreateEvent;	
	import remoting.events.RemotingEvent;
	
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
		private var _vuMeterEnabled:Boolean;
		
		private var _recordProgress:ProgressBar;
		private var _visualTickSpr:QSprite;

		private var _isRecording:Boolean;
		private var _precountTimer:Timer;
		private var _precountSound:Sound;
		private var _isPrecounting:Boolean;
		private var _startTime:uint;
		private var _syncedRecordTimeout:uint;
		
		private static const _MAX_REC_LEN:uint = 10 * 60 * 1000; // 10 minutes
		private static var _maxrecTimeout:uint;

		
		
		/**
		 * Constructor.
		 * @param trackID Track ID
		 */
		public function RecordTrack(trackID:uint) {
			super(trackID, {killBtnSkin:new Embeds.buttonKillTrack()}); // XXX FIX ASSET

			// add components
			_vuMeter = new VUMeter({x:9, y:2, leds:10, spacingV:0, stereo:false, skin:new Embeds.vuMeter()}, VUMeter.DIRECTION_VERTICAL);
			_visualTickSpr = new QSprite({alpha:0, visible:false, blendMode:BlendMode.HARDLIGHT});
			Drawing.drawRect(_visualTickSpr, 0, 0, Settings.TRACKCONTROLS_WIDTH, Settings.TRACK_HEIGHT, 0xff0000, .9);
			
			_recordProgress = new ProgressBar({x:Settings.TRACKCONTROLS_WIDTH, y:27,
				background:new Embeds.recordProgressBack(), progress:new Embeds.recordProgress(),
				grid:new Rectangle(9, 0, 22, 14)})
			_recordProgress.visible = true;
			_recordProgress.width = Settings.WAVEFORM_WIDTH;

			// refresh texts
			refresh();

			// add to display list
			addChildren(_recordProgress, $killBtn);
			addChildren(this, _vuMeter, _visualTickSpr, _recordProgress);

			enableVuMeter();	
			
			$killBtn.addEventListener(MouseEvent.CLICK, _onKillClick, false, 0, true);			
		}

		
		
		/**
		 * Destructor.
		 */
		override public function destroy():void {
			disableVuMeter();
			
			// remove from display list
			removeChildren(this, _vuMeter, _visualTickSpr, _recordProgress);
			
			// destroy components
			_vuMeter.destroy();
			_recordProgress.destroy();
						
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
			_recordProgress.progress = App.editor.msecToStageX(pos);
			return(pos);
		}
		
		

		/**
		 * Start recording event handler.
		 * @param event Event data
		 */		
		public function startRecording(event:Event = null):void {
			var precountDelay:uint = 60000 / Settings.BPM;
			
			Logger.debug('Start precounting');
			_isPrecounting = true;			
			_addPrecountTimer(precountDelay, 4);
						
			_syncedRecordTimeout = setTimeout(_onStartSyncedRecord, precountDelay * 4);
			_maxrecTimeout = setTimeout(_onMaximalRecordLength, _MAX_REC_LEN);
			
			//_recordOverlayTick();
		}



		private function _onStartSyncedRecord():void {
			_isRecording = true;
		
			try {
				Logger.info('Synced record start.');
				App.connection.streamService.record();
			}
			catch(err:Error) {
				App.messageModal.show({title:'Record track', description:sprintf('Error recording track.\n%s', err.message), buttons:MessageModal.BUTTONS_OK, icon:MessageModal.ICON_WARNING});
				return; 
			}
		}		

		
		
		/**
		 * Stop recording event handler.
		 * @param event Event data
		 */
		public function stopRecording(event:Event = null):void {
			clearTimeout(_maxrecTimeout);

			if(_isRecording) {
				Logger.debug('Stop recording.');
				App.connection.streamService.stop();
				_isRecording = false;				
			}
			else if(_isPrecounting) {
				Logger.debug('Stop precounting.');
				_precountTimer.stop();
				_isPrecounting = false;
			}
			
			_startTime = 0;

			Tweener.addTween(_visualTickSpr, {alpha:0, visible:false});
			
			_removePrecountTimer();
		}
		


		/**
		 * Add precount timer.
		 */
		private function _addPrecountTimer(delay:uint, count:uint):void {
			// remove old precount timer if it is already added
			_removePrecountTimer();
			
			// add precount timer
			_precountTimer = new Timer(delay);
			_precountSound = new Embeds.soundPrecountSnd() as Sound;

			_precountTimer.repeatCount = count;
			_precountTimer.start();

			_precountTimer.addEventListener(TimerEvent.TIMER, _recordOverlayTick, false, 0, true);
			_precountTimer.addEventListener(TimerEvent.TIMER_COMPLETE, _onPrecountComplete, false, 0, true);
		}

		
		
		/**
		 * Remove precount timer.
		 */
		private function _removePrecountTimer():void {
			if(_precountTimer != null) {
				_precountTimer.removeEventListener(TimerEvent.TIMER, _recordOverlayTick);
				_precountTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, _onPrecountComplete);
				_precountTimer.stop();
				_precountTimer = null;
				clearTimeout(_syncedRecordTimeout);
			}
		}

		
		
		/**
		 * Visual tick.
		 */
		private function _recordOverlayTick(event:TimerEvent = null):void {
			_precountSound.play();
			
			_visualTickSpr.alpha = .5;
			_visualTickSpr.visible = true;
			Tweener.addTween(_visualTickSpr, {alpha:0, time:0.5, transition:'easeOutSine'});
		}


		
		private function _onPrecountComplete(event:TimerEvent):void {
			_isPrecounting = false;
			clearTimeout(_syncedRecordTimeout);
			
			Tweener.removeTweens(_visualTickSpr);
			_visualTickSpr.alpha = .25;
			
			_startTime = uint(new Date());

			dispatchEvent(new TrackEvent(TrackEvent.RECORD_START, true));
		}
		
		

		public function _onMaximalRecordLength():void {
			dispatchEvent(new SamplerEvent(SamplerEvent.PLAYBACK_COMPLETE, true));
		}
		
		
		
		public function enableVuMeter():void {
			if(!_vuMeterEnabled) {
				this.addEventListener(Event.ENTER_FRAME, _onEnterFrame, false, 0, true);
				_vuMeterEnabled = true;
			}
		}
		
		
		
		public function disableVuMeter():void {
			if(_vuMeterEnabled) {
				this.removeEventListener(Event.ENTER_FRAME, _onEnterFrame);
				_vuMeterEnabled = false;
			}
		}
		
		
		
		private function _onEnterFrame(event:Event):void {
			_vuMeter.level = App.connection.streamService.recordLevel;
		}
		
		
	
		private function _onKillClick(event:Event = null):void {
			App.editor.killRecordTrack();
		}		
	}
}
