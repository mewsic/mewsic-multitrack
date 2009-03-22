package application {
	import application.AppEvent;
	
	import caurina.transitions.Tweener;
	
	import config.Embeds;
	import config.Settings;
	
	import de.popforge.utils.sprintf;
	
	import org.bytearray.display.ScaleBitmap;
	import org.osflash.thunderbolt.Logger;
	import org.vancura.graphics.Drawing;
	import org.vancura.graphics.QSprite;
	import org.vancura.util.addChildren;
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.geom.Rectangle;	

	
	
	/**
	 * Common panel functions
	 * 
	 * @author Vaclav Vancura (http://vaclav.vancura.org)
	 * @since Jun 14, 2008
	 */
	public class PanelCommon extends Sprite {

		
		
		public static const BACK_TYPE_LIGHT:String = 'backTypeLight';
		public static const BACK_TYPE_DARK:String = 'backTypeDark';
		public static const BACK_TYPE_BLUE_1:String = 'backTypeBlue1';
		public static const BACK_TYPE_BLUE_2:String = 'backTypeBlue2';
		public static const BACK_TYPE_BLACK:String = 'backTypeBlack';
		private static const _START_HEIGHT:Number = 20;
		protected var $canvasSpr:QSprite;
		protected var $aboveSpr:QSprite;
		protected var $behindSpr:QSprite;
		protected var $panelID:String;
		private var _backDarkSBM:ScaleBitmap;
		private var _backLightSBM:ScaleBitmap;
		private var _backBlue1SBM:ScaleBitmap;
		private var _backBlue2SBM:ScaleBitmap;
		private var _backBlackSBM:ScaleBitmap;
		private var _canvasMaskSpr:QSprite;
		private var _currentBackSBM:ScaleBitmap;
		private var _currentBackType:String;
		private var _currentHeight:Number = _START_HEIGHT;

		
		
		/**
		 * Constructor.
		 */
		public function PanelCommon() {
			super();
			
			// add background ScaleBitmaps
			_backDarkSBM = new ScaleBitmap((new Embeds.panelDarkBackBD() as Bitmap).bitmapData);
			_backLightSBM = new ScaleBitmap((new Embeds.panelLightBackBD() as Bitmap).bitmapData);
			_backBlue1SBM = new ScaleBitmap((new Embeds.panelBlue1BackBD() as Bitmap).bitmapData);
			_backBlue2SBM = new ScaleBitmap((new Embeds.panelBlue2BackBD() as Bitmap).bitmapData);			_backBlackSBM = new ScaleBitmap((new Embeds.panelBlackBackBD() as Bitmap).bitmapData);
			
			// set background ScaleBitmaps parameters
			_backDarkSBM.scale9Grid = _backLightSBM.scale9Grid = _backBlue1SBM.scale9Grid = _backBlue2SBM.scale9Grid = _backBlackSBM.scale9Grid = new Rectangle(17, 19, 66, 2);
			_backDarkSBM.width = _backLightSBM.width = _backBlue1SBM.width = _backBlue2SBM.width = _backBlackSBM.width = Settings.STAGE_WIDTH;
			_backDarkSBM.height = _backLightSBM.height = _backBlue1SBM.height = _backBlue2SBM.height = _backBlackSBM.height = 40;
			_backDarkSBM.y = _backLightSBM.y = _backBlue1SBM.y = _backBlue2SBM.y = _backBlackSBM.y = -10;
			_backDarkSBM.alpha = _backLightSBM.alpha = _backBlue1SBM.alpha = _backBlue2SBM.alpha = _backBlackSBM.alpha = .5;
			_backDarkSBM.visible = _backLightSBM.visible = _backBlue1SBM.visible = _backBlue2SBM.visible = _backBlackSBM.visible = false;

			// other sprites
			_canvasMaskSpr = new QSprite({x:6, y:0});
			$canvasSpr = new QSprite({x:6, y:0, mask:_canvasMaskSpr});
			$aboveSpr = new QSprite();
			$behindSpr = new QSprite();

			// drawing
			Drawing.drawRect($canvasSpr, 0, 0, Settings.STAGE_WIDTH - 12, 1, 0xFF0000, 0);
			Drawing.drawRect(_canvasMaskSpr, 0, 0, Settings.STAGE_WIDTH - 12, 100, 0x000000, .25);

			// add to display list
			addChildren(this, $behindSpr, _backDarkSBM, _backLightSBM, _backBlue1SBM, _backBlue2SBM, _backBlackSBM, $canvasSpr, _canvasMaskSpr, $aboveSpr);
		}

		
		
		/**
		 * Animate height change.
		 * @param value New height
		 */
		protected function $animateHeightChange(value:Number):void {
			if(value == _currentHeight) {
				// no change is going to happen
				Logger.debug(sprintf('Panel %s asked to change it\'s height, but it\'s same, so no change will happen', $panelID));
				return;
			}
			else {
				// change height
				Logger.debug(sprintf('Panel %s changes it\'s height to %u px', $panelID, value));
				
				var o:Object = new Object();
				o.height = _currentHeight + 1;

				// animate it				
				Tweener.addTween(o, {time:Settings.STAGE_HEIGHT_CHANGE_TIME, height:value, transition:'easeInOutQuad', onUpdate:function():void {
					height = this.height;
				}});
			}
			
			// dispatch
			dispatchEvent(new AppEvent(AppEvent.HIDE_DROPBOX, true));
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
			return _currentHeight + 21;
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
		 * Type could be: BACK_TYPE_DARK, BACK_TYPE_LIGHT, BACK_RECORD_TRACK_1 and BACK_RECORD_TRACK_2
		 * @param bt Back type (BACK_TYPE_DARK, BACK_TYPE_LIGHT, BACK_RECORD_TRACK_1 or BACK_RECORD_TRACK_2)
		 */
		public function setBackType(bt:String):void {
			// don't fade if nothing changes
			if(bt == _currentBackType) return;
			
			var bto:ScaleBitmap;
			switch(bt) {
				
				case BACK_TYPE_DARK:
					bto = _backDarkSBM;
					break;
					
				case BACK_TYPE_LIGHT:
					bto = _backLightSBM;
					break;
					
				case BACK_TYPE_BLUE_1:
					bto = _backBlue1SBM;
					break;
					
				case BACK_TYPE_BLUE_2:
					bto = _backBlue2SBM;
					break;
					
				case BACK_TYPE_BLACK:
					bto = _backBlackSBM;
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
			
			// dispatch
			dispatchEvent(new AppEvent(AppEvent.HIDE_DROPBOX, true));
		}
	}
}
