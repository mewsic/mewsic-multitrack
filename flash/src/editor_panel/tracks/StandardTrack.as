package editor_panel.tracks {
	import application.App;
	
	import caurina.transitions.Tweener;
	
	import config.Embeds;
	import config.Filters;
	import config.Settings;
	
	import controls.Button;
	import controls.Slider;
	import controls.SliderEvent;
	
	import de.popforge.utils.sprintf;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import org.osflash.thunderbolt.Logger;
	import org.vancura.graphics.QBitmap;
	import org.vancura.util.addChildren;
	import org.vancura.util.removeChildren;	

	
	
	/**
	 * Standard track.
	 * 
	 * TODO: Write documentation
	 * 
	 * @author Vaclav Vancura (http://vaclav.vancura.org)
	 * @since Jun 19, 2008
	 */
	public class StandardTrack extends TrackCommon {

		
		
		private var _volumeSlider:Slider;
		private var _volumeActive:QBitmap;
		private var _volumeMuted:QBitmap;

		private var _background:QBitmap;
		
		// private var _balanceKnob:Knob; XXX RE-ENABLE ME
		
		
		
		/**
		 * Constructor.
		 * @param trackID Track ID
		 */
		public function StandardTrack(trackID:uint) {
			super(trackID, TrackCommon.STANDARD_TRACK);

			// add components
			_volumeSlider = new Slider({x:10, backSkin:new Embeds.backgroundSliderVolume(), thumbSkin:new Embeds.buttonSliderVolume(),
				marginBegin:5, marginEnd:5, wheelRatio:.015},
				Slider.DIRECTION_VERTICAL);
				
			_volumeActive = new QBitmap({x:18, embed:new Embeds.backgroundVolumeActive()});
			_volumeMuted = new QBitmap({x:18, embed:new Embeds.backgroundVolumeMuted()});

			_background = new QBitmap({x:Settings.TRACKCONTROLS_WIDTH, height:52, embed:new Embeds.backgroundTrack()}); // Track lane background

//			_balanceKnob = new Knob({x:458, y:1, backSkin:new Embeds.buttonContainerPanKnobBD(), pointerSpr:new Embeds.buttonContainerPanKnobPointerSpr(), rangeBegin:-118, rangeEnd:118});

			// add to display list
			addChildren(this, _background, _volumeSlider, _volumeActive, _volumeMuted);
			
			// add handlers
			$addHandlers();
			
			// add event listeners
			$killBtn.addEventListener(MouseEvent.CLICK, _onKillClick, false, 0, true);
			
			_volumeSlider.addEventListener(SliderEvent.REFRESH, _onVolumeSliderRefresh, false, 0, true);
//			_balanceKnob.addEventListener(KnobEvent.REFRESH, _onKnobRefresh, false, 0, true);
			super.addEventListener(TrackEvent.REFRESH, _onRefresh, false, 0, true);
			
			// set states and refresh
			_volumeSlider.thumbPos = 1 - .9;
			_onRefresh();			
		}

		
		
		/**
		 * Destructor.
		 */
		override public function destroy():void {
			// remove event listeners
			$killBtn.removeEventListener(MouseEvent.CLICK, _onKillClick);
			
			_volumeSlider.removeEventListener(SliderEvent.REFRESH, _onVolumeSliderRefresh);
//			_balanceKnob.removeEventListener(KnobEvent.REFRESH, _onKnobRefresh);

			super.removeEventListener(TrackEvent.REFRESH, _onRefresh);

			// remove from display list
			removeChildren(this, _volumeSlider, _volumeActive, _volumeMuted);

			// destroy components
			$killBtn.destroy();

			_volumeSlider.destroy();

//			_balanceKnob.destroy();
			
			super.destroy();
		}

		
		
		override public function refresh():void {
//			_balanceKnob.angle = 118 * $trackData.trackBalance;
			_volumeSlider.thumbPos = $trackData.trackVolume;
			
			
			super.refresh();
		}

		
		
		override public function load():void {
			super.load();
			
			refresh();
			
			// load sampler and waveform
			$sampler.load(App.connection.serverPath + $trackData.trackSampleURL, $trackData.trackMilliseconds);
			$waveform.load(App.connection.serverPath + $trackData.trackWaveformURL, $trackData.trackMilliseconds);
		}
		
		
		
		override public function play():void {
			$killBtn.alpha = .4;
			$killBtn.areEventsEnabled = false;
			
			super.play();
		}

		
		
		override public function stop():void {
			$killBtn.alpha = 1;
			$killBtn.areEventsEnabled = true;
			
			super.stop();
		}
		
		
		
		override public function resume():void {
			$killBtn.alpha = .4;
			$killBtn.areEventsEnabled = false;
			
			super.resume();
		}

		
		
		override public function pause():void {
			$killBtn.alpha = 1;
			$killBtn.areEventsEnabled = true;
			
			super.pause();
		}

		
		public function set volume(value:Number):void {
			try {
				$sampler.volume = value;
			}
			catch(err:Error) {
				// sampler may be not initialized
			}
			finally {
				_volumeSlider.thumbPos = 1 - value;
			}
		}
		
		
		
		/**
		 * Kill button click event handler.
		 * @param event Event data
		 */
		private function _onKillClick(event:MouseEvent):void {
			Logger.debug(sprintf('Kill track (trackID=%u, trackTitle=%s)', $trackData.trackID, $trackData.trackTitle));
			dispatchEvent(new TrackEvent(TrackEvent.KILL));
		}

		
		
		private function _onRefresh(event:Event = null):void {
/*			_muteOffBtn.visible = !$isMuted;
			_muteOnBtn.visible = $isMuted;
			_soloOffBtn.visible = !$isSolo;
			_soloOnBtn.visible = $isSolo;*/
		}

		
		
/*		private function _onKnobRefresh(event:KnobEvent):void {
			var p:Number = -1 / (118 / event.thumbAngle);
			
			$sampler.balance = p;
			$trackData.trackBalance = p;
			
			dispatchEvent(new TrackEvent(TrackEvent.BALANCE_CHANGE, false, false, {balance:p}));
		}*/

		
		
		private function _onVolumeSliderRefresh(event:SliderEvent):void {
			try {
				var v:Number = 1 - event.thumbPos;
				$sampler.volume = v;
				$trackData.trackVolume = v;
				
				var fadeIn:Object = {time:0.1, alpha:1, transition:'easeOutSine'};
				var fadeOut:Object = {time:0.1, alpha:0, transition:'easeOutSine'};

				// iteration 1 - no fadein/out
				// _volumeActive.visible = v > 0;
				// _volumeMuted.visible = v == 0;

				// iteration 2 - fadein/out
				Tweener.addTween(_volumeActive, v > 0 ? fadeIn : fadeOut);
				Tweener.addTween(_volumeMuted, v == 0 ? fadeIn : fadeOut);	

				dispatchEvent(new TrackEvent(TrackEvent.VOLUME_CHANGE, false, false, {volume:v}));
			}
			catch(err:Error) {
				// sampler may be not initialized
			}
		}
	}
}
