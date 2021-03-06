package modals {
	import application.AppEvent;
	
	import config.Embeds;
	import config.Filters;
	import config.Formats;
	
	import controls.Button;
	
	import org.osflash.thunderbolt.Logger;
	import org.vancura.graphics.QTextField;
	import org.vancura.util.addChildren;
	
	import flash.events.MouseEvent;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;	

	
	
	/**
	 * Download track modal.
	 * 
	 * TODO: Write documentation
	 * 
	 * @author Vaclav Vancura (http://vaclav.vancura.org)
	 * @since Aug 06, 2008
	 */
	public class DownloadTrackModal extends ModalCommon {

		
		
		private static const _PANEL_WIDTH:Number = 380;
		private static const _PANEL_HEIGHT:Number = 348;
		private static const _PANEL_Y:Number = -55;
		private var _titleTF:QTextField;
		private var _descriptionTF:QTextField;
		private var _okBtn:Button;
		private var _downloadButton:Button;
		private var _downloadURL:String;

		
		
		/**
		 * Constructor.
		 * @param o QSprite config Object
		 */
		public function DownloadTrackModal(o:Object = null) {
			super(o);
			
			// add graphics
			_titleTF = new QTextField({text:'Download track', x:50, y:64, width:_PANEL_WIDTH - 100, defaultTextFormat:Formats.modalTitle, filters:Filters.modalTitle, sharpness:50});
			_descriptionTF = new QTextField({text:'Download track by clicking the icon below:', x:50, y:100, width:_PANEL_WIDTH - 100, defaultTextFormat:Formats.modalDescription});
			
			// add buttons
			_downloadButton = new Button({x:Math.round((_PANEL_WIDTH - 100) / 2 ), y:130, width:100, height:100, skin:new Embeds.buttonRedBD(), icon:new Embeds.modalIconAmpBD(), textOutOffsY:-32, textOverOffsY:-32, textPressOffsY:-31});
			_okBtn = new Button({x:Math.round((_PANEL_WIDTH - 100) / 2), y:245, width:100, text:'OK', icon:new Embeds.glyphOKBD});
			
			// add to display list
			addChildren($contentSpr, _titleTF, _descriptionTF, _okBtn, _downloadButton);
			
			// add event listeners
			_downloadButton.addEventListener(MouseEvent.CLICK, _onDownloadClick, false, 0, true);
			_okBtn.addEventListener(MouseEvent.CLICK, _onOKClick, false, 0, true);
		}

		
		
		/**
		 * Show save track modal.
		 * @param c Config object
		 */
		override public function show(c:Object = null):void {
			if(_downloadURL != null) {
				Logger.info('Showing download track modal.');
				
				super.show(c);
				
				// set default sizes
				width = _PANEL_WIDTH;
				height = _PANEL_HEIGHT;
				y = _PANEL_Y;
			}
			else throw new Error('Download URL not defined.');
		}
		
		
		
		override public function hide():void {
			_downloadURL = null;
			
			super.hide();
		}
		
		
		
		public function set downloadURL(value:String):void {
			_downloadURL = value;
		}

		
		
		/**
		 * Cancel button click event handler.
		 * @param event Event data
		 */
		private function _onOKClick(event:MouseEvent):void {
			hide();
		}
		
		
		
		private function _onDownloadClick(event:MouseEvent):void {
			navigateToURL(new URLRequest(_downloadURL), '_blank');
		}
	}
}