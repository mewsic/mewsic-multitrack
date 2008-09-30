package controls {
	import flash.events.Event;
	
	import org.osflash.thunderbolt.Logger;
	import org.vancura.graphics.QBitmap;
	import org.vancura.graphics.QSprite;
	import org.vancura.util.addChildren;
	import org.vancura.util.removeChildren;
	
	import com.gskinner.utils.Rnd;
	
	import de.popforge.utils.sprintf;
	
	import br.com.stimuli.loading.BulkErrorEvent;
	import br.com.stimuli.loading.BulkLoader;
	
	import caurina.transitions.Tweener;
	
	import config.Embeds;
	import config.Settings;	

	
	
	/**
	 * Thumbnail control.
	 * 
	 * @author Vaclav Vancura (http://vaclav.vancura.org)
	 * @since Jun 14, 2008
	 */
	public class Thumbnail extends QSprite {

		
		
		private var _frameBM:QBitmap;
		private var _progressBM:QBitmap;
		private var _errorBM:QBitmap;
		private var _contentBM:QBitmap;
		private var _url:String;
		private var _isLoaded:Boolean;
		private var _isLoading:Boolean;
		private var _contentID:String;
		private var _loader:BulkLoader;

		
		
		/**
		 * Constructor.
		 * @param c QSprite config Object
		 */
		public function Thumbnail(c:Object = null) {
			super(c);
			
			// add graphics
			_frameBM = new QBitmap({embed:new Embeds.thumbnailFrameBD()});
			_progressBM = new QBitmap({visible:false, embed:new Embeds.thumbnailProgressBD()});
			_errorBM = new QBitmap({visible:false, embed:new Embeds.thumbnailErrorBD()});
			_contentBM = new QBitmap({visible:false, x:3, y:3});

			// add to display list
			addChildren(this, _progressBM, _errorBM, _contentBM, _frameBM);
			
			// add BulkLoader
			var id:String = sprintf('thumbnail.%u.%u', uint(new Date()), Rnd.integer(1000, 9999)); 
			_contentID = sprintf('%s.content', id);
			_loader = new BulkLoader(sprintf('%s.loader', id));
		}

		
		
		/**
		 * Destructor.
		 */
		public function destroy():void {
			// remove from display list
			removeChildren(this, _progressBM, _errorBM, _contentBM, _frameBM);
		}
		
		
		
		/**
		 * Load thumbnail.
		 * @param url Thumbnail URL
		 */
		public function load(url:String):void {
			// if thumbnail is already loaded, unload it first
			if(_isLoaded) unload();
			
			// set flags
			_url = url;
			_isLoading = true;
			Logger.debug(sprintf('Loading thumbnail image (%s)', _url));
			
			// set visual properties
			_progressBM.visible = true;
			
			// load it
			with(_loader.add(url, {
				id:_contentID, type:BulkLoader.TYPE_IMAGE})) {
				addEventListener(Event.COMPLETE, _onLoadDone, false, 0, true);
				addEventListener(BulkLoader.ERROR, _onLoadError, false, 0, true);
			}
			_loader.start();
		}
		
		
		
		/**
		 * Unload thumbnail.
		 */
		public function unload():void {
			// set flags
			_isLoaded = false;
			
			// set visual properties
			_progressBM.visible = false;
			_errorBM.visible = false;
			
			// animation
			Tweener.addTween(_contentBM, {time:.25, alpha:0, transition:'easeInSine', onComplete:function():void {
				_contentBM.visible = false;
			}});
		}
		
		
		
		/**
		 * Loading done event handler.
		 * @param event Event data
		 */
		private function _onLoadDone(event:Event):void {
			// set flags
			_isLoading = false;
			_isLoaded = true;

			// set visual properties			
			_contentBM.alpha = 0;
			_contentBM.visible = true;
			_contentBM.bitmapData = _loader.getBitmapData(_contentID, true);
			_contentBM.width = 30;
			_contentBM.height = 30;
			_contentBM.smoothing = true;

			// fade in animation			
			Tweener.addTween(_contentBM, {time:Settings.FADEIN_TIME, alpha:1, transition:'easeOutSine', onComplete:function():void {
				_progressBM.visible = false;
				_errorBM.visible = false;
			}});
		}
		
		
		
		/**
		 * Loading error event handler.
		 * @param event Event data
		 */
		private function _onLoadError(event:BulkErrorEvent):void {
			Logger.warn(sprintf('Error loading thumbnail image (%s)', _url));
			
			// set flags
			_isLoading = false;
			
			// set visual properties
			_progressBM.visible = false;
			_errorBM.visible = true;
		}
	}
}
