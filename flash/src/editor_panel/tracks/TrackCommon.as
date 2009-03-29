package editor_panel.tracks {
	import application.App;
	
	import caurina.transitions.Tweener;
	
	import config.Embeds;
	import config.Filters;
	import config.Formats;
	import config.Settings;
	
	import controls.Button;
	import controls.Thumbnail;
	
	import de.popforge.utils.sprintf;
	
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

		// protected var $backBM:QBitmap; no background
		protected var $titleTF:QTextField;
		protected var $specsTagsTF:QTextField;

		protected var $avatarThumb:Thumbnail;
		protected var $instrumentThumb:Thumbnail;
		private var _changeInstrumentButton:Button;

		private var _selectInstrument:QSprite;
		private var _selectInstrumentTF:QTextField;
		private var _selectInstrumentButton:Button; 
		
		protected var $killBtn:Button;
		protected var $separator:QBitmap;
		
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
		public function TrackCommon(trackID:uint, c:Object = null) {
			super();
			
			$trackID = trackID;

			// add components
			$titleTF = new QTextField({alpha:0, x:154, width:116, height:52,
				defaultTextFormat:Formats.standardContainerTitle,
				filters:Filters.standardContainerContentTitle,
				sharpness:-25, thickness:-50});
	
			$specsTagsTF = new QTextField({alpha:0, x:154, width:116, height:52,
				defaultTextFormat:Formats.standardContainerSpecsContent,
				filters:Filters.standardContainerContentTitle,
				sharpness:-25, thickness:-50});
			
			$avatarThumb = new Thumbnail({x:32, y:3, showFrame:true});

			$instrumentThumb = new Thumbnail({x:90, y:3});
			_changeInstrumentButton = new Button({x:130, y:42, skin:new Embeds.iconSelectInstrument()}, Button.TYPE_NOSCALE_BUTTON);
			_changeInstrumentButton.visible = false;

			
			_selectInstrument = new QSprite({x:97, y:20});
			_selectInstrument.visible = false;

			_selectInstrumentTF = new QTextField({alpha:1, width:80, height:40, text:"Select",
				defaultTextFormat:Formats.standardContainerTitle, filters:Filters.recordContainerContentTitle,
				sharpness:-25, thickness:-50});
	
			_selectInstrumentButton = new Button({x:10, y:20, skin:new Embeds.iconSelectInstrument()}, Button.TYPE_NOSCALE_BUTTON); // XXX TEMPORARY
			

			$killBtn = new Button({x:Settings.WAVEFORM_WIDTH - 18, y:5, skin:c.killBtnSkin}, Button.TYPE_NOSCALE_BUTTON);

			$separator = new QBitmap({x:0, y:Settings.TRACK_HEIGHT - 2, embed:new Embeds.separatorTrack()});
			

			// add to display list
			addChildren(_selectInstrument, _selectInstrumentTF, _selectInstrumentButton);
			addChildren(this, $separator, $avatarThumb, $instrumentThumb, _changeInstrumentButton, _selectInstrument, $titleTF, $specsTagsTF);
			
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
				$killBtn.destroy();
				
				// the killBtn is removed from display list  in derived classes,
				// because it has to be a child of the waveform/progressbar object,
				// more refactoring soon.
				removeChildren(this, $avatarThumb, $instrumentThumb, _changeInstrumentButton, _selectInstrument, $titleTF, $specsTagsTF);
				removeChildren(_selectInstrument, _selectInstrumentTF, _selectInstrumentButton);				
			}
			catch(err3:Error) {
				Logger.warn(sprintf('Error removing graphics for %s:\n%s', toString(), err3.message));
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
		}
		
		
		public function rescale(x:uint):void {
		}
		
		
		public function load():void {
			if($trackData == null)
				throw new Error('Track data is not set.');
			
			_userService.request({userNickname:$trackData.trackUserNickname});
			
			// get instrument description and icon
			if($trackData.trackInstrumentID) {
				var instrumentIconURL:String = App.connection.instrumentsService.byID($trackData.trackInstrumentID).instrumentIconURL;
				$instrumentThumb.load(App.connection.serverPath + instrumentIconURL);
				$instrumentThumb.visible = true;
				_changeInstrumentButton.visible = true;
				_selectInstrument.visible = false;			
			} else {
				$instrumentThumb.visible = false;
				_changeInstrumentButton.visible = false;
				_selectInstrument.visible = true;
			}
		}

		
		
		/**
		 * Play.
		 */
		public function play():void {
			trace("Track play()")
		}

		
		
		/**
		 * Stop.
		 */
		public function stop():void {
			trace("Track stop()");
		}

		
		
		/**
		 * Pause.
		 */
		public function pause():void {
			trace("Track pause()");
		}

		
		
		/**
		 * Resume.
		 */
		public function resume():void {
			trace("Track resume()");
		}

		
		
		/**
		 * Seek.
		 */
		public function seek(position:Number):void {
			trace("Track seek("+position+")");
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
		
		
		public function get volume():Number {
			return 0;
		}
		
		
		
		public function set volume(v:Number):void {
		}
		
		
		
		public function get position():uint {
			return 0;
		}

		
		
		public function set position(v:uint):void {
		}
		
		
		
		
	}
}