package manager_panel {
	import application.App;
	import application.AppEvent;
	import application.PanelCommon;
	
	import caurina.transitions.Tweener;
	
	import config.Embeds;
	import config.Filters;
	import config.Formats;
	import config.Settings;
	
	import controls.Button;
	import controls.Input;
	import controls.InputEvent;
	
	import manager_panel.search.AdvancedSearch;
	import manager_panel.search.AdvancedSearchEvent;
	import manager_panel.search.SubpanelHandler;
	import manager_panel.tabs.TabCommon;
	import manager_panel.tabs.TabEvent;
	
	import modals.MessageModal;
	
	import remoting.data.GenreData;
	import remoting.data.InstrumentData;
	import remoting.dynamic_services.SearchService;
	import remoting.events.SearchEvent;
	
	import de.popforge.utils.sprintf;
	
	import com.gskinner.utils.StringUtils;
	
	import org.osflash.thunderbolt.Logger;
	import org.vancura.graphics.Drawing;
	import org.vancura.graphics.QBitmap;
	import org.vancura.graphics.QSprite;
	import org.vancura.util.addChildren;
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;	

	
	
	/**
	 * Search tab for manager panel.
	 * 
	 * TODO: Write documentation
	 * 
	 * @author Vaclav Vancura (http://vaclav.vancura.org)
	 * @since Jun 24, 2008
	 */
	public class Search extends TabCommon {

		
		
		private static const _TAB_ID:String = 'TabSearch';
		private static const _SUBTAB_Y:Number = 34;
		private static const _HEADER_X:Number = 20;
		private static const _ADVANCED_SEARCH_HEIGHT:Number = 77;
		private static const _SEARCH_RESULTS_HEIGHT:Number = 417;
		private static const _VIEW_SEARCH_RESULTS:String = 'viewSearchResults';
		private static const _VIEW_ADVANCED_SEARCH:String = 'viewAdvancedSearch';
		private static const _VIEW_NONE:String = 'viewNone';
		private var _advancedSearchSubTab:AdvancedSearch;
		private var _advancedSearchMaskSpr:QSprite;
		private var _searchResultsSubTab:SubpanelHandler;
		private var _searchResultsMaskSpr:QSprite;
		private var _headerEditBtn:Button;
		private var _headerEditInput:Input;
		private var _headerFrontBM:QBitmap;
		private var _headerFixBM:QBitmap;
		private var _headerWaitPieMC:MovieClip;
		private var _menuAdvancedSearchBtn:Button;
		private var _currentView:String;
		private var _menuResetSearchBtn:Button;
		private var _service:SearchService;

		
		
		/**
		 * Constructor.
		 * @param o Config data
		 */
		public function Search(o:Object = null) {
			super(_TAB_ID, PanelCommon.BACK_TYPE_DARK, o);
			
			// add masks
			_advancedSearchMaskSpr = new QSprite({x:6, y:_SUBTAB_Y - _ADVANCED_SEARCH_HEIGHT - 34});
			_searchResultsMaskSpr = new QSprite({x:6, y:_SUBTAB_Y - _SEARCH_RESULTS_HEIGHT});
			
			// add header
			_headerFrontBM = new QBitmap({embed:new Embeds.tabSearchFrontBD()});
			_headerEditInput = new Input({x:8, y:7, width:240, introText:'Search...'});
			_headerEditBtn = new Button({x:247, y:7, width:31, height:24, skin:new Embeds.buttonBlueMiniBD(), icon:new Embeds.glyphGoBD()});
			_headerFixBM = new QBitmap({embed:new Embeds.tabSearchFixBD(), x:_HEADER_X});
			_headerWaitPieMC = new Embeds.waitPieBlackMC() as MovieClip;
			
			// add subtabs
			_advancedSearchSubTab = new AdvancedSearch({x:6, y:_SUBTAB_Y, mask:_advancedSearchMaskSpr, alpha:0});
			_searchResultsSubTab = new SubpanelHandler({x:6, y:_SUBTAB_Y + _ADVANCED_SEARCH_HEIGHT, mask:_searchResultsMaskSpr, alpha:0});
			
			// add menu
			_menuAdvancedSearchBtn = new Button({visible:false, x:27, y:7, width:110, height:22, text:'Advanced search...', skin:new Embeds.buttonMenuBD(), textOutFormat:Formats.menuOut, textOutFilters:Filters.menuOutLabel, textOverFormat:Formats.menuOver, textOverFilters:Filters.menuOverLabel, textPressFormat:Formats.menuOver, textPressFilters:Filters.menuOverLabel});
			_menuResetSearchBtn = new Button({visible:false, x:200, y:7, width:50, height:22, text:'Reset', skin:new Embeds.buttonMenuBD(), textOutFormat:Formats.menuOut, textOutFilters:Filters.menuOutLabel, textOverFormat:Formats.menuOver, textOverFilters:Filters.menuOverLabel, textPressFormat:Formats.menuOver, textPressFilters:Filters.menuOverLabel});
			
			// drawing
			Drawing.drawRect(_advancedSearchMaskSpr, 0, 0, Settings.STAGE_WIDTH - 12, _ADVANCED_SEARCH_HEIGHT + 34);
			Drawing.drawRect(_searchResultsMaskSpr, 0, 0, Settings.STAGE_WIDTH - 12, _SEARCH_RESULTS_HEIGHT);

			// set visual properties
			$headerSpr.x = _HEADER_X;
			_headerEditInput.alpha = 0;
			_headerEditBtn.alpha = 0;
			_headerWaitPieMC.x = _HEADER_X + _headerFrontBM.width - 4;
			_headerWaitPieMC.y = 19;
			_headerWaitPieMC.visible = false;

			// add to display list
			addChildren($headerSpr, _headerFrontBM, _headerEditInput, _headerEditBtn, _headerWaitPieMC);
			addChildren($contentSpr, _advancedSearchSubTab, _advancedSearchMaskSpr, _searchResultsSubTab, _searchResultsMaskSpr, _headerFixBM, _menuAdvancedSearchBtn, _menuResetSearchBtn);

			// intro animation
			Tweener.addTween($headerSpr, {time:Settings.STAGE_HEIGHT_CHANGE_TIME, y:-35, rounded:true, transition:'easeInOutQuad'});
			Tweener.addTween(_headerEditInput, {alpha:1, delay:.2, time:Settings.STAGE_HEIGHT_CHANGE_TIME, transition:'easeInSine'});
			Tweener.addTween(_headerEditBtn, {alpha:1, delay:.2, time:Settings.STAGE_HEIGHT_CHANGE_TIME, transition:'easeInSine'});
			
			_setView(_VIEW_ADVANCED_SEARCH);
			
			// add event listeners
			_headerEditBtn.addEventListener(MouseEvent.CLICK, _onHeaderEditBtnClick, false, 0, true);
			_headerEditInput.addEventListener(MouseEvent.CLICK, _onHeaderEditInputClick, false, 0, true);
			_headerEditInput.addEventListener(InputEvent.ENTER_PRESSED, _onHeaderEditBtnClick, false, 0, true);
			_headerEditInput.addEventListener(InputEvent.FOCUS_IN, _onInputFocusIn, false, 0, true);
			_menuAdvancedSearchBtn.addEventListener(MouseEvent.CLICK, _onAdvancedSearchBtnClick, false, 0, true);
			_menuResetSearchBtn.addEventListener(MouseEvent.CLICK, _onResetSearchBtnClick, false, 0, true);
			_advancedSearchSubTab.addEventListener(AdvancedSearchEvent.ADVANCED_SEARCH, _onAdvancedSearch, false, 0, true);
		}

		
		
		/**
		 * Set this tab visible.
		 * @param value Visibility flag
		 */
		override public function set visible(value:Boolean):void {
			if(visible == value) return;
			else {
				super.visible = value;
				if(value) _setView(_VIEW_NONE);
			}
		}

		
		
		public function postInit():void {
			_service = new SearchService();
			_service.url = App.connection.serverPath + App.connection.configService.searchRequestURL;
			_service.addEventListener(SearchEvent.REQUEST_DONE, _onRequestDone, false, 0, true);
		}

		
		
		public function get advancedSearchSubTab():AdvancedSearch {
			return _advancedSearchSubTab;
		}
		
		
		
		public function get searchResultsSubTab():SubpanelHandler {
			return _searchResultsSubTab;
		}

		
		
		private function _onAdvancedSearchBtnClick(event:MouseEvent):void {
			_setView(_VIEW_ADVANCED_SEARCH);
		}

		
		
		private function _onResetSearchBtnClick(event:MouseEvent):void {
			_setView(_VIEW_NONE);
		}

		
		
		private function _onHeaderEditInputClick(event:MouseEvent):void {
			dispatchEvent(new TabEvent(TabEvent.ACTIVATE));
		}

		
		
		private function _onHeaderEditBtnClick(event:Event):void {
			dispatchEvent(new TabEvent(TabEvent.ACTIVATE));
			_searchByKeyword();
		}

		
		
		private function _searchByKeyword():void {
			if(App.connection.configService.isConnecting) {
				// config is not yet loaded, don't allow to display Search
				App.messageModal.show({title:'Search', description:'Server hasn\'t yet returned some required information.\nPlease wait few seconds and try again.', buttons:MessageModal.BUTTONS_OK});
				return;
			}
			
			var query:String = StringUtils.removeExtraWhitespace(_headerEditInput.text);
			
			if(query == '') {
				// don't search empty query
				Logger.warn('Empty query string');
				return;
			}
			else {
				Logger.info(sprintf('Searching for keyword "%s"', query));
				
				_searchResultsSubTab.cleanResults();
				_headerWaitPieMC.visible = true;
				_setView(_VIEW_SEARCH_RESULTS);
				
				try {
					_service.request({keyword:query});
				}
				catch(err:Error) {
					Logger.error(sprintf('Error thrown while searching:\n%s', err.message));
					_headerWaitPieMC.visible = false;
				}
			}
		}

		
		
		private function _onAdvancedSearch(event:AdvancedSearchEvent):void {
			if(App.connection.configService.isConnecting) {
				// config is not yet loaded, don't allow to display Search
				App.messageModal.show({title:'Search', description:'Server hasn\'t yet returned some required information.\nPlease wait few seconds and try again.', buttons:MessageModal.BUTTONS_OK});
				return;
			}
			
			try {
				var si:String = (event.instrument == '') ? '' : App.connection.instrumentsService.byName(event.instrument).instrumentID.toString();
				var sg:String = (event.genre == '') ? '' : App.connection.genresService.byName(event.genre).genreID.toString();
			}
			catch(err1:Error) {
				App.messageModal.show({title:'Advanced search', description:sprintf('Parameters error.\n%s', err1.message), buttons:MessageModal.BUTTONS_OK, icon:MessageModal.ICON_WARNING});
				return;
			}
			
			Logger.info(sprintf('Advanced search:\n  author=%s\n  title=%s\n  genre=%s\n  country=%s\n  bpm=%s\n  key=%s\n  instrument=%s', event.author, event.title, sg, event.country, event.bpm, event.key, si));
			
			_searchResultsSubTab.cleanResults();
			_headerWaitPieMC.visible = true;
			_setView(_VIEW_SEARCH_RESULTS);
			
			try {
				_service.request({author:event.author, title:event.title, genre:sg, country:event.country, bpm:event.bpm, key:event.key, instrument:si});
			}
			catch(err2:Error) {
				Logger.error(sprintf('Error thrown while searching:\n%s', err2.message));
				_headerWaitPieMC.visible = false;
			}
		}

		
		
		/**
		 * Remoting replied.
		 * @param event Event data
		 */
		private function _onRequestDone(event:SearchEvent):void {
			_headerWaitPieMC.visible = false;
			
			Logger.info(sprintf('Displaying search results (%u songs, %u tracks)', event.songList.length, event.trackList.length));
			
			try {
				_searchResultsSubTab.parseResults(event.songList, event.trackList);
			}
			catch(err:Error) {
				Logger.warn(sprintf('Error switching views (%s)', err.message));
				return;
			}
		}

		
		
		private function _setView(view:String):void {
			var advmy:int;
			var advsa:Number;
			var sermy:int;
			var sersa:Number;
			
			if(view == _currentView) return;
			
			switch(view) {
				case _VIEW_NONE:
					advmy = _SUBTAB_Y - _ADVANCED_SEARCH_HEIGHT - 34;
					advsa = 0;
					
					_menuAdvancedSearchBtn.visible = true;
					_menuResetSearchBtn.visible = false;
					$contentHeight = 36;				
					Tweener.addTween(this, {time:Settings.TAB_CHANGE_TIME, onComplete:function():void {
						dispatchEvent(new TabEvent(TabEvent.CHANGE_HEIGHT));
					}});
					Tweener.addTween(this, {time:Settings.TAB_CHANGE_TIME * 2, onComplete:function():void {
						_advancedSearchSubTab.reset();
					}});
					
					break;
				
				case _VIEW_ADVANCED_SEARCH:
					advmy = _SUBTAB_Y - 34;
					advsa = 1;
					
					_menuAdvancedSearchBtn.visible = false;
					_menuResetSearchBtn.visible = true;
					$contentHeight = _SUBTAB_Y + _ADVANCED_SEARCH_HEIGHT + 16;
					dispatchEvent(new TabEvent(TabEvent.CHANGE_HEIGHT));
					
					break;
					
				case _VIEW_SEARCH_RESULTS:
					advmy = _SUBTAB_Y - 34;
					advsa = 1;
					sermy = _SUBTAB_Y + _ADVANCED_SEARCH_HEIGHT;
					sersa = 1;

					_menuAdvancedSearchBtn.visible = false;
					_menuResetSearchBtn.visible = true;
					_searchResultsSubTab.cleanResults();
					$contentHeight = _SUBTAB_Y + _ADVANCED_SEARCH_HEIGHT + _SEARCH_RESULTS_HEIGHT + 16;
					dispatchEvent(new TabEvent(TabEvent.CHANGE_HEIGHT));
					
					break;
					
				default:
					throw new Error('Invalid search view.');
			}
			
			Tweener.addTween(_advancedSearchMaskSpr, {y:advmy, time:Settings.STAGE_HEIGHT_CHANGE_TIME, rounded:true, transition:'easeInOutQuad'});
			Tweener.addTween(_advancedSearchSubTab, {alpha:advsa, time:Settings.STAGE_HEIGHT_CHANGE_TIME, transition:'easeOutSine'});
			Tweener.addTween(_searchResultsMaskSpr, {y:sermy, time:Settings.STAGE_HEIGHT_CHANGE_TIME, rounded:true, transition:'easeInOutQuad'});
			Tweener.addTween(_searchResultsSubTab, {alpha:sersa, time:Settings.STAGE_HEIGHT_CHANGE_TIME, transition:'easeOutSine'});
			
			_currentView = view;			
		}

		
		
		/**
		 * Input focus event listener.
		 * @param event Event data
		 */
		private function _onInputFocusIn(event:InputEvent):void {
			// dispatch
			dispatchEvent(new AppEvent(AppEvent.HIDE_DROPBOX, true));
		}
	}
}
