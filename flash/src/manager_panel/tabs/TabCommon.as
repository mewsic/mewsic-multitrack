package manager_panel.tabs {
	import caurina.transitions.Tweener;
	
	import config.Embeds;
	import config.Filters;
	import config.Formats;
	import config.Settings;
	
	import org.bytearray.display.ScaleBitmap;
	import org.vancura.graphics.Drawing;
	import org.vancura.graphics.QSprite;
	import org.vancura.graphics.QTextField;
	import org.vancura.util.addChildren;
	
	import flash.display.Bitmap;
	import flash.geom.Rectangle;
	import flash.text.TextFieldAutoSize;	

	
	
	/**
	 * Tab common functions
	 * 
	 * @author Vaclav Vancura (http://vaclav.vancura.org)
	 * @since Jun 24, 2008
	 */
	public class TabCommon extends QSprite {

		
		
		private static const _BADGE_FADE_TIME:Number = .5;
		private static const _BADE_FADE_DELAY:Number = 1;
		protected var $badgeSpr:QSprite;
		protected var $headerSpr:QSprite;
		protected var $headerMaskSpr:QSprite;
		protected var $contentHeight:Number = 36;
		protected var $contentSpr:QSprite;
		private var _badgeBackSBM:ScaleBitmap;
		private var _badgeLabelTF:QTextField;
		private var _isVisible:Boolean;
		private var _id:String;
		private var _defaultBackground:String;
		private var _contentContainerSpr:QSprite;

		
		
		/**
		 * Constructor.
		 */
		public function TabCommon(id:String, defaultBackground:String, o:Object = null) {
			super(o);
			_id = id;
			_defaultBackground = defaultBackground;
			
			// add basic sprites
			$headerMaskSpr = new QSprite({y:-35});
			$headerSpr = new QSprite({mask:$headerMaskSpr});
			$badgeSpr = new QSprite({y:-38, mouseEnabled:false, alpha:0});
			$contentSpr = new QSprite();
			_contentContainerSpr = new QSprite({visible:false});
			
			// add badge
			_badgeBackSBM = new ScaleBitmap((new Embeds.tabBadgeBD() as Bitmap).bitmapData);
			_badgeBackSBM.scale9Grid = new Rectangle(14, 14, 1, 1);
			_badgeLabelTF = new QTextField({defaultTextFormat:Formats.tabBadge, filters:Filters.tabBadge, x:9, y:6, mouseEnabled:false, autoSize:TextFieldAutoSize.LEFT});
			
			// drawing
			Drawing.drawRect($headerMaskSpr, 0, 0, Settings.STAGE_WIDTH, 35);
			
			// add to display list
			addChildren($badgeSpr, _badgeBackSBM, _badgeLabelTF);
			addChildren(_contentContainerSpr, $contentSpr);
			addChildren(this, $headerSpr, $badgeSpr, _contentContainerSpr, $headerMaskSpr);
		}

		
		
		/**
		 * Set badge label.
		 * @param value Label
		 */
		public function set badgeLabel(value:String):void {
			_badgeLabelTF.text = value;
			_badgeBackSBM.width = _badgeLabelTF.textWidth + 24;
			
			var x:Number = $headerSpr.width - _badgeBackSBM.width;
			_badgeBackSBM.x = x;
			_badgeLabelTF.x = x + 9;
			
			// fade badge, but always wait a while, because it may be possible that the whole area is not visible yet
			$badgeSpr.visible = true; 
			Tweener.addTween($badgeSpr, {
				delay:_BADE_FADE_DELAY, time:_BADGE_FADE_TIME, alpha:(value != '') ? 1 : 0, transition:(value != '') ? 'easeOutSine' : 'easeInSine', onComplete:function():void {
				$badgeSpr.visible = (value != '');
			}});
		}

		
		
		/**
		 * Get visibility flag.
		 * @return Visibility flag
		 */
		override public function get visible():Boolean {
			return _isVisible;
		}

		
		
		/**
		 * Set visibility flag
		 * @param value Visibility flag
		 */
		override public function set visible(value:Boolean):void {
			if(_isVisible == value) return;
			
			Tweener.removeTweens(this);
			Tweener.removeTweens(_contentContainerSpr);
			
			if(value) {
				_contentContainerSpr.alpha = 0;
				_contentContainerSpr.visible = true;
				$contentSpr.cacheAsBitmap = true;
				Tweener.addTween(this, {time:Settings.TAB_CHANGE_TIME, onComplete:function():void {
					dispatchEvent(new TabEvent(TabEvent.CHANGE_BACK_TYPE, false, false, {backType:_defaultBackground}));
				}});
				Tweener.addTween(_contentContainerSpr, {delay:Settings.TAB_CHANGE_TIME, time:Settings.TAB_CHANGE_TIME, alpha:1, transition:'easeOutSine', onComplete:function():void {
					$contentSpr.cacheAsBitmap = false;
					_isVisible = true;
				}});
			}
			else {
				$contentSpr.cacheAsBitmap = true;
				Tweener.addTween(_contentContainerSpr, {time:Settings.TAB_CHANGE_TIME, alpha:0, transition:'easeInSine', onComplete:function():void {
					_contentContainerSpr.visible = false;
					$contentSpr.cacheAsBitmap = false;
					_isVisible = false;
				}});
			}
		}

		
		
		/**
		 * Get tab ID.
		 * @return Tab ID
		 */
		public function get id():String {
			return _id;
		}

		
		
		/**
		 * Get content height.
		 * @return Content height
		 */		
		public function get contentHeight():Number {
			return $contentHeight;
		}
	}
}
