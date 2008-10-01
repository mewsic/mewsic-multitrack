package modals {
	import application.AppEvent;
	
	import config.Filters;
	import config.Formats;
	
	import org.osflash.thunderbolt.Logger;
	import org.vancura.graphics.QTextField;
	import org.vancura.util.addChildren;	

	
	
	/**
	 * Close modal.
	 * 
	 * TODO: Write documentation
	 * 
	 * @author Vaclav Vancura (http://vaclav.vancura.org)
	 * @since Jul 25, 2008
	 */
	public class CloseModal extends ModalCommon {

		
		
		private static const _PANEL_WIDTH:Number = 380;
		private static const _PANEL_HEIGHT:Number = 40;
		private static const _PANEL_Y:Number = 14;
		private var _titleTF:QTextField;
		private var _descriptionTF:QTextField;

		
		
		/**
		 * Constructor.
		 * @param o QSprite config Object
		 */
		public function CloseModal(o:Object = null) {
			super(o);
			
			// add graphics
			_titleTF = new QTextField({text:'Closing song', x:50, y:64, width:_PANEL_WIDTH - 100, defaultTextFormat:Formats.modalTitle, filters:Filters.modalTitle, sharpness:50});
			_descriptionTF = new QTextField({text:'Please wait...', x:50, y:100, width:_PANEL_WIDTH - 100, defaultTextFormat:Formats.modalDescription});
			
			// add to display list
			addChildren($contentSpr, _titleTF, _descriptionTF);
		}

		
		
		/**
		 * Show save song modal.
		 * @param c Config object
		 */
		override public function show(c:Object = null):void {
			Logger.info('Showing close modal.');
			
			super.show(c);
			
			// set default sizes
			width = _PANEL_WIDTH;
			height = _PANEL_HEIGHT;
			y = _PANEL_Y;
			
			// dispatch
			dispatchEvent(new AppEvent(AppEvent.HIDE_DROPBOX, true));
			dispatchEvent(new AppEvent(AppEvent.RELOAD_PAGE, true));
		}

		
		
		override public function hide():void {
			super.hide();
		}
	}
}