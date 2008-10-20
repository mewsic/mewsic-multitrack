package modals {
	import application.App;
	import application.AppEvent;
	
	import config.Embeds;
	import config.Filters;
	import config.Formats;
	import config.Settings;
	
	import controls.Button;
	import controls.Dropbox;
	import controls.Input;
	import controls.InputEvent;
	import controls.Toolbar;
	
	import dropbox.DropboxEvent;
	
	import remoting.ServiceCommon;
	import remoting.data.SongData;
	import remoting.data.WorkerStatusData;
	import remoting.dynamic_services.TrackCreateService;
	import remoting.dynamic_services.TrackEncodeService;
	import remoting.dynamic_services.WorkerEncodeService;
	import remoting.events.RemotingEvent;
	import remoting.events.TrackCreateEvent;
	import remoting.events.TrackEncodeEvent;
	import remoting.events.WorkerEvent;
	
	import de.popforge.utils.sprintf;
	
	import org.osflash.thunderbolt.Logger;
	import org.vancura.graphics.QTextField;
	import org.vancura.util.addChildren;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.text.TextFieldAutoSize;
	import flash.utils.Timer;	

	
	
	/**
	 * Save track modal.
	 * 
	 * TODO: Write documentation
	 * 
	 * @author Vaclav Vancura (http://vaclav.vancura.org)
	 * @since Jul 19, 2008
	 */
	public class SaveTrackModal extends ModalCommon {

		
		
		private static const _PANEL_WIDTH:Number = 720;
		private static const _PANEL_HEIGHT:Number = 329;
		private static const _PANEL_Y:Number = -50;
		private static const _WORKER_ID:String = 'workerSaveTrack';
		private var _toolbar1:Toolbar;
		private var _instrumentDropbox:Dropbox;
		private var _keyDropbox:Dropbox;
		private var _bpmInput:Input;
		private var _titleInput:Input;
		private var _instrumentDescriptionInput:Input;
		private var _descriptionInput:Input;
		private var _titleTF:QTextField;
		private var _ideaTF:QTextField;
		private var _cancelBtn:Button;
		private var _saveBtn:Button;
		private var _ideaBtn:Button;
		private var _isEncoding:Boolean;
		private var _isIdea:Boolean;
		private var _encodeKey:String;
		private var _workerEncodeService:WorkerEncodeService;
		private var _trackEncodeService:TrackEncodeService;
		private var _trackCreateService:TrackCreateService;
		private var _encodeWorkerTimer:Timer;

		
		
		/**
		 * Constructor.
		 * @param o QSprite config Object
		 */
		public function SaveTrackModal(o:Object = null) {
			super(o);
			
			// add titles
			_titleTF = new QTextField({x:50, y:64, width:_PANEL_WIDTH - 100, defaultTextFormat:Formats.modalTitle, filters:Filters.modalTitle, sharpness:50});
			_ideaTF = new QTextField({text:'Idea track', x:32, y:76, defaultTextFormat:Formats.modalDescriptionLeft, autoSize:TextFieldAutoSize.LEFT});
			
			// add toolbars
			_toolbar1 = new Toolbar({x:50, y:104, width:620, height:106, skin:new Embeds.toolbarModalBD()});
			
			// add inputs
			_keyDropbox = new Dropbox({introText:'Key', width:113, x:312, y:9});
			_bpmInput = new Input({width:182, x:428, y:9});
			_titleInput = new Input({introText:'Track name', width:299, x:10, y:9});
			_descriptionInput = new Input({introText:'Track description', width:600, x:10, y:41});
			_instrumentDescriptionInput = new Input({introText:'Instrument description', width:298, x:312, y:73});
			_instrumentDropbox = new Dropbox({introText:'Instrument', x:100, y:73, width:209});
			
			// add buttons
			_cancelBtn = new Button({x:Math.round(_PANEL_WIDTH) / 2 - 194, y:226, width:100, text:'Cancel', icon:new Embeds.glyphCancelBD()});
			_saveBtn = new Button({x:Math.round(_PANEL_WIDTH) / 2 - 86, y:226, width:280, icon:new Embeds.glyphSaveBD()});
			_ideaBtn = new Button({x:10, y:77, width:18, height:16, skin:new Embeds.buttonGrayNanoBD(), textOutFilters:Filters.buttonGrayLabel, textOverFilters:Filters.buttonGrayLabel, textPressFilters:Filters.buttonGrayLabel, textOutOffsY:-1, textOverOffsY:-1, textPressOffsY:0});
			
			// add to display list
			addChildren(_toolbar1, _instrumentDropbox, _keyDropbox, _bpmInput, _titleInput, _instrumentDescriptionInput, _descriptionInput, _ideaBtn, _ideaTF);
			addChildren($contentSpr, _titleTF, _toolbar1, _cancelBtn, _saveBtn);
			
			// add encoding stuff
			_encodeWorkerTimer = new Timer(Settings.WORKER_INTERVAL * 1000);
			_trackEncodeService = new TrackEncodeService();
			_trackCreateService = new TrackCreateService();
			_workerEncodeService = new WorkerEncodeService();
			
			// add event listeners
			_cancelBtn.addEventListener(MouseEvent.CLICK, _onCancelClick, false, 0, true);
			_saveBtn.addEventListener(MouseEvent.CLICK, _onSaveClick, false, 0, true);
			_ideaBtn.addEventListener(MouseEvent.CLICK, _onIdeaClick, false, 0, true);
			_encodeWorkerTimer.addEventListener(TimerEvent.TIMER, _onEncodeWorkerBang, false, 0, true);
			_instrumentDropbox.addEventListener(InputEvent.CHANGE, _parseData, false, 0, true);
			_keyDropbox.addEventListener(InputEvent.CHANGE, _parseData, false, 0, true);
			_bpmInput.addEventListener(InputEvent.CHANGE, _parseData, false, 0, true);
			_titleInput.addEventListener(InputEvent.CHANGE, _parseData, false, 0, true);
			_instrumentDescriptionInput.addEventListener(InputEvent.CHANGE, _parseData, false, 0, true);
			_descriptionInput.addEventListener(InputEvent.CHANGE, _parseData, false, 0, true);
			_trackEncodeService.addEventListener(RemotingEvent.REQUEST_FAILED, _onTrackEncodeFailed, false, 0, true);
			_trackEncodeService.addEventListener(TrackEncodeEvent.REQUEST_DONE, _onTrackEncodeDone, false, 0, true);
			_trackCreateService.addEventListener(RemotingEvent.REQUEST_FAILED, _onTrackCreateFailed, false, 0, true);
			_trackCreateService.addEventListener(TrackCreateEvent.REQUEST_DONE, _onTrackCreateDone, false, 0, true);
			_workerEncodeService.addEventListener(RemotingEvent.REQUEST_FAILED, _onEncodeWorkerFailed, false, 0, true);
			_workerEncodeService.addEventListener(WorkerEvent.REQUEST_DONE, _onEncodeWorkerDone, false, 0, true);
			_titleInput.addEventListener(InputEvent.FOCUS_IN, _onInputFocusIn, false, 0, true);
			_instrumentDescriptionInput.addEventListener(InputEvent.FOCUS_IN, _onInputFocusIn, false, 0, true);
			_descriptionInput.addEventListener(InputEvent.FOCUS_IN, _onInputFocusIn, false, 0, true);
			_bpmInput.addEventListener(InputEvent.FOCUS_IN, _onInputFocusIn, false, 0, true);
			_instrumentDropbox.addEventListener(DropboxEvent.CLICK, _parseData, false, 0, true);
			_keyDropbox.addEventListener(DropboxEvent.CLICK, _parseData, false, 0, true);
			
			// fill dropboxes
			_keyDropbox.list = Settings.KEY_LIST;
		}

		
		
		public function postInit():void {
			_instrumentDropbox.list = App.connection.instrumentsService.instrumentsNameList;
		}

		
		
		/**
		 * Show record track modal.
		 * @param c Config object
		 */
		override public function show(c:Object = null):void {
			if(!_isEncoding) {
				Logger.info('Showing save track modal.');
				super.show(c);
				
				// reset values
				_isEncoding = false;
				_titleTF.text = 'Save track';
				_instrumentDropbox.reset();
				_keyDropbox.reset();
				_titleInput.reset();
				_instrumentDescriptionInput.reset();
				_descriptionInput.reset();
				
				// grab values from core song
				_bpmInput.text = App.connection.coreSongData.songBPM.toString(); 
				
				// set initial visual properties
				_saveBtn.alpha = .4;
				_saveBtn.areEventsEnabled = false;
				_cancelBtn.x = Math.round(_PANEL_WIDTH) / 2 - 194;
				_saveBtn.x = Math.round(_PANEL_WIDTH) / 2 - 86;
				_saveBtn.width = 280;
				_saveBtn.text = 'Save (please fill all information above)';
				
				// set default sizes
				width = _PANEL_WIDTH;
				height = _PANEL_HEIGHT;
				y = _PANEL_Y;
				
				// add service urls
				// (in constructor it's unknown since config is not loaded yet)
				_trackEncodeService.url = App.connection.mediaPath + App.connection.configService.mediaEncodeRequestURL;
				_trackCreateService.url = App.connection.serverPath + App.connection.configService.trackCreateRequestURL;
				_workerEncodeService.url = App.connection.mediaPath + App.connection.configService.workerEncodeRequestURL;
			}
			else {
				// track is already encoding
				App.messageModal.show({title:'Encoding track', description:'Your track is already encoding.\nPlease watch its progress in the panel below.', buttons:MessageModal.BUTTONS_OK});
			}
			
			// dispatch
			dispatchEvent(new AppEvent(AppEvent.HIDE_DROPBOX, true));
		}

		
		
		/**
		 * Hide save modal.
		 */
		override public function hide():void {
			if(_isEncoding) {
				_isEncoding = false;
			}
			super.hide();
			
			// dispatch
			dispatchEvent(new AppEvent(AppEvent.HIDE_DROPBOX, true));
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
		 * Enables save button if everything is filled in.
		 * Disables if something is missing.
		 */
		private function _parseData(event:Event = null):void {
			var allow:Boolean = true;
			
			if(_instrumentDropbox.text == '') allow = false;
			if(_keyDropbox.text == '') allow = false;
			if(_bpmInput.text == '') allow = false;
			if(_titleInput.text == '') allow = false;
			
			_saveBtn.areEventsEnabled = (allow);
			_saveBtn.alpha = (allow) ? 1 : .4;
			_saveBtn.text = (allow) ? 'Save' : 'Save (please fill all information above)';
			_cancelBtn.morph({x:(allow) ? (Math.round(_PANEL_WIDTH) / 2 - 104) : (Math.round(_PANEL_WIDTH) / 2 - 194)});
			_saveBtn.morph({x:(allow) ? (Math.round(_PANEL_WIDTH) / 2 + 4) : (Math.round(_PANEL_WIDTH) / 2 - 86), width:(allow) ? 100 : 280});
		}

		
		
		/**
		 * Cancel button click event handler.
		 * @param event Event data
		 */
		private function _onCancelClick(event:MouseEvent):void {
			App.editor.killRecordTrack();
			
			hide();
			
			// dispatch
			dispatchEvent(new AppEvent(AppEvent.HIDE_DROPBOX, true));
		}

		
		
		/**
		 * Save button click event handler.
		 * Disable save button.
		 * Start save.
		 * @param event Event data
		 */
		private function _onSaveClick(event:MouseEvent):void {
			_isEncoding = true;
			
			try {
				_trackEncodeService.request({filename:App.connection.streamService.filename});
				hide();
			}
			catch(err:Error) {
				App.messageModal.show({title:'Saving error', description:sprintf('Error while saving your track:\n%s', err.message), buttons:MessageModal.BUTTONS_OK});
				_isEncoding = false;
				hide();
			}
			
			// dispatch
			dispatchEvent(new AppEvent(AppEvent.HIDE_DROPBOX, true));
		}

		
		
		/**
		 * Track encode failed event handler.
		 * @param event Event data
		 */
		private function _onTrackEncodeFailed(event:RemotingEvent):void {
			App.messageModal.show({title:'Save track', description:'Error while adding track.', buttons:MessageModal.BUTTONS_OK, icon:MessageModal.ICON_WARNING});
			_removeEncodeWorker();
			
			// dispatch
			dispatchEvent(new AppEvent(AppEvent.HIDE_DROPBOX, true));
		}

		
		
		/**
		 * Track encode done event handler.
		 * Add track to editor.
		 * @param event Event data
		 */
		private function _onTrackEncodeDone(event:TrackEncodeEvent):void {
			_encodeKey = event.key;
			
			try {
				App.worker.addWorker(_WORKER_ID, 'Encoding track');
				_encodeWorkerTimer.start();
				_onEncodeWorkerBang();
			}
			catch(err:Error) {
				Logger.error(sprintf('Cannot start encoding of your track.\nPlease wait a while and try again.\n%s', err.message));
			}
			
			// dispatch
			dispatchEvent(new AppEvent(AppEvent.HIDE_DROPBOX, true));
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
		 * Saving and encoding done, parse results.
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
						var si:String = (_instrumentDropbox.text == '') ? '' : App.connection.instrumentsService.byName(_instrumentDropbox.text).instrumentID.toString();
						_trackCreateService.request({songID:App.connection.coreSongData.songID, userID:App.connection.coreUserData.userID, filename:event.workerStatusData.output, milliseconds:event.workerStatusData.length * 1000, instrumentID:si, key:_keyDropbox.text, bpm:_bpmInput.text, title:_titleInput.text, instrumentDescription:_instrumentDescriptionInput.text, description:_descriptionInput.text, isIdea:_isIdea});
					}
					catch(err:Error) {
						_removeEncodeWorker();
						App.messageModal.show({title:'Encoding error', description:sprintf('Error while encoding your track:\n%s', err.message), buttons:MessageModal.BUTTONS_OK});
						return;
					}
			}
			
			if(finished) _removeEncodeWorker();
			
			// dispatch
			dispatchEvent(new AppEvent(AppEvent.HIDE_DROPBOX, true));
		}

		
		
		/**
		 * Encode worker failed event handler.
		 * @param event Event data
		 */
		private function _onEncodeWorkerFailed(event:RemotingEvent):void {
			App.messageModal.show({title:'Encoding error', description:'Encoding of your track failed.', buttons:MessageModal.BUTTONS_OK, icon:MessageModal.ICON_WARNING});
			_removeEncodeWorker();
			
			// dispatch
			dispatchEvent(new AppEvent(AppEvent.HIDE_DROPBOX, true));
		}

		
		
		/**
		 * Track upload failed event handler.
		 * @param event Event data
		 */
		private function _onTrackCreateFailed(event:RemotingEvent):void {
			App.messageModal.show({title:'Save track', description:'Error while creating track.', buttons:MessageModal.BUTTONS_OK, icon:MessageModal.ICON_WARNING});
			_removeEncodeWorker();
			
			// dispatch
			dispatchEvent(new AppEvent(AppEvent.HIDE_DROPBOX, true));
		}

		
		
		/**
		 * Track upload done event handler.
		 * Add track to editor.
		 * @param event Event data
		 */
		private function _onTrackCreateDone(event:TrackCreateEvent):void {
			_removeEncodeWorker();
			App.editor.addTrack(event.trackData.trackID);
			App.editor.killRecordTrack();
			
			// dispatch
			dispatchEvent(new AppEvent(AppEvent.HIDE_DROPBOX, true));
		}

		
		
		/**
		 * Idea button click event handler.
		 * Toggle checkbox.
		 * @param event Event data
		 */
		private function _onIdeaClick(event:MouseEvent):void {
			_isIdea = !_isIdea;
			_ideaBtn.icon = (_isIdea) ? new Embeds.glyphCheckboxOnBD() : new Embeds.glyphCheckboxOffBD();
			
			// dispatch
			dispatchEvent(new AppEvent(AppEvent.HIDE_DROPBOX, true));
		}

		
		
		/**
		 * Input focus event listener.
		 * @param event Event data
		 */
		private function _onInputFocusIn(event:InputEvent):void {
			dispatchEvent(new AppEvent(AppEvent.HIDE_DROPBOX, true));
		}
	}
}