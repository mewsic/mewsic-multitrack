package manager_panel.search {
	import caurina.transitions.Tweener;
	
	import config.Embeds;
	import config.Settings;
	
	import org.vancura.graphics.Drawing;
	import org.vancura.graphics.QBitmap;
	import org.vancura.graphics.QSprite;
	import org.vancura.util.addChildren;
	import org.vancura.util.removeChildren;
	
	import flash.events.MouseEvent;	

	
	
	/**
	 * Row common functions.
	 * 
	 * @author Vaclav Vancura (http://vaclav.vancura.org)
	 * @since Jul 12, 2008
	 */
	public class SearchRowCommon extends QSprite {

		
		
		protected static const $CONTENT_WIDTH:uint = 292;
		protected static const $CONTENT_HEIGHT:uint = 49; 
		protected var $type:String;
		protected var $contentSpr:QSprite;
		private var _backBD:QBitmap;
		private var _activeBM:QBitmap;
		private var _activeSpr:QSprite;
		private var _maskSpr:QSprite;

		
		
		/**
		 * Constructor.
		 * @param c Sprite config Object
		 * @param t Type (Settings.TYPE_SONG or Settings.TYPE_TRACK)
		 */
		public function SearchRowCommon(t:String, c:Object = null) {
			super(c);
			
			// check for allowed type
			if(t != Settings.TYPE_SONG && t != Settings.TYPE_TRACK) throw new TypeError('Invalid row type');
			$type = t;
			
			// create graphics
			if($type == Settings.TYPE_SONG) {
				_backBD = new QBitmap({embed:new Embeds.subpanelSearchSongBackBD});
				_activeBM = new QBitmap({embed:new Embeds.subpanelSearchPanel1HoverBD});
			}
			else {
				_backBD = new QBitmap({embed:new Embeds.subpanelSearchTrackBackBD});
				_activeBM = new QBitmap({embed:new Embeds.subpanelSearchPanel2HoverBD});
			}
			_activeSpr = new QSprite({alpha:0, buttonMode:true});
			_maskSpr = new QSprite();
			$contentSpr = new QSprite({mouseEnabled:false, mask:_maskSpr});
			
			// drawing
			Drawing.drawRect(_maskSpr, 0, 0, $CONTENT_WIDTH, $CONTENT_HEIGHT, 0xFF0000, .2);
			
			// add to displaty list
			addChildren(_activeSpr, _activeBM);
			addChildren(this, _backBD, _activeSpr, $contentSpr, _maskSpr);
			
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
			removeChildren(_activeSpr, _activeBM);
			removeChildren(this, _backBD, _activeSpr, $contentSpr, _maskSpr);
		}

		
		
		/**
		 * Get type of row (Settings.TYPE_SONG or Settings.TYPE_TRACK).
		 * @return Type (Settings.TYPE_SONG or Settings.TYPE_TRACK)
		 */
		public function get type():String {
			return $type;
		}

		
		
		/**
		 * Get row height.
		 * @return Row height
		 */
		override public function get height():Number {
			return $CONTENT_HEIGHT;
		}

		
		
		/**
		 * Active out event handler.
		 * @param event Event data
		 */
		private function _onActiveOut(event:MouseEvent):void {
			Tweener.removeTweens(_activeSpr);
			Tweener.addTween(_activeSpr, {time:.15, alpha:0, transition:'easeInSine'});
		}

		
		
		/**
		 * Active over event handler.
		 * @param event Event data
		 */
		private function _onActiveOver(event:MouseEvent):void {
			Tweener.removeTweens(_activeSpr);
			_activeSpr.alpha = 1;
		}
	}
}
