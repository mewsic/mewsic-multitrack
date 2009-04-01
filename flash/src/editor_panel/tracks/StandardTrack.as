package editor_panel.tracks {
	import application.App;
	
	import caurina.transitions.Tweener;
	
	import config.Embeds;
	import config.Settings;
	
	import controls.ProgressBar;
	import controls.Slider;
	import controls.SliderEvent;
	
	import de.popforge.utils.sprintf;
	
	import editor_panel.sampler.Sampler;
	import editor_panel.sampler.SamplerEvent;
	import editor_panel.waveform.Waveform;
	
	import flash.events.DataEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.TimerEvent;
	import flash.geom.Rectangle;
	import flash.net.FileReference;
	import flash.net.URLRequest;
	import flash.net.URLVariables;
	import flash.utils.Timer;
	
	import modals.MessageModal;
	
	import org.osflash.thunderbolt.Logger;
	import org.vancura.graphics.QBitmap;
	import org.vancura.util.addChildren;
	import org.vancura.util.removeChildren;
	
	import remoting.data.WorkerStatusData;
	import remoting.dynamic_services.TrackEncodeService;
	import remoting.dynamic_services.TrackFetchService;
	import remoting.dynamic_services.WorkerEncodeService;
	import remoting.events.RemotingEvent;
	import remoting.events.TrackEncodeEvent;
	import remoting.events.TrackFetchEvent;
	import remoting.events.WorkerEvent;

	
	/**
	 * Standard track.
	 * 
	 * TODO: Write documentation
	 * 
	 * @author Vaclav Vancura (http://vaclav.vancura.org)
	 * @since Jun 19, 2008
	 */
	public class StandardTrack extends TrackCommon {

		
		private static const _WORKER_ID:String = 'workerSaveTrack';
		
		private var _sampler:Sampler;
		private var _waveform:Waveform;

		private var _volumeSlider:Slider;
		private var _volumeActive:QBitmap;
		private var _volumeMuted:QBitmap;

		private var _background:QBitmap;
		
		// private var _balanceKnob:Knob; XXX RE-ENABLE ME
		
		private var _progressBar:ProgressBar;

		// Encoding stuff
		private var _encodeKey:String;
		private var _workerEncodeService:WorkerEncodeService;
		private var _trackEncodeService:TrackEncodeService;
		private var _encodeWorkerTimer:Timer;
		private var _trackFetchService:TrackFetchService;

		/**
		 * Constructor.
		 * @param trackID Track ID
		 */
		public function StandardTrack(trackID:uint) {
			super(trackID, {killBtnSkin:new Embeds.buttonKillTrack()});

			// create components
			_sampler = new Sampler();
			_waveform = new Waveform({x:Settings.TRACKCONTROLS_WIDTH});
			_waveform.visible = false;
			
			_progressBar = new ProgressBar({x:Settings.TRACKCONTROLS_WIDTH, y:27,
				background:new Embeds.recordProgressBack(), progress:new Embeds.recordProgress(),
				grid:new Rectangle(9, 0, 22, 14)})
			_progressBar.visible = false;
			_progressBar.width = Settings.WAVEFORM_WIDTH;
			_progressBar.progress = 1;
			

			// add event listeners
			_sampler.addEventListener(SamplerEvent.SAMPLE_PROGRESS, _onSamplerProgress, false, 0, true);
			_sampler.addEventListener(SamplerEvent.SAMPLE_DOWNLOADED, _onSamplerDownloaded, false, 0, true);
			_sampler.addEventListener(SamplerEvent.PLAYBACK_COMPLETE, _onSamplerPlaybackComplete, false, 0, true);

			// add components
			_volumeSlider = new Slider({x:4, y:4, backSkin:new Embeds.backgroundSliderVolume(), thumbSkin:new Embeds.buttonSliderVolume(),
				marginBegin:5, marginEnd:5, wheelRatio:.015},
				Slider.DIRECTION_VERTICAL);
				
			_volumeActive = new QBitmap({x:12, embed:new Embeds.backgroundVolumeActive()});
			_volumeMuted = new QBitmap({x:12, embed:new Embeds.backgroundVolumeMuted()});

			_background = new QBitmap({x:Settings.TRACKCONTROLS_WIDTH - 1, height:Settings.TRACK_HEIGHT - 1, y:1, embed:new Embeds.backgroundTrack()}); // Track lane background
			_background.alpha = 0;
			
//			_balanceKnob = new Knob({x:458, y:1, backSkin:new Embeds.buttonContainerPanKnobBD(), pointerSpr:new Embeds.buttonContainerPanKnobPointerSpr(), rangeBegin:-118, rangeEnd:118});

			// add to display list
			addChildren(_waveform, $killBtn);
			addChildren(this, _background, _volumeSlider, _volumeActive, _volumeMuted, _waveform, _progressBar);
			
			// add event listeners
			$killBtn.addEventListener(MouseEvent.CLICK, _onKillClick, false, 0, true);

			_waveform.addEventListener(MouseEvent.MOUSE_OVER, function():void {
				Tweener.addTween(_background, {alpha:1, time:Settings.FADEIN_TIME, transition:'easeOutSine'}); });
			_waveform.addEventListener(MouseEvent.MOUSE_OUT, function():void {
				Tweener.addTween(_background, {alpha:0, time:Settings.FADEOUT_TIME, transition:'easeOutSine'}); });
			
			_volumeSlider.addEventListener(SliderEvent.REFRESH, _onVolumeSliderRefresh, false, 0, true);
//			_balanceKnob.addEventListener(KnobEvent.REFRESH, _onKnobRefresh, false, 0, true);
			
			// set states and refresh
			_volumeSlider.thumbPos = 1 - .9;
		}

		
		
		/**
		 * Destructor.
		 */
		override public function destroy():void {
			// remove event listeners
			_sampler.removeEventListener(SamplerEvent.SAMPLE_PROGRESS, _onSamplerProgress);
			_sampler.removeEventListener(SamplerEvent.PLAYBACK_COMPLETE, _onSamplerPlaybackComplete);
				
			$killBtn.removeEventListener(MouseEvent.CLICK, _onKillClick);
			
			_volumeSlider.removeEventListener(SliderEvent.REFRESH, _onVolumeSliderRefresh);
//			_balanceKnob.removeEventListener(KnobEvent.REFRESH, _onKnobRefresh);

			// remove from display list
			removeChildren(_waveform, $killBtn);
			removeChildren(this, _background, _volumeSlider, _volumeActive, _volumeMuted, _waveform, _progressBar);

			// destroy components
			_sampler.destroy();
			_waveform.destroy();
			_progressBar.destroy();
			_volumeSlider.destroy();

//			_balanceKnob.destroy();
			
			super.destroy();
		}

		
		
		override public function refresh():void {
//			_balanceKnob.angle = 118 * $trackData.trackBalance;
			_volumeSlider.thumbPos = $trackData.trackVolume;

			// refresh volume & balance
			_sampler.volume = $trackData.trackVolume;
			_sampler.balance = $trackData.trackBalance;
			
			super.refresh();
		}



		override public function rescale(msec:uint):void {
			_waveform.stretch(msec);
		}

		
		
		override public function load():void {
			super.load();
			
			refresh();
			
			// load sampler and waveform
			if($trackData.trackSampleURL && $trackData.trackWaveformURL) {
				_sampler.load(App.connection.serverPath + $trackData.trackSampleURL, $trackData.trackMilliseconds);
				_waveform.load(App.connection.serverPath + $trackData.trackWaveformURL, $trackData.trackMilliseconds);
				_waveform.visible = true;
				_progressBar.visible = false;
			} else {
				_waveform.visible = false;
				_progressBar.visible = true;
			}
		}
		
		
		
		override public function play():void {
			$killBtn.alpha = .4;
			$killBtn.areEventsEnabled = false;
			
			_sampler.play();
		}

		
		
		override public function stop():void {
			$killBtn.alpha = 1;
			$killBtn.areEventsEnabled = true;

			_sampler.stop();			
		}
		
		
		
		override public function pause():void {
			$killBtn.alpha = 1;
			$killBtn.areEventsEnabled = true;
			
			_sampler.pause();
		}

		
		override public function resume():void {
			$killBtn.alpha = .4;
			$killBtn.areEventsEnabled = false;
			
			_sampler.resume();
		}



		override public function seek(position:Number):void {
			_sampler.seek(position);
		}
		

		
		override public function get position():uint {
			return _sampler.position;
		}



		override public function get volume():Number {
			return _sampler.volume;
		}
		
		
		
		override public function set volume(value:Number):void {
			try {
				_sampler.volume = value;
			}
			catch(err:Error) {
				// sampler may be not initialized
			}
			finally {
				_volumeSlider.thumbPos = 1 - value;
			}
		}
		
		
		public function get isPlaying():Boolean {
			return _sampler.isPlaying;
		}
		
		
		
		public function get milliseconds():uint {
			return _sampler.milliseconds;
		}
		
		
		
		/**
		 * Kill button click event handler.
		 * @param event Event data
		 */
		private function _onKillClick(event:MouseEvent = null):void {
			Logger.debug(sprintf('Kill track (trackID=%u, trackTitle=%s)', $trackData.trackID, $trackData.trackTitle));

			if(_encodeWorkerTimer) {
				_encodeWorkerTimer.stop();
				_encodeWorkerTimer = null;
			}
			
			dispatchEvent(new TrackEvent(TrackEvent.KILL));
		}



		/**
		 * Sample download progress
		 */
		private function _onSamplerProgress(event:SamplerEvent):void {
			_waveform.progress = event.data.progress;
		}
		
		
		
		/**
		 * Sample download completed
		 */
		private function _onSamplerDownloaded(event:SamplerEvent):void {
			_waveform.progress = 1;
			dispatchEvent(new TrackEvent(TrackEvent.SAMPLE_DOWNLOADED, false, false, {track:this}));
		}
		
		
		
		/**
		 * Sample playback completed
		 */
		private function _onSamplerPlaybackComplete(event:SamplerEvent):void {
			dispatchEvent(event);
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
				_sampler.volume = v;
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
		
		
		
		/// UPLOAD STUFF
		/// 
		public function upload(fileReference:FileReference):void {
			var variables:URLVariables = new URLVariables();
			variables.track_id = $trackID;
			variables.id = App.connection.coreUserData.userID;

			var request:URLRequest = new URLRequest();
			request.url = App.connection.mediaPath + App.connection.configService.mediaUploadRequestURL + '&';
			request.data = variables;

			fileReference.addEventListener(ProgressEvent.PROGRESS, _onFileProgress, false, 0, true);
			fileReference.addEventListener(DataEvent.UPLOAD_COMPLETE_DATA, _onFileUploadComplete, false, 0, true);
			fileReference.addEventListener(IOErrorEvent.IO_ERROR, _onFileUploadFailed, false, 0, true);
			fileReference.addEventListener(SecurityErrorEvent.SECURITY_ERROR, _onFileUploadFailed, false, 0, true);

			fileReference.upload(request);			
		}

		
		
		private function _onFileProgress(event:ProgressEvent):void {
			var w:uint = _progressBar.width / (event.bytesTotal / event.bytesLoaded);
			_progressBar.progress = w / 2; // Half width for upload. The rest is for encoding.
		}
		
		private function _onFileUploadFailed(event:Event):void {
			_onKillClick();
	
			App.messageModal.show({title:'Upload track', description:'Error while uploading track.',
				buttons:MessageModal.BUTTONS_OK, icon:MessageModal.ICON_WARNING});

			dispatchEvent(new TrackEvent(TrackEvent.UPLOAD_FAILED, false, false, {track:this}));
		}
		
		private function _onFileUploadComplete(event:DataEvent):void {
			_progressBar.progress = _progressBar.width / 2;

			_encodeKey = XML(event.data).@key;

			_workerEncodeService = new WorkerEncodeService();
			_workerEncodeService.url = App.connection.mediaPath + App.connection.configService.workerEncodeRequestURL;
			_workerEncodeService.addEventListener(WorkerEvent.REQUEST_DONE, _onEncodeWorkerProgress, false, 0, true);
			_workerEncodeService.addEventListener(RemotingEvent.REQUEST_FAILED, _onTrackEncodeFailed, false, 0, true);
	
			Logger.info("Upload done, start polling");

			_encodeWorkerTimer = new Timer(Settings.WORKER_INTERVAL * 1000);
			_encodeWorkerTimer.addEventListener(TimerEvent.TIMER, _onEncodeWorkerBang, false, 0, true);

			_encodeWorkerTimer.start();
			_onEncodeWorkerBang();
			
			dispatchEvent(new TrackEvent(TrackEvent.UPLOAD_COMPLETED, false, false, {track:this}));
		}
		
		
		
		/// ENCODING STUFF
		///
		public function encode(recordName:String):void {
			_encodeWorkerTimer = new Timer(Settings.WORKER_INTERVAL * 1000);
			_encodeWorkerTimer.addEventListener(TimerEvent.TIMER, _onEncodeWorkerBang, false, 0, true);

			_trackEncodeService = new TrackEncodeService();
			_workerEncodeService = new WorkerEncodeService();

			_trackEncodeService.url = App.connection.mediaPath + App.connection.configService.mediaEncodeRequestURL;
			_workerEncodeService.url = App.connection.mediaPath + App.connection.configService.workerEncodeRequestURL;

			_trackEncodeService.addEventListener(TrackEncodeEvent.REQUEST_DONE, _onTrackEncodeRequestDone, false, 0, true);
			_workerEncodeService.addEventListener(WorkerEvent.REQUEST_DONE, _onEncodeWorkerProgress, false, 0, true);

			_trackEncodeService.addEventListener(RemotingEvent.REQUEST_FAILED, _onTrackEncodeFailed, false, 0, true);
			_workerEncodeService.addEventListener(RemotingEvent.REQUEST_FAILED, _onTrackEncodeFailed, false, 0, true);
			
			_trackEncodeService.request({filename:recordName, trackID:$trackID});
			
			_progressBar.visible = true;
		}


		
		/**
		 * Track encode failed event handler.
		 * @param event Event data
		 */
		private function _onTrackEncodeFailed(event:TrackEvent):void {
			_onKillClick(); /// XXX FIXME

			App.messageModal.show({title:'Save track', description:'Error while encoding track.',
				buttons:MessageModal.BUTTONS_OK, icon:MessageModal.ICON_WARNING});
		}



		/**
		 * Track encode request done event handler.
		 * Start banging the worker for completion.
		 * @param event Event data
		 */
		private function _onTrackEncodeRequestDone(event:TrackEncodeEvent):void {
			Logger.info("Encoding request done, start polling");
			_encodeKey = event.key;
			
			_encodeWorkerTimer.start();
			_onEncodeWorkerBang();
		}



		/**
		 * Encode worker bang event handler.
		 * Bangs encoder worker. But only if it is not connecting, preventing overloading.
		 * @param event Event data
		 */
		private function _onEncodeWorkerBang(event:Event = null):void {
			if(!_workerEncodeService.isConnecting) {
				_workerEncodeService.request({key:_encodeKey});
				_progressBar.progress += 5;
			}
		}



		/**
		 * Encode worker done event handler.
		 * Saving and encoding done, parse results.
		 * If everything is ok, add track to editor (after request).
		 * @param event Event data
		 */
		private function _onEncodeWorkerProgress(event:WorkerEvent):void {
			Logger.info("Encode worker progress: " + event.workerStatusData.status);

			switch(event.workerStatusData.status) {
				case WorkerStatusData.STATUS_ERROR:
					_onKillClick();					

					App.messageModal.show({title:'Encoding error', description:'Error while encoding your track.',
						buttons:MessageModal.BUTTONS_OK, icon:MessageModal.ICON_WARNING});
					break;
					
				case WorkerStatusData.STATUS_FINISHED:
					_encodeWorkerTimer.stop();
					_encodeWorkerTimer = null;
				
					// refresh track
					_trackFetchService = new TrackFetchService();
					
					_trackFetchService.url = App.connection.serverPath + App.connection.configService.trackFetchRequestURL;
					_trackFetchService.addEventListener(TrackFetchEvent.REQUEST_DONE, _onTrackFetchDone, false, 0, true);
					_trackFetchService.addEventListener(TrackFetchEvent.REQUEST_FAILED, _onTrackFetchFailed, false, 0, true);
					
					_trackFetchService.request({trackID:$trackData.trackID});
	
					break;
					
				default:
					// still running .. progress update should be done here.
			}
		}



		private function _onTrackFetchDone(event:TrackFetchEvent):void {
			Logger.info("Refetched track " + event.trackData.trackID);
			
			$trackData = event.trackData;
			this.load();
			
			_trackFetchService.removeEventListener(TrackFetchEvent.REQUEST_DONE, _onTrackFetchDone);
			_trackFetchService.removeEventListener(TrackFetchEvent.REQUEST_FAILED, _onTrackFetchFailed);
			
			dispatchEvent(new TrackEvent(TrackEvent.REFRESH, false, false, {track:this}));			
		}



		private function _onTrackFetchFailed(event:TrackFetchEvent):void {
			App.messageModal.show({title:"Unable to fetch track", description:"please try again"});
			_onKillClick();
			
			_trackFetchService.removeEventListener(TrackFetchEvent.REQUEST_DONE, _onTrackFetchDone);
			_trackFetchService.removeEventListener(TrackFetchEvent.REQUEST_FAILED, _onTrackFetchFailed);			
		}
	}
}
