package editor_panel.containers
{
	import caurina.transitions.Tweener;
	
	import config.Embeds;
	import config.Settings;
	
	import controls.Button;
	import controls.MorphSprite;
	import controls.Toolbar;
	
	import flash.events.MouseEvent;
	
	import org.vancura.graphics.Drawing;
	import org.vancura.graphics.QBitmap;
	import org.vancura.graphics.QSprite;
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
			_openButton = new Button({x:5, y:10, skin:new Embeds.buttonKillTrack()}, Button.TYPE_NOSCALE_BUTTON);
			_openButton.addEventListener(MouseEvent.CLICK, _onOpenButtonClick, false, 0, true);

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
			addChildren(_tabSpr, _tabBackground, _openButton);
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
		
		
		
		public function open():void {
			if(_isOpened) {
				throw new Error('Panel already open');
			}
			
			_isOpened = true;
			_recountHeight();
			
			Tweener.addTween(_tabSpr, _fadeOut);
			
			Tweener.addTween(_toolbarSpr, _fadeIn);			
			Tweener.addTween(_closeButton, _fadeIn);			
		}
		
		public function close():void {
			if(!_isOpened) {
				throw new Error('Panel is not open');
			}
			
			_isOpened = false;

			Tweener.addTween(_toolbarSpr, _fadeOut);			
			Tweener.addTween(_closeButton, _fadeOut);

			Tweener.addTween(_tabSpr, _fadeIn);

			_recountHeight();
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