package {
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.external.ExternalInterface;
	import flash.geom.Rectangle;
	import flash.utils.getDefinitionByName;

	import org.bytearray.display.ScaleBitmap;
	import org.vancura.graphics.QSprite;

	import caurina.transitions.Tweener;	

	
	
	/**
	 * Global preloader.
	 * First preloader bar with smoothing.
	 * 
	 * @author Vaclav Vancura (http://vaclav.vancura.org)
	 * @since Jun 19, 2008
	 */
	public class GlobalPreloader extends MovieClip {

		[Embed(source='../lib/assets/preloader_assets.swf', symbol='BackBD')] private static var _backBD:Class; 
		[Embed(source='../lib/assets/preloader_assets.swf', symbol='ProgressBD')] private static var _progressBD:Class;
		
		private static const _MAIN_CLASS_NAME:String = 'Multitrack_Editor';
		private static const _STAGE_WIDTH:uint = 690;
		private static const _PROGRESS_WIDTH:uint = 670;
		private var _visualSpr:QSprite;
		private var _backSBM:ScaleBitmap;
		private var _progressSBM:ScaleBitmap;
		private var _isLoading:Boolean = true;

		
		
		/**
		 * Global preloader constructor.
		 * GlobalPreloader handles all global preloading, displays preloading bar etc.
		 * When everything is loaded, it calls application/App and launches the rest of runtime.
		 */
		public function GlobalPreloader() {
			// stop main timeline
			stop();

			// init stage
			stage.showDefaultContextMenu = false;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;

			// add display objects
			_visualSpr = new QSprite();
			_backSBM = new ScaleBitmap((new _backBD() as Bitmap).bitmapData);
			_backSBM.scale9Grid = new Rectangle(17, 0, 66, 30);
			_backSBM.width = _STAGE_WIDTH;
			_progressSBM = new ScaleBitmap((new _progressBD() as Bitmap).bitmapData);
			_progressSBM.scale9Grid = new Rectangle(5, 0, 6, 8);
			_progressSBM.x = 12;
			_progressSBM.y = 6;
			_progressSBM.width = 1;
			_progressSBM.alpha = 0;

			// add to display list
			addChild(_visualSpr);
			_visualSpr.addChild(_backSBM);
			_visualSpr.addChild(_progressSBM);

			// start intro logo animation
			Tweener.addTween(_progressSBM, {time:.2, alpha:1, delay:.2, transition:'easeInSine'});

			// add events
			addEventListener(Event.ENTER_FRAME, _onEnterFrame, false, 0, true);
		}

		
		
		/**
		 * Global preloader destructor.
		 * Called when everything successfully preloaded.
		 * Calls application/App.
		 */
		public function destroy():void {
			// remove progress bar animation
			Tweener.removeTweens(_progressSBM);
			
			// application is not loading anymore
			_isLoading = false;

			// remove events
			removeEventListener(Event.ENTER_FRAME, _onEnterFrame);

			// jump to next frame
			nextFrame();

			// wait and kill preload graphics
			Tweener.addTween(_visualSpr, {time:.5, alpha:0, transition:'linear', onComplete:function():void {
				_visualSpr.removeChild(_backSBM);
				_visualSpr.removeChild(_progressSBM);
				removeChild(_visualSpr);
				_visualSpr = null;
			}});

			// call main class
			var mainClass:Class;
			try {
				mainClass = Class(getDefinitionByName(_MAIN_CLASS_NAME));
			}
			catch(err:Error) {
				// main class not found
				var msg:String = 'Main class (' + _MAIN_CLASS_NAME + ') not found';
				try {
					// try to display javascript alert()
					ExternalInterface.call('alert', msg);
				}
				catch(f:Error) {
					// no ExternalInterface available (e.g. app is displayed in standalone Flash Player)
					trace(msg);
				}
				return;
			}

			// main class found, so launch it
			var app:Object = new mainClass();
			addChild(app as DisplayObject);

			// the app is running now
		}

		
		
		/**
		 * ENTER_FRAME event handler.
		 * Refresh progress bar.
		 * @param event Event data
		 */
		private function _onEnterFrame(event:Event):void {
			if(framesLoaded == totalFrames && _isLoading) destroy();
			else {
				var w:int = Math.round(_PROGRESS_WIDTH / (root.loaderInfo.bytesTotal / root.loaderInfo.bytesLoaded));
				Tweener.addTween(_progressSBM, {width:w, time:.25, rounded:true});
			}
		}
	}
}
