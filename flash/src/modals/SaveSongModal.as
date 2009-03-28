package modals {
	import application.App;
	import application.AppEvent;
	
	import config.Embeds;
	import config.Filters;
	import config.Formats;
	
	import controls.Button;
	
	import remoting.data.SongData;
	import remoting.dynamic_services.SongExportService;
	import remoting.dynamic_services.SongSaveService;
	import remoting.events.RemotingEvent;
	import remoting.events.SongExportEvent;
	import remoting.events.SongSaveEvent;
	
	import de.popforge.utils.sprintf;
	
	import org.osflash.thunderbolt.Logger;
	import org.vancura.graphics.QTextField;
	import org.vancura.util.addChildren;
	
	import flash.events.MouseEvent;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;	

	
	
	/**
	 * Save song modal.
	 * 
	 * TODO: Write documentation
	 * 
	 * @author Vaclav Vancura (http://vaclav.vancura.org)
	 * @since Jul 19, 2008
	 */
	public class SaveSongModal extends ModalCommon {

		
		
		private static const _PANEL_WIDTH:Number = 455;
		private static const _PANEL_HEIGHT:Number = 247;
		private static const _PANEL_Y:Number = -38;
		private var _titleTF:QTextField;
		private var _cancelBtn:Button;
		private var _saveBtn:Button;
		private var _descriptionTF:QTextField;
		private var _saveAndCloseBtn:Button;
		private var _isSaving:Boolean;
		private var _isExporting:Boolean;
		private var _songSaveService:SongSaveService;
		private var _songExportService:SongExportService;
		private var _isClosing:Boolean;
		private var _songData:SongData;

		
		
		/**
		 * Constructor.
		 * @param o QSprite config Object
		 */
		public function SaveSongModal(o:Object = null) {
			super(o);
			
			// add graphics
			_titleTF = new QTextField({text:'Save song', x:50, y:64, width:_PANEL_WIDTH - 100, defaultTextFormat:Formats.modalTitle, filters:Filters.modalTitle, sharpness:50});
			_descriptionTF = new QTextField({text:'Do you want to save the song or to save and close it?\nUntil you close this song, it won\'t be published on Myousica.', x:50, y:100, width:_PANEL_WIDTH - 100, defaultTextFormat:Formats.modalDescription});
			
			// add buttons
			_cancelBtn = new Button({x:Math.round(_PANEL_WIDTH) / 2 - 159, y:144, width:100, text:'Cancel', icon:new Embeds.glyphCancelBD});
			_saveBtn = new Button({x:Math.round(_PANEL_WIDTH) / 2 - 51, y:144, width:100, text:'Save', icon:new Embeds.glyphSaveBD()});
			_saveAndCloseBtn = new Button({x:Math.round(_PANEL_WIDTH) / 2 + 57, y:144, width:100, text:'Save and Close'});
			
			// add to display list
			addChildren($contentSpr, _titleTF, _descriptionTF, _cancelBtn, _saveBtn, _saveAndCloseBtn);
			
			// add saving stuff
			_songSaveService = new SongSaveService();
			_songExportService = new SongExportService();

			// add event listeners
			_cancelBtn.addEventListener(MouseEvent.CLICK, _onCancelClick, false, 0, true);
			_saveBtn.addEventListener(MouseEvent.CLICK, _onSaveClick, false, 0, true);
			_saveAndCloseBtn.addEventListener(MouseEvent.CLICK, _onSaveAndCloseClick, false, 0, true);
			_songSaveService.addEventListener(RemotingEvent.REQUEST_FAILED, _onSongSaveFailed, false, 0, true);
			_songSaveService.addEventListener(SongSaveEvent.REQUEST_DONE, _onSongSaveDone, false, 0, true);
			_songExportService.addEventListener(RemotingEvent.REQUEST_FAILED, _onSongExportFailed, false, 0, true);
			_songExportService.addEventListener(SongExportEvent.REQUEST_DONE, _onSongExportDone, false, 0, true);
		}

		
		
		/**
		 * Show save song modal.
		 * @param c Config object
		 */
		override public function show(c:Object = null):void {
			if(!_isSaving) {
				_songData = App.connection.coreSongData; 
				
				if(_songData.songTitle == '' || _songData.songAuthor == '' || _songData.songKey == '' || _songData.songGenreID == 0) {
					App.messageModal.show({title:'Save song', description:'Please fill in all the song information above!', buttons:MessageModal.BUTTONS_OK});
					return;
				}
				
				Logger.info('Showing song save modal.');
				
				super.show(c);
				
				// set default sizes
				width = _PANEL_WIDTH;
				height = _PANEL_HEIGHT;
				y = _PANEL_Y;
				
				// add service urls
				// (in constructor it's unknown since config is not loaded yet)
				_songSaveService.url = App.connection.serverPath + App.connection.configService.songExportRequestURL;
				_songExportService.url = App.connection.mediaPath + App.connection.configService.mediaExportRequestURL;
			}
			else {
				App.messageModal.show({title:'Save song', description:'Your song is already being saved.', buttons:MessageModal.BUTTONS_OK});
			}
		}

		
		
		/**
		 * Cancel button click event handler.
		 * @param event Event data
		 */
		private function _onCancelClick(event:MouseEvent):void {
			hide();
		}

		
		
		private function _onSaveClick(event:MouseEvent):void {
			_isSaving = true;
			
			try {
				_songSaveService.request({songData:_songData, userData:App.connection.coreUserData});
				hide();
			}
			catch(err:Error) {
				App.messageModal.show({title:'Saving error', description:sprintf('Error while saving your track:\n%s', err.message), buttons:MessageModal.BUTTONS_OK});
				_isSaving = false;
				hide();
			}
		}

		
		
		/**
		 * Song save done event handler.
		 * Add track to editor.
		 * @param event Event data
		 */
		private function _onSongSaveDone(event:SongSaveEvent):void {
			if(_isClosing) {
				try {
					_songExportService.request({songData:_songData, isSave:true});
				}
				catch(err:Error) {
					App.messageModal.show({title:'Saving error', description:sprintf('Error while saving your track:\n%s', err.message), buttons:MessageModal.BUTTONS_OK});
					_isSaving = false;
					hide();
				}
			}
			else {
				_isSaving = false;
				hide();
			}
		}

		
		
		/**
		 * Song save failed event handler.
		 * @param event Event data
		 */
		private function _onSongSaveFailed(event:RemotingEvent):void {
			App.messageModal.show({title:'Save song error', description:'Error while saving song.', buttons:MessageModal.BUTTONS_OK, icon:MessageModal.ICON_WARNING});
			_isSaving = false;
			hide();
		}

		
		
		/**
		 * Song export done event handler.
		 * Add track to editor.
		 * @param event Event data
		 */
		private function _onSongExportDone(event:SongExportEvent):void {
			App.closeModal.show();
			
			navigateToURL(new URLRequest(sprintf('/songs/%u', App.connection.coreSongData.songID)), '_self');
		}

		
		
		/**
		 * Song export failed event handler.
		 * @param event Event data
		 */
		private function _onSongExportFailed(event:RemotingEvent):void {
			App.messageModal.show({title:'Export song error', description:'Error while exporting song.', buttons:MessageModal.BUTTONS_OK, icon:MessageModal.ICON_WARNING});
			_isExporting = false;
			hide();
		}

		
		
		private function _onSaveAndCloseClick(event:MouseEvent):void {
			_isClosing = true;
			_onSaveClick(event);
		}
	}
}