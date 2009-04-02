package modals {
	import application.AppEvent;
	
	import config.Embeds;
	import config.Filters;
	import config.Formats;
	
	import controls.Button;
	
	import org.osflash.thunderbolt.Logger;
	import org.vancura.graphics.QBitmap;
	import org.vancura.graphics.QTextField;
	import org.vancura.util.addChildren;
	
	import flash.events.MouseEvent;	

	
	
	/**
	 * Message modal.
	 * 
	 * TODO: Write documentation
	 * 
	 * @author Vaclav Vancura (http://vaclav.vancura.org)
	 * @since Jul 01, 2008
	 */
	public class MessageModal extends ModalCommon {

		
		
		public static const BUTTONS_NONE:String = 'buttonsNone';
		public static const BUTTONS_OK:String = 'buttonsOK';
		public static const BUTTONS_RELOAD:String = 'buttonsReload';
		public static const ICON_NONE:String = 'iconNone';
		public static const ICON_ERROR:String = 'iconError';
		public static const ICON_WARNING:String = 'iconWarning';
		private static const _ICON_WIDTH:uint = 250;
		private static const _PANEL_WIDTH:uint = 520;
		private var _iconErrorBM:QBitmap;
		private var _iconWarningBM:QBitmap;
		private var _titleTF:QTextField;
		private var _descriptionTF:QTextField;
		private var _okBtn:Button;
		private var _reloadBtn:Button;

		
		
		/**
		 * Constructor.
		 * @param o QSprite config Object
		 */
		public function MessageModal(o:Object = null) {
			super(o);
			
			// add icons
			_iconErrorBM = new QBitmap({embed:new Embeds.modalIconErrorBD()});
			_iconWarningBM = new QBitmap({embed:new Embeds.modalIconWarningBD()});
			
			// add buttons
			_okBtn = new Button({width:100, text:'OK', icon:new Embeds.glyphOKBD});			_reloadBtn = new Button({width:150, text:'Reload page', icon:new Embeds.glyphOKBD});
			
			// add text
			_titleTF = new QTextField({x:50, width:_PANEL_WIDTH - 100, defaultTextFormat:Formats.modalTitle, filters:Filters.modalTitle, sharpness:50});
			_descriptionTF = new QTextField({x:50, width:_PANEL_WIDTH - 100, defaultTextFormat:Formats.modalDescription});
			
			// add to display list
			addChildren($contentSpr, _titleTF, _descriptionTF, _okBtn, _reloadBtn, _iconErrorBM, _iconWarningBM);
			
			// add event listeners
			_okBtn.addEventListener(MouseEvent.CLICK, _onBtnOKClick, false, 0, true);			_reloadBtn.addEventListener(MouseEvent.CLICK, _onBtnReloadClick, false, 0, true);
		}

		
		
		/**
		 * Show a message modal.
		 * Config Object could contain:
		 * config.title - Title text
		 * config.description - Description text
		 * config.buttons - Buttons config (e.g. BUTTONS_NONE, BUTTONS_OK)
		 * config.icon - Icon config (e.g. ICON_NONE, ICON_ERROR, ICON_WARNING)
		 * @param config Config object
		 */
		override public function show(c:Object = null):void {
			if(c == null) c = new Object();
			
			if(c.title == undefined) c.title = 'Message';
			if(c.description == undefined) c.description = '';
			if(c.buttons == undefined) c.buttons = BUTTONS_OK;
			if(c.icon == undefined) c.icon = ICON_NONE;
			
			// output to trace panel
			switch(c.icon) {
				case ICON_ERROR: 
					Logger.error(c.title, c.description); 
					break;
				case ICON_WARNING:
					Logger.warn(c.title, c.description);
					break;
				default:
					Logger.info(c.title, c.description);
					break;
			}
			
			// hide all old components
			// will be shown on the end of this method
			_okBtn.visible = false;
			_reloadBtn.visible = false;
			_iconErrorBM.visible = false;
			_iconWarningBM.visible = false;
			
			// set visual properties and assign text
			_titleTF.text = c.title;
			_descriptionTF.text = c.description;
			
			// set sizes
			var h:Number = 64;
			if(c.icon != ICON_NONE) h = 120;
			_titleTF.y = h; 
			h += _titleTF.textHeight; 
			_descriptionTF.y = h + 10; 
			h += _descriptionTF.textHeight + 10;
			
			// set background size
			width = _PANEL_WIDTH;
			height = h + 123;
			
			// set icon position
			_iconErrorBM.x = _iconWarningBM.x = Math.round((_PANEL_WIDTH - _ICON_WIDTH) / 2);
			
			// set component visibility
			if(c.buttons == BUTTONS_OK) {
				_okBtn.visible = true;
				_okBtn.x = Math.round((_PANEL_WIDTH - _okBtn.width) / 2);
				_okBtn.y = h + 20;
				h += _okBtn.height; 
			}
			
			if(c.buttons == BUTTONS_RELOAD) {
				_reloadBtn.visible = true;
				_reloadBtn.x = Math.round((_PANEL_WIDTH - _reloadBtn.width) / 2);
				_reloadBtn.y = h + 20;
				h += _reloadBtn.height;
			}
			
			if(c.icon == ICON_ERROR) {
				_iconErrorBM.visible = true;
			}
			
			if(c.icon == ICON_WARNING) {
				_iconWarningBM.visible = true;
			}
			
			super.show(c);
		}

		
		
		/**
		 * OK Button clicked.
		 * @param event Event data
		 */
		private function _onBtnOKClick(event:MouseEvent):void {
			hide();
		}
		
		
		
		private function _onBtnReloadClick(event:MouseEvent):void {
			dispatchEvent(new AppEvent(AppEvent.RELOAD_PAGE, true));
		}
	}
}