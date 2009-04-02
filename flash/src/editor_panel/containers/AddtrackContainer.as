package editor_panel.containers
{
	import caurina.transitions.Tweener;
	
	import config.Embeds;
	import config.Settings;
	
	import controls.Button;
	import controls.MorphSprite;
	import controls.Toolbar;
	
	import org.vancura.graphics.Drawing;
	import org.vancura.graphics.QBitmap;
	import org.vancura.graphics.QSprite;
	import org.vancura.util.addChildren;

	public class AddtrackContainer extends MorphSprite
	{		
		private var _isOpened:Boolean;
		private var _height:Number;

		private var _tabBackground:QBitmap;

		private var _toolbar:Toolbar;
		private var _toolbarBackground:QSprite;

		private var _recordButton:Button;
		private var _searchButton:Button;
		private var _uploadButton:Button;
		
		private var _fadeOut:Object = {alpha:0, time:Settings.STAGE_HEIGHT_CHANGE_TIME, visible:false};
		private var _fadeIn:Object = {alpha:1, time:Settings.STAGE_HEIGHT_CHANGE_TIME, visible:true};

		public function AddtrackContainer(c:Object=null)
		{
			super(c);

			// initially closed
			_isOpened = false;
			
			// add graphics
			_tabBackground = new QBitmap({embed:new Embeds.backgroundTab()});

			_toolbarBackground = new MorphSprite();
			_toolbarBackground.visible = false;
			Drawing.drawRect(_toolbarBackground, 0, 0, Settings.TRACKCONTROLS_WIDTH, Settings.TRACK_HEIGHT, 0xE6E6E6, 1.0);

			_recordButton = new Button({x:0, y:0, skin:new Embeds.buttonRecordSmall(), icon:new Embeds.glyphRecordSmall()});
			_searchButton = new Button({x:50, y:10, skin:new Embeds.buttonSearchSmall(), icon:new Embeds.glyphSearchSmall()});
			_uploadButton = new Button({x:100, y:20, skin:new Embeds.buttonUploadSmall(), icon:new Embeds.glyphUploadSmall()});
			
			_toolbar = new Toolbar();
			_toolbar.addChildRight(_recordButton);
			_toolbar.addChildRight(_searchButton);
			_toolbar.addChildRight(_uploadButton);

			_toolbar.visible = false;
			// set visual properties
			$morphTime = Settings.STAGE_HEIGHT_CHANGE_TIME;
			$morphTransition = 'easeInOutQuad';

			// add to display list
			addChildren(this, _tabBackground, _toolbar, _toolbarBackground);
			
			_recountHeight();
		}
		
		public function open():void {
			if(_isOpened) {
				throw new Error('Panel already open');
			}
			
			_isOpened = true;
			_recountHeight();
			
			//_tabBackground.morph(_fadeOut);
			//_toolbarBackground.morph(_fadeIn);
			Tweener.addTween(_tabBackground, _fadeOut);
			Tweener.addTween(_toolbarBackground, _fadeIn);			
		}
		
		public function close():void {
			if(!_isOpened) {
				throw new Error('Panel is not open');
			}
			
			_isOpened = false;
			_recountHeight();
			
			//_toolbarBackground.morph(_fadeOut);
			//_tabBackground.morph(_fadeIn);
			Tweener.addTween(_toolbarBackground, _fadeOut);
			Tweener.addTween(_tabBackground, _fadeIn);
		}
		
		private function _recountHeight():void {
			_height = _isOpened ? _toolbarBackground.height : _tabBackground.height;

			dispatchEvent(new ContainerEvent(ContainerEvent.CONTENT_HEIGHT_CHANGE, true));
		}
		
		override public function get height():Number {
			return _height;
		}
		
	}
}