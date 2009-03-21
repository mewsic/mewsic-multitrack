package manager_panel {
	import application.AppEvent;
	import application.PanelCommon;
	
	import caurina.transitions.Tweener;
	
	import config.Settings;
	
	import manager_panel.tabs.TabEvent;
	import manager_panel.tabs.TabManager;
	
	import de.popforge.utils.sprintf;
	
	import org.vancura.util.addChildren;	

	
	
	/**
	 * Manager panel.
	 * 
	 * @author Vaclav Vancura (http://vaclav.vancura.org)
	 * @since Jun 24, 2008
	 */
	public class Manager extends PanelCommon {

		
		
		private var _isRendered:Boolean;
		private var _tabMySongs:MySongs;
		private var _tabManager:TabManager;

		
		
		/**
		 * Constructor.
		 */
		public function Manager() {
			$panelID = 'panelManager'; 
			super();
			setBackType(BACK_TYPE_DARK);

			// panel is invisible first, so it doesn't mess up preloader bar
			// it's made visible later in _refresh()
			this.alpha = 0;
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
						
						// add tab manager
						_tabManager = new TabManager();
						
						// add tabs
						_tabMySongs = new MySongs();
						
						// add to tab manager
						_tabManager.addTab(_tabMySongs);
			
						// add to display list
						addChildren($aboveSpr, _tabManager);
						
						// add event listeners
						_tabMySongs.addEventListener(TabEvent.CHANGE_HEIGHT, $onChangeHeight, false, 0, true);
						_tabMySongs.addEventListener(TabEvent.CHANGE_BACK_TYPE, $onChangeBackType, false, 0, true);
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
		 * Get My Songs tab.
		 * @return My Songs tab
		 */
		public function get tabMySongs():MySongs {
			return _tabMySongs;
		}
	}
}
