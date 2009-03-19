package manager_panel.lists {
	import application.App;
	
	import config.Embeds;
	import config.Filters;
	import config.Formats;
	
	import controls.Button;
	
	import remoting.data.InstrumentData;
	import remoting.data.TrackData;
	
	import org.vancura.graphics.Bitmapping;
	import org.vancura.graphics.Drawing;
	import org.vancura.graphics.QBitmap;
	import org.vancura.graphics.QSprite;
	import org.vancura.graphics.QTextField;
	import org.vancura.util.addChildren;
	import org.vancura.util.removeChildren;
	
	import flash.display.Bitmap;
	import flash.events.MouseEvent;
	import flash.text.TextFieldAutoSize;	

	
	
	/**
	 * Track row.
	 * 
	 * @author Vaclav Vancura (http://vaclav.vancura.org)
	 * @since Jul 10, 2008
	 */
	public class ListTrackRow extends QSprite {

		
		
		private static const _CONTENT_WIDTH:Number = 966;
		private static const _CONTENT_HEIGHT:Number = 25;
		private var _backSBM:QBitmap;
		private var _maskSpr:QSprite;
		private var _contentSpr:QSprite;
		private var _userTF:QTextField;
		private var _descriptionTF:QTextField;
		private var _keyTF:QTextField;
		private var _bpmTF:QTextField;
		private var _genreTF:QTextField;
		private var _instrumentsTF:QTextField;
		private var _titleTF:QTextField;
		private var _authorTF:QTextField;
//		private var _killBtn:Button;
//		private var _playBtn:Button;
		private var _editBtn:Button;
		private var _starRatingBM:QBitmap;
		private var _data:TrackData;

		
		
		/**
		 * Constructor.
		 * @param data Song data
		 * @param o QSprite config
		 */
		public function ListTrackRow(td:TrackData, o:Object = null) {
			_data = td;
			super(o);
			
			// get genre name
			var genreName:String = 'Unknown';
			
			// add background
			_backSBM = new QBitmap({embed: new Embeds.subpanelMyListTrackBackBD});
			_maskSpr = new QSprite();
			_contentSpr = new QSprite({mask:_maskSpr});
			
			// add textfields
			_userTF = new QTextField({x:2, y:3, width:123, defaultTextFormat:Formats.tabTrackHeaderL, text:_data.trackUserNickname, multiline:false, filters:Filters.tabTrackHeader, autoSize:TextFieldAutoSize.CENTER});
			_authorTF = new QTextField({x:130, y:3, width:124, defaultTextFormat:Formats.tabTrackHeaderL, text:_data.trackAuthor, multiline:false, filters:Filters.tabTrackHeader, autoSize:TextFieldAutoSize.CENTER});
			_titleTF = new QTextField({x:259, y:3, width:123, defaultTextFormat:Formats.tabTrackHeaderL, text:_data.trackTitle, multiline:false, filters:Filters.tabTrackHeader, autoSize:TextFieldAutoSize.CENTER});
			_instrumentsTF = new QTextField({x:387, y:3, width:75, defaultTextFormat:Formats.tabTrackHeaderL, text:App.connection.instrumentsService.byID(_data.trackInstrumentID).instrumentName, multiline:false, filters:Filters.tabTrackHeader, autoSize:TextFieldAutoSize.CENTER});
			_genreTF = new QTextField({x:467, y:3, width:75, defaultTextFormat:Formats.tabTrackHeaderL, text:genreName, multiline:false, filters:Filters.tabTrackHeader, autoSize:TextFieldAutoSize.CENTER});
			_bpmTF = new QTextField({x:546, y:3, width:26, defaultTextFormat:Formats.tabTrackHeaderC, text:_data.trackBPM, multiline:false, filters:Filters.tabTrackHeader, autoSize:TextFieldAutoSize.CENTER});
			_keyTF = new QTextField({x:576, y:3, width:26, defaultTextFormat:Formats.tabTrackHeaderC, text:_data.trackKey, multiline:false, filters:Filters.tabTrackHeader, autoSize:TextFieldAutoSize.CENTER});
			_descriptionTF = new QTextField({x:607, y:3, width:242, defaultTextFormat:Formats.tabTrackHeaderL, text:_data.trackDescription, multiline:false, filters:Filters.tabTrackHeader, autoSize:TextFieldAutoSize.CENTER});
			
			// add buttons
			_editBtn = new Button({x:927, y:5, width:33, height:14, skin:new Embeds.buttonMyListStandardBD(), icon:new Embeds.glyphEditNanoBD(), textOutFilters:Filters.tabButtonText, textOverFilters:Filters.tabButtonText, textPressFilters:Filters.tabButtonText, textOutFormat:Formats.buttonSmall, textOverFormat:Formats.buttonSmall, textPressFormat:Formats.buttonSmall, textOutOffsY:-3, textOverOffsY:-3, textPressOffsY:-2});
//			_playBtn = new Button({x:909, y:5, width:23, height:14, skin:new Embeds.buttonMyListTrackBD(), icon:new Embeds.glyphPlayNanoBD(), textOutFilters:Filters.tabButtonTrack, textOverFilters:Filters.tabButtonTrack, textPressFilters:Filters.tabButtonTrack, textOutFormat:Formats.buttonSmall, textOverFormat:Formats.buttonSmall, textPressFormat:Formats.buttonSmall, textOutOffsY:-3, textOverOffsY:-3, textPressOffsY:-2});
//			_killBtn = new Button({x:935-13, y:5, width:23+13, height:14, skin:new Embeds.buttonMyListStandardBD(), icon:new Embeds.glyphKillNanoBD(), textOutFilters:Filters.tabButtonText, textOverFilters:Filters.tabButtonText, textPressFilters:Filters.tabButtonText, textOutFormat:Formats.buttonSmall, textOverFormat:Formats.buttonSmall, textPressFormat:Formats.buttonSmall, textOutOffsY:-3, textOverOffsY:-3, textPressOffsY:-2});
			
			// add star rating
			_starRatingBM = new QBitmap({x:857, y:6});
			_starRatingBM.bitmapData = Bitmapping.crop((new Embeds.subpanelTrackHeaderStarRatingBD() as Bitmap).bitmapData, 0, Math.round(_data.trackRating) * 11, 60, 11);

			// drawing			
			Drawing.drawRect(_maskSpr, 0, 0, _CONTENT_WIDTH, _backSBM.height, 0xFF0000, .2);
			
			// add to display list
			addChildren(_contentSpr, _userTF, _authorTF, _titleTF, _instrumentsTF, _genreTF, _bpmTF, _keyTF, _descriptionTF, _editBtn, /*_playBtn, _killBtn, */_starRatingBM);
			addChildren(this, _backSBM, _contentSpr, _maskSpr);
			
			// add event listeners
			_editBtn.addEventListener(MouseEvent.CLICK, _onEditClick, false, 0, true);
//			_killBtn.addEventListener(MouseEvent.CLICK, _onKillClick, false, 0, true);
		}

		
		
		/**
		 * Destructor.
		 */
		public function destroy():void {
			// remove event listeners
			_editBtn.removeEventListener(MouseEvent.CLICK, _onEditClick);
//			_killBtn.removeEventListener(MouseEvent.CLICK, _onKillClick);
			
			// remove from display list
			removeChildren(_contentSpr, _userTF, _authorTF, _titleTF, _instrumentsTF, _genreTF, _bpmTF, _keyTF, _descriptionTF, _editBtn, /*_playBtn, _killBtn,*/ _starRatingBM);
			removeChildren(this, _backSBM, _contentSpr, _maskSpr);
		}

		
		
		/**
		 * Get content height.
		 * @return Content height
		 */
		override public function get height():Number {
			return _CONTENT_HEIGHT;
		}

		
		
		/**
		 * Edit button click event handler.
		 * @param event Event data
		 */
		private function _onEditClick(event:MouseEvent):void {
			App.editor.addTrack(_data.trackID);
		}

		
		
		/**
		 * Kill button click event handler.
		 * @param event Event data
		 */
//		private function _onKillClick(event:MouseEvent):void {
//			Logger.debug(sprintf('Killing track row (trackID=%u, trackTitle=%s', _data.trackID, _data.trackTitle));
//		}
	}
}
