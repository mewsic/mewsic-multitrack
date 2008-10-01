package editor_panel {
	import config.Embeds;
	import config.Filters;
	
	import controls.Button;
	import controls.Slider;
	
	import org.vancura.graphics.MorphSprite;
	import org.vancura.graphics.QBitmap;
	import org.vancura.util.addChildren;
	
	import flash.events.MouseEvent;	

	
	
	/**
	 * Viewport scroller.
	 * 
	 * TODO: Write documentation
	 * 
	 * @author Vaclav Vancura (http://vaclav.vancura.org)
	 * @since Jul 7, 2008
	 */
	public class Scroller extends MorphSprite {

		
		
		private var _backBM:QBitmap;
		private var _leftBtn:Button;
		private var _rightBtn:Button;
		private var _thumbSlider:Slider;

		
		
		/**
		 * Constructor.
		 * @param c Config data
		 */
		public function Scroller(c:Object = null) {
			super(c);
			
			// add components
			_backBM = new QBitmap({x:520, embed:new Embeds.viewportScrollerBackBD()});
			_leftBtn = new Button({alpha:.4, x:520, y:2, width:17, height:16, skin:new Embeds.buttonGrayNanoBD(), icon:new Embeds.glyphScrollLeftBD(), textOutFilters:Filters.buttonGrayLabel, textOverFilters:Filters.buttonGrayLabel, textPressFilters:Filters.buttonGrayLabel, textOutOffsY:-1, textOverOffsY:-1, textPressOffsY:0});
			_rightBtn = new Button({alpha:.4, x:949, y:2, width:17, height:16, skin:new Embeds.buttonGrayNanoBD(), icon:new Embeds.glyphScrollRightBD(), textOutFilters:Filters.buttonGrayLabel, textOverFilters:Filters.buttonGrayLabel, textPressFilters:Filters.buttonGrayLabel, textOutOffsY:-1, textOverOffsY:-1, textPressOffsY:0});
			_thumbSlider = new Slider({x:588, y:2, width:309, slideTime:.5, backSkin:new Embeds.sliderViewportScrollerBD(), thumbSkin:new Embeds.buttonViewportScrollerThumbBD(), wheelRatio:.005});
			
			// disabled first
			_leftBtn.areEventsEnabled = false;
			_rightBtn.areEventsEnabled = false;
			_thumbSlider.areEventsEnabled = false;
			_thumbSlider.alpha = .4;

			// add to display list
			addChildren(this, _backBM, _leftBtn, _rightBtn, _thumbSlider);
			
			// add event listeners
			_leftBtn.addEventListener(MouseEvent.CLICK, _onLeftClick, false, 0, true);
			_rightBtn.addEventListener(MouseEvent.CLICK, _onRightClick, false, 0, true);
		}

		
		
		/**
		 * Reset.
		 */
		public function reset():void {
			_thumbSlider.thumbPos = 0;
		}
		
		
		
		public function set position(value:Number):void {
			_thumbSlider.thumbPos = value;
		}
		
		
		
		/**
		 * Set enabled flag.
		 * @param value Enabled flag
		 */
		public function set isEnabled(value:Boolean):void {
			_leftBtn.areEventsEnabled = value;
			_rightBtn.areEventsEnabled = value;
			_thumbSlider.areEventsEnabled = value;
			
			_leftBtn.alpha = (value) ? 1 : .4;
			_rightBtn.alpha = (value) ? 1 : .4;
			_thumbSlider.alpha = (value) ? 1 : .4;
		}

		
		
		/**
		 * Move slider 10% right.
		 * @param event Event data
		 */
		private function _onRightClick(event:MouseEvent):void {
			_thumbSlider.thumbPos += .1;
		}

		
		
		/**
		 * Move slider 10% left.
		 * @param event Event data
		 */
		private function _onLeftClick(event:MouseEvent):void {
			_thumbSlider.thumbPos -= .1;
		}
	}
}
