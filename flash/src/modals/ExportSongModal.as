package modals {
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import org.osflash.thunderbolt.Logger;
	import org.vancura.controls.Button;
	import org.vancura.graphics.QTextField;
	import org.vancura.util.addChildren;
	
	import de.popforge.utils.sprintf;
	
	import application.App;
	import application.AppEvent;
	
	import config.Embeds;
	import config.Filters;
	import config.Formats;
	import config.Settings;
	
	import remoting.data.WorkerStatusData;
	import remoting.dynamic_services.SongExportService;
	import remoting.dynamic_services.WorkerExportService;
	import remoting.events.RemotingEvent;
	import remoting.events.SongExportEvent;
	import remoting.events.WorkerEvent;	

	
	
	/**
	 * Export song modal.
	 * 
	 * TODO: Write documentation
	 * 
	 * @author Vaclav Vancura (http://vaclav.vancura.org)
	 * @since Jul 19, 2008
	 */
	public class ExportSongModal extends ModalCommon {

		
		
		private static const _PANEL_WIDTH:Number = 425;
		private static const _PANEL_HEIGHT:Number = 291;
		private static const _PANEL_Y:Number = -38;
		private static const _WORKER_ID:String = 'workerExport';
		private var _titleTF:QTextField;
		private var _cancelBtn:Button;
		private var _exportBtn:Button;
		private var _descriptionTF:QTextField;
		private var _isExporting:Boolean;
		private var _exportWorkerTimer:Timer;
		private var _workerExportService:WorkerExportService;
		private var _songExportService:SongExportService;
		private var _exportKey:String;

		
		
		/**
		 * Constructor.
		 * @param o QSprite config Object
		 */
		public function ExportSongModal(o:Object = null) {
			super(o);
			
			// add graphics
			_titleTF = new QTextField({text:'Export song', x:50, y:64, width:_PANEL_WIDTH - 100, defaultTextFormat:Formats.modalTitle, filters:Filters.modalTitle, sharpness:50});
			_descriptionTF = new QTextField({text:'The current project will be saved as an MP3 file. You will see the exporting progress in the progress panel below and once the exporting is done, you will be notified.\n\nDo you want to proceed?', x:50, y:100, width:_PANEL_WIDTH - 100, defaultTextFormat:Formats.modalDescription});
			
			// add buttons
			_cancelBtn = new Button({x:Math.round(_PANEL_WIDTH) / 2 - 104, y:188, width:100, text:'Cancel', icon:new Embeds.glyphCancelBD});
			_exportBtn = new Button({x:Math.round(_PANEL_WIDTH) / 2 + 4, y:188, width:100, text:'Export'});
			
			// add to display list
			addChildren($contentSpr, _titleTF, _descriptionTF, _cancelBtn, _exportBtn);

			// add exporting stuff
			_songExportService = new SongExportService();
			_exportWorkerTimer = new Timer(Settings.WORKER_INTERVAL * 1000);
			_workerExportService = new WorkerExportService();

			// add event listeners
			_cancelBtn.addEventListener(MouseEvent.CLICK, _onCancelClick, false, 0, true);
			_exportBtn.addEventListener(MouseEvent.CLICK, _onExportClick, false, 0, true);
			_exportWorkerTimer.addEventListener(TimerEvent.TIMER, _onExportWorkerBang, false, 0, true);
			_songExportService.addEventListener(RemotingEvent.REQUEST_FAILED, _onSongExportFailed, false, 0, true);
			_songExportService.addEventListener(SongExportEvent.REQUEST_DONE, _onSongExportWaiting, false, 0, true);
			_workerExportService.addEventListener(RemotingEvent.REQUEST_FAILED, _onExportWorkerFailed, false, 0, true);
			_workerExportService.addEventListener(WorkerEvent.REQUEST_DONE, _onExportWorkerDone, false, 0, true);
		}

		
		
		/**
		 * Show export song modal.
		 * @param c Config object
		 */
		override public function show(c:Object = null):void {
			if(!_isExporting) {
				Logger.info('Showing song export modal.');
				
				super.show(c);
				
				// set default sizes
				width = _PANEL_WIDTH;
				height = _PANEL_HEIGHT;
				y = _PANEL_Y;
				
				// add service urls
				// (in constructor it's unknown since config is not loaded yet)
				_songExportService.url = App.connection.mediaPath + App.connection.configService.mediaExportRequestURL;
				_workerExportService.url = App.connection.mediaPath + App.connection.configService.workerExportRequestURL;
			}
			else {
				// song is already exporting
				App.messageModal.show({title:'Export song', description:'Your song is already exporting. Please watch its progress in the panel below.', buttons:MessageModal.BUTTONS_OK});
			}
			
			// dispatch
			dispatchEvent(new AppEvent(AppEvent.HIDE_DROPBOX, true));
		}

		
		
		/**
		 * Remove export worker event listeners.
		 */
		private function _removeExportWorker():void {
			_exportWorkerTimer.stop();
			_isExporting = false;
			App.worker.removeWorker(_WORKER_ID);
		}

		
		
		/**
		 * Cancel button click event handler.
		 * @param event Event data
		 */
		private function _onCancelClick(event:MouseEvent):void {
			hide();
			
			// dispatch
			dispatchEvent(new AppEvent(AppEvent.HIDE_DROPBOX, true));
		}

		
		
		private function _onExportClick(event:MouseEvent):void {
			_isExporting = true;
			
			try {
				_songExportService.request({songData:App.connection.coreSongData});
			}
			catch(err:Error) {
				App.messageModal.show({title:'Exporting error', description:sprintf('Error while exporting your track:\n%s', err.message), buttons:MessageModal.BUTTONS_OK});
				_isExporting = false;
			}
			
			hide();
			
			// dispatch
			dispatchEvent(new AppEvent(AppEvent.HIDE_DROPBOX, true));
		}

		
		
		/**
		 * Song export done event handler.
		 * Add track to editor.
		 * @param event Event data
		 */
		private function _onSongExportWaiting(event:SongExportEvent):void {
			_exportKey = event.key;
			
			try {
				App.worker.addWorker(_WORKER_ID, 'Exporting song');
				_exportWorkerTimer.start();
				_onExportWorkerBang();
				_isExporting = true;
			}
			catch(err1:Error) {
				Logger.error(sprintf('Could not add export worker:\n%s', err1.message));
				hide();
			}
			
			// dispatch
			dispatchEvent(new AppEvent(AppEvent.HIDE_DROPBOX, true));
		}

		
		
		/**
		 * Export worker bang event handler.
		 * Bangs export worker. But only if it is not connecting, preventing overloading.
		 * @param event Event data
		 */
		private function _onExportWorkerBang(event:Event = null):void {
			if(!_workerExportService.isConnecting) {
				try {
					_workerExportService.request({key:_exportKey});
				}
				catch(err:Error) {
					Logger.warn(sprintf('Error banging export worker:\n%s', err.message));
				}
			}
		}

		
		
		/**
		 * Export worker done event handler.
		 * Uploading and exporting done, parse results.
		 * @param event Event data
		 */
		private function _onExportWorkerDone(event:WorkerEvent):void {
			var finished:Boolean;
			
			switch(event.workerStatusData.status) {
				case WorkerStatusData.STATUS_ERROR:
					finished = true;
					App.messageModal.show({title:'Exporting error', description:'Error while exporting your song.', buttons:MessageModal.BUTTONS_OK, icon:MessageModal.ICON_WARNING});
					_removeExportWorker();
					break;
					
				case WorkerStatusData.STATUS_FINISHED:
					finished = true;
					_removeExportWorker();
					
					try {
						Logger.info(sprintf('Exporting done (url=%s)', event.workerStatusData.output));
						App.downloadSongModal.downloadURL = App.connection.serverPath + event.workerStatusData.output; 
						App.downloadSongModal.show();
					}
					catch(err:Error) {
						App.messageModal.show({title:'Exporting error', description:sprintf('Error while exporting your song:\n%s', err.message), buttons:MessageModal.BUTTONS_OK});
						_removeExportWorker();
					}
			}
			
			// dispatch
			dispatchEvent(new AppEvent(AppEvent.HIDE_DROPBOX, true));
		}

		
		
		/**
		 * Export worker failed event handler.
		 * @param event Event data
		 */
		private function _onExportWorkerFailed(event:RemotingEvent):void {
			App.messageModal.show({title:'Exporting error', description:'Exporting of your song failed.', buttons:MessageModal.BUTTONS_OK, icon:MessageModal.ICON_WARNING});
			_isExporting = false;
			_removeExportWorker();
			hide();
			
			// dispatch
			dispatchEvent(new AppEvent(AppEvent.HIDE_DROPBOX, true));
		}

		
		
		/**
		 * Song export failed event handler.
		 * @param event Event data
		 */
		private function _onSongExportFailed(event:RemotingEvent):void {
			App.messageModal.show({title:'Export song error', description:'Error while exporting song.', buttons:MessageModal.BUTTONS_OK, icon:MessageModal.ICON_WARNING});
			_isExporting = false;
			_removeExportWorker();
			hide();
			
			// dispatch
			dispatchEvent(new AppEvent(AppEvent.HIDE_DROPBOX, true));
		}
	}
}