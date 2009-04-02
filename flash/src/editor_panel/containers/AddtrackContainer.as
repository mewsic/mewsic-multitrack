package editor_panel.containers
{
	import application.App;
	
	import caurina.transitions.Tweener;
	
	import config.Embeds;
	import config.Filters;
	import config.Formats;
	import config.Settings;
	
	import controls.Button;
	import controls.MorphSprite;
	import controls.Toolbar;
	
	import flash.events.MouseEvent;
	
	import org.vancura.graphics.Drawing;
	import org.vancura.graphics.QBitmap;
	import org.vancura.graphics.QSprite;
	import org.vancura.graphics.QTextField;
	import org.vancura.util.addChildren;

	public class AddtrackContainer extends MorphSprite
	{		
		// business logic
		private var _isOpened:Boolean;
		private var _height:Number;

		// tab element
		private var _tabSpr:QSprite;
		private var _tabBackground:QBitmap;
		private var _openButton:Button;
		private var _addInstrumentSpr:QSprite;
		private var _addInstrumentTF:QTextField;
		
		// closebutton
		private var _closeButton:Button;

		// toolbar element
		private var _toolbarSpr:QSprite;
		private var _toolbarBackground:QSprite;
		private var _toolbar:Toolbar;

		// toolbar buttons
		private var _recordButton:Button;
		private var _searchButton:Button;
		private var _uploadButton:Button;

		// fadein/out transitions
		private var _fadeOut:Object = {alpha:0, time:Settings.STAGE_HEIGHT_CHANGE_TIME, visible:false};
		private var _fadeIn:Object = {alpha:1, time:Settings.STAGE_HEIGHT_CHANGE_TIME, visible:true};

		public function AddtrackContainer(c:Object=null)
		{
			super(c);

			// initially closed
			_isOpened = false;
			
			// add tab
			_tabSpr = new QSprite(); // visible

			_tabBackground = new QBitmap({embed:new Embeds.backgroundTab()});
			_openButton = new Button({x:10, y:10, skin:new Embeds.buttonKillTrack()}, Button.TYPE_NOSCALE_BUTTON);
			_openButton.addEventListener(MouseEvent.CLICK, _onOpenButtonClick, false, 0, true);

			_addInstrumentTF = new QTextField({x:26, y:7, text:"Add new instrument", width:120,
				defaultTextFormat:Formats.controllerText, filters:Filters.controllerText});

			// Draw clickable sprite
			_addInstrumentSpr = new QSprite({x:22, y:9, alpha:0, mouseEnabled:true, buttonMode:true, tabEnabled:false});
			_addInstrumentSpr.addEventListener(MouseEvent.CLICK, _onOpenButtonClick, false, 0, true);
			Drawing.drawRect(_addInstrumentSpr, 0, 0, _addInstrumentTF.width + 4, _addInstrumentTF.textHeight);

			// add closebutton
			_closeButton = new Button({x:Settings.TRACKCONTROLS_WIDTH + Settings.KILL_BUTTON_X, y:Settings.KILL_BUTTON_Y,
				skin:new Embeds.buttonKillTrack()}, Button.TYPE_NOSCALE_BUTTON);
			_closeButton.visible = false; // invisible

			_closeButton.addEventListener(MouseEvent.CLICK, _onCloseButtonClick, false, 0, true);

			// add toolbar
			_toolbarSpr = new QSprite();
			_toolbarSpr.visible = false; // invisible

			_toolbarBackground = new MorphSprite();
			Drawing.drawRect(_toolbarBackground, 0, 0, Settings.TRACKCONTROLS_WIDTH - 1, Settings.TRACK_HEIGHT - 1, 0xE6E6E6, 1.0);

			_recordButton = new Button({x: 0, width:60, height:38, skin:new Embeds.buttonRecordSmall(), icon:new Embeds.glyphRecordSmall()});
			_searchButton = new Button({x:10, width:60, height:38, skin:new Embeds.buttonSearchSmall(), icon:new Embeds.glyphSearchSmall()});
			_uploadButton = new Button({x:10, width:60, height:38, skin:new Embeds.buttonUploadSmall(), icon:new Embeds.glyphUploadSmall()});
			
			_recordButton.addEventListener(MouseEvent.CLICK, _onRecordButtonClick, false, 0, true);
			_searchButton.addEventListener(MouseEvent.CLICK, _onSearchButtonClick, false, 0, true);
			_uploadButton.addEventListener(MouseEvent.CLICK, _onUploadButtonClick, false, 0, true);
			
			_toolbar = new Toolbar({x:15, y:5, childSpacing:13});
			_toolbar.addChildRight(_recordButton);
			_toolbar.addChildRight(_searchButton);
			_toolbar.addChildRight(_uploadButton);

			// set morph sprite settings
			$morphTime = Settings.STAGE_HEIGHT_CHANGE_TIME;
			$morphTransition = 'easeInOutQuad';

			$isChangeWidthEnabled = false;
			$isChangeHeightEnabled = false;
			$isMorphWidthEnabled = false;
			$isMorphHeightEnabled = false;

			// add to display list
			addChildren(_tabSpr, _tabBackground, _openButton, _addInstrumentTF, _addInstrumentSpr);
			addChildren(_toolbarSpr, _toolbarBackground, _toolbar);
			addChildren(this, _tabSpr, _closeButton, _toolbarSpr);
			
			_recountHeight();
		}
		
		private function _onOpenButtonClick(event:MouseEvent):void {
			open();
		}

		private function _onCloseButtonClick(event:MouseEvent):void {
			close();
		}
		
		
		
		private function _onRecordButtonClick(event:MouseEvent):void {
			App.editor.clickRecord();
			close();
		}
		
		private function _onSearchButtonClick(event:MouseEvent):void {
			App.editor.clickSearch();
			close();
		}
		
		private function _onUploadButtonClick(event:MouseEvent):void {
			App.editor.clickUpload();
			close();
		}
		
		public function open():void {
			if(_isOpened)
				return;

			_isOpened = true;
			_recountHeight();
			
			Tweener.addTween(_tabSpr, _fadeOut);
			
			Tweener.addTween(_toolbarSpr, _fadeIn);			
			Tweener.addTween(_closeButton, _fadeIn);			
		}
		
		public function close():void {
			if(!_isOpened)
				return;
			
			_isOpened = false;

			Tweener.addTween(_toolbarSpr, _fadeOut);			
			Tweener.addTween(_closeButton, _fadeOut);

			Tweener.addTween(_tabSpr, _fadeIn);

			_recountHeight();
		}


		/// XXX NOT DRY, FUNCTION CODE REPEATED IN Editor.as
		/// AND INLINE CODE REPEATED EVERYWHERE. FIXME FIXME
		/// TODO
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



		public function disableRecord():void {
			_disableButton(_recordButton);
		}
		public function enableRecord():void {			
			_enableButton(_recordButton);
		}
		public function disableSearch():void {
			_disableButton(_searchButton);			
		}
		public function enableSearch():void {			
			_enableButton(_searchButton);
		}
		public function disableUpload():void {
			_disableButton(_uploadButton);
		}
		public function enableUpload():void {			
			_enableButton(_uploadButton);
		}

		private function _recountHeight():void {
			_height = _isOpened ? _toolbarBackground.height : _tabBackground.height + 5;

			dispatchEvent(new ContainerEvent(ContainerEvent.CONTENT_HEIGHT_CHANGE, true));
		}
		
		override public function get height():Number {
			return _height;
		}
		
	}
}