package editor_panel.ruler {
	import flash.events.MouseEvent;
	import flash.text.TextFieldAutoSize;
	
	import org.vancura.graphics.Drawing;
	import org.vancura.graphics.QBitmap;
	import org.vancura.graphics.QSprite;
	import org.vancura.graphics.QTextField;
	import org.vancura.util.addChildren;
	
	import application.App;
	
	import caurina.transitions.Tweener;
	
	import config.Embeds;
	import config.Formats;	

	
	
	/**
	 * Ruler scroller.
	 * 
	 * @author Vaclav Vancura (http://vaclav.vancura.org)
	 * @since Jun 20, 2008
	 */
	public class Scroller extends QSprite {

		
		
		private static const _TICK_COUNT:uint = 1000;
		private var _backBM:QBitmap;
		private var _gradBM:QBitmap;
		private var _tickContentSpr:QSprite;
		private var _tickMaskSpr:QSprite;
		private var _labelList:Array;

		
		
		/**
		 * Constructor.
		 * @param c QSprite config Object
		 */
		public function Scroller(c:Object = null) {
			super(c);
			
			_labelList = new Array();
			
			// add components
			_backBM = new QBitmap({x:520, embed:new Embeds.rulerBackBD()});
			_gradBM = new QBitmap({x:520, height:24, embed:new Embeds.viewportGradsBD()});
			_tickMaskSpr = new QSprite();
			_tickContentSpr = new QSprite({x:520, mask:_tickMaskSpr});
			
			// draw mask
			Drawing.drawRect(_tickMaskSpr, 520, 0, 446, 24);
			
			// draw lines
			for(var a:uint = 0;a < _TICK_COUNT; a++ ) {
				var x:uint = a * 10;
				var y:uint = (a % 5 == 0) ? 13 : 18;
				var l:uint = (a % 5 == 0) ? 0x808080 : 0xa0a0a0;
				
				Drawing.strokeLine(_tickContentSpr, x, y, x, 30, l);
				Drawing.strokeLine(_tickContentSpr, x + 1, y, x + 1, 30, 0xd0d0d0);
				
				if(a % 5 == 0) {
					var t:QTextField = new QTextField({x:x, y:2, width:50, text:App.getTimeCode(a * 1000), defaultTextFormat:Formats.rulerTickLabel, mouseEnabled:false, autoSize:TextFieldAutoSize.LEFT});
					_tickContentSpr.addChild(t);
					_labelList.push(t);
				} 
			}

			// add to display list
			addChildren(this, _backBM, _gradBM, _tickContentSpr, _tickMaskSpr);
			
			// add event listeners
			App.editor.addEventListener(MouseEvent.MOUSE_DOWN, _onSeek, false, 0, true);
		}

		
		
		/**
		 * Scroll waveform.
		 * @param px Position (in px)
		 */
		public function scrollTo(px:int):void {
			Tweener.removeTweens(_tickContentSpr);
			Tweener.addTween(_tickContentSpr, {time:.5, x:px + 520, rounded:true});
		}
		
		
		
		/**
		 * Seek scroller event handler.
		 * @param event Event data
		 */
		private function _onSeek(event:MouseEvent):void {
			if(event.currentTarget.mouseY > 64 && event.currentTarget.mouseY < 86) {
				// it's in vertical limits
				var p:int = event.currentTarget.mouseX - App.editor.currentScrollPos - 521 - 6;
				
				// count horizontal limits
				if(p < 0) p = 0;
				if(p > App.editor.milliseconds / 100) p = App.editor.milliseconds / 100;
				  
				// seek the editor
				App.editor.seek(p * 100);
			}
		}
	}
}
