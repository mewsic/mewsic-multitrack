package manager_panel.search {
	import application.App;
	
	import config.Embeds;
	import config.Filters;
	import config.Formats;
	import config.Settings;
	
	import controls.Button;
	import controls.Thumbnail;
	
	import manager_panel.search.SearchRowCommon;
	
	import remoting.data.SongData;
	import remoting.dynamic_services.UserService;
	import remoting.events.UserEvent;
	
	import de.popforge.utils.sprintf;
	
	import org.bytearray.display.ScaleBitmap;
	import org.osflash.thunderbolt.Logger;
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
	 * Song row.
	 * 
	 * @author Vaclav Vancura (http://vaclav.vancura.org)
	 * @since Jul 11, 2008
	 */
	public class SearchSongRow extends SearchRowCommon {

		
		
		private var _data:SongData;
		private var _siblingsSBM:ScaleBitmap;
		private var _siblingsTF:QTextField;
		private var _authorTF:QTextField;
		private var _titleTF:QTextField;
		private var _starRatingBM:QBitmap;
		private var _editBtn:Button;
		private var _avatarThumb:Thumbnail;
		private var _userService:UserService;

		
		
		/**
		 * Constructor.
		 * @param c Sprite config Object
		 * @param sd Song data
		 */
		public function SearchSongRow(sd:SongData, c:Object = null) {
			super(Settings.TYPE_SONG, c);
			_data = sd;
			
			var t:String = sprintf('%u VERS.', sd.songSiblingsCount);
			var author:String = sd.songAuthor;
			var songTitle:String = sd.songTitle;
			if(author == '') author = '(No author)';
			if(songTitle == '') songTitle = '(No title)';
			
			// add text boxes
			_authorTF = new QTextField({x:42, y:2, width:$CONTENT_WIDTH - 47, defaultTextFormat:Formats.searchResultsPanelSongRowAuthor, text:author, mouseEnabled:false, height:14});
			_titleTF = new QTextField({x:42, y:12, width:$CONTENT_WIDTH - 47, defaultTextFormat:Formats.searchResultsPanelSongRowTitle, filters:Filters.searchResultsPanelSongRowTitle, text:songTitle, mouseEnabled:false, height:17});
			
			// add siblings badge
			_siblingsTF = new QTextField({y:32, defaultTextFormat:Formats.searchResultsPanelRowBadge, filters:Filters.searchResultsPanelSongRowBadge, text:t, autoSize:TextFieldAutoSize.LEFT, sharpness:50, thickness:-100, mouseEnabled:false});
			_siblingsSBM = new ScaleBitmap((new Embeds.subpanelSearchPanel1CountBD() as Bitmap).bitmapData);
			_siblingsSBM.scale9Grid = new Rectangle(8, 0, 2, 19);
			_siblingsSBM.width = Math.round(_siblingsTF.textWidth) + 11;
			_siblingsSBM.x = $CONTENT_WIDTH - Math.round(_siblingsTF.textWidth) - 119;
			_siblingsSBM.y = 30;
			_siblingsTF.x = _siblingsSBM.x + 3;
			
			// add star rating
			_starRatingBM = new QBitmap({x:190, y:34});
			_starRatingBM.bitmapData = Bitmapping.crop((new Embeds.subpanelSongHeaderStarRatingBD() as Bitmap).bitmapData, 0, Math.round(sd.songRating) * 11, 60, 11);
			
			// add edit button
			_editBtn = new Button({x:254, y:32, width:33, height:14, skin:new Embeds.buttonSearchSongBD(), icon:new Embeds.glyphEditNanoBD(), textOutFilters:Filters.buttonSearchSongLabel, textOverFilters:Filters.buttonSearchSongLabel, textPressFilters:Filters.buttonSearchSongLabel, textOutFormat:Formats.buttonSmall, textOverFormat:Formats.buttonSmall, textPressFormat:Formats.buttonSmall, textOutOffsY:-3, textOverOffsY:-3, textPressOffsY:-2});
			
			// add avatar
			_avatarThumb = new Thumbnail({x:4, y:3, mouseEnabled:false});
			
			// add to display list
			addChildren($contentSpr, _avatarThumb, _siblingsSBM, _siblingsTF, _authorTF, _titleTF, _starRatingBM, _editBtn);
			
			// add event listeners
			_editBtn.addEventListener(MouseEvent.CLICK, _onEditClick, false, 0, true);
			
			// set user service
			_userService = new UserService();
			_userService.url = App.connection.serverPath + App.connection.configService.userRequestURL;
			_userService.addEventListener(UserEvent.REQUEST_DONE, _onUserDone, false, 0, true);
			
			// load avatar
			try { 
				_userService.request({userNickname:sd.songUserNickname});
			}
			catch(err:Error) { 
				Logger.error(sprintf('Could not get user data:\n%s', err.message)); 
			}
		}

		
		
		/**
		 * Destructor.
		 */
		override public function destroy():void {
			// remove event listeners
			_editBtn.removeEventListener(MouseEvent.CLICK, _onEditClick);
			_userService.removeEventListener(UserEvent.REQUEST_DONE, _onUserDone);
			
			// remove avatar
			_avatarThumb.destroy();
			
			// remove from display list
			removeChildren($contentSpr, _avatarThumb, _siblingsSBM, _siblingsTF, _authorTF, _titleTF, _starRatingBM, _editBtn);
			
			// destroy components
			_editBtn.destroy();
			
			super.destroy();
		}

		
		
		/**
		 * Get song data.
		 * @return Song data
		 */
		public function get data():SongData {
			return _data;
		}

		
		
		/**
		 * Edit button click event handler.
		 * @param event Event data
		 */
		private function _onEditClick(event:MouseEvent):void {
			App.editor.addSong(_data.songID);
		}

		
		
		/**
		 * User done event handler.
		 * Invoked when user info for this track is loaded.
		 * Load his/her avatar image.
		 * @param event Event data
		 */
		private function _onUserDone(event:UserEvent):void {
			// we get this event after all user calls, so filter it for needed user
			_avatarThumb.load(App.connection.serverPath + event.userData.userAvatarURL);
		}
	}
}
