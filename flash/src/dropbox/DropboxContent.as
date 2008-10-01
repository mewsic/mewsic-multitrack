package dropbox {
	import caurina.transitions.Tweener;
	
	import config.Embeds;
	
	import controls.Slider;
	import controls.SliderEvent;
	
	import dropbox.DropboxEvent;
	import dropbox.DropboxItem;
	
	import de.popforge.utils.sprintf;
	
	import org.bytearray.display.ScaleBitmap;
	import org.osflash.thunderbolt.Logger;
	import org.vancura.graphics.Drawing;
	import org.vancura.graphics.QSprite;
	import org.vancura.util.addChildren;
	
	import flash.display.Bitmap;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;	

	
	
	/**
	 * Dropbox content.
	 *  
	 * @author Vaclav Vancura (http://vaclav.vancura.org)
	 * @since Jul 24, 2008
	 */
	public class DropboxContent extends QSprite {

		
		
		private static const _DEFAULT_HEIGHT:uint = 150;
		private var _backSBM:ScaleBitmap;
		private var _slider:Slider;
		private var _listContentSpr:QSprite;
		private var _isVisible:Boolean;
		private var _itemList:Array = new Array();
		private var _listMaskSpr:QSprite;
		private var _currentHeight:uint;
		private var _currentID:String;

		
		
		/**
		 * Constructor.
		 * @param c QSprite config Object
		 */
		public function DropboxContent(c:Object = null) {
			super(c);
			
			// create background
			_backSBM = new ScaleBitmap((new Embeds.dropboxBackBD() as Bitmap).bitmapData);
			_backSBM.scale9Grid = new Rectangle(16, 23, 10, 10);
			
			// create scroller
			_slider = new Slider({y:4, marginBegin:20, marginEnd:20, slideTime:.5, height:200, backSkin:new Embeds.dropboxScrollerBackBD(), thumbSkin:new Embeds.dropboxScrollerThumbBD(), wheelRatio:.005}, Slider.DIRECTION_VERTICAL);
			
			// create list
			_listMaskSpr = new QSprite();
			_listContentSpr = new QSprite({mask:_listMaskSpr});
			
			// drawing
			Drawing.drawRect(_listMaskSpr, 0, 0, 100, 100, 0xFF0000, .3);
			
			// set visual properties
			this.visible = false;
			
			// add to display list
			addChildren(this, _backSBM, _listContentSpr, _listMaskSpr, _slider);
			
			// add event listeners
			_slider.addEventListener(SliderEvent.REFRESH, _onSliderRefresh, false, 0, true);
		}

		
		
		/**
		 * Show dropbox.
		 * @param id New ID
		 * @param list List of values
		 * @param width Width
		 * @param x X
		 * @param y Y
		 */
		public function show(id:String, x:int, y:int, width:int, list:Array):void {
			Logger.debug(sprintf('Show dropbox (id=%s, x=%d, y=%d, width=%d)', id, x, y, width));
			
			// set new id
			_currentID = id;
			
			// remove old items
			for each(var i1:DropboxItem in _itemList) {
				i1.removeEventListener(MouseEvent.CLICK, _onItemClick);
				_listContentSpr.removeChild(i1);
				i1.destroy();
			}
			_itemList = new Array();
			
			// create new items
			var my:uint = 5;
			for each(var li:String in list) {
				var i2:DropboxItem = new DropboxItem(li, width, {y:my});
				my += i2.height;
				_listContentSpr.addChild(i2);
				i2.addEventListener(MouseEvent.CLICK, _onItemClick, false, 0, true);
				_itemList.push(i2);
			}
			
			// stop animation
			Tweener.removeTweens(this);
			
			// set visual properties
			this.visible = true;
			this.alpha = 1;
			this.x = x - 6;
			this.y = y + 21;
			_currentHeight = _DEFAULT_HEIGHT;
			_backSBM.width = width + 12;
			_backSBM.height = _currentHeight;
			_slider.x = width - 9;
			_slider.height = _currentHeight - 16;
			_slider.thumbPos = 0;
			_listMaskSpr.x = 7;
			_listMaskSpr.y = 2;
			_listMaskSpr.width = width - 16;
			_listMaskSpr.height = _currentHeight - 13;
			_isVisible = true;
		}

		
		
		/**
		 * Hide dropbox.
		 */
		public function hide():void {
			if(_isVisible) {
				Tweener.removeTweens(this);
				Tweener.addTween(this, {alpha:0, time:.1, transition:'easeInSine', onComplete:function():void {
					this.visible = false;
					_isVisible = false;
					_currentID = null;
				}});
			}
		}

		
		
		/**
		 * Get current dropbox ID.
		 * @return Current dropbox ID
		 */
		public function get currentID():String {
			return _currentID;
		}

		
		
		/**
		 * Slider scrolling.
		 * @param event Event data
		 */
		private function _onSliderRefresh(event:SliderEvent):void {
			var my:int = Math.round((_listContentSpr.height - _currentHeight + 16) * event.thumbPos) * -1;
			Tweener.removeTweens(_listContentSpr);
			Tweener.addTween(_listContentSpr, {y:my, time:.3, rounded:true});
		}

		
		
		/**
		 * Item click event.
		 * @param event Event data
		 */
		private function _onItemClick(event:MouseEvent):void {
			dispatchEvent(new DropboxEvent(DropboxEvent.CLICK, false, false, _currentID, event.currentTarget.label));
			hide();
		}
	}
}
