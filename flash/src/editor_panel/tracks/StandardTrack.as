package editor_panel.tracks {
	import application.App;
	
	import caurina.transitions.Tweener;
	
	import config.Embeds;
	import config.Filters;
	import config.Formats;
	import config.Settings;
	
	import controls.Button;
	import controls.Knob;
	import controls.KnobEvent;
	import controls.Slider;
	import controls.SliderEvent;
	import controls.Thumbnail;
	
	import remoting.data.TrackData;
	
	import de.popforge.utils.sprintf;
	
	import org.osflash.thunderbolt.Logger;
	import org.vancura.graphics.QTextField;
	import org.vancura.util.addChildren;
	import org.vancura.util.removeChildren;
	
	import flash.events.Event;
	import flash.events.MouseEvent;	

	
	
	/**
	 * Standard track.
	 * 
	 * TODO: Write documentation
	 * 
	 * @author Vaclav Vancura (http://vaclav.vancura.org)
	 * @since Jun 19, 2008
	 */
	public class StandardTrack extends TrackCommon {

		
		
		private var _killBtn:Button;
		private var _muteOffBtn:Button;
		private var _muteOnBtn:Button;
		private var _saveBtn:Button;
		private var _soloOffBtn:Button;
		private var _soloOnBtn:Button;
		private var _volumeSlider:Slider;
		private var _knob:Knob;
		private var _instrumentThumbnail:Thumbnail;
		private var _instrumentTF:QTextField;

		
		
		/**
		 * Constructor.
		 * @param trackID Track ID
		 */
		public function StandardTrack(trackID:uint) {
			super(trackID, TrackCommon.STANDARD_TRACK);

			// add components
			_soloOffBtn = new Button({x:398, y:5, skin:new Embeds.buttonContainerToolbarLTBD(), icon:new Embeds.glyphSoloSmallBD(), textOutFilters:Filters.buttonBeigeLabel, textOverFilters:Filters.buttonBeigeLabel, textPressFilters:Filters.buttonBeigeLabel}, Button.TYPE_NOSCALE_BUTTON);
			_muteOffBtn = new Button({x:423, y:5, skin:new Embeds.buttonContainerToolbarRTBD(), icon:new Embeds.glyphMuteSmallBD(), textOutFilters:Filters.buttonBeigeLabel, textOverFilters:Filters.buttonBeigeLabel, textPressFilters:Filters.buttonBeigeLabel}, Button.TYPE_NOSCALE_BUTTON);
			_soloOnBtn = new Button({x:398, y:5, skin:new Embeds.buttonContainerToolbarLTActiveBD(), icon:new Embeds.glyphSoloSmallBD(), textOutFilters:Filters.buttonActiveLabel, textOverFilters:Filters.buttonActiveLabel, textPressFilters:Filters.buttonActiveLabel}, Button.TYPE_NOSCALE_BUTTON);
			_muteOnBtn = new Button({x:423, y:5, skin:new Embeds.buttonContainerToolbarRTActiveBD(), icon:new Embeds.glyphMuteSmallBD(), textOutFilters:Filters.buttonActiveLabel, textOverFilters:Filters.buttonActiveLabel, textPressFilters:Filters.buttonActiveLabel}, Button.TYPE_NOSCALE_BUTTON);
			_saveBtn = new Button({x:398, y:25, skin:new Embeds.buttonContainerToolbarLBBD(), icon:new Embeds.glyphSaveSmallBD(), textOutFilters:Filters.buttonBeigeLabel, textOverFilters:Filters.buttonBeigeLabel, textPressFilters:Filters.buttonBeigeLabel}, Button.TYPE_NOSCALE_BUTTON);
			_killBtn = new Button({x:423, y:25, skin:new Embeds.buttonContainerToolbarRBBD(), icon:new Embeds.glyphKillSmallBD(), textOutFilters:Filters.buttonBeigeLabel, textOverFilters:Filters.buttonBeigeLabel, textPressFilters:Filters.buttonBeigeLabel}, Button.TYPE_NOSCALE_BUTTON);
			_volumeSlider = new Slider({x:350, backSkin:new Embeds.sliderStandardContainerVolumeBD(), thumbSkin:new Embeds.standardContainerVolumeThumbBD(), marginBegin:5, marginEnd:5, wheelRatio:.015}, Slider.DIRECTION_VERTICAL);
			_knob = new Knob({x:458, y:1, backSkin:new Embeds.buttonContainerPanKnobBD(), pointerSpr:new Embeds.buttonContainerPanKnobPointerSpr(), rangeBegin:-118, rangeEnd:118});
			_instrumentTF = new QTextField({alpha:0, x:82, width:61, height:52, defaultTextFormat:Formats.standardContainerInstrument, filters:Filters.standardContainerContentTitle, sharpness:-25, thickness:-50});
			_instrumentThumbnail = new Thumbnail({x:47, y:6});

			// add to display list
			addChildren(this, _soloOffBtn, _soloOnBtn, _muteOffBtn, _muteOnBtn, _saveBtn, _killBtn, _volumeSlider, _knob, _instrumentThumbnail, _instrumentTF);
			
			// add handlers
			$addHandlers();
			
			// add event listeners
			_soloOffBtn.addEventListener(MouseEvent.CLICK, _onSoloClick, false, 0, true);
			_muteOffBtn.addEventListener(MouseEvent.CLICK, _onMuteClick, false, 0, true);
			_soloOnBtn.addEventListener(MouseEvent.CLICK, _onSoloClick, false, 0, true);
			_muteOnBtn.addEventListener(MouseEvent.CLICK, _onMuteClick, false, 0, true);
			_saveBtn.addEventListener(MouseEvent.CLICK, _onSaveClick, false, 0, true);
			_killBtn.addEventListener(MouseEvent.CLICK, _onKillClick, false, 0, true);
			_volumeSlider.addEventListener(SliderEvent.REFRESH, _onVolumeSliderRefresh, false, 0, true);
			_knob.addEventListener(KnobEvent.REFRESH, _onKnobRefresh, false, 0, true);
			super.addEventListener(TrackEvent.REFRESH, _onRefresh, false, 0, true);
			
			// set states and refresh
			_volumeSlider.thumbPos = 1 - .9;
			_onRefresh();
			
			// show save button only for logged user
			if(!App.connection.coreUserLoginStatus) {
				_saveBtn.alpha = .4;
				_saveBtn.areEventsEnabled = false;
			}
		}

		
		
		/**
		 * Destructor.
		 */
		override public function destroy():void {
			// remove event listeners
			_soloOffBtn.removeEventListener(MouseEvent.CLICK, _onSoloClick);
			_muteOffBtn.removeEventListener(MouseEvent.CLICK, _onMuteClick);
			_soloOnBtn.removeEventListener(MouseEvent.CLICK, _onSoloClick);
			_muteOnBtn.removeEventListener(MouseEvent.CLICK, _onMuteClick);
			_saveBtn.removeEventListener(MouseEvent.CLICK, _onSaveClick);
			_killBtn.removeEventListener(MouseEvent.CLICK, _onKillClick);
			_knob.removeEventListener(KnobEvent.REFRESH, _onKnobRefresh);
			_volumeSlider.removeEventListener(SliderEvent.REFRESH, _onVolumeSliderRefresh);
			super.removeEventListener(TrackEvent.REFRESH, _onRefresh);

			// remove from display list
			removeChildren(this, _soloOffBtn, _soloOnBtn, _muteOffBtn, _muteOnBtn, _saveBtn, _killBtn, _volumeSlider, _knob, _instrumentThumbnail, _instrumentTF);

			// destroy components
			_soloOffBtn.destroy();
			_muteOffBtn.destroy();
			_saveBtn.destroy();
			_killBtn.destroy();
			_knob.destroy();
			_volumeSlider.destroy();
			_instrumentThumbnail.destroy();
			
			super.destroy();
		}

		
		
		override public function refresh():void {
			_instrumentTF.y = Math.round((52 - _instrumentTF.textHeight) / 2) - 5;
			
			_knob.angle = 118 * $trackData.trackBalance;
			_volumeSlider.thumbPos = $trackData.trackVolume;
			
			super.refresh();
		}

		
		
		override public function load():void {
			super.load();
			
			// get instrument description and icon
			var instrumentDescription:String;
			var instrumentIconURL:String;
			try {
				instrumentDescription = App.connection.instrumentsService.byID($trackData.trackInstrumentID).instrumentName;
				instrumentIconURL = App.connection.instrumentsService.byID($trackData.trackInstrumentID).instrumentIconURL;
			}
			catch(err2:Error) {
				instrumentDescription = 'Unknown instrument'; 
			}
			
			_instrumentTF.text = instrumentDescription;
			_instrumentThumbnail.load(App.connection.serverPath + instrumentIconURL);
			
			refresh();
			
			Tweener.addTween(_instrumentTF, {time:Settings.FADEIN_TIME, alpha:1, transition:'easeOutSine'});
			
			// load sampler and waveform
			$sampler.load(App.connection.serverPath + $trackData.trackSampleURL, $trackData.trackMilliseconds);
			$waveform.load(App.connection.serverPath + $trackData.trackWaveformURL, $trackData.trackMilliseconds);
		}
		
		
		
		override public function play():void {
			_killBtn.alpha = .4;
			_killBtn.areEventsEnabled = false;
			
			_saveBtn.alpha = .4;
			_saveBtn.areEventsEnabled = false;
			
			super.play();
		}

		
		
		override public function stop():void {
			_killBtn.alpha = 1;
			_killBtn.areEventsEnabled = true;
			
			// show save button only for logged user
			if(App.connection.coreUserLoginStatus) {
				_saveBtn.alpha = 1;
				_saveBtn.areEventsEnabled = true;
			}
			
			super.stop();
		}
		
		
		
		override public function resume():void {
			_killBtn.alpha = .4;
			_killBtn.areEventsEnabled = false;
			
			_saveBtn.alpha = .4;
			_saveBtn.areEventsEnabled = false;
			
			super.resume();
		}

		
		
		override public function pause():void {
			_killBtn.alpha = 1;
			_killBtn.areEventsEnabled = true;
			
			// show save button only for logged user
			if(App.connection.coreUserLoginStatus) {
				_saveBtn.alpha = 1;
				_saveBtn.areEventsEnabled = true;
			}
			
			super.pause();
		}

		
		
		public function toggleMute():void {
			_onMuteClick();
		}
		
		
		
		public function toggleSolo():void {
			_onSoloClick();
		}
		
		
		
		public function alterVolume(step:Number):void {
			_volumeSlider.thumbPos += step;
		}

		
		
		public function alterBalance(step:Number):void {
			_knob.angle += step * 200;
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

		
		
		/**
		 * Save button click event handler.
		 * @param event Event data
		 */
		private function _onSaveClick(event:MouseEvent):void {
			Logger.debug(sprintf('Save track (trackID=%u, trackTitle=%s)', $trackData.trackID, $trackData.trackTitle));
			App.downloadTrackModal.downloadURL = App.connection.serverPath + App.connection.configService.trackDownloadRequestURL.replace(/{:track_id}/g, $trackData.trackID);
			App.downloadTrackModal.show();
		}

		
		
		/**
		 * Mute button click event handler.
		 * @param event Event data
		 */
		private function _onMuteClick(event:MouseEvent = null):void {
			if($isMuted) {
				Logger.debug(sprintf('Unmute track (trackID=%u, trackTitle=%s)', $trackData.trackID, $trackData.trackTitle));
				$isMuted = false;
				dispatchEvent(new TrackEvent(TrackEvent.MUTE_OFF));
			}
			else {
				Logger.debug(sprintf('Mute track (trackID=%u, trackTitle=%s)', $trackData.trackID, $trackData.trackTitle));
				$isMuted = true;
				dispatchEvent(new TrackEvent(TrackEvent.MUTE_ON));
			}
			_onRefresh();
		}

		
		
		/**
		 * Solo button click event handler.
		 * @param event Event data
		 */
		private function _onSoloClick(event:MouseEvent = null):void {
			if($isSolo) {
				Logger.debug(sprintf('Unsolo track (trackID=%u, trackTitle=%s)', $trackData.trackID, $trackData.trackTitle));
				$isSolo = false;
				dispatchEvent(new TrackEvent(TrackEvent.SOLO_OFF));
			}
			else {
				Logger.debug(sprintf('Solo track (trackID=%u, trackTitle=%s)', $trackData.trackID, $trackData.trackTitle));
				$isSolo = true;
				dispatchEvent(new TrackEvent(TrackEvent.SOLO_ON));
			}
			_onRefresh();
		}

		
		
		private function _onRefresh(event:Event = null):void {
			_muteOffBtn.visible = !$isMuted;
			_muteOnBtn.visible = $isMuted;
			_soloOffBtn.visible = !$isSolo;
			_soloOnBtn.visible = $isSolo;
		}

		
		
		private function _onKnobRefresh(event:KnobEvent):void {
			var p:Number = -1 / (118 / event.thumbAngle);
			
			$sampler.balance = p;
			$trackData.trackBalance = p;
			
			dispatchEvent(new TrackEvent(TrackEvent.BALANCE_CHANGE, false, false, {balance:p}));
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
	}
}
