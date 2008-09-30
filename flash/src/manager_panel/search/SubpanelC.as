package manager_panel.search {
	import flash.events.MouseEvent;
	import flash.text.TextFieldAutoSize;
	
	import org.osflash.thunderbolt.Logger;
	import org.vancura.graphics.QBitmap;
	import org.vancura.graphics.QTextField;
	import org.vancura.util.addChildren;
	
	import de.popforge.utils.sprintf;
	
	import config.Embeds;
	import config.Filters;
	import config.Formats;
	
	import manager_panel.search.SearchTrackRow;
	
	import remoting.data.TrackData;	

	
	
	/**
	 * Subpanel C.
	 *
	 * @author Vaclav Vancura (http://vaclav.vancura.org)
	 * @since Jul 12, 2008
	 */
	public class SubpanelC extends SubpanelCommon {

		
		
		private var _trackItems:Array;
		private var _headerBackBM:QBitmap;
		private var _headerTitleTF:QTextField;
		private var _rowList:Array;
		private var _currentType:String;

		
		
		/**
		 * Constructor.
		 * @param height Container height
		 * @param c Sprite config Object
		 */
		public function SubpanelC(height:uint, c:Object = null) {
			super(height, c);
			
			// add header
			_headerBackBM = new QBitmap({embed:new Embeds.subpanelSearchHeaderBackBD()});
			_headerTitleTF = new QTextField({x:13, y:6, width:255, defaultTextFormat:Formats.searchResultsPanelHeader, filters:Filters.searchResultsPanelHeader, autoSize:TextFieldAutoSize.LEFT, sharpness:50});
			
			// add to display object
			addChildren($headerSpr, _headerBackBM, _headerTitleTF);
		}
		
		
		
		/**
		 * Change search mode.
		 * @param t Search mode
		 */
		public function set currentType(t:String):void {
			Logger.debug(sprintf('Switchning subpanel C search mode to %s', t));
			
			_currentType = t;
			clean();
			fill();
			
			_headerTitleTF.text = 'Song results';
		}

		
		
		/**
		 * Set data.
		 * @param si Song items
		 * @param title Title
		 */
		public function setData(ti:Array, title:String):void {
			_trackItems = ti;
			_headerTitleTF.text = title;
		}

		
		
		/**
		 * Fill content with data.
		 */
		public function fill():void {
			if($isFilled) throw new Error('Subpanel C already filled. Clean it first.');
			else {
				var sy:uint = 0;
				try {
					// current mode is tracks, parse data
					Logger.info('Adding tracks to listing');
					
					for each(var ti:TrackData in _trackItems) {
						Logger.info(sprintf('  *  Adding (trackID=%u, trackTitle=%s)', ti.trackID, ti.trackTitle));
						var trow:SearchTrackRow = new SearchTrackRow(ti, {y:sy});
						$contentSpr.addChild(trow);
						trow.addEventListener(MouseEvent.CLICK, _onRowClick, false, 0, true);
						sy += trow.height;
						_rowList.push(trow);
					}
				}
				catch(err:Error) {
					Logger.warn(sprintf('Error adding subpanel C row (%s)', err.message));
				}
				
				$isFilled = true;
				setStatus(STATUS_RESULTS);
			}
		}
		
		
		
		/**
		 * Clean.
		 */
		public function clean():void {
			Logger.debug('Cleaning current subpanel C rows');
			for each(var row:* in _rowList) {
				try{
					$contentSpr.removeChild(row);
					row.removeEventListener(MouseEvent.CLICK, _onRowClick);
					row.destroy();
				}
				catch(err:Error) {
					Logger.error(sprintf('Error cleaning subpanel C row (%s)', err.message));
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
	}
}
