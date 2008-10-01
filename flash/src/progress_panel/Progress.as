package progress_panel {
	import application.AppEvent;
	import application.PanelCommon;
	
	import caurina.transitions.Tweener;
	
	import config.Filters;
	import config.Formats;
	import config.Settings;
	
	import de.popforge.utils.sprintf;
	
	import org.osflash.thunderbolt.Logger;
	import org.vancura.graphics.QSprite;
	import org.vancura.graphics.QTextField;
	import org.vancura.util.addChildren;
	
	import flash.text.TextFieldAutoSize;	

	
	
	/**
	 * Progress panel.
	 * 
	 * TODO: Write documentation
	 * 
	 * @author Vaclav Vancura (http://vaclav.vancura.org)
	 * @since Jun 24, 2008
	 */
	public class Progress extends PanelCommon {

		
		
		private var _isRendered:Boolean;
		private var _infoTF:QTextField;
		private var _workerList:Array;
		private var _workerSpr:QSprite;

		
		
		/**
		 * Constructor.
		 */
		public function Progress() {
			$panelID = 'panelProgress'; 
			super();
			setBackType(BACK_TYPE_BLUE_1);

			// panel is invisible first, so it doesn't mess up preloader bar
			// it's made visible later in _refresh()
			this.alpha = 0;
			
			// prepare worker list
			_workerList = new Array();
		}

		
		
		/**
		 * Config is loaded, launch it.
		 */
		public function launch():void {
			if(!_isRendered) {
				// panel is reneder
				_isRendered = true;

				// animate height change
				// wait until it's done and than add panel elements
				Tweener.addTween(this, {time:Settings.STAGE_HEIGHT_CHANGE_TIME, onComplete:function():void {
					try {
						$animateHeightChange(36);
						
						// add graphics
						_infoTF = new QTextField({alpha:0, x:19, y:9, width:400, autoSize:TextFieldAutoSize.LEFT, defaultTextFormat:Formats.progress, filters:Filters.progress, thickness:-150, sharpness:50});
						_workerSpr = new QSprite({x:19, y:20});
						
						// add to display list
						addChildren($canvasSpr, _infoTF, _workerSpr);
						
						// set visual properties
						_infoTF.text = 'No running tasks.';
						
						// add event listeners
						
						// animation
						Tweener.addTween(_infoTF, {alpha:1, time:Settings.FADEIN_TIME, delay:Settings.FADEIN_TIME, transition:'easeOutSine'});
					}
					catch(err:Error) {
						dispatchEvent(new AppEvent(AppEvent.FATAL_ERROR, true, false, sprintf('Could not add manager panel.\nPlease reload the page.\n%s', err.message)));
					}
				}});

				// animate alpha
				Tweener.addTween(this, {alpha:1, time:Settings.STAGE_HEIGHT_CHANGE_TIME, transition:'easeOutSine'});
			}
		}

		
		
		/**
		 * Add new worker badge.
		 * @param description Description text
		 * @param id Worker ID
		 */
		public function addWorker(id:String, description:String):void {
			Logger.debug(sprintf('Adding new worker (id=%s)', id));
			
			var w:ProgressItem = new ProgressItem(id, description);
			_workerSpr.addChild(w);
			_workerList.push(w);
			_refreshHeight();
			_refreshCount();
		}

		
		
		/**
		 * Remove worker by its ID.
		 * @param id Worker ID
		 */
		public function removeWorker(id:String):void {
			var found:Boolean;
			
			for each(var i:ProgressItem in _workerList) {
				if(i.isEnabled && i.id == id) {
					found = true;
					_workerSpr.removeChild(i);
					i.destroy();
				}
			}
			
			if(found) {
				_refreshHeight();
				_refreshCount();
			}
		}

		
		
		/**
		 * Refresh workers count.
		 */
		private function _refreshCount():void {
			var c:uint = 0;
			
			for each(var i:ProgressItem in _workerList) {
				if(i.isEnabled) c++;
			}
							
			if(c == 0) {
				_infoTF.text = 'No running tasks.';
			}
			else {
				if(c == 1) _infoTF.text = '1 running task:';
				else _infoTF.text = sprintf('%u running tasks:', c);
			}
		}

		
		
		/**
		 * Refresh height.
		 */
		private function _refreshHeight():void {
			var my:uint = 10;
			var h:uint = 36;
			
			for each(var i:ProgressItem in _workerList) {
				if(i.isEnabled) {
					if(i.y == 0) {
						// intro pos
						i.y = my;
					}
					else {
						// animate pos change
						Tweener.addTween(i, {y:my, time:Settings.STAGE_HEIGHT_CHANGE_TIME, rounded:true, transition:'easeInOutQuad'});
					}
					
					i.y = my;
					h += i.height;
					my += i.height;
				}
			}
			$animateHeightChange(h);
		}
	}
}
