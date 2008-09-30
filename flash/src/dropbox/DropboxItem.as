package dropbox {
	import flash.events.MouseEvent;
	import flash.text.TextFieldAutoSize;
	
	import org.vancura.graphics.Drawing;
	import org.vancura.graphics.QSprite;
	import org.vancura.graphics.QTextField;
	import org.vancura.util.addChildren;
	import org.vancura.util.removeChildren;
	
	import caurina.transitions.Tweener;
	
	import config.Formats;		

	
	
	/**
	 * Dropbox item.
	 * 
	 * @author Vaclav Vancura (http://vaclav.vancura.org)
	 * @since Jul 24, 2008
	 */
	public class DropboxItem extends QSprite {

		
		
		private var _labelTF:QTextField;
		private var _activeSpr:QSprite;

		
		
		/**
		 * Dropbox item constructor.
		 * @param c QSprite config object
		 * @param label Dropbox item label
		 * @param width Dropbox item width
		 */
		public function DropboxItem(label:String, width:uint, c:Object = null) {
			super(c);
			
			// add graphics
			_labelTF = new QTextField({alpha:.5, x:10, mouseEnabled:false, text:label, defaultTextFormat:Formats.dropboxList, width:width - 20, autoSize:TextFieldAutoSize.LEFT});
			_activeSpr = new QSprite({buttonMode:true});
			
			// drawing
			Drawing.drawRect(_activeSpr, 7, 0, width - 14, Math.floor(_labelTF.textHeight + 6), 0xFF0000, 0);
			
			// add to display list
			addChildren(this, _labelTF, _activeSpr);
			
			// add event listeners
			_activeSpr.addEventListener(MouseEvent.ROLL_OVER, _onActiveOver, false, 0, true);
			_activeSpr.addEventListener(MouseEvent.ROLL_OUT, _onActiveOut, false, 0, true);
		}

		
		
		/**
		 * Destructor.
		 */
		public function destroy():void {
			// remove event listeners
			_activeSpr.removeEventListener(MouseEvent.ROLL_OVER, _onActiveOver);
			_activeSpr.removeEventListener(MouseEvent.ROLL_OUT, _onActiveOut);
			
			// remove from display list
			removeChildren(this, _labelTF, _activeSpr);
		}

		
		
		/**
		 * Get dropbox item height.
		 * @return Dropbox item height
		 */
		override public function get height():Number {
			return Math.floor(_labelTF.textHeight + 6);
		}
		
		
		
		/**
		 * Get dropbox item label.
		 * @return Dropbox item label
		 */
		public function get label():String {
			return _labelTF.text;
		}

		
		
		/**
		 * Active part mouse over event handler.
		 * @param event Event data
		 */
		private function _onActiveOver(event:MouseEvent):void {
			Tweener.removeTweens(_activeSpr);
			_labelTF.alpha = 1;
		}

		
		
		/**
		 * Active part mouse out event handler.
		 * @param event Event data
		 */
		private function _onActiveOut(event:MouseEvent):void {
			Tweener.removeTweens(_labelTF);
			Tweener.addTween(_labelTF, {alpha:.5, time:.15, transition:'easeInSine'});
		}
	}
}
