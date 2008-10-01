package manager_panel.lists {
	import application.App;
	
	import config.Embeds;
	import config.Filters;
	import config.Formats;
	
	import controls.Button;
	
	import remoting.data.SongData;
	import remoting.data.TrackData;
	
	import de.popforge.utils.sprintf;
	
	import org.bytearray.display.ScaleBitmap;
	import org.osflash.thunderbolt.Logger;
	import org.vancura.graphics.Bitmapping;
	import org.vancura.graphics.Drawing;
	import org.vancura.graphics.QBitmap;
	import org.vancura.graphics.QSprite;
	import org.vancura.graphics.QTextField;
	import org.vancura.util.addChildren;
	import org.vancura.util.removeChildren;
	
	import flash.display.Bitmap;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.text.TextFieldAutoSize;	

	
	
	/**
	 * Song row.
	 * 
	 * @author Vaclav Vancura (http://vaclav.vancura.org)
	 * @since Jul 07, 2008
	 */
	public class ListSongRow extends QSprite {

		
		
		private static const _CONTENT_WIDTH:Number = 966;
		private static const _HEADER_HEIGHT:Number = 26;
		private var _backSBM:ScaleBitmap;
		private var _trackList:Array = new Array();
		private var _contentSpr:QSprite;
		private var _maskSpr:QSprite;
		private var _headerSpr:QSprite;
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
		private var _data:SongData;

		
		
		/**
		 * Constructor.
		 * @param data Song data
		 * @param o QSprite config
		 */
		public function ListSongRow(sd:SongData, o:Object = null) {
			super(o);
			_data = sd;
			
			// get genre name
			var genreName:String;
			try { 
				genreName = App.connection.genresService.byID(_data.songGenreID).genreName; 
			}
			catch(err:Error) { 
				genreName = 'Unknown genre'; 
			}
			
			// add background
			_backSBM = new ScaleBitmap((new Embeds.subpanelMyListSongBackBD()).bitmapData);
			_backSBM.scale9Grid = new Rectangle(0, 26, 966, 53);
			
			// add header and content
			_maskSpr = new QSprite();
			_headerSpr = new QSprite({mask:_maskSpr});
			_contentSpr = new QSprite({y:_HEADER_HEIGHT});
			
			// add header textfields
			_userTF = new QTextField({x:2, y:3, width:123, defaultTextFormat:Formats.tabSongHeaderL, text:_data.songUserNickname, multiline:false, filters:Filters.tabSongHeader, autoSize:TextFieldAutoSize.CENTER});
			_authorTF = new QTextField({x:130, y:3, width:124, defaultTextFormat:Formats.tabSongHeaderL, text:_data.songAuthor, multiline:false, filters:Filters.tabSongHeader, autoSize:TextFieldAutoSize.CENTER});
			_titleTF = new QTextField({x:259, y:3, width:123, defaultTextFormat:Formats.tabSongHeaderL, text:_data.songTitle, multiline:false, filters:Filters.tabSongHeader, autoSize:TextFieldAutoSize.CENTER});
			_instrumentsTF = new QTextField({x:387, y:3, width:75, defaultTextFormat:Formats.tabSongHeaderL, text:_data.songInstrumentsCount, multiline:false, filters:Filters.tabSongHeader, autoSize:TextFieldAutoSize.CENTER});
			_genreTF = new QTextField({x:467, y:3, width:75, defaultTextFormat:Formats.tabSongHeaderL, text:genreName, multiline:false, filters:Filters.tabSongHeader, autoSize:TextFieldAutoSize.CENTER});
			_bpmTF = new QTextField({x:546, y:3, width:26, defaultTextFormat:Formats.tabSongHeaderC, text:_data.songBPM, multiline:false, filters:Filters.tabSongHeader, autoSize:TextFieldAutoSize.CENTER});
			_keyTF = new QTextField({x:576, y:3, width:26, defaultTextFormat:Formats.tabSongHeaderC, text:_data.songKey, multiline:false, filters:Filters.tabSongHeader, autoSize:TextFieldAutoSize.CENTER});
			_descriptionTF = new QTextField({x:607, y:3, width:242, defaultTextFormat:Formats.tabSongHeaderL, text:_data.songDescription, multiline:false, filters:Filters.tabSongHeader, autoSize:TextFieldAutoSize.CENTER});
			
			// add header buttons
			_editBtn = new Button({x:927, y:5, width:33, height:14, skin:new Embeds.buttonMyListStandardBD(), icon:new Embeds.glyphEditNanoBD(), textOutFilters:Filters.tabButtonText, textOverFilters:Filters.tabButtonText, textPressFilters:Filters.tabButtonText, textOutFormat:Formats.buttonSmall, textOverFormat:Formats.buttonSmall, textPressFormat:Formats.buttonSmall, textOutOffsY:-3, textOverOffsY:-3, textPressOffsY:-2});
//			_playBtn = new Button({x:909, y:5, width:23, height:14, skin:new Embeds.buttonMyListSongBD(), icon:new Embeds.glyphPlayNanoBD(), textOutFilters:Filters.tabButtonSong, textOverFilters:Filters.tabButtonSong, textPressFilters:Filters.tabButtonSong, textOutFormat:Formats.buttonSmall, textOverFormat:Formats.buttonSmall, textPressFormat:Formats.buttonSmall, textOutOffsY:-3, textOverOffsY:-3, textPressOffsY:-2});
//			_killBtn = new Button({x:935-13, y:5, width:23+13, height:14, skin:new Embeds.buttonMyListStandardBD(), icon:new Embeds.glyphKillNanoBD(), textOutFilters:Filters.tabButtonText, textOverFilters:Filters.tabButtonText, textPressFilters:Filters.tabButtonText, textOutFormat:Formats.buttonSmall, textOverFormat:Formats.buttonSmall, textPressFormat:Formats.buttonSmall, textOutOffsY:-3, textOverOffsY:-3, textPressOffsY:-2});
			
			// add header star rating
			_starRatingBM = new QBitmap({x:857, y:7});
			_starRatingBM.bitmapData = Bitmapping.crop((new Embeds.subpanelSongHeaderStarRatingBD() as Bitmap).bitmapData, 0, Math.round(_data.songRating) * 11, 60, 11);

			// drawing
			Drawing.drawRect(_maskSpr, 0, 0, _CONTENT_WIDTH, _HEADER_HEIGHT);
			
			// add content
			var my:Number = 2;
			if(_data.songTracks.length > 0) {
				for each(var i:TrackData in _data.songTracks) {
					Logger.info(sprintf('  - Adding track (trackID=%u, trackTitle=%s)', i.trackID, i.trackTitle));
					var ct:ListSongTrackRow = new ListSongTrackRow(i, {y:my});
					_contentSpr.addChild(ct);
					_trackList.push(ct);
					my += ct.height;
				}
			}
			else {
				// no tracks
				Logger.info('  - No tracks');
				var et:ListSongTrackEmpty = new ListSongTrackEmpty({y:my});
				_contentSpr.addChild(et);
				_trackList.push(et);
				my += et.height;
			}

			// set visual properties
			_backSBM.height = my + 31;
			
			// add to display list
			addChildren(_headerSpr, _userTF, _authorTF, _titleTF, _instrumentsTF, _genreTF, _bpmTF, _keyTF, _descriptionTF, _editBtn, /*_playBtn, _killBtn, */_starRatingBM);
			addChildren(this, _backSBM, _headerSpr, _maskSpr, _contentSpr);
			
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
			
			// remove content
			for each(var ct:ListSongTrackCommon in _trackList) {
				_contentSpr.removeChild(ct);
				ct.destroy();
			}
			
			// remove from display list
			removeChildren(_headerSpr, _userTF, _authorTF, _titleTF, _instrumentsTF, _genreTF, _bpmTF, _keyTF, _descriptionTF, _editBtn, /*_playBtn, _killBtn,*/ _starRatingBM);
			removeChildren(this, _backSBM, _headerSpr, _maskSpr, _contentSpr);
		}

		
		
		/**
		 * Get content height.
		 * @return Content height
		 */
		override public function get height():Number {
			return _backSBM.height;
		}

		
		
		/**
		 * Edit button click event handler.
		 * @param event Event data
		 */
		private function _onEditClick(event:MouseEvent):void {
			App.editor.addSong(_data.songID);
		}

		
		
		/**
		 * Kill button click event handler.
		 * @param event Event data
		 */
//		private function _onKillClick(event:MouseEvent):void {
//			Logger.debug(sprintf('Killing song row (songID=%u, songTitle=%s', _data.songID, _data.songTitle));
//		}
	}
}
