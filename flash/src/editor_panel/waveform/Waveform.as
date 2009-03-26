package editor_panel.waveform {
	import application.App;
	
	import br.com.stimuli.loading.BulkLoader;
	
	import caurina.transitions.Tweener;
	
	import com.gskinner.utils.Rnd;
	
	import config.Embeds;
	import config.Formats;
	import config.Settings;
	
	import de.popforge.utils.sprintf;
	
	import editor_panel.tracks.TrackCommon;
	
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.events.Event;
	import flash.text.TextFieldAutoSize;
	
	import org.osflash.thunderbolt.Logger;
	import org.vancura.graphics.Drawing;
	import org.vancura.graphics.QBitmap;
	import org.vancura.graphics.QSprite;
	import org.vancura.graphics.QTextField;
	import org.vancura.util.addChildren;
	import org.vancura.util.removeChildren;	

	
	
	/**
	 * Waveform.
	 * 
	 * TODO: Write documentation
	 * 
	 * @author Vaclav Vancura (http://vaclav.vancura.org)
	 * @since Jun 27, 2008
	 */
	public class Waveform extends QSprite {

				
		
		private var _backSpr:QSprite;
		private var _waveformBackBM:QBitmap;
		private var _waveformFrontMaskSpr:QSprite;
		private var _waveformFrontBM:QBitmap;
		private var _waveformSpr:QSprite;
		private var _waveformMaskSpr:QSprite;
		private var _waveformRecordSpr:QSprite;
		private var _preloadInfoBackBM:QBitmap;
		private var _preloadInfoSpr:QSprite;
		private var _preloadInfoLabelTF:QTextField;
		private var _waveformID:String;
		private var _waveformWidth:uint;
		private var _milliseconds:uint;
		private var _type:String;
		private var _bitmap:BitmapData;

		
		
		/**
		 * Constructor.
		 * @param o MorphSprite config Object
		 */
		public function Waveform(t:String, o:Object = null) {
			super(o);
			
			_type = t;
			
			var id:String = sprintf('waveform.%u.%u', uint(new Date()), Rnd.integer(1000, 9999));			
			_waveformID = sprintf('%s.waveform', id);
			
			// add background
			_backSpr = new QSprite({alpha:.3});
			
			// add waveform
			_waveformMaskSpr = new QSprite();
			_waveformSpr = new QSprite({alpha:0, mask:_waveformMaskSpr});
			_waveformFrontMaskSpr = new QSprite({x:-2880});
			_waveformBackBM = new QBitmap({blendMode:BlendMode.MULTIPLY, y:-1, alpha:.1});
			_waveformFrontBM = new QBitmap({blendMode:BlendMode.MULTIPLY, y:-1, mask:_waveformFrontMaskSpr, alpha:.5});
			_waveformRecordSpr = new QSprite({visible:(_type == TrackCommon.RECORD_TRACK)});
			
			// add preloader info
			_preloadInfoSpr = new QSprite({visible:(_type == TrackCommon.STANDARD_TRACK), alpha:0, x:4, y:19});
			_preloadInfoBackBM = new QBitmap({embed:new Embeds.viewportPreloadInfoBackBD});
			_preloadInfoLabelTF = new QTextField({defaultTextFormat:Formats.viewportPreloadInfoLabel, text:'0 %', width:25, autoSize:TextFieldAutoSize.LEFT});

			// drawing
			Drawing.drawRect(_backSpr, 0, 0, 447, 24, 0xFFFFFF);
			Drawing.drawRect(_backSpr, 0, 25, 447, 24, 0xFFFFFF);
			Drawing.drawRect(_waveformMaskSpr, 0, 0, 447, 49);
			Drawing.drawRect(_waveformRecordSpr, 0, 0, 1, 49, 0xB90616);

			// add to display list
			addChildren(_waveformSpr, _waveformBackBM, _waveformFrontBM, _waveformFrontMaskSpr, _waveformRecordSpr);
			addChildren(_preloadInfoSpr, _preloadInfoBackBM, _preloadInfoLabelTF);
			addChildren(this, _backSpr, _waveformSpr, _waveformMaskSpr, _preloadInfoSpr);
			
			// fade in preload info
			Tweener.addTween(_preloadInfoSpr, {delay:Settings.FADEIN_TIME, time:Settings.FADEIN_TIME, alpha:1, transition:'easeOutSine'});
		}

		
		
		/**
		 * Destructor.
		 */
		public function destroy():void {
			// remove from display list
			removeChildren(_waveformSpr, _waveformBackBM, _waveformFrontBM, _waveformFrontMaskSpr, _waveformRecordSpr);
			removeChildren(_preloadInfoSpr, _preloadInfoBackBM, _preloadInfoLabelTF);
			removeChildren(this, _backSpr, _waveformSpr, _waveformMaskSpr, _preloadInfoSpr);
			
			_bitmap.dispose();
		}

		
		
		public function load(vf:String, ms:uint):void {
			Logger.info(sprintf('Loading waveform (%s)', vf));
			
			_milliseconds = ms;
			
			with(App.bulkLoader.add(vf, {
				id:_waveformID, type:BulkLoader.TYPE_IMAGE})) {
				addEventListener(Event.COMPLETE, _onWaveformDone, false, 0, true);
			}
			App.bulkLoader.start();
		}

		
		
		/**
		 * Scroll waveform.
		 * @param px Position (in px)
		 */
		public function scrollTo(px:int):void {
			Tweener.removeTweens(_waveformSpr);
			Tweener.addTween(_waveformSpr, {time:.5, x:px, rounded:true});
		}

		
		
		/**
		 * Get waveform width.
		 * @return Waveform width (in px)
		 */
		public function get waveformWidth():uint {
			return _waveformWidth;
		}

		
		
		public function set recordPosition(value:uint):void {
			_waveformSpr.alpha = 1;
			_waveformRecordSpr.width = Math.round(value / 100);
		}

		
		
		/**
		 * Waveform loading done event handler.
		 * @param event Event data
		 */
		private function _onWaveformDone(event:Event):void {
			if(_bitmap) throw new Error("Bitmap already loaded for waveform " + _waveformID);
			_bitmap = App.bulkLoader.getBitmapData(_waveformID, true).clone();

			// draw preloader mask
			Drawing.drawRect(_waveformFrontMaskSpr, 0, 0, Settings.WAVEFORM_WIDTH, 49, 0xFF0000, .3);
			
			Logger.debug(sprintf('Waveform %s loaded, width=%d', _waveformID, _waveformWidth));
			_drawWaveform();	
		}


		
		public function stretch(maxLength:uint):void {
			_waveformWidth = _milliseconds * Settings.WAVEFORM_WIDTH / maxLength;

			// If already loaded, ease out transition with fading
			if (_bitmap && _waveformSpr.alpha > 0) {
				Tweener.addTween(_waveformSpr, {time:Settings.FADEOUT_TIME, alpha:0, transition:'easeOutSine', onComplete:_drawWaveform});
			}
		}
		
		private function _drawWaveform():void {				
			_waveformBackBM.bitmapData = _bitmap;
			_waveformFrontBM.bitmapData = _bitmap;

			if(!_waveformWidth) _waveformWidth = Settings.WAVEFORM_WIDTH;
			_waveformBackBM.width = _waveformWidth;
			_waveformFrontBM.width = _waveformWidth;

			// fadein waveform
			Tweener.addTween(_waveformSpr, {time:Settings.FADEIN_TIME, alpha:1, transition:'easeOutSine'});
		}
		
		
		
		public function set progress(p:Number):void {
			var px:int = _waveformWidth * p - _waveformWidth;
			 
			// set preload label
			_preloadInfoLabelTF.text = sprintf('%u %%', p * 100);
			
			// animation
			Tweener.removeTweens(_waveformFrontMaskSpr);
			Tweener.addTween(_waveformFrontMaskSpr, {x:px, time:Settings.FADEIN_TIME});
						
			if(p >= 1) {
				// remove preloader info
				Tweener.removeTweens(_preloadInfoSpr);
				Tweener.addTween(_preloadInfoSpr, {time:Settings.FADEIN_TIME, alpha:0, transition:'easeOutSine', onComplete:function():void {
					_preloadInfoSpr.visible = false;
				}});
			}
		}
	}
}
