package modals {
	import flash.geom.Rectangle;
	
	import org.bytearray.display.ScaleBitmap;
	import org.vancura.graphics.Drawing;
	import org.vancura.graphics.QSprite;
	import org.vancura.util.addChildren;
	
	import application.AppEvent;
	
	import caurina.transitions.Tweener;
	
	import config.Embeds;
	import config.Settings;		

	
	
	/**
	 * Common modal stuff.
	 * 
	 * TODO: Write documentation
	 * 
	 * @author Vaclav Vancura (http://vaclav.vancura.org)
	 * @since Jul 18, 2008
	 */
	public class ModalCommon extends QSprite {

		
		
		protected static const $FADE_TIME:Number = .3;
		protected var $isVisible:Boolean;
		protected var $contentSpr:QSprite;
		private var _containerSpr:QSprite;
		private var _faderSpr:QSprite;
		private var _backSBM:ScaleBitmap;

		
		
		/**
		 * Constructor.
		 * @param o QSprite config Object
		 */
		public function ModalCommon(o:Object = null) {
			super(o);
			
			// add graphics
			_containerSpr = new QSprite();
			_faderSpr = new QSprite({alpha:.65});
			_backSBM = new ScaleBitmap((new Embeds.modalBackBD()).bitmapData);
			_backSBM.scale9Grid = new Rectangle(68, 100, 10, 10);
			$contentSpr = new QSprite();
			
			// drawing
			Drawing.drawRect(_faderSpr, 0, 0, Settings.STAGE_WIDTH, 2800, 0xf5f5f5);
			
			// set visual properties
			this.visible = false;
			$isVisible = false;
			
			// add to display list
			addChildren($contentSpr, _backSBM);
			addChildren(_containerSpr, $contentSpr);
			addChildren(this, _faderSpr, _containerSpr);
		}

		
		
		/**
		 * Show a modal.
		 * @param c Config Object
		 */
		public function show(c:Object = null):void {
			if(c == null) c = new Object();
			
			if($isVisible) {
				hide();
				Tweener.removeTweens($contentSpr);
				Tweener.removeTweens(this);
			}
			
			// set visual properties and assign text
			this.alpha = 0;
			this.visible = true;
			$contentSpr.y = 0;
			$contentSpr.cacheAsBitmap = true;
			$isVisible = true;
			
			// fadein animation
			Tweener.addTween(this, {time:$FADE_TIME, alpha:1, transition:'easeOutSine'});
			Tweener.addTween($contentSpr, {time:$FADE_TIME * 2, y:60, rounded:true, transition:'easeOutSine', onComplete:function():void {
				$contentSpr.cacheAsBitmap = false;
			}});
			
			c; // disable FDT warning
			
			// dispatch
			dispatchEvent(new AppEvent(AppEvent.HIDE_DROPBOX, true));
		}

		
		
		/**
		 * Hide the modal.
		 */
		public function hide():void {
			if($isVisible) {
				$isVisible = false;
				$contentSpr.cacheAsBitmap = true;
			
				// fadeout animation
				Tweener.addTween($contentSpr, {time:$FADE_TIME * 2, y:120, rounded:true, transition:'easeInSine'});
				Tweener.addTween(this, {delay:$FADE_TIME, time:$FADE_TIME, alpha:0, transition:'easeInSine', onComplete:function():void {
					this.visible = false;
					$contentSpr.cacheAsBitmap = false;
				}});
			}
			
			// dispatch
			dispatchEvent(new AppEvent(AppEvent.HIDE_DROPBOX, true));
		}

		
		
		/**
		 * Get visibility flag.
		 * @return Visibility flag
		 */
		public function get isVisible():Boolean {
			return $isVisible;
		}
		
		
		
		/**
		 * Set width.
		 * @param value width
		 */
		override public function set width(value:Number):void {
			_backSBM.width = value;
			$contentSpr.x = Math.round((stage.stageWidth - value) / 2);
		}
		
		
		
		/**
		 * Set height.
		 * @param value height
		 */
		override public function set height(value:Number):void {
			_backSBM.height = value;
		}
		
		
		
		/**
		 * Set X.
		 * @param value X
		 */
		override public function set x(value:Number):void {
		}
		
		
		
		/**
		 * Set Y.
		 * @param value y
		 */
		override public function set y(value:Number):void {
			_containerSpr.y = value;
		}
	}
}