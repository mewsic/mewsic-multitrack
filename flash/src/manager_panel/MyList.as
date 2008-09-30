package manager_panel {
	import flash.events.MouseEvent;
	import flash.text.TextFieldAutoSize;
	
	import org.osflash.thunderbolt.Logger;
	import org.vancura.controls.Button;
	import org.vancura.graphics.QBitmap;
	import org.vancura.graphics.QTextField;
	import org.vancura.util.addChildren;
	
	import de.popforge.utils.sprintf;
	
	import application.App;
	import application.PanelCommon;
	
	import caurina.transitions.Tweener;
	
	import config.Embeds;
	import config.Filters;
	import config.Formats;
	import config.Settings;
	
	import manager_panel.lists.ListSongRow;
	import manager_panel.lists.ListTrackRow;
	import manager_panel.tabs.TabCommon;
	import manager_panel.tabs.TabEvent;
	
	import modals.MessageModal;
	
	import remoting.data.SongData;
	import remoting.data.TrackData;
	import remoting.dynamic_services.MyListService;
	import remoting.events.MyListEvent;	

	
	
	/**
	 * My List tab for the manager panel.
	 *
	 * TODO: Write documentation
	 * 
	 * @author Vaclav Vancura (http://vaclav.vancura.org)
	 * @since Jun 24, 2008
	 */
	public class MyList extends TabCommon {

		
		
		private static const _TAB_ID:String = 'TabMyList';
		private static const _SUBTAB_Y:Number = 29;
		private static const _HEADER_X:Number = 826;
		private var _headerBtn:Button;
		private var _headerFixBM:QBitmap;
		private var _songList:Array;
		private var _isListFilled:Boolean;
		private var _userTF:QTextField;
		private var _toolsTF:QTextField;
		private var _ratingTF:QTextField;
		private var _descriptionTF:QTextField;
		private var _keyTF:QTextField;
		private var _bpmTF:QTextField;
		private var _genreTF:QTextField;
		private var _instrumentsTF:QTextField;
		private var _titleTF:QTextField;
		private var _authorTF:QTextField;
		private var _trackList:Array;
		private var _service:MyListService;

		
		
		/**
		 * Constructor.
		 * @param o Config data
		 */
		public function MyList(o:Object = null) {
			super(_TAB_ID, PanelCommon.BACK_TYPE_BLUE_2, o);
			
			// create lists
			_songList = new Array();
			_trackList = new Array();
			
			// add graphics
			_headerBtn = new Button({alpha:0, skin:new Embeds.tabMyListFrontBD(), textOutFilters:Filters.tabMyListHeader, textOverFilters:Filters.tabMyListHeader, textPressFilters:Filters.tabMyListHeader, text:'My List'}, Button.TYPE_NOSCALE_BUTTON);
			_headerFixBM = new QBitmap({embed:new Embeds.tabMyListFixBD(), x:_HEADER_X});
			_userTF = new QTextField({x:6 + 0, y:7, width:128, autoSize:TextFieldAutoSize.LEFT, defaultTextFormat:Formats.tabHeader, filters:Filters.tabMyListHeader, thickness:-150, sharpness:50, text:'User'});
			_authorTF = new QTextField({x:6 + 128, y:7, width:129, autoSize:TextFieldAutoSize.LEFT, defaultTextFormat:Formats.tabHeader, filters:Filters.tabMyListHeader, thickness:-150, sharpness:50, text:'Author'});
			_titleTF = new QTextField({x:6 + 257, y:7, width:128, autoSize:TextFieldAutoSize.LEFT, defaultTextFormat:Formats.tabHeader, filters:Filters.tabMyListHeader, thickness:-150, sharpness:50, text:'Title'});
			_instrumentsTF = new QTextField({x:6 + 385, y:7, width:80, autoSize:TextFieldAutoSize.LEFT, defaultTextFormat:Formats.tabHeader, filters:Filters.tabMyListHeader, thickness:-150, sharpness:50, text:'Instruments'});
			_genreTF = new QTextField({x:6 + 465, y:7, width:80, autoSize:TextFieldAutoSize.LEFT, defaultTextFormat:Formats.tabHeader, filters:Filters.tabMyListHeader, thickness:-150, sharpness:50, text:'Genre'});
			_bpmTF = new QTextField({x:6 + 545, y:7, width:30, autoSize:TextFieldAutoSize.LEFT, defaultTextFormat:Formats.tabHeader, filters:Filters.tabMyListHeader, thickness:-150, sharpness:50, text:'BPM'});
			_keyTF = new QTextField({x:6 + 575, y:7, width:30, autoSize:TextFieldAutoSize.LEFT, defaultTextFormat:Formats.tabHeader, filters:Filters.tabMyListHeader, thickness:-150, sharpness:50, text:'Key'});
			_descriptionTF = new QTextField({x:6 + 605, y:7, width:191, autoSize:TextFieldAutoSize.LEFT, defaultTextFormat:Formats.tabHeader, filters:Filters.tabMyListHeader, thickness:-150, sharpness:50, text:'Description'});
			_ratingTF = new QTextField({x:6 + 796, y:7, width:70, autoSize:TextFieldAutoSize.LEFT, defaultTextFormat:Formats.tabHeader, filters:Filters.tabMyListHeader, thickness:-150, sharpness:50, text:'Rating'});
			_toolsTF = new QTextField({x:6 + 866, y:7, width:100, autoSize:TextFieldAutoSize.LEFT, defaultTextFormat:Formats.tabHeader, filters:Filters.tabMyListHeader, thickness:-150, sharpness:50, text:'Tools'});
			
			// set visual properties
			$headerSpr.x = _HEADER_X;
			$badgeSpr.x = _HEADER_X;
			
			// add to display list
			addChildren($headerSpr, _headerBtn);
			addChildren($contentSpr, _headerFixBM, _userTF, _authorTF, _titleTF, _instrumentsTF, _genreTF, _bpmTF, _keyTF, _descriptionTF, _ratingTF, _toolsTF);
			
			// intro animation
			Tweener.addTween(_headerBtn, {delay:.1, time:Settings.STAGE_HEIGHT_CHANGE_TIME, alpha:1, y:-24, rounded:true, transition:'easeInOutQuad'});
			
			// add event listeners
			_headerBtn.addEventListener(MouseEvent.CLICK, _onHeaderClick, false, 0, true);
		}

		
		
		/**
		 * Set this tab visible.
		 * @param value Visibility flag
		 */
		override public function set visible(value:Boolean):void {
			// user is logged in, display My List
			_headerBtn.areEventsEnabled = !value;
			super.visible = value;
			
			if(value) {
				$contentHeight = $contentSpr.height;
				Tweener.addTween(this, {time:Settings.TAB_CHANGE_TIME, onComplete:function():void {
					dispatchEvent(new TabEvent(TabEvent.CHANGE_HEIGHT));
				}});
			}
		}

		
		
		public function postInit():void {
			try {
				_service = new MyListService();
				_service.url = App.connection.serverPath + App.connection.configService.myListRequestURL;
				_service.addEventListener(MyListEvent.REQUEST_DONE, _onRequestDone, false, 0, true);
				_service.request();
			}
			catch(err:Error) {
				Logger.error(sprintf('Could not get My List:\n%s', err.message));
			}
		}

		
		
		private function _onHeaderClick(event:MouseEvent):void {
			if(App.connection.configService.isConnecting) {
				// config is not yet loaded, don't allow to display My List
				App.messageModal.show({title:'My List', description:'Server hasn\'t yet returned some required information.\nPlease wait few seconds and try again.', buttons:MessageModal.BUTTONS_OK});
				return;
			}
			if(!App.connection.coreUserLoginStatus) {
				// user is not logged in, don't allow him to display My List
				App.messageModal.show({title:'My List', description:'You have to log in to use the My List.', buttons:MessageModal.BUTTONS_OK});
				return;
			}
			if(!_isListFilled) {
				// list not filled yet
				App.messageModal.show({title:'My List', description:'Server has not yet returned any data for My List table.\nPlease wait few seconds and try again.', buttons:MessageModal.BUTTONS_OK});
				return;
			}
			if(!$isListNotEmpty) {
				// list empty
				App.messageModal.show({title:'My List', description:'You\'ve got nothing in your list.', buttons:MessageModal.BUTTONS_OK});
				return;
			}
			if(!visible) dispatchEvent(new TabEvent(TabEvent.ACTIVATE));
		}

		
		
		private function _onRequestDone(event:MyListEvent):void {
			if(_isListFilled) throw new Error('My List already filled.');
			else {
				try {
					var tl:int = event.trackList.length;
					var sl:int = event.songList.length;
					var my:Number = _SUBTAB_Y;
					
					Logger.info(sprintf('Filling My list (%u tracks, %u songs)', tl, sl));
					if(sl > 0 || tl > 0) badgeLabel = sprintf('%u+%u', tl, sl);
					else badgeLabel = '';
					
					// add solo tracks
					for each(var j:TrackData in event.trackList) {
						Logger.info(sprintf('Adding track to My List (trackID=%u, trackTitle=%s)', j.trackID, j.trackTitle));
						
						var t:ListTrackRow = new ListTrackRow(j, {x:6, y:my});
						$contentSpr.addChild(t);
						my += t.height;
						
						_trackList.push(t);
					}
								
					// add songs
					for each(var i:SongData in event.songList) {
						Logger.info(sprintf('Adding song to My List (songID=%u, songTitle=%s)', i.songID, i.songTitle));
						
						var st:ListSongRow = new ListSongRow(i, {x:6, y:my});
						$contentSpr.addChild(st);
						my += st.height;
						
						_songList.push(st);
					}
				}
				catch(err:Error) {
					Logger.warn(sprintf('Problem loading My List (%s)', err.message));
				}
				
				// prevent re-filling
				_isListFilled = true;
				$isListNotEmpty = (_trackList.length > 0 || _songList.length > 0);
			}
		}
	}
}
