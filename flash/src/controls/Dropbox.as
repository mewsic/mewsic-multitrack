package controls {
	import application.App;
	
	import config.Embeds;
	import config.Filters;
	
	import dropbox.DropboxEvent;
	
	import de.popforge.utils.sprintf;
	
	import com.gskinner.utils.Rnd;
	
	import org.vancura.util.addChildren;
	import org.vancura.util.removeChildren;
	
	import flash.events.MouseEvent;
	import flash.geom.Point;	

	
	
	/**
	 * Dropbox control. 
	 * 
	 * @author Vaclav Vancura (http://vaclav.vancura.org)
	 * @since Jul 24, 2008
	 */
	public class Dropbox extends Input {

		
		
		private var _dropBtn:Button;
		private var _list:Array = new Array();
		private var _id:String;
		private var _isEventAdded:Boolean;
		private var _resetBtn:Button;

		
		
		/**
		 * Constructor.
		 * @param c Input config Object
		 */
		public function Dropbox(c:Object = null) {
			// set dropbox hash
			_id = sprintf('dropbox.%u.%u', uint(new Date()), Rnd.integer(1000, 9999));
			
			// create dropbox button
			_dropBtn = new Button({width:13, height:24, textOutFilters:Filters.buttonGrayLabel, textOverFilters:Filters.buttonGrayLabel, textPressFilters:Filters.buttonGrayLabel, skin:new Embeds.buttonGrayNanoBD(), icon:new Embeds.glyphDropboxBD()});
			_resetBtn = new Button({visible:false, skin:new Embeds.buttonDropdownResetBD()}, Button.TYPE_NOSCALE_BUTTON);
			
			// alter settings and create super
			c.isDropbox = true;			
			super(c);
			
			// add to display list
			addChildren(this, _dropBtn, _resetBtn);
			
			// add event listeners
			super.addEventListener(MouseEvent.CLICK, _onInputClick, false, 0, true);
			_resetBtn.addEventListener(MouseEvent.CLICK, _onResetClick, false, 0, true);
		}

		
		
		/**
		 * Destructor.
		 */
		override public function destroy():void {
			// remove event listeners
			super.removeEventListener(MouseEvent.CLICK, _onInputClick);
			_resetBtn.removeEventListener(MouseEvent.CLICK, _onResetClick);
//			if(_isEventAdded) App.dropboxContent.removeEventListener(DropboxEvent.CLICK, _onItemClick);
			
			// remove form display list
			removeChildren(this, _dropBtn, _resetBtn);
			
			// destroy components
			_dropBtn.destroy();
			
			// destroy super
			super.destroy();
		}

		
		
		/**
		 * Reset to default value.
		 */
		override public function reset():void {
			_resetBtn.visible = false;
			super.reset();
		}

		
		
		/**
		 * Set width.
		 * @param value Width
		 */
		override public function set width(value:Number):void {
			super.width = value;
			_dropBtn.x = value - 13;
			_resetBtn.x = value - 13 - 18;
		}

		
		
		/**
		 * Set list of values.
		 * @param value List of values.
		 */
		public function set list(value:Array):void {
			_list = value;
		}
		
		
		
		/**
		 * Input click event handler.
		 * This means dropbox is activated.
		 * @param event Event data
		 */
		private function _onInputClick(event:MouseEvent):void {
			// convert click point to global value
			var p:Point = localToGlobal(new Point(0, 0));
			
			if(!_isEventAdded) {
				// attach click handler
//				App.dropboxContent.addEventListener(DropboxEvent.CLICK, _onItemClick, false, 0, true);
				_isEventAdded = true;
			}
			
			// if it's clicked for the second time,
			// it means user wants to hide dropbox
//			if(App.dropboxContent.currentID == _id) {
//				App.dropboxContent.hide();
//				return;
//			}
			
			// no, just show it.
			// new dropbox is visible now.
//			App.dropboxContent.show(_id, p.x, p.y, this.width, _list);
		}

		
		
		/**
		 * Item click event handler.
		 * Some item from the dropbox was selected.
		 * @param event Event data
		 */
		private function _onItemClick(event:DropboxEvent):void {
			// check for the right dropbox
			if(event.id == _id) {
				// this dropbox is selected
				// grab title
				super.text = event.label;
				
				// reset button should be visible,
				// so the dropbox could be reverted.
				_resetBtn.visible = true;
				
				// dispatch
				dispatchEvent(event);
			}
		}
		
		
		
		/**
		 * Reset button click event handler.
		 * Reset dropbox value.
		 * @param event Event data
		 */
		private function _onResetClick(event:MouseEvent):void {
			// reset value
			super.reset();
			_resetBtn.visible = false;
			
			// stop all mouse event propagation
			event.stopPropagation();
		}
	}
}
