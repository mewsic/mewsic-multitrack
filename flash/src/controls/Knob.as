package controls {
	import org.vancura.graphics.QSprite;
	import org.vancura.util.addChildren;
	import org.vancura.util.removeChildren;
	
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;	

	
	
	/**
	 * Knob control.
	 * 
	 * TODO: Write documentation
	 * TODO: More advanced error handling
	 * TODO: Clean
	 * 
	 * @author Vaclav Vancura (http://vaclav.vancura.org)
	 * @since Jun 14, 2008
	 */
	public class Knob extends MorphSprite {

		
		
		private static const _MIDPOINT_RANGE:int = 20;
		public static var defMorphTime:Number = DefaultControlSettings.DEF_MORPH_TIME;
		public static var defBackSkin:BitmapData = null;
		public static var defPointerSpr:Sprite = null;
		public static var defOverInTime:Number = DefaultControlSettings.DEF_OVER_IN_TIME;
		public static var defOverOutTime:Number = DefaultControlSettings.DEF_OVER_OUT_TIME;
		public static var defPressInTime:Number = DefaultControlSettings.DEF_PRESS_IN_TIME;
		public static var defPressOutTime:Number = DefaultControlSettings.DEF_PRESS_OUT_TIME;
		protected var $backBtn:Button;
		protected var $pointerSpr:QSprite;
		protected var $overInTime:Number;
		protected var $overOutTime:Number;
		protected var $pressInTime:Number;
		protected var $pressOutTime:Number;
		protected var $currentThumbAngle:Number = 0;
		protected var $rangeBegin:Number;
		protected var $rangeEnd:Number;
		private var _areEventsEnabled:Boolean = true;
		private var _startY:Number;
		private var _lastThumbAngle:Number;

		
		
		public function Knob(c:Object = null) {
			super();

			if(c == null) c = new Object();
			if(c.pointerSpr == undefined && defPointerSpr == null) throw new Error('Default knob pointer is not defined.');

			// get some data
			$overInTime = (c.overInTime != undefined) ? c.overInTime : defOverInTime;
			$overOutTime = (c.overOutTime != undefined) ? c.overOutTime : defOverOutTime;
			$pressInTime = (c.pressInTime != undefined) ? c.pressInTime : defPressInTime;
			$pressOutTime = (c.pressOutTime != undefined) ? c.pressOutTime : defPressOutTime;
			$morphTime = (c.morphTime != undefined) ? c.morphTime : defMorphTime;
			
			// construct back data
			var backData:Object = {
				$overInTime:$overInTime, $overOutTime:$overOutTime, $pressInTime:$pressInTime, $pressOutTime:$pressOutTime, morphTime:(c.morphTime != undefined) ? c.morphTime : defMorphTime, skin:(c.backSkin != undefined) ? c.backSkin : defBackSkin
			};
			
			// add back button
			$backBtn = new Button(backData, Button.TYPE_NOSCALE_BUTTON);

			// construct pointer data
			var pointerData:Object = {
				embed:(c.pointerSpr != undefined) ? c.pointerSpr : defPointerSpr, x:$backBtn.width / 2, y:$backBtn.height / 2, mouseEnabled:false
			};

			// add pointer sprite
			$pointerSpr = new QSprite(pointerData);

			// noscale button mode
			$isChangeWidthEnabled = false;
			$isChangeHeightEnabled = false;
			$isMorphWidthEnabled = false;
			$isMorphHeightEnabled = false;

			// add to display list
			addChildren(this, $backBtn, $pointerSpr);
			
			// set visual properties
			this.x = (c.x != undefined) ? c.x : 0;
			this.y = (c.y != undefined) ? c.y : 0;
			this.visible = (c.visible != undefined) ? c.visible : true;
			this.alpha = (c.alpha != undefined) ? c.alpha : 1;
			this.mask = (c.mask != undefined) ? c.mask : null;
			this.$rangeBegin = (c.rangeBegin != undefined) ? c.rangeBegin : 0;
			this.$rangeEnd = (c.rangeEnd != undefined) ? c.rangeEnd : 0;
			
			// add event listeners
			$backBtn.addEventListener(ButtonEvent.PRESS, _onDragStart, false, 0, true);
			$backBtn.addEventListener(ButtonEvent.RELEASE_INSIDE, _onDragStop, false, 0, true);			$backBtn.addEventListener(ButtonEvent.RELEASE_OUTSIDE, _onDragStop, false, 0, true);
		}

		
		
		public function destroy():void {
			// remove event listeners
			$backBtn.removeEventListener(ButtonEvent.PRESS, _onDragStart);
			$backBtn.removeEventListener(ButtonEvent.RELEASE_INSIDE, _onDragStop);
			$backBtn.removeEventListener(ButtonEvent.RELEASE_OUTSIDE, _onDragStop);
			this.removeEventListener(Event.ENTER_FRAME, _onDragRefresh);
			
			// remove from display list
			removeChildren(this, $backBtn, $pointerSpr);

			// destroy subcontrols
			$backBtn.destroy();
		}

		
		
		public function get areEventsEnabled():Boolean {
			return _areEventsEnabled;
		}

		
		
		public function set areEventsEnabled(value:Boolean):void {
			_areEventsEnabled = value;
			$backBtn.areEventsEnabled = value;
		}
		
		
		
		public function set angle(value:Number):void {
			$currentThumbAngle = value;
			refreshThumb();
		}

		
		
		public function get angle():Number {
			return $currentThumbAngle;
		}

		
		
		private function _onDragStart(event:ButtonEvent):void {
			_startY = event.currentTarget.mouseY;
			_lastThumbAngle = $currentThumbAngle;
			this.addEventListener(Event.ENTER_FRAME, _onDragRefresh, false, 0, true);
		}
		
		
		
		private function _onDragRefresh(event:Event):void {
			var my:Number = (event.currentTarget.mouseY - _startY) * 2 + _lastThumbAngle;
			
			if(my < $rangeBegin - _MIDPOINT_RANGE) my = $rangeBegin - _MIDPOINT_RANGE;
			if(my > $rangeEnd + _MIDPOINT_RANGE) my = $rangeEnd + _MIDPOINT_RANGE;
			
			if(my != $currentThumbAngle) {
				$currentThumbAngle = my;
				refreshThumb();
			}
		}

		
		
		private function _onDragStop(event:ButtonEvent):void {
			this.removeEventListener(Event.ENTER_FRAME, _onDragRefresh);
		}
		
		
		
		public function refreshThumb():void {
			var p:Number;
			
			if($currentThumbAngle < _MIDPOINT_RANGE * -1) p = $currentThumbAngle + _MIDPOINT_RANGE;
			else if($currentThumbAngle > _MIDPOINT_RANGE) p = $currentThumbAngle - _MIDPOINT_RANGE;
			else p = 0;
			$pointerSpr.rotation = p * -1;
			
			dispatchEvent(new KnobEvent(KnobEvent.REFRESH, false, false, p));
		}
	}
}
