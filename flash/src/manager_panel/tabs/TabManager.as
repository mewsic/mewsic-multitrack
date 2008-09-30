package manager_panel.tabs {
	import org.osflash.thunderbolt.Logger;
	import org.vancura.graphics.QSprite;
	
	import de.popforge.utils.sprintf;
	
	import manager_panel.tabs.TabCommon;	

	
	
	/**
	 * Tab manager.
	 * 
	 * @author Vaclav Vancura (http://vaclav.vancura.org)
	 * @since Jul 9, 2008
	 */
	public class TabManager extends QSprite {

		
		
		private var _tabList:Array = new Array();

		
		
		/**
		 * Constructor.
		 * @param c Config Object
		 */
		public function TabManager(c:Object = null) {
			super(c);
		}
		
		
		
		/**
		 * Add a new tab.
		 * @param tab Tab contents.
		 */
		public function addTab(tab:TabCommon):void {
			addChild(tab);
			tab.addEventListener(TabEvent.ACTIVATE, _onChangeActiveTab, false, 0, true);
			_tabList.push(tab);			
		}

		
		
		/**
		 * Set current tab.
		 * @param tab Current tab
		 */
		public function set currentTab(tab:TabCommon):void {
			Logger.info(sprintf('Changing current tab to %s', tab.id));
			for each(var i:TabCommon in _tabList) i.visible = (i == tab);
		}
		
		
		
		/**
		 * Tab changed event.
		 * @param event Event data
		 */
		private function _onChangeActiveTab(event:TabEvent):void {
			currentTab = event.target as TabCommon;
		}
	}
}
