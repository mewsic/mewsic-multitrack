package manager_panel.search {
	import application.App;
	
	import config.Embeds;
	import config.Filters;
	import config.Formats;
	import config.Settings;
	
	import controls.Button;
	
	import manager_panel.search.SearchSongRow;
	import manager_panel.search.SearchTrackRow;
	
	import remoting.data.SongData;
	import remoting.data.TrackData;
	
	import de.popforge.utils.sprintf;
	
	import org.osflash.thunderbolt.Logger;
	import org.vancura.graphics.QBitmap;
	import org.vancura.graphics.QTextField;
	import org.vancura.util.addChildren;
	
	import flash.events.MouseEvent;
	import flash.text.TextFieldAutoSize;		

	
	
	/**
	 * Subpanel A.
	 *
	 * @author Vaclav Vancura (http://vaclav.vancura.org)
	 * @since Jul 12, 2008
	 */
	public class SubpanelA extends SubpanelCommon {

		
		
		private var _trackItems:Array;
		private var _songItems:Array;
		private var _headerBackBM:QBitmap;
		private var _headerTitleTF:QTextField;
		private var _headerSwitchBtn:Button;
		private var _rowList:Array;
		private var _currentType:String;

		
		
		/**
		 * Constructor.
		 * @param height Container height
		 * @param c Sprite config Object
		 */
		public function SubpanelA(height:uint, c:Object = null) {
			super(height, c);
			
			// add header
			_headerBackBM = new QBitmap({embed:new Embeds.subpanelSearchHeaderBackBD()});
			_headerTitleTF = new QTextField({x:13, y:6, defaultTextFormat:Formats.searchResultsPanelHeader, filters:Filters.searchResultsPanelHeader, autoSize:TextFieldAutoSize.LEFT, sharpness:50});
			_headerSwitchBtn = new Button({y:4, width:100, height:20, skin:new Embeds.buttonMenuBD(), textOutFormat:Formats.searchResultsPanelMenuOut, textOutFilters:Filters.searchResultsPanelMenuOut, textOverFormat:Formats.searchResultsPanelMenuOver, textOverFilters:Filters.searchResultsPanelMenuOver, textPressFormat:Formats.searchResultsPanelMenuOver, textPressFilters:Filters.searchResultsPanelMenuOver, textOutOffsY:-2, textOverOffsY:-2, textPressOffsY:-1});
			
			// add to display object
			addChildren($headerSpr, _headerBackBM, _headerTitleTF, _headerSwitchBtn);
			
			// add event listeners
			_headerSwitchBtn.addEventListener(MouseEvent.CLICK, _onHeaderSwitchClick, false, 0, true);
		}

		
		
		/**
		 * Change search mode.
		 * @param t Search mode
		 */
		public function set currentType(t:String):void {
			Logger.debug(sprintf('Switchning subpanel A search mode to %s', t));
			
			dispatchEvent(new SubpanelEvent(SubpanelEvent.RESET));
			
			_currentType = t;
			
			fill();
			
			var tl:int = (_trackItems == null) ? 0 : _trackItems.length;
			var sl:int = (_songItems == null) ? 0 : _songItems.length;
			
			_headerTitleTF.text = (_currentType == Settings.TYPE_SONG) ? 'Song results' : 'Track results';
			_headerSwitchBtn.x = _headerTitleTF.textWidth + 13 + 10;
			_headerSwitchBtn.width = 300;
			_headerSwitchBtn.text = sprintf('%s (%s)', (_currentType == Settings.TYPE_SONG) ? 'SWITCH TO TRACKS' : 'SWITCH TO SONGS', App.getPlural((_currentType == Settings.TYPE_SONG) ? tl : sl, '%u VERSION', '%u VERSIONS'));
			
			_headerSwitchBtn.width = _headerSwitchBtn.textWidth + 16;
			
			dispatchEvent(new SubpanelEvent(SubpanelEvent.REFRESH));
		}
		
		
		
		/**
		 * Set data.
		 * @param si Song items
		 * @param title Title
		 */
		public function setData(si:Array, ti:Array):void {
			_songItems = si;
			_trackItems = ti;
		}

		
		
		/**
		 * Fill content with data.
		 */
		public function fill():void {
			if($isFilled) throw new Error('Subpanel A already filled. Clean it first.');
			else {
				var sy:uint = 0;
				try {
					if(_currentType == Settings.TYPE_SONG) {
						// current mode is songs, parse data
						Logger.info('Adding songs to listing');
						
						if(_songItems != null) {
							for each(var si:SongData in _songItems) {
								Logger.info(sprintf('  *  Adding (songID=%u, songTitle=%s)', si.songID, si.songTitle));
								var srow:SearchSongRow = new SearchSongRow(si, {y:sy});
								$contentSpr.addChild(srow);
								srow.addEventListener(MouseEvent.CLICK, _onRowClick, false, 0, true);
								sy += srow.height;
								_rowList.push(srow);
							}
						}
					}
					else {
						// current mode is tracks, parse data
						Logger.info('Adding tracks to listing');
						
						if(_trackItems != null) {
							for each(var ti:TrackData in _trackItems) {
								Logger.info(sprintf('  *  Adding (trackID=%u, trackTitle=%s)', ti.trackID, ti.trackTitle));
								var trow:SearchTrackRow = new SearchTrackRow(ti, {y:sy});
								$contentSpr.addChild(trow);
								trow.addEventListener(MouseEvent.CLICK, _onRowClick, false, 0, true);
								sy += trow.height;
								_rowList.push(trow);
							}
						}
					}
				}
				catch(err:Error) {
					Logger.warn(sprintf('Error adding subpanel A row (%s)', err.message));
				}
				
				$isFilled = true;
				setStatus(STATUS_RESULTS);
			}
		}

		
		
		/**
		 * Clean.
		 */
		public function clean():void {
			Logger.debug('Cleaning current subpanel A rows');
			for each(var row:* in _rowList) {
				try {
					$contentSpr.removeChild(row);
					row.removeEventListener(MouseEvent.CLICK, _onRowClick);
					row.destroy();
				}
				catch(err:Error) {
					Logger.error(sprintf('Error cleaning subpanel A row (%s)', err.message));
				}
			}
			_rowList = new Array();
			
			$isFilled = false;
			setStatus(STATUS_INFO);
		}

		
		
		/**
		 * Row click event handler.
		 * @param event Event data
		 */
		private function _onRowClick(event:MouseEvent):void {
			dispatchEvent(new SubpanelEvent(SubpanelEvent.ROW_SELECT, false, false, {data:event.currentTarget.data, type:event.currentTarget.type}));
		}

		
		
		/**
		 * Header switch event handler.
		 * @param event Event data
		 */
		private function _onHeaderSwitchClick(event:MouseEvent):void {
			currentType = (_currentType == Settings.TYPE_SONG) ? Settings.TYPE_TRACK : Settings.TYPE_SONG;
		}
	}
}
