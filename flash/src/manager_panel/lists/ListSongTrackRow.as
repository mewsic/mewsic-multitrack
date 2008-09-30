package manager_panel.lists {
	import manager_panel.lists.ListSongTrackCommon;
	import flash.display.Bitmap;
	import flash.events.MouseEvent;
	import flash.text.TextFieldAutoSize;
	
	import org.vancura.controls.Button;
	import org.vancura.graphics.Bitmapping;
	import org.vancura.graphics.QBitmap;
	import org.vancura.graphics.QTextField;
	import org.vancura.util.addChildren;
	import org.vancura.util.removeChildren;
	
	import application.App;
	
	import config.Embeds;
	import config.Filters;
	import config.Formats;
	
	import remoting.data.TrackData;	

	
	
	/**
	 * Song track row.
	 *
	 * @author Vaclav Vancura (http://vaclav.vancura.org)
	 * @since Jul 07, 2008
	 */
	public class ListSongTrackRow extends ListSongTrackCommon {

		
		
		private var _userTF:QTextField;
		private var _descriptionTF:QTextField;
		private var _keyTF:QTextField;
		private var _bpmTF:QTextField;
		private var _genreTF:QTextField;
		private var _instrumentsTF:QTextField;
		private var _titleTF:QTextField;
		private var _authorTF:QTextField;
		private var _editBtn:Button;
//		private var _playBtn:Button;
		private var _starRatingBM:QBitmap;
		private var _data:TrackData;

		
		
		/**
		 * Constructor.
		 * @param sd Song data
		 * @param o QSprite config
		 */
		public function ListSongTrackRow(sd:TrackData, o:Object = null) {
			super(o);
			_data = sd;
			
			// get genre name
			var genreName:String;
			try { 
				genreName = App.connection.genresService.byID(_data.trackGenreID).genreName; 
			}
			catch(err:Error) { 
				genreName = 'Unknown genre'; 
			}
			
			// add textfields
			_userTF = new QTextField({x:2, width:123, defaultTextFormat:Formats.tabSongTrackL, text:_data.trackUserNickname, multiline:false, autoSize:TextFieldAutoSize.CENTER});
			_authorTF = new QTextField({x:130, width:124, defaultTextFormat:Formats.tabSongTrackL, text:_data.trackAuthor, multiline:false, autoSize:TextFieldAutoSize.CENTER});
			_titleTF = new QTextField({x:259, width:123, defaultTextFormat:Formats.tabSongTrackL, text:_data.trackTitle, multiline:false, autoSize:TextFieldAutoSize.CENTER});
			_instrumentsTF = new QTextField({x:387, width:75, defaultTextFormat:Formats.tabSongTrackL, text:App.connection.instrumentsService.byID(_data.trackInstrumentID).instrumentName, multiline:false, autoSize:TextFieldAutoSize.CENTER});
			_genreTF = new QTextField({x:467, width:75, defaultTextFormat:Formats.tabSongTrackL, text:genreName, multiline:false, autoSize:TextFieldAutoSize.CENTER});
			_bpmTF = new QTextField({x:543, width:26, defaultTextFormat:Formats.tabSongTrackC, text:_data.trackBPM, multiline:false, autoSize:TextFieldAutoSize.CENTER});
			_keyTF = new QTextField({x:576, width:26, defaultTextFormat:Formats.tabSongTrackC, text:_data.trackKey, multiline:false, autoSize:TextFieldAutoSize.CENTER});
			_descriptionTF = new QTextField({x:607, width:242, defaultTextFormat:Formats.tabSongTrackL, text:_data.trackDescription, multiline:false, autoSize:TextFieldAutoSize.CENTER});
			
			// add buttons
			_editBtn = new Button({x:927, y:1, width:33, height:14, skin:new Embeds.buttonMyListStandardBD(), icon:new Embeds.glyphEditNanoBD(), textOutFilters:Filters.tabButtonText, textOverFilters:Filters.tabButtonText, textPressFilters:Filters.tabButtonText, textOutFormat:Formats.buttonSmall, textOverFormat:Formats.buttonSmall, textPressFormat:Formats.buttonSmall, textOutOffsY:-3, textOverOffsY:-3, textPressOffsY:-2});
//			_playBtn = new Button({x:909, y:1, width:23, height:14, skin:new Embeds.buttonMyListTrackBD(), icon:new Embeds.glyphPlayNanoBD(), textOutFilters:Filters.tabButtonTrack, textOverFilters:Filters.tabButtonTrack, textPressFilters:Filters.tabButtonTrack, textOutFormat:Formats.buttonSmall, textOverFormat:Formats.buttonSmall, textPressFormat:Formats.buttonSmall, textOutOffsY:-3, textOverOffsY:-3, textPressOffsY:-2});
			
			// add star rating
			_starRatingBM = new QBitmap({x:857, y:2});
			_starRatingBM.bitmapData = Bitmapping.crop((new Embeds.subpanelSongTrackStarRatingBD() as Bitmap).bitmapData, 0, Math.round(_data.trackRating) * 10, 59, 10);
			
			// add to display list
			addChildren($contentSpr, _userTF, _authorTF, _titleTF, _instrumentsTF, _genreTF, _bpmTF, _keyTF, _descriptionTF, _editBtn, /*_playBtn, */ _starRatingBM);
			addChildren(this, $contentSpr);
			
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
			removeChildren($contentSpr, _userTF, _authorTF, _titleTF, _instrumentsTF, _genreTF, _bpmTF, _keyTF, _descriptionTF, _editBtn, /*_playBtn, */ _starRatingBM);
			removeChildren(this, $contentSpr);
			
			super.destroy();
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
