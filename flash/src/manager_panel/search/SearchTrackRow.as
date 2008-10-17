package manager_panel.search {
	import application.App;
	
	import config.Embeds;
	import config.Filters;
	import config.Formats;
	import config.Settings;
	
	import controls.Button;
	import controls.Thumbnail;
	
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
		private var _instrumentThumb:Thumbnail;

		
		
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
			_authorTF = new QTextField({x:42, y:2, width:$CONTENT_WIDTH - 47, defaultTextFormat:Formats.searchResultsPanelTrackRowAuthor, text:author, mouseEnabled:false, height:14});
			_titleTF = new QTextField({x:42, y:12, width:$CONTENT_WIDTH - 47, defaultTextFormat:Formats.searchResultsPanelTrackRowTitle, filters:Filters.searchResultsPanelTrackRowTitle, text:trackTitle, mouseEnabled:false, height:17});
			
			// add siblings badge
			_siblingsTF = new QTextField({y:32, defaultTextFormat:Formats.searchResultsPanelRowBadge, filters:Filters.searchResultsPanelTrackRowBadge, text:t, autoSize:TextFieldAutoSize.LEFT, sharpness:50, thickness:-100, mouseEnabled:false});
			_siblingsSBM = new ScaleBitmap((new Embeds.subpanelSearchPanel2CountBD() as Bitmap).bitmapData);
			_siblingsSBM.scale9Grid = new Rectangle(8, 0, 2, 19);
			_siblingsSBM.width = Math.round(_siblingsTF.textWidth) + 11;
			_siblingsSBM.x = $CONTENT_WIDTH - Math.round(_siblingsTF.textWidth) - 119;
			_siblingsSBM.y = 30;
			_siblingsTF.x = _siblingsSBM.x + 3;
			
			// add star rating
			_starRatingBM = new QBitmap({x:190, y:34});
			_starRatingBM.bitmapData = Bitmapping.crop((new Embeds.subpanelTrackHeaderStarRatingBD() as Bitmap).bitmapData, 0, Math.round(td.trackRating) * 11, 60, 11);
			
			// add edit button
			_editBtn = new Button({x:254, y:32, width:33, height:14, skin:new Embeds.buttonSearchTrackBD(), icon:new Embeds.glyphEditNanoBD(), textOutFilters:Filters.buttonSearchTrackLabel, textOverFilters:Filters.buttonSearchTrackLabel, textPressFilters:Filters.buttonSearchTrackLabel, textOutFormat:Formats.buttonSmall, textOverFormat:Formats.buttonSmall, textPressFormat:Formats.buttonSmall, textOutOffsY:-3, textOverOffsY:-3, textPressOffsY:-2});

			// add avatar
			_instrumentThumb = new Thumbnail({x:4, y:3, mouseEnabled:false});
			
			// add to display list
			addChildren($contentSpr, _instrumentThumb, _siblingsSBM, _siblingsTF, _authorTF, _titleTF, _starRatingBM, _editBtn);
			
			// add event listeners
			_editBtn.addEventListener(MouseEvent.CLICK, _onEditClick, false, 0, true);
			
			// get instrument description and icon
			var instrumentIconURL:String;
			try {
				instrumentIconURL = App.connection.instrumentsService.byID(td.trackInstrumentID).instrumentIconURL;
			}
			catch(err2:Error) {
			}
			
			// load instrument thumbnail
			_instrumentThumb.load(App.connection.serverPath + instrumentIconURL);
		}

		
		
		/**
		 * Destructor.
		 */
		override public function destroy():void {
			// remove event listeners
			_editBtn.removeEventListener(MouseEvent.CLICK, _onEditClick);
			
			// remove avatar
			_instrumentThumb.destroy();
			
			// remove from display list
			removeChildren($contentSpr, _instrumentThumb, _siblingsSBM, _siblingsTF, _authorTF, _titleTF, _starRatingBM, _editBtn);
			
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
