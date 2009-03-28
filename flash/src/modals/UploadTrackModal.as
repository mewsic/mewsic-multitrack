package modals {
	import application.App;
	import application.AppEvent;
	
	import caurina.transitions.Tweener;
	
	import config.Embeds;
	import config.Filters;
	import config.Formats;
	import config.Settings;
	
	import controls.Button;
	import controls.Dropbox;
	import controls.Input;
	import controls.InputEvent;
	import controls.ProgressBar;
	import controls.Toolbar;
	
	import de.popforge.utils.sprintf;
	
	import dropbox.DropboxEvent;
	
	import flash.display.Bitmap;
	import flash.events.DataEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.TimerEvent;
	import flash.geom.Rectangle;
	import flash.net.FileFilter;
	import flash.net.FileReference;
	import flash.net.URLRequest;
	import flash.text.TextFieldAutoSize;
	import flash.utils.Timer;
	
	import org.bytearray.display.ScaleBitmap;
	import org.osflash.thunderbolt.Logger;
	import org.vancura.graphics.QTextField;
	import org.vancura.util.addChildren;
	
	import remoting.data.WorkerStatusData;
	import remoting.dynamic_services.TrackCreateService;
	import remoting.dynamic_services.WorkerEncodeService;
	import remoting.events.RemotingEvent;
	import remoting.events.TrackCreateEvent;
	import remoting.events.WorkerEvent;	

	
	
	/**
	 * Upload track modal.
	 * 
	 * TODO: Write documentation
	 * 
	 * @author Vaclav Vancura (http://vaclav.vancura.org)
	 * @since Jul 19, 2008
	 */
	public class UploadTrackModal extends ModalCommon {

		
		
		private static const _PANEL_WIDTH:Number = 500;
		private static const _PANEL_HEIGHT:Number = 300;
		private static const _PANEL_Y:Number = 10;
		private static const _WORKER_ID:String = 'workerUploadTrack';
		private var _toolbar:Toolbar;
		private var _titleTF:QTextField;
		private var _filenameTF:QTextField;
		private var _browseBtn:Button;
		private var _cancelBtn:Button;
		private var _uploadBtn:Button;
		private var _uploadURL:URLRequest;
		private var _file:FileReference;
		private var _progressWidth:Number;
		private var _isUploading:Boolean;
		private var _isEncoding:Boolean;
		private var _encodeKey:String;
		private var _workerEncodeService:WorkerEncodeService;
		private var _trackCreateService:TrackCreateService;
		private var _encodeWorkerTimer:Timer;

		private var _progressBar:ProgressBar;
		
		/**
		 * Constructor.
		 * @param o QSprite config Object
		 */
		public function UploadTrackModal(o:Object = null) {
			super(o);
			
			// add titles
			_titleTF = new QTextField({x:50, y:64, width:_PANEL_WIDTH - 100, defaultTextFormat:Formats.modalTitle, filters:Filters.modalTitle, sharpness:50});
			_filenameTF = new QTextField({x:125, y:12, width:480, defaultTextFormat:Formats.modalDescriptionLeft, autoSize:TextFieldAutoSize.LEFT});
			
			// add toolbars
			_toolbar = new Toolbar({x:50, y:225, width:620, height:42, skin:new Embeds.toolbarModalBD()});
			
			// add buttons
			_browseBtn = new Button({x:10, y:9, width:108, height:24, text:'Browse...', skin:new Embeds.buttonBlueMiniBD()});
			_cancelBtn = new Button({x:Math.round(_PANEL_WIDTH) / 2 - 194, y:282, width:100, text:'Cancel', icon:new Embeds.glyphCancelBD()});
			_uploadBtn = new Button({x:Math.round(_PANEL_WIDTH) / 2 - 86, y:282, width:280, icon:new Embeds.glyphUpload2BD()});
			
			// add progress bar
			_progressBar = new ProgressBar({background:new Embeds.modalUploadBackBD(),
				progress:new Embeds.modalUploadProgressBD(), grid:new Rectangle(9, 0, 22, 14)});
			_progressBar.y = 14;
			
			// add to display list
			addChildren(_toolbar, _browseBtn, _filenameTF, _progressBar);
			addChildren($contentSpr, _titleTF, _toolbar, _cancelBtn, _uploadBtn);
			
			// add encoding stuff
			_uploadURL = new URLRequest();
			_file = new FileReference();	
			_encodeWorkerTimer = new Timer(Settings.WORKER_INTERVAL * 1000);
			_trackCreateService = new TrackCreateService();
			_workerEncodeService = new WorkerEncodeService();
			
			// add event listeners
			_cancelBtn.addEventListener(MouseEvent.CLICK, _onCancelClick, false, 0, true);
			_browseBtn.addEventListener(MouseEvent.CLICK, _onBrowseClick, false, 0, true);
			_uploadBtn.addEventListener(MouseEvent.CLICK, _onUploadClick, false, 0, true);

			_file.addEventListener(Event.SELECT, _onFileSelect, false, 0, true);
			_file.addEventListener(ProgressEvent.PROGRESS, _onFileProgress, false, 0, true);
			_file.addEventListener(DataEvent.UPLOAD_COMPLETE_DATA, _onFileUploadComplete, false, 0, true);
			
			_file.addEventListener(IOErrorEvent.IO_ERROR, _onFileError, false, 0, true);
			_file.addEventListener(SecurityErrorEvent.SECURITY_ERROR, _onFileSecurityError, false, 0, true);

			_encodeWorkerTimer.addEventListener(TimerEvent.TIMER, _onEncodeWorkerBang, false, 0, true);

			_trackCreateService.addEventListener(RemotingEvent.REQUEST_FAILED, _onTrackCreateFailed, false, 0, true);
			_trackCreateService.addEventListener(TrackCreateEvent.REQUEST_DONE, _onTrackCreateDone, false, 0, true);
			
			_workerEncodeService.addEventListener(RemotingEvent.REQUEST_FAILED, _onEncodeWorkerFailed, false, 0, true);
			_workerEncodeService.addEventListener(WorkerEvent.REQUEST_DONE, _onEncodeWorkerDone, false, 0, true);

		}

		
		
		public function postInit():void {
			// fill in with instrument names
			//_instrumentDropbox.list = App.connection.instrumentsService.instrumentsNameList;
		}
		
		
		
		/**
		 * Show record track modal.
		 * @param c Config object
		 */
		override public function show(c:Object = null):void {
			if(!_isEncoding) {
				Logger.info('Showing upload track modal.');
				super.show(c);
				
				// reset values
				_isUploading = false;
				_uploadURL.url = '';
				_filenameTF.text = '';
				_titleTF.text = 'Upload track';
				
				// set initial visual properties
				_browseBtn.alpha = 1;
				_uploadBtn.alpha = .4;
				_browseBtn.areEventsEnabled = true;
				_uploadBtn.areEventsEnabled = false;
				_cancelBtn.x = Math.round(_PANEL_WIDTH) / 2 - 194;
				_uploadBtn.x = Math.round(_PANEL_WIDTH) / 2 - 86;
				_uploadBtn.width = 280;
				_progressBar.visible = false;
				_uploadBtn.text = 'Upload (please fill all information above)';
				
				// set default sizes
				width = _PANEL_WIDTH;
				height = _PANEL_HEIGHT;
				y = _PANEL_Y;
				
				// add service urls
				// (in constructor it's unknown since config is not loaded yet)
				_trackCreateService.url = App.connection.serverPath + App.connection.configService.trackCreateRequestURL;
				_workerEncodeService.url = App.connection.mediaPath + App.connection.configService.workerEncodeRequestURL;
			}
			else {
				// track is already encoding
				App.messageModal.show({title:'Encoding track', description:'Your track is already encoding.\nPlease watch its progress in the panel below.', buttons:MessageModal.BUTTONS_OK});
			}			
		}

		
		
		/**
		 * Hide upload modal.
		 */
		override public function hide():void {
			if(_isUploading) {
				_isUploading = false;
				_file.cancel();
			}
			super.hide();
		}

		
		
		/**
		 * Remove encode worker event listeners.
		 */
		private function _removeEncodeWorker():void {
			_encodeWorkerTimer.stop();
			_isEncoding = false;
			App.worker.removeWorker(_WORKER_ID);
		}

		
		
		/**
		 * Parse entered data.
		 * Enables upload button if everything is filled in.
		 * Disables if something is missing.
		 */
		private function _parseData(event:Event = null):void {
			var allow:Boolean = true;
			
			if(_uploadURL.url == '') allow = false;
			
			_uploadBtn.areEventsEnabled = (allow);
			_uploadBtn.alpha = (allow) ? 1 : .4;
			_uploadBtn.text = (allow) ? 'Upload' : 'Upload (please fill all information above)';
			_cancelBtn.morph({x:(allow) ? (Math.round(_PANEL_WIDTH) / 2 - 104) : (Math.round(_PANEL_WIDTH) / 2 - 194)});
			_uploadBtn.morph({x:(allow) ? (Math.round(_PANEL_WIDTH) / 2 + 4) : (Math.round(_PANEL_WIDTH) / 2 - 86), width:(allow) ? 100 : 280});
		}

		
		
		/**
		 * Cancel button click event handler.
		 * @param event Event data
		 */
		private function _onCancelClick(event:MouseEvent):void {
			hide();
		}

		
		
		/**
		 * Upload button click event handler.
		 * Disable browse and upload buttons.
		 * Start upload.
		 * @param event Event data
		 */
		private function _onUploadClick(event:MouseEvent):void {
			_uploadBtn.areEventsEnabled = false;
			_browseBtn.areEventsEnabled = false;
			_uploadBtn.alpha = .4;
			_browseBtn.alpha = .4;
		
			
			//_uploadBackSBM.x = _uploadProgressSBM.x = 
			_progressBar.x = _filenameTF.x + _filenameTF.textWidth + 10;
			//_uploadBackSBM.width = _progressWidth;
			_progressBar.width = 610 - _progressBar.x;   
			//_uploadBackSBM.visible = _uploadProgressSBM.visible = true;
			_progressBar.visible = true;
			_titleTF.text = 'Uploading track';
			
			_isUploading = true;
			_file.upload(_uploadURL);
		}

		
		
		/**
		 * Browse button click event handler.
		 * Show open dialog.
		 * @param event Event data
		 */
		private function _onBrowseClick(event:MouseEvent):void {
			_file.browse([new FileFilter('Sound files (*.mp3)', '*.mp3')]);
		}

		
		
		/**
		 * File progress event handler.
		 * File uploading progress, update progress bar.
		 * @param event Event data
		 */
		private function _onFileProgress(event:ProgressEvent):void {
			var w:uint = _progressWidth / (event.bytesTotal / event.bytesLoaded);
			_progressBar.progress = w;			
		}

		
		
		/**
		 * File selected event handler.
		 * Enable upload button and display filename in a TextField.
		 * @param event Event data
		 */
		private function _onFileSelect(event:Event):void {
			_uploadURL.url = App.connection.mediaPath + App.connection.configService.mediaUploadRequestURL;
			_filenameTF.text = _file.name;
			_parseData();
		}

		
		
		/**
		 * File error event handler.
		 * Displays a message window with error description.
		 * @param event Event data
		 */
		private function _onFileError(event:IOErrorEvent):void {
			Logger.error('ioerror', event.text);
			var desc:String = sprintf('Read error while uploading file.\nPlease check that the file name is correct.\n%s', event);
			App.messageModal.show({title:'Upload error', description:desc, buttons:MessageModal.BUTTONS_OK, icon:MessageModal.ICON_WARNING});
		}

		
		
		/**
		 * File security error event handler.
		 * Displays a message window with error description.
		 * @param event Event data
		 */
		private function _onFileSecurityError(event:SecurityErrorEvent):void {
			var desc:String = sprintf('Read error while uploading file.\nPlease check that the file name is correct.\n%s', event);
			App.messageModal.show({title:'Upload error', description:desc, buttons:MessageModal.BUTTONS_OK, icon:MessageModal.ICON_WARNING});
		}

		
		
		/**
		 * File upload complete event handler.
		 * Upload is complete, start encoding.
		 * @param event Event data
		 */
		private function _onFileUploadComplete(event:DataEvent):void {
			var response:XML = XML(event.data);
			_encodeKey = response.@key;
			Logger.info(sprintf('Upload complete, encoding (key=%s)', _encodeKey));
			
			_isUploading = false;
			_isEncoding = true;
			
			try {
				App.worker.addWorker(_WORKER_ID, sprintf('Encoding track %s', _file.name));
				_encodeWorkerTimer.start();
				_onEncodeWorkerBang();
			}
			catch(err:Error) {
				Logger.error(sprintf('Cannot start encoding of your track.\nPlease wait a while and try again.\n%s', err.message));
			}
			
			hide();
		}

		
		
		/**
		 * Encode worker bang event handler.
		 * Bangs encoder worker. But only if it is not connecting, preventing overloading.
		 * @param event Event data
		 */
		private function _onEncodeWorkerBang(event:Event = null):void {
			if(!_workerEncodeService.isConnecting) {
				try {
					_workerEncodeService.request({key:_encodeKey});
				}
				catch(err:Error) {
					Logger.warn(sprintf('Error banging encode worker:\n%s', err.message));
				}
			}
		}

		
		
		/**
		 * Encode worker done event handler.
		 * Uploading and encoding done, parse results.
		 * If everything is ok, add track to editor (after request).
		 * @param event Event data
		 */
		private function _onEncodeWorkerDone(event:WorkerEvent):void {
			var finished:Boolean;
			
			switch(event.workerStatusData.status) {
				case WorkerStatusData.STATUS_ERROR:
					finished = true;
					App.messageModal.show({title:'Encoding error', description:'Error while encoding your track.', buttons:MessageModal.BUTTONS_OK, icon:MessageModal.ICON_WARNING});
					break;
					
				case WorkerStatusData.STATUS_FINISHED:
					finished = true;
					
					try {
						_trackCreateService.request({
						  songID:       App.connection.coreSongData.songID,
						  userID:       App.connection.coreUserData.userID,
						  filename:     event.workerStatusData.output,
						  milliseconds: event.workerStatusData.length * 1000
						});
					}
					catch(err:Error) {
						_removeEncodeWorker();
						App.messageModal.show({title:'Encoding error', description:sprintf('Error while encoding your track:\n%s', err.message), buttons:MessageModal.BUTTONS_OK});
						return;
					}
			}
			
			if(finished) _removeEncodeWorker();
		}

		
		
		/**
		 * Encode worker failed event handler.
		 * @param event Event data
		 */
		private function _onEncodeWorkerFailed(event:RemotingEvent):void {
			App.messageModal.show({title:'Encoding error', description:'Encoding of your track failed.', buttons:MessageModal.BUTTONS_OK, icon:MessageModal.ICON_WARNING});
			_removeEncodeWorker();
		}

		
		
		/**
		 * Track upload failed event handler.
		 * @param event Event data
		 */
		private function _onTrackCreateFailed(event:RemotingEvent):void {
			App.messageModal.show({title:'Save track', description:'Error while creating track.', buttons:MessageModal.BUTTONS_OK, icon:MessageModal.ICON_WARNING});
			_removeEncodeWorker();
		}

		
		
		/**
		 * Track upload done event handler.
		 * Add track to editor.
		 * @param event Event data
		 */
		private function _onTrackCreateDone(event:TrackCreateEvent):void {
			_removeEncodeWorker();
			App.editor.addTrack(event.trackData.trackID);
		}
		
		
		
	}
}