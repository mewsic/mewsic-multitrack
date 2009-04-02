package {
	import flash.display.Sprite;
	import flash.events.Event;

	import org.osflash.thunderbolt.Logger;
	import org.vancura.modalwindow.ModalWindow;
	
	import de.popforge.utils.sprintf;

	import application.App;
	import application.AppEvent;

	import caurina.transitions.Tweener;

	import config.Settings;

	[SWF(width='690', height='40', backgroundColor='0xF5F5F5', frameRate='30')]

	[Frame(factoryClass='GlobalPreloader')]



	/**
	 * Application starter.
	 * This is the core of the whole application.
	 *
	 * @author Vaclav Vancura (http://vaclav.vancura.org)
	 * @since Jun 13, 2008
	 */
	public class Adelao_Myousica_Multitrack_Editor extends Sprite {



		public static var app:App;
		public static var modalWindow:ModalWindow;



		/**
		 * Constructor.
		 */
		public function Adelao_Myousica_Multitrack_Editor() {
			// we have to wait a while until stage is displayed:
			Tweener.addTween((new Object()), {time:.05, onComplete:function():void {

				// add modal window
				modalWindow = new ModalWindow();

				try {
					// check for settings in flashvars
					// and throw errors if something is missing
					if(root.loaderInfo.parameters.serverPath == undefined) throw new Error('Server path not defined (you have to use serverPath parameter).');
					if(root.loaderInfo.parameters.settingsXMLPath == undefined) throw new Error('Settings XML path not defined (you have to use settingsXMLPath parameter).');
					if(root.loaderInfo.parameters.songID == undefined) throw new Error('Song ID not defined (you have to use songID parameter).');

					// init logger and enable it if log is enabled in flashvars
					Settings.isLogEnabled = (root.loaderInfo.parameters.isLogEnabled == 'yes');
					Logger.hide = !Settings.isLogEnabled;

					// set service dump grabbing if enabled in flashvars
					Settings.isServiceDumpEnabled = (root.loaderInfo.parameters.isServiceDumpEnabled == 'yes');

					// init application
					app = new App({serverPath:root.loaderInfo.parameters.serverPath, settingsXMLPath:root.loaderInfo.parameters.settingsXMLPath, songID:root.loaderInfo.parameters.songID, loadSong:loaderInfo.parameters.loadSong == 'yes'});

					// add to display list
					addChild(app);

					// postinit (stage is specified after addChild())
					app.postInit();

					// add events
					app.addEventListener(AppEvent.FATAL_ERROR, _onAppFatalError, false, 0, true);
					app.addEventListener(AppEvent.CALL_STAGE_RESIZE, _onResize, false, 0, true);
					stage.addEventListener(Event.RESIZE, _onResize, false, 0, true);

					// initial resize
					_onResize();
				}
				catch(err:Error) {
					// something bad happened
					error(sprintf('Error initializing application\n%s', err.message));
				}
				finally {
					// add modal window to the display list and set it's width
					addChild(modalWindow);
					modalWindow.width = Settings.STAGE_WIDTH;
				}
			}});
		}



		/**
		 * Display ModalWindow with error output.
		 * This function is used by the core only.
		 * The application itself uses it's own MessageBox functionality.
		 * @param description Error description ('Unknown exception' used if nothing specified)
		 */
		public function error(description:String = 'Unknown exception'):void {
			modalWindow.show(description); // output to modal window
		}



		/**
		 * Set application width.
		 * Not used in this application as it can't be resized by the user.
		 * @param value Width
		 */
		override public function set width(value:Number):void {
		}



		/**
		 * Set application height.
		 * Not used in this application as it can't be resized by the user.
		 * @param value Height
		 */
		override public function set height(value:Number):void {
		}



		/**
		 * The onResize event handler.
		 * Not used in this application as it can't be resized by the user.
		 * @param e Event data
		 */
		private function _onResize(event:Event = null):void {
		}



		/**
		 * Fatal error event handler.
		 * Dispatched when something really bad happened.
		 * It will display ModalWindow, so it can be used by the core only.
		 * The application itself has another method to display error messages (via MessageBox)
		 * @param e Event data
		 */
		private function _onAppFatalError(event:AppEvent):void {
			error(sprintf('Application fatal error: %s', event.description));
		}
	}
}
