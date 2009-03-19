package application {
	import br.com.stimuli.loading.BulkLoader;
	
	import caurina.transitions.*;
	
	import config.Embeds;
	import config.Filters;
	import config.Formats;
	import config.Settings;
	
	import controls.Button;
	import controls.Input;
	import controls.Toolbar;
	
	import de.popforge.utils.sprintf;
	
	import dropbox.DropboxContent;
	
	import editor_panel.Editor;
	
	import flash.display.*;
	import flash.events.*;
	import flash.external.*;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	
	import manager_panel.Manager;
	
	import modals.CloseModal;
	import modals.DownloadSongModal;
	import modals.DownloadTrackModal;
	import modals.ExportSongModal;
	import modals.MessageModal;
	import modals.SaveSongModal;
	import modals.SaveTrackModal;
	import modals.UploadTrackModal;
	
	import org.osflash.thunderbolt.Logger;
	import org.vancura.graphics.FPS;
	import org.vancura.util.addChildren;
	
	import progress_panel.Progress;
	
	import remoting.Connection;
	import remoting.events.RemotingEvent;	

	
	
	/**
	 * Application handler.
	 * Handles all application events and initializes all modules.
	 *
	 * @author Vaclav Vancura (http://vaclav.vancura.org)
	 * @since Jun 13, 2008
	 */
	public class App extends Sprite {

		
		
		private static const _ERROR_STAGE_HEIGHT:Number = 400;
		public static var bulkLoader:BulkLoader;
		public static var connection:Connection;
		public static var editor:Editor;
		public static var manager:Manager;
		public static var worker:Progress;
		public static var settings:Settings;
		public static var messageModal:MessageModal;
		public static var exportSongModal:ExportSongModal;
		public static var saveSongModal:SaveSongModal;
		public static var uploadTrackModal:UploadTrackModal;
		public static var saveTrackModal:SaveTrackModal;
		public static var downloadSongModal:DownloadSongModal;
		public static var downloadTrackModal:DownloadTrackModal;
		public static var closeModal:CloseModal;
		public static var dropboxContent:DropboxContent;
		public static var fps:FPS;
		public static var recordSyncDelay:int;
		private var _currentStageHeight:int = Settings.START_STAGE_HEIGHT;
		private var _isMouseInside:Boolean;
		private var _lastMouseX:int;
		private var _lastMouseY:int;
		private var _helpServicesCounter:uint = 0;
		private var _loadSong:Boolean;
		private var _fastSeekTimeout:uint;

		
		
		/**
		 * Constructor.
		 * Create new application handler.
		 * @throws New Error if something goes wrong (rendering content, etc.)
		 * @param data Settings Object
		 */
		public function App(data:Object) {
			super();

			// init embeds
			Embeds;

			// init loader
			bulkLoader = new BulkLoader('main', 30);
			
			// init remoting connection
			connection = new Connection();

			// add data from FlashVars
			connection.serverPath = data.serverPath;
			connection.configService.url = connection.serverPath + data.settingsXMLPath;
			connection.coreSongData.songID = data.songID;
			_loadSong = data.loadSong;

			// set GUI defaults
			_addDefaults();

			// add modules
			try {
				// add panels
				editor = new Editor();
				manager = new Manager();
				worker = new Progress();
				
				// add modal windows
				messageModal = new MessageModal();
				exportSongModal = new ExportSongModal();
				saveSongModal = new SaveSongModal();
				uploadTrackModal = new UploadTrackModal();
				saveTrackModal = new SaveTrackModal();
				downloadSongModal = new DownloadSongModal();
				downloadTrackModal = new DownloadTrackModal();
				closeModal = new CloseModal();
				
				// add dropbox content window
				dropboxContent = new DropboxContent();

				// add fps meter and enable it if needed
				if(Settings.isLogEnabled) {
					fps = new FPS(Formats.fps);
					fps.x = 606;
					fps.y = 10;
				}
			}
			catch(err1:Error) {
				// something went wrong
				throw new Error(sprintf('Fatal error while rendering content.\nPlease reload the page.\n%s', err1.message));
			}

			// add global connection events
			connection.addEventListener(RemotingEvent.CONFIG_REQUEST_DONE, _onRemotingConfigRequestDone, false, 0, true);
			connection.addEventListener(RemotingEvent.REQUEST_FAILED, _onRemotingFailed, false, 0, true);
			connection.addEventListener(RemotingEvent.TIMEOUT, _onRemotingTimeout, false, 0, true);
			
			// add static services events
			connection.instrumentsService.addEventListener(RemotingEvent.REQUEST_DONE, _onHelpServicesDone, false, 0, true);

			connection.coreSongService.addEventListener(RemotingEvent.REQUEST_DONE, _onHelpServicesDone, false, 0, true);
			connection.coreSongService.addEventListener(RemotingEvent.REFRESH_DONE, _onSongRefreshResponse, false, 0, true);

			connection.coreUserService.addEventListener(RemotingEvent.REQUEST_DONE, _onHelpServicesDone, false, 0, true);
			
			// add this events
			this.addEventListener(Event.ENTER_FRAME, _onEnterFrame, false, 0, true);
			this.addEventListener(AppEvent.HEIGHT_CHANGE, _onHeightChange, false, 0, true);
			this.addEventListener(AppEvent.REFRESH_TOP_PANE, _onRefreshTopPane, false, 0, true);
			this.addEventListener(AppEvent.HIDE_DROPBOX, _onHideDropbox, false, 0, true);
			this.addEventListener(AppEvent.RELOAD_PAGE, _onReloadPage, false, 0, true);

			// init javascript to actionscript calls
			try {
				ExternalInterface.addCallback('refreshSong', _onSongRefresh);
			}
			catch(err2:Error) {
				// could not set up js bridge
				Logger.error(sprintf('Fatal error while initializing JS.\nPlease reload the page.\n%s', err2.message));
			}

			// add modules to display list
			addChildren(this, editor, manager, worker, exportSongModal, saveSongModal, uploadTrackModal, saveTrackModal, downloadSongModal, downloadTrackModal, closeModal, messageModal, dropboxContent);
			if(Settings.isLogEnabled) addChildren(this, fps);

			// wait for stage initial display
			// and connect services after a short while
			Tweener.addTween(this, {time:Settings.PANEL_EDITOR_LAUNCH_DELAY, onComplete:App.editor.launch});
			Tweener.addTween(this, {time:Settings.PANEL_MANAGER_LAUNCH_DELAY, onComplete:App.manager.launch});
			Tweener.addTween(this, {time:Settings.PANEL_WORKER_LAUNCH_DELAY, onComplete:App.worker.launch});
			Tweener.addTween(this, {time:Settings.CONNECTION_LAUNCH_DELAY, onComplete:connection.configService.request});
		}

		
		
		/**
		 * Post initialization part.
		 * Called when the application gets a Stage reference.
		 */
		public function postInit():void {
			stage.addEventListener(Event.MOUSE_LEAVE, _onMouseLeave, false, 0, true);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, _onKeyDown, false, 0, true);
		}

		
		
		/**
		 * Convert msecs to time code.
		 * @param l Msecs
		 * @return Timecode
		 */
		public static function getTimeCode(l:Number):String {
			var m:uint = l / 1000 / 60;
			var s:uint = (l - (m * 1000 * 60)) / 1000;
			var o:String = sprintf('%u:%02u', m, s);
			return o;
		}

		
		
		/**
		 * Get plural.
		 * @param count Count
		 * @param plural Plural variant
		 * @param singular Singular variant
		 */
		public static function getPlural(count:uint, singular:String, plural:String):String {
			if(count == 1) return sprintf(singular, count);
			else return sprintf(plural, count);
		}

		
		
		/**
		 * Set Stage height and call JavaScript to resize Flash object.
		 * Sends a Logger.warn when something goes wrong.
		 * @param value Height in px
		 */
		public function set stageHeight(value:Number):void {
			try {
				// resize flash object
				ExternalInterface.call('setFlashHeight', Math.round(value));
				_currentStageHeight = value;
			}
			catch(err:Error) {
				// this is weird
				Logger.warn(sprintf('Could not resize Flash object.\n%s', err.message));
			}
		}

		
		
		/**
		 * Get current stage height
		 * @return Current stage height
		 */
		public function get stageHeight():Number {
			return _currentStageHeight;
		}

		
		
		/**
		 * Add GUI defaults.
		 */
		private function _addDefaults():void {
			// define button defaults
			Button.defSkin = (new Embeds.buttonBlueBD() as Bitmap).bitmapData;
			Button.defTextOutFormat = Button.defTextOverFormat = Button.defTextPressFormat = Formats.buttonStandard;
			Button.defTextOutFilters = Button.defTextOverFilters = Button.defTextPressFilters = Filters.buttonBlueLabel;
			Button.defTextOutAlpha = Button.defTextOverAlpha = Button.defTextPressAlpha = 1;
			Button.defHeight = 32;
			Button.defTextOutOffsY = Button.defTextOverOffsY = -3;
			Button.defTextPressOffsY = -2;

			// define toolbar defaults
			Toolbar.defSkin = (new Embeds.toolbarMidGrayBD() as Bitmap).bitmapData;

			// define input defaults
			Input.defBackSkin = (new Embeds.inputStandardBD() as Bitmap).bitmapData;
			Input.defTextOutFormat = Formats.inputOut;
			Input.defTextOverFormat = Formats.inputOver;
			Input.defTextPressFormat = Formats.inputPress;
			Input.defTextIntroFormat = Formats.inputIntro;
			Input.defTextOutFilters = Input.defTextOverFilters = Input.defTextPressFilters = Input.defTextIntroFilters = Filters.inputLabel;
			Input.defTextOutOffsY = Input.defTextOverOffsY = Input.defTextIntroOffsY = -2;
			Input.defTextOffsX = 4;
			Input.defTextPressOffsY = -1;
		}

		
		
		/**
		 * Timeout happened while connecting or requesting service.
		 * Displays a message modal with information.
		 * @param e Event data
		 */
		private function _onRemotingTimeout(event:RemotingEvent):void {
			var dsc:String;
			var l8r:String = '\nPlease try again later.';
			var btn:String = MessageModal.BUTTONS_RELOAD;
			var ico:String = MessageModal.ICON_ERROR;
			
			if(event.currentTarget == connection.streamService) {
				Logger.warn('Could not connect stream');
				editor.disableStreamFunctions();
				return;
			}

			switch(event.currentTarget) {
				
				case connection.configService:
					dsc = 'Could not load user config data.' + l8r;
					break;
										
				case connection.instrumentsService:
					dsc = 'Could not load instruments data.' + l8r;
					break;
					
				case connection.coreSongService:
					dsc = 'Could not load core song.' + l8r;
					break;
					
				case connection.coreUserService:
					dsc = 'Could not load core user.' + l8r;
					break;
					
				default:
					dsc = 'Timeout while connecting service.' + l8r;
			}

			// if stage height is not reinited, set some dummy value
			// this applies when some error happens before anything else (like rendering of content)
			if(stageHeight == Settings.START_STAGE_HEIGHT) stageHeight = _ERROR_STAGE_HEIGHT;
			
			// show message modal
			App.messageModal.show({title:'Timeout', description:dsc, buttons:btn, icon:ico});
		}
		
		/**
		 * Remoting connection or request failed.
		 * Displays a message modal with information.
		 * @param e Event data
		 */
		private function _onRemotingFailed(event:RemotingEvent):void {
			// if stage height is not reinited, set some dummy value
			// this applies when some error happens before anything else (like rendering of content)
			if(stageHeight == Settings.START_STAGE_HEIGHT) stageHeight = _ERROR_STAGE_HEIGHT;
			
			// show message modal
			App.messageModal.show({title:'Error', description:event.description, buttons:MessageModal.BUTTONS_NONE, icon:MessageModal.ICON_ERROR});
		}

		
		
		/**
		 * Config request done.
		 * Transfer all service URLs to corresponding services.
		 * @param e Event data
		 */
		private function _onRemotingConfigRequestDone(event:RemotingEvent):void {
			try {
				// set services url
				connection.streamService.url = connection.configService.streamGatewayURL;
				connection.instrumentsService.url = connection.serverPath + connection.configService.instrumentsRequestURL;
				connection.coreSongService.url = connection.serverPath + connection.configService.songFetchRequestURL;
				connection.coreUserService.url = connection.serverPath + connection.configService.userRequestURL;

				// connect static services
				connection.streamService.connect();
				connection.instrumentsService.request();
				connection.coreSongService.request({songID:connection.coreSongData.songID});

				// get core user data
				// or fill it with guest information in case user is not logged in
				if(connection.coreUserLoginStatus) {
					connection.coreUserService.request({userID:connection.coreUserData.userID});
				} else {
					connection.coreUserService.setGuest();
				}
			}
			catch(err:Error) {
				// if stage height is not reinited, set some dummy value
				// this applies when some error happens before anything else (like rendering of content)
				if(stageHeight == Settings.START_STAGE_HEIGHT) stageHeight = _ERROR_STAGE_HEIGHT;
				
				// show message modal
				App.messageModal.show({title:'Config', description:sprintf('%s\nPlease try again later.', err.message), buttons:MessageModal.BUTTONS_NONE, icon:MessageModal.ICON_ERROR});
			}
		}

		
		
		/**
		 * OnEnterFrame event handler to check for mouse position (if it is inside FLash object or outside).
		 * @param e Event data
		 */
		private function _onEnterFrame(e:Event):void {
			if(!_isMouseInside && mouseX > 0 && mouseX < Settings.STAGE_WIDTH && mouseY > 0 && mouseY < _currentStageHeight && (_lastMouseX != mouseX || _lastMouseY != mouseY)) {
				_isMouseInside = true;
			}
		}

		
		
		/**
		 * Mouse left the Stage.
		 * @param e Event data
		 */
		private function _onMouseLeave(e:Event):void {
			_isMouseInside = false;
			_lastMouseX = mouseX;
			_lastMouseY = mouseY;

			// release all buttons
			Button.releaseAll();
		}

		
		
		/**
		 * Height of a panel changed.
		 * Calls setStageHeight() to resize Flash object.
		 * @param e Event data
		 */
		private function _onHeightChange(e:AppEvent):void {
			var sum:Number = 0;
			sum += editor.height;
			sum += 30;
			sum += manager.height;
			sum += worker.height;

			manager.y = editor.height + 30;
			worker.y = editor.height + manager.height + 30;
			editor.height + manager.height + worker.height + 30;
			
			sum += 40; // dropbox fix
			stageHeight = sum;
		}

		
		
		/**
		 * Help services done event.
		 * Counts all help services and once everything is done, it fires song loading.
		 * @param event Event data
		 */
		private function _onHelpServicesDone(event:RemotingEvent):void {
			if(++_helpServicesCounter == 7) {
				editor.postInit();
				manager.tabMyList.postInit();
				manager.tabMySongs.postInit();
				manager.tabSearch.postInit();
				manager.tabSearch.advancedSearchSubTab.postInit();
				manager.tabSearch.searchResultsSubTab.postInit();
				uploadTrackModal.postInit();
				saveTrackModal.postInit();
				
				if(_loadSong) {
					Logger.info(sprintf('Loading core song %u', connection.coreSongData.songID));
					App.editor.addSong(connection.coreSongData.songID);
				}
			}
		}

		
		
		/**
		 * Refresh top pane in HTML, call JavaScript.
		 * @param event Event data
		 */
		private function _onRefreshTopPane(event:AppEvent):void {
			Logger.debug('Refreshing top pane');
			ExternalInterface.call('refreshTopPane');
		}

		
		
		/**
		 * Reload page event handler.
		 * Reloads whole page via javascript.
		 * @param event Event data
		 */
		private function _onReloadPage(event:AppEvent):void {
			Logger.debug('Reloading page');
			ExternalInterface.call('reload');
		}

		
		
		/**
		 * Hide dropbox event handler.
		 * Called when other control gains focus and so on.
		 * @param event Event data
		 */
		private function _onHideDropbox(event:AppEvent):void {
			dropboxContent.hide();
		}

		
		
		/**
		 * Refresh song data event handler.
		 * @param event Event data
		 */
		private function _onSongRefreshResponse(event:RemotingEvent):void {
			editor.refreshSongData();
		}

		
		
		/**
		 * Song information in HTML page was changed, refresh song values and re-render content.
		 */
		private function _onSongRefresh():void {
			connection.coreSongService.refresh();
		}

		
		
		/**
		 * Key was pressed.
		 */
		private function _onKeyDown(event:KeyboardEvent):void {
			Logger.error('charcode=' + event.charCode + ', keycode=' + event.keyCode + ', alt=' + event.altKey + ', ctrl=' + event.ctrlKey);
			
			// TODO: save and close doesn't work, not possible with modal windows.
			
			// check ctrl combos
			if(event.ctrlKey) {
				switch(event.keyCode) {
					case 49:
						// solo 0
						editor.toggleTrackSolo(0);
						return;
						break;
						
					case 50:
						// solo 1
						editor.toggleTrackSolo(1);
						return;
						break;
						
					case 51:
						// solo 2
						editor.toggleTrackSolo(2);
						return;
						break;
						
					case 52:
						// solo 3
						editor.toggleTrackSolo(3);
						return;
						break;
						
					case 53:
						// solo 4
						editor.toggleTrackSolo(4);
						return;
						break;
						
					case 54:
						// solo 5
						editor.toggleTrackSolo(5);
						return;
						break;
						
					case 55:
						// solo 6
						editor.toggleTrackSolo(6);
						return;
						break;
						
					case 56:
						// solo 7
						editor.toggleTrackSolo(7);
						return;
						break;
						
					case 57:
						// solo 8
						editor.toggleTrackSolo(8);
						return;
						break;
						
					case 17:
						// increase volume of track 0 by 5%
						editor.alterTrackVolume(0, -.05);
						return;
						break;
						
					case 23:
						// increase volume of track 1 by 5%
						editor.alterTrackVolume(1, -.05);
						return;
						break;
						
					case 5:
						// increase volume of track 2 by 5%
						editor.alterTrackVolume(2, -.05);
						return;
						break;
						
					case 18:
						// increase volume of track 3 by 5%
						editor.alterTrackVolume(3, -.05);
						return;
						break;
						
					case 20:
						// increase volume of track 4 by 5%
						editor.alterTrackVolume(4, -.05);
						return;
						break;
						
					case 25:
						// increase volume of track 5 by 5%
						editor.alterTrackVolume(5, -.05);
						return;
						break;
						
					case 21:
						// increase volume of track 6 by 5%
						editor.alterTrackVolume(6, -.05);
						return;
						break;
						
					case 9:
						// increase volume of track 7 by 5%
						editor.alterTrackVolume(7, -.05);
						return;
						break;
						
					case 15:
						// increase volume of track 8 by 5%
						editor.alterTrackVolume(8, -.05);
						return;
						break;
						
					case 1:
						// decrease volume of track 0 by 5%
						editor.alterTrackVolume(0, .05);
						return;
						break;
						
					case 19:
						// decrease volume of track 1 by 5%
						editor.alterTrackVolume(1, .05);
						return;
						break;
						
					case 4:
						// decrease volume of track 2 by 5%
						editor.alterTrackVolume(2, .05);
						return;
						break;
						
					case 6:
						// decrease volume of track 3 by 5%
						editor.alterTrackVolume(3, .05);
						return;
						break;
						
					case 7:
						// decrease volume of track 4 by 5%
						editor.alterTrackVolume(4, .05);
						return;
						break;
						
					case 8:
						// decrease volume of track 5 by 5%
						editor.alterTrackVolume(5, .05);
						return;
						break;
						
					case 10:
						// decrease volume of track 6 by 5%
						editor.alterTrackVolume(6, .05);
						return;
						break;
						
					case 11:
						// decrease volume of track 7 by 5%
						editor.alterTrackVolume(7, .05);
						return;
						break;
						
					case 12:
						// decrease volume of track 8 by 5%
						editor.alterTrackVolume(8, .05);
						return;
						break;
				}
			}
			
			// check alt combos
			if(event.altKey) {
				switch(event.keyCode) {
					case 49:
						// mute 0
						editor.toggleTrackMute(0);
						return;
						break;
						
					case 50:
						// mute 1
						editor.toggleTrackMute(1);
						return;
						break;
						
					case 51:
						// mute 2
						editor.toggleTrackMute(2);
						return;
						break;
						
					case 52:
						// mute 3
						editor.toggleTrackMute(3);
						return;
						break;
						
					case 53:
						// mute 4
						editor.toggleTrackMute(4);
						return;
						break;
						
					case 54:
						// mute 5
						editor.toggleTrackMute(5);
						return;
						break;
						
					case 55:
						// mute 6
						editor.toggleTrackMute(6);
						return;
						break;
						
					case 56:
						// mute 7
						editor.toggleTrackMute(7);
						return;
						break;
						
					case 57:
						// mute 8
						editor.toggleTrackMute(8);
						return;
						break;
						
					case 156:
						// pan left of track 0 by 5%
						editor.alterTrackBalance(0, -.05);
						return;
						break;
						
					case 221:
						// pan left of track 1 by 5%
						editor.alterTrackBalance(1, -.05);
						return;
						break;
						
//					case XXX:
//						// TODO: doesn't work on mac 
//						// pan left of track 2 by 5%
//						editor.alterTrackBalance(2, -.05);
//						return;
//						break;
						
					case 174:
						// pan left of track 3 by 5%
						editor.alterTrackBalance(3, -.05);
						return;
						break;
						
					case 134:
						// pan left of track 4 by 5%
						editor.alterTrackBalance(4, -.05);
						return;
						break;
						
					case 165:
						// pan left of track 5 by 5%
						editor.alterTrackBalance(5, -.05);
						return;
						break;
						
//					case 117:
//						// TODO: doesn't work on mac 
//						// pan left of track 6 by 5%
//						editor.alterTrackBalance(6, -.05);
//						return;
//						break;
						
//					case 105:
//						// TODO: doesn't work on mac 
//						// pan left of track 7 by 5%
//						editor.alterTrackBalance(7, -.05);
//						return;
//						break;
						
					case 248:
						// pan left of track 8 by 5%
						editor.alterTrackBalance(8, -.05);
						return;
						break;
						
					case 229:
						// pan right of track 0 by 5%
						editor.alterTrackBalance(0, .05);
						return;
						break;
						
					case 223:
						// pan right of track 1 by 5%
						editor.alterTrackBalance(1, .05);
						return;
						break;
						
					case 240:
						// pan right of track 2 by 5%
						editor.alterTrackBalance(2, .05);
						return;
						break;
						
					case 131:
						// pan right of track 3 by 5%
						editor.alterTrackBalance(3, .05);
						return;
						break;
						
					case 169:
						// pan right of track 4 by 5%
						editor.alterTrackBalance(4, .05);
						return;
						break;
						
					case 178:
						// pan right of track 5 by 5%
						editor.alterTrackBalance(5, .05);
						return;
						break;
						
					case 208:
						// pan right of track 6 by 5%
						editor.alterTrackBalance(6, .05);
						return;
						break;
						
					case 190:
						// pan right of track 7 by 5%
						editor.alterTrackBalance(7, .05);
						return;
						break;
						
					case 172:
						// pan right of track 8 by 5%
						editor.alterTrackBalance(8, .05);
						return;
						break;
				}
			}
			
			// check single chars
			switch(event.charCode) {
				case 43:
					// +
					// Increase master volume by 5%
					editor.alterMasterVolume(.05);
					return;
					break;
					
				case 45:
					// -
					// Decrease master volume by 5%
					editor.alterMasterVolume(-.05);
					return;
					break;
					
				case 32:
					// spacebar
					// Toggle play/pause
					editor.alterPlaybackState();
					return;
					break;
					
				case 44:
					// ,
					// Rewind by 5 seconds
					editor.alterPosition(-5);
					return;
					break;
					
				case 46:
					// .
					// Fastforward by 5 seconds
					editor.alterPosition(5);
					return;
					break;
			}
			
			// check key codes
			switch(event.keyCode) {
				case 38:
					// up arrow
					// Increase master volume by 5%
					editor.alterMasterVolume(.05);
					return;
					break;
					
				case 40:
					// down arrow
					// Decrease master volume by 5%
					editor.alterMasterVolume(-.05);
					return;
					break;
					
				case 13:
					// return
				case 96:
					// numeric 0
					// Toggle play/pause
					editor.alterPlaybackState();
					return;
					break;
					
				case 97:
					// numeric 1
					// Rewind by 5 seconds
					editor.alterPosition(-5);
					return;
					break;
					
				case 98:
					// numeric 2
					// Fastforward by 5 seconds
					editor.alterPosition(5);
					return;
					break;
					
				case 37:
					// left arrow
					// Move playhead backwards by 3 seconds while key is pressed, when the key is released resume
					// playing from the reached position.
					editor.alterPosition(-1);
					clearTimeout(_fastSeekTimeout);
					_fastSeekTimeout = setTimeout(editor.play, 200);
					return;
					break;
					
				case 39:
					// right arrow
					// Move playhead forward by 3 seconds while key is pressed, when the key is released resume
					// playing from the reached position.
					editor.pause();
					editor.alterPosition(1);
					clearTimeout(_fastSeekTimeout);
					_fastSeekTimeout = setTimeout(editor.play, 200);
					return;
					break;
					
				case 82:
					// r
				case 123:
					// F12
				case 99:
					// numeric 3
					// Start recording: if there's no "blue track", create it. If it's already there, start track record
					editor.createAndRecord();
					return;
					break;
					
				case 77:
					// m
				case 100:
					// numeric 4
					// Toggle metronome
					editor.toggleMetronome();
					return;
					break;
										
				case 85:
					// u
					// Show the track upload form
					editor.upload();
					return;
					break;
					
				case 69:
					// e
					// Show the export song dialog
					editor.export();
					return;
					break;
					
				case 83:
					// s
					// Save the project
					editor.save();
					return;
					break;
			}
		}
	}
}
