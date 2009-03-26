package editor_panel.tracks {
	import application.App;
	
	import caurina.transitions.Tweener;
	
	import config.Embeds;
	import config.Filters;
	import config.Formats;
	import config.Settings;
	
	import controls.Thumbnail;
	
	import de.popforge.utils.sprintf;
	
	import editor_panel.sampler.Sampler;
	import editor_panel.sampler.SamplerEvent;
	import editor_panel.waveform.Waveform;
	
	import flash.display.Sprite;
	
	import org.osflash.thunderbolt.Logger;
	import org.vancura.graphics.QBitmap;
	import org.vancura.graphics.QSprite;
	import org.vancura.graphics.QTextField;
	import org.vancura.util.addChildren;
	import org.vancura.util.removeChildren;
	
	import remoting.data.TrackData;
	import remoting.dynamic_services.UserService;
	import remoting.events.UserEvent;	

	
	
	/**
	 * Common track functions.
	 * 
	 * TODO: Write documentation
	 * 
	 * @author Vaclav Vancura (http://vaclav.vancura.org)
	 * @since Jun 20, 2008
	 */
	public class TrackCommon extends Sprite {

		
		
		public static const RECORD_TRACK:String = 'recordTrack';
		public static const STANDARD_TRACK:String = 'standardTrack';

		protected var $sampler:Sampler;
		protected var $waveform:Waveform;

		// protected var $backBM:QBitmap; no background
		protected var $titleTF:QTextField;
		protected var $specsTagsTF:QTextField;

		protected var $avatarThumb:Thumbnail;
		protected var $instrumentThumb:Thumbnail;
		protected var $selectInstrument:QSprite;
		
		protected var $trackData:TrackData;
		protected var $trackType:String;
		
		protected var $isMuted:Boolean;
		protected var $isSolo:Boolean;
		
		protected var $trackID:uint;
		
		private var _isEnabled:Boolean = true;
		private var _userService:UserService;

		
		
		/**
		 * Constructor.
		 * @param t Track type (STANDARD_TRACK or RECORD_TRACK)
		 * @param trackID Track ID
		 */
		public function TrackCommon(trackID:uint, t:String) {
			super();
			
			$trackID = trackID;

			// check for valid type
			if(t != STANDARD_TRACK && t != RECORD_TRACK) throw new TypeError('Track type has to be STANDARD_TRACK or RECORD_TRACK');
			else $trackType = t;
			
			// add components
			//$backBM = new QBitmap({embed:($trackType == STANDARD_TRACK) ? new Embeds.standardContainerBackBD() : new Embeds.recordContainerBackBD()});
			$titleTF = new QTextField({alpha:0, x:154, width:116, height:52,
				defaultTextFormat:($trackType == STANDARD_TRACK) ? Formats.standardContainerTitle : Formats.recordContainerTitle,
				filters:($trackType == STANDARD_TRACK) ? Filters.standardContainerContentTitle : Filters.recordContainerContentTitle,
				sharpness:-25, thickness:-50});
	
			$specsTagsTF = new QTextField({alpha:0, x:154, width:116, height:52,
				defaultTextFormat:($trackType == STANDARD_TRACK) ? Formats.standardContainerSpecsContent : Formats.recordContainerSpecsContent,
				filters:($trackType == STANDARD_TRACK) ? Filters.standardContainerContentTitle : Filters.recordContainerContentTitle,
				sharpness:-25, thickness:-50});
			
			$avatarThumb = new Thumbnail({x:32, y:6});
			$instrumentThumb = new Thumbnail({x:67, y:6});
			
			$selectInstrument = new QSprite({x:70, y:15});
			var selectText:QTextField = new QTextField({alpha:1, width:80, height:40, text:"Select",
				defaultTextFormat:Formats.standardContainerTitle, filters:Filters.recordContainerContentTitle,
				sharpness:-25, thickness:-50});
	
			var selectIcon:QBitmap = new QBitmap({embed: new Embeds.iconSelectInstrument()});
			
			addChildren($selectInstrument, selectText, selectIcon);
			$selectInstrument.visible = false;

			// add to display list
			addChildren(this, /*$backBM,*/ $avatarThumb, $instrumentThumb, $selectInstrument, $titleTF, $specsTagsTF);
			
			// set user service
			_userService = new UserService();
			_userService.url = App.connection.serverPath + App.connection.configService.userRequestURL;
			_userService.addEventListener(UserEvent.REQUEST_DONE, _onUserDone, false, 0, true);
		}

		
		
		/**
		 * Destructor.
		 */
		public function destroy():void {
			// remove event listeners
			_userService.removeEventListener(UserEvent.REQUEST_DONE, _onUserDone);
			
			// destroy components
			try {
				$avatarThumb.destroy();
				$instrumentThumb.destroy();
				removeChildren(this, /*$backBM,*/ $avatarThumb, $instrumentThumb, $titleTF, $specsTagsTF);
			}
			catch(err3:Error) {
				Logger.warn(sprintf('Error removing graphics for %s:\n%s', toString(), err3.message));
			}
			
			if($sampler) {
				// remove event listeners
				$sampler.removeEventListener(SamplerEvent.SAMPLE_PROGRESS, _onSamplerProgress);
				$sampler.removeEventListener(SamplerEvent.PLAYBACK_COMPLETE, _onSamplerPlaybackComplete);
				
				// destroy
				try {
					$sampler.destroy();
				}
				catch(err1:Error) {
					Logger.warn(sprintf('Error removing sampler for %s:\n%s', toString(), err1.message));
				}
			}
			
			if($waveform) {
				// remove from display list
				removeChild($waveform);
				
				// destroy
				try {
					$waveform.destroy();
				}
				catch(err2:Error) {
					Logger.warn(sprintf('Error removing waveform for %s:\n%s', toString(), err2.message));
				}
			}
			
			_isEnabled = false;
		}
		
		
		
		override public function toString():String {
			return sprintf('Track (title=%s)', $titleTF.text);
		}
		
		
		
		public function refresh():void {
			if($trackData != null) {
				// fill texts
				$titleTF.text = $trackData.trackTitle;
				$specsTagsTF.text = $trackData.trackTags;
				
				// fade in texts
				var proto:Object = {time:Settings.FADEIN_TIME, alpha:1, transition:'easeOutSine'};
				Tweener.addTween($titleTF, proto);
				Tweener.addTween($specsTagsTF, proto);
			}
			
			// refresh texts
			var bh:Number = $titleTF.textHeight + 2;
			var by:Number = Math.round((52 - bh) / 2) - 6;
			$titleTF.y = by;
			$specsTagsTF.y = $titleTF.y + bh + 2;
			
			// refresh volume & balance
			if($trackType == STANDARD_TRACK) {
				$sampler.volume = $trackData.trackVolume;
				$sampler.balance = $trackData.trackBalance;
			}
		}



		public function stretchWaveform(_milliseconds:uint):void {
			$waveform.stretch(_milliseconds);
		}
		
		
		public function load():void {
			if($trackData == null) throw new Error('Track data is not set.');
			
			try { 
				_userService.request({userNickname:$trackData.trackUserNickname});
			}
			catch(err:Error) { 
				Logger.error(sprintf('Could not get user data:\n%s', err.message)); 
			}
			
			// get instrument description and icon
			if($trackData.trackInstrumentID) {
				var instrumentIconURL:String = App.connection.instrumentsService.byID($trackData.trackInstrumentID).instrumentIconURL;
				$instrumentThumb.load(App.connection.serverPath + instrumentIconURL);
				$instrumentThumb.visible = true;
				$selectInstrument.visible = false;				
			} else {
				$instrumentThumb.visible = false;
				$selectInstrument.visible = true;
			}
		}

		
		
		/**
		 * Play.
		 */
		public function play():void {
			$sampler.play();
		}

		
		
		/**
		 * Stop.
		 */
		public function stop():void {
			$sampler.stop();
		}

		
		
		/**
		 * Pause.
		 */
		public function pause():void {
			$sampler.pause();
		}

		
		
		/**
		 * Resume.
		 */
		public function resume():void {
			$sampler.resume();
		}

		
		
		/**
		 * Seek.
		 */
		public function seek(position:Number):void {
			$sampler.seek(position);
		}

		
		
		/**
		 * Scroll waveform.
		 * @param px Position (in px)
		 */
		public function scrollTo(px:int):void {
			$waveform.scrollTo(px);
		}

		
		
		public function get isSolo():Boolean {
			return $isSolo;
		}

		
		
		public function get isMuted():Boolean {
			return $isMuted;
		}

		
		
		public function set isSolo(value:Boolean):void {
			$isSolo = value;
			$isMuted = false;
			$sampler.isMuted = isMuted;
			dispatchEvent(new TrackEvent(TrackEvent.REFRESH));
		}

		
		
		public function set isMuted(value:Boolean):void {
			$isMuted = value;
			$isSolo = false;
			$sampler.isMuted = isMuted;
			dispatchEvent(new TrackEvent(TrackEvent.REFRESH));
		}
		
		
		
		public function set trackData(td:TrackData):void {
			$trackData = td;
			refresh();
		}
		
		
		
		public function get trackData():TrackData {
			return $trackData;
		}
		
		
		
		public function get trackID():uint {
			return $trackID;
		}

		
		
		/**
		 * Get track enabled flag.
		 * @return Track enabled flag.
		 */
		public function get isEnabled():Boolean {
			return _isEnabled;
		}

		
		
		public function get volume():Number {
			return $sampler.volume;
		}
		
		
		
		public function get position():uint {
			return $sampler.position;
		}

		
		
		protected function $addHandlers():void {
			// create components
			$sampler = new Sampler($trackType);
			$waveform = new Waveform($trackType, {x:520});
			
			// add to display list
			addChild($waveform);
			
			// add event listeners
			$sampler.addEventListener(SamplerEvent.SAMPLE_PROGRESS, _onSamplerProgress, false, 0, true);
			$sampler.addEventListener(SamplerEvent.SAMPLE_DOWNLOADED, _onSamplerDownloaded, false, 0, true);
			$sampler.addEventListener(SamplerEvent.PLAYBACK_COMPLETE, _onSamplerPlaybackComplete, false, 0, true);
		}

		
		
		/**
		 * User done event handler.
		 * Invoked when user info for this track is loaded.
		 * Load his/her avatar image.
		 * @param event Event data
		 */
		private function _onUserDone(event:UserEvent):void {
			// we get this event after all user calls, so filter it for needed user
			if(event.userData.userNickname == $trackData.trackUserNickname) {
				$avatarThumb.load(App.connection.serverPath + event.userData.userAvatarURL);
			}
		}
		
		
		
		private function _onSamplerProgress(event:SamplerEvent):void {
			$waveform.progress = event.data.progress;
		}
		
		private function _onSamplerDownloaded(event:SamplerEvent):void {
			$waveform.progress = 1;
		}
		
		
		
		private function _onSamplerPlaybackComplete(event:SamplerEvent):void {
			dispatchEvent(event);
		}
	}
}