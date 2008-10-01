package manager_panel.search {
	import application.App;
	
	import config.Embeds;
	import config.Filters;
	import config.Formats;
	import config.Settings;
	
	import controls.Button;
	
	import manager_panel.search.SearchRowCommon;
	
	import remoting.data.TrackData;
	
	import de.popforge.utils.sprintf;
	
	import org.bytearray.display.ScaleBitmap;
	import org.vancura.graphics.Bitmapping;
	import org.vancura.graphics.QBitmap;
	import org.vancura.graphics.QTextField;
	import org.vancura.util.addChildren;
	import org.vancura.util.removeChildren;
	
	import flash.display.Bitmap;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.text.TextFieldAutoSize;	

	
	
	/**
	 * Track row.
	 *
	 * @author Vaclav Vancura (http://vaclav.vancura.org)
	 * @since Jul 11, 2008
	 */
	public class SearchTrackRow extends SearchRowCommon {

		
		
		private var _data:TrackData;
		private var _siblingsSBM:ScaleBitmap;
		private var _siblingsTF:QTextField;
		private var _authorTF:QTextField;
		private var _titleTF:QTextField;
		private var _starRatingBM:QBitmap;
		private var _editBtn:Button;

		
		
		/**
		 * Constructor.
		 * @param c Sprite config Object
		 * @param sd Track data
		 */
		public function SearchTrackRow(td:TrackData, c:Object = null) {
			super(Settings.TYPE_TRACK, c);
			_data = td;
			
			var t:String = sprintf('%u SONG', td.trackSongsCount);
			if(td.trackSongsCount > 1 || td.trackSongsCount == 0) t += 'S';
			var author:String = td.trackAuthor;
			var trackTitle:String = td.trackTitle;
			if(author == '') author = '(No author)';
			if(trackTitle == '') trackTitle = '(No title)';
			
			// add text boxes
			_authorTF = new QTextField({x:57, y:2, width:126, defaultTextFormat:Formats.searchResultsPanelTrackRowAuthor, text:author, mouseEnabled:false, height:14});
			_titleTF = new QTextField({x:57, y:12, width:126, defaultTextFormat:Formats.searchResultsPanelTrackRowTitle, filters:Filters.searchResultsPanelTrackRowTitle, text:trackTitle, mouseEnabled:false, height:17});
			
			// add siblings badge
			_siblingsTF = new QTextField({x:8, y:8, defaultTextFormat:Formats.searchResultsPanelRowBadge, filters:Filters.searchResultsPanelTrackRowBadge, text:t, autoSize:TextFieldAutoSize.LEFT, sharpness:50, thickness:-100, mouseEnabled:false});
			_siblingsSBM = new ScaleBitmap((new Embeds.subpanelSearchPanel2CountBD() as Bitmap).bitmapData);
			_siblingsSBM.scale9Grid = new Rectangle(8, 0, 2, 19);
			_siblingsSBM.width = Math.round(_siblingsTF.textWidth) + 11;
			_siblingsSBM.x = 5;
			_siblingsSBM.y = 6;
			
			// add star rating
			_starRatingBM = new QBitmap({x:188, y:9});
			_starRatingBM.bitmapData = Bitmapping.crop((new Embeds.subpanelTrackHeaderStarRatingBD() as Bitmap).bitmapData, 0, Math.round(td.trackRating) * 11, 60, 11);
			
			// add edit button
			_editBtn = new Button({x:251, y:8, width:33, height:14, skin:new Embeds.buttonSearchTrackBD(), icon:new Embeds.glyphEditNanoBD(), textOutFilters:Filters.buttonSearchTrackLabel, textOverFilters:Filters.buttonSearchTrackLabel, textPressFilters:Filters.buttonSearchTrackLabel, textOutFormat:Formats.buttonSmall, textOverFormat:Formats.buttonSmall, textPressFormat:Formats.buttonSmall, textOutOffsY:-3, textOverOffsY:-3, textPressOffsY:-2});
			
			// add to display list
			addChildren($contentSpr, _siblingsSBM, _siblingsTF, _authorTF, _titleTF, _starRatingBM, _editBtn);
			
			// add event listeners
			_editBtn.addEventListener(MouseEvent.CLICK, _onEditClick, false, 0, true);
		}

		
		
		/**
		 * Destructor.
		 */
		override public function destroy():void {
			// remove event listeners
			_editBtn.removeEventListener(MouseEvent.CLICK, _onEditClick);
			
			// remove from display list
			removeChildren($contentSpr, _siblingsSBM, _siblingsTF, _authorTF, _titleTF, _starRatingBM, _editBtn);
			
			// destroy components
			_editBtn.destroy();
			
			super.destroy();
		}

		
		
		/**
		 * Get track data.
		 * @return Track data
		 */
		public function get data():TrackData {
			return _data;
		}

		
		
		/**
		 * Edit button click event handler.
		 * @param event Event data
		 */
		private function _onEditClick(event:MouseEvent):void {
			App.editor.addTrack(_data.trackID);
		}
	}
}
