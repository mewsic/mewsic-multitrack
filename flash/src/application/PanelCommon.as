package application {
	import caurina.transitions.Tweener;
	
	import config.Embeds;
	import config.Settings;
	
	import de.popforge.utils.sprintf;
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	
	import org.bytearray.display.ScaleBitmap;
	import org.osflash.thunderbolt.Logger;
	import org.vancura.graphics.Drawing;
	import org.vancura.graphics.QSprite;
	import org.vancura.util.addChildren;	

	
	
	/**
	 * Common panel functions
	 * 
	 * @author Vaclav Vancura (http://vaclav.vancura.org)
	 * @since Jun 14, 2008
	 */
	public class PanelCommon extends Sprite {

		
		
		public static const BACK_TYPE_WHITE:String = 'backTypeWhite';
		private static const _START_HEIGHT:Number = 20;
		
		protected var $canvasSpr:QSprite;
		protected var $aboveSpr:QSprite;
		protected var $behindSpr:QSprite;
		protected var $panelID:String;

		private var _backWhiteSBM:ScaleBitmap;

		private var _canvasMaskSpr:QSprite;
		private var _currentBackSBM:ScaleBitmap;
		private var _currentBackType:String;
		private var _currentHeight:Number = _START_HEIGHT;

		
		
		/**
		 * Constructor.
		 */
		public function PanelCommon() {
			super();
						
			// New canvas scalebitmap
			_backWhiteSBM = new ScaleBitmap((new Embeds.backgroundCanvasWhite() as Bitmap).bitmapData);
			_backWhiteSBM.scale9Grid = new Rectangle(17, 19, 66, 2)
			_backWhiteSBM.width = Settings.STAGE_WIDTH;
			_backWhiteSBM.height = 40;
			_backWhiteSBM.y = -10;
			_backWhiteSBM.visible = false

			// other sprites
			_canvasMaskSpr = new QSprite({x:6, y:0});
			$canvasSpr = new QSprite({x:6, y:0, mask:_canvasMaskSpr});
			$aboveSpr = new QSprite();
			$behindSpr = new QSprite();

			// drawing
			Drawing.drawRect($canvasSpr, 0, 0, Settings.STAGE_WIDTH - 12, 1, 0xFF0000, 0);
			Drawing.drawRect(_canvasMaskSpr, 0, 0, Settings.STAGE_WIDTH - 12, 100, 0x000000, 0.25);

			// add to display list
			addChildren(this, $behindSpr, _backWhiteSBM, $canvasSpr, _canvasMaskSpr, $aboveSpr);
		}

		
		
		/**
		 * Animate height change.
		 * @param value New height
		 */
		protected function $animateHeightChange(value:Number):void {
			if(value == _currentHeight) {
				// no change is going to happen
				Logger.debug(sprintf('Panel %s asked to change its height, but it\'s same, so no change will happen', $panelID));
				return;
			}
			else {
				// change height
				Logger.debug(sprintf('Panel %s changes its height to %u px', $panelID, value));
				
				var o:Object = new Object();
				o.height = _currentHeight + 1;

				// animate it				
				Tweener.addTween(o, {time:Settings.STAGE_HEIGHT_CHANGE_TIME, height:value, transition:'easeInOutQuad', onUpdate:function():void {
					height = this.height;
				}});
			}
		}

		
		
		/**
		 * Set panel height.
		 * @param value Height
		 */
		override public function set height(value:Number):void {
			var h:Number = Math.round(value) + _START_HEIGHT;
			_currentBackSBM.height = h;
			_canvasMaskSpr.height = h - _START_HEIGHT;
			_currentHeight = value;
			dispatchEvent(new AppEvent(AppEvent.HEIGHT_CHANGE, true));
		}

		
		
		/**
		 * Get panel height.
		 * @return Panel height
		 */
		override public function get height():Number {
			return _currentHeight;
		}

		
		
		/**
		 * Set panel Y.
		 * @param value Panel Y
		 */
		override public function set y(value:Number):void {
			super.y = Math.round(value);
		}

		
		
		/**
		 * Set panel background type.
		 * Type could be only: BACK_TYPE_WHITE
		 * @param bt Back type (BACK_TYPE_WHITE)
		 */
		public function setBackType(bt:String):void {
			// don't fade if nothing changes
			if(bt == _currentBackType) return;
			
			var bto:ScaleBitmap;
			switch(bt) {
				
				case BACK_TYPE_WHITE:
					bto = _backWhiteSBM;
					break;
					
				default:
					throw new Error(sprintf('Invalid pabel back type (%s)', bt));
					
			}
			
			// check for current back
			if(_currentBackSBM != null) {
				// fade out old back
				bto.visible = true;
				bto.alpha = 0;
				bto.height = _currentHeight + _START_HEIGHT;
				
				Tweener.addTween(_currentBackSBM, {time:Settings.TAB_CHANGE_TIME, alpha:0, transition:'easeInSine'});
				Tweener.addTween(bto, {time:Settings.TAB_CHANGE_TIME, alpha:1, transition:'easeOutSine', onComplete:function():void {
					_currentBackSBM.visible = false;
					_currentBackSBM = bto;
					_currentBackType = bt;
				}});
			}
			else {
				// current back is not defined, so define it.
				// now we can change height of the back as usual
				_currentBackSBM = bto;
				_currentBackSBM.visible = true;
				_currentBackType = bt;
				
				Tweener.addTween(_currentBackSBM, {time:Settings.TAB_CHANGE_TIME, alpha:1, transition:'easeOutSine'});
			}
		}
	}
}
