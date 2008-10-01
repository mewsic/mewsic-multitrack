package editor_panel.ruler {
	import application.App;
	
	import caurina.transitions.Tweener;
	
	import config.Embeds;
	import config.Formats;
	
	import org.vancura.graphics.QBitmap;
	import org.vancura.graphics.QSprite;
	import org.vancura.graphics.QTextField;
	import org.vancura.util.addChildren;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextFieldAutoSize;	

	
	
	/**
	 * Ruler playhead.
	 * 
	 * @author Vaclav Vancura (http://vaclav.vancura.org)
	 * @since Jun 23, 2008
	 */
	public class Playhead extends QSprite {

		
		
		private var _activeBackBM:QBitmap;
		private var _activeValueTF:QTextField;
		private var _activeContainerSpr:QSprite;
		private var _dragContainerSpr:QSprite;
		private var _dragBackBM:QBitmap;
		private var _dragValueTF:QTextField;
		private var _dragMouseOffs:Number;
		private var _isDragging:Boolean;
		private var _lastDragPos:int;

		
		
		/**
		 * Constructor.
		 * @param c QSprite config Object
		 */
		public function Playhead(c:Object = null) {
			super(c);
			
			// add components
			_activeContainerSpr = new QSprite();
			_dragContainerSpr = new QSprite({visible:false});
			_activeBackBM = new QBitmap({x:-23, embed:new Embeds.rulerPlayheadBackBD()});
			_dragBackBM = new QBitmap({x:-23, embed:new Embeds.rulerPlayheadDragBD()});
			_activeValueTF = new QTextField({x:-23, y:3, width:47, defaultTextFormat:Formats.rulerPlayhead, text:'0:00', mouseEnabled:false, autoSize:TextFieldAutoSize.LEFT});			_dragValueTF = new QTextField({alpha:.9, x:-23, y:3, width:47, defaultTextFormat:Formats.rulerPlayhead, text:'0:00', mouseEnabled:false, autoSize:TextFieldAutoSize.LEFT});
			
			// set visual properties
			this.useHandCursor = true;
			this.mouseEnabled = true;
			this.buttonMode = true;
			this.tabEnabled = false;
			this.focusRect = false;

			// add to display list
			addChildren(_activeContainerSpr, _activeBackBM, _activeValueTF);
			addChildren(_dragContainerSpr, _dragBackBM, _dragValueTF);
			addChildren(this, _activeContainerSpr, _dragContainerSpr);
			
			// add event listeners
			this.addEventListener(MouseEvent.MOUSE_DOWN, _onDragStart, false, 0, true);
			App.editor.addEventListener(MouseEvent.MOUSE_UP, _onDragStop, false, 0, true);
		}

		
		
		/**
		 * Set label.
		 * @param value Label text
		 */
		public function set label(value:String):void {
			_activeValueTF.text = value;
		}

		
		
		/**
		 * Start dragging event handler.
		 * @param event Event data
		 */
		private function _onDragStart(event:MouseEvent):void {
			if(!_isDragging) {
				// we are not dragging
				// so start it
				_isDragging = true;
				
				// check for drag offset
				_dragMouseOffs = _activeContainerSpr.mouseX;
				
				// stop animaion
				Tweener.removeTweens(_dragContainerSpr);
				
				// start ghosting
				_dragContainerSpr.alpha = 1;
				
				// attach ENTER_FRAME event
				App.editor.addEventListener(Event.ENTER_FRAME, _onDragMove, false, 0, true);
			}
		}

		
		
		/**
		 * Stop dragging event handler.
		 * @param event Event data
		 */
		private function _onDragStop(event:MouseEvent):void {
			if(_isDragging) {
				// we are dragging
				// so stop it
				_isDragging = false;
				
				// animate
				Tweener.addTween(_dragContainerSpr, {x:_dragContainerSpr.x - _lastDragPos, alpha:0, time:.5});
				Tweener.addTween(_dragContainerSpr, {alpha:0, time:.8, transition:'easeOutSine', onComplete:function():void {
					_dragContainerSpr.visible = false;
				}});
				
				// remove ENTER_FRAME event
				App.editor.removeEventListener(Event.ENTER_FRAME, _onDragMove);
				
				// seek editor to a new position
				App.editor.seek((_lastDragPos * 100) + App.editor.currentPosition);
			}
		}
		
		
		
		/**
		 * Move playhead even handler.
		 * @param event Event data
		 */
		private function _onDragMove(event:Event):void {
			if(_isDragging) {
				// we are dragging
				var mx:int = event.currentTarget.mouseX - _dragMouseOffs - App.editor.currentScrollPos - (App.editor.currentPosition / 100) - 521 - 6;
				var sx:int = App.editor.currentPosition / -100;
				
				// count limits
				if(mx < sx) mx = sx;
				if(mx > App.editor.milliseconds / 100 + sx) mx = App.editor.milliseconds / 100 + sx;
				
				// move playhead
				_dragContainerSpr.x = mx;
				_dragValueTF.text = App.getTimeCode((mx - sx) * 100);
				_lastDragPos = mx;
				
				// make sure it's visible
				_dragContainerSpr.visible = true;
			}
		}
	}
}
