package editor_panel.sampler {
	import application.App;
	
	import br.com.stimuli.loading.BulkErrorEvent;
	import br.com.stimuli.loading.BulkLoader;
	
	import de.popforge.utils.sprintf;
	
	import com.gskinner.utils.Rnd;
	
	import org.osflash.thunderbolt.Logger;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.ProgressEvent;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;	

	
	
	/**
	 * Sampler.
	 * 
	 * @author Vaclav Vancura (http://vaclav.vancura.org)
	 * @since Jun 23, 2008
	 */
	public class Sampler extends EventDispatcher {

		
		
		private var _sampleID:String;
		private var _sampleSound:Sound;
		private var _sampleChannel:SoundChannel;
		private var _isSampleDownloaded:Boolean;
		private var _isSamplePlaying:Boolean;
		private var _isSamplePaused:Boolean;
		private var _isSampleOpen:Boolean;
		private var _pausedSamplePos:uint;
		private var _currentSoundTransform:SoundTransform;
		private var _isMuted:Boolean;
		private var _unmutedVolume:Number;
		private var _milliseconds:uint;
		private var _type:String;

		
		
		/**
		 * Constructor.
		 * @param o MorphSprite config Object
		 */
		public function Sampler(t:String) {
			_type = t;
			
			var id:String = sprintf('sampler.%u.%u', uint(new Date()), Rnd.integer(1000, 9999));			
			_sampleID = sprintf('%s.sample', id);
			_currentSoundTransform = new SoundTransform();
		}

		
		
		/**
		 * Destructor.
		 */
		public function destroy():void {
			// remove sample
			if(_sampleChannel) {
				_sampleChannel.removeEventListener(Event.SOUND_COMPLETE, _onSoundComplete);
			}			
		}

		
		
		/**
		 * Load sample.
		 * @param ms Sample length in ms
		 * @param sf Sample filename
		 */
		public function load(sf:String, ms:uint):void {
			Logger.info(sprintf('Loading sample (%s)', sf));
			
			_milliseconds = ms;
			
			// load it
			with(App.bulkLoader.add(sf, {
				id:_sampleID, type:BulkLoader.TYPE_SOUND})) {
				addEventListener(BulkLoader.OPEN, _onSampleOpen, false, 0, true);
				addEventListener(BulkLoader.PROGRESS, _onSampleProgress, false, 0, true);
				addEventListener(BulkLoader.ERROR, _onSampleError, false, 0, true);
			}
			App.bulkLoader.start();
		}

		
		
		/**
		 * Play sample.
		 */
		public function play():void {
			_sampleChannel = _sampleSound.play(0);
			_sampleChannel.soundTransform = _currentSoundTransform;
			_isSamplePlaying = true;
			_isSamplePaused = false;
			_sampleChannel.addEventListener(Event.SOUND_COMPLETE, _onSoundComplete, false, 0, true);
			_refreshSoundTransform();
		}

		
		
		/**
		 * Stop sample.
		 */
		public function stop():void {
			_sampleChannel.removeEventListener(Event.SOUND_COMPLETE, _onSoundComplete);
			_sampleChannel.stop();
			_isSamplePlaying = false;
			_isSamplePaused = false;
			_pausedSamplePos = 0;
		}			

		
		
		/**
		 * Pause sample.
		 */
		public function pause():void {
			if(_isSamplePlaying) {
				if(!_isSamplePaused) {
					_isSamplePaused = true;
					_pausedSamplePos = _sampleChannel.position;
					_sampleChannel.removeEventListener(Event.SOUND_COMPLETE, _onSoundComplete);
					_sampleChannel.stop();
				}
				else throw new Error('Sample playing but paused.');
			}
			else throw new Error('Sample not playing.');
		}

		
		
		/**
		 * Resume sample.
		 */
		public function resume():void {
			if(_isSamplePlaying) {
				if(_isSamplePaused) {
					_isSamplePaused = false;
					_sampleChannel = _sampleSound.play(_pausedSamplePos); 
					_sampleChannel.addEventListener(Event.SOUND_COMPLETE, _onSoundComplete, false, 0, true);
					_refreshSoundTransform();
				}
				else throw new Error('Sample playing but not paused.');
			}
			else throw new Error('Sample not playing.');
		}

		
		
		/**
		 * Seek sample.
		 * @param position Seek position in ms
		 */
		public function seek(position:uint):void {
			if(_isSamplePlaying) {
				// sample playing
				if(_isSamplePaused) {
					_pausedSamplePos = position; 
				}
				else {
					_sampleChannel.removeEventListener(Event.SOUND_COMPLETE, _onSoundComplete);
					_sampleChannel.stop();
					_sampleChannel = _sampleSound.play(position); 
					_sampleChannel.addEventListener(Event.SOUND_COMPLETE, _onSoundComplete, false, 0, true);
					_refreshSoundTransform();
				}
			}
			else {
				// sample not playing
				// dummy seek
				_pausedSamplePos = position;
			}
		}

		
		
		/**
		 * Get sample downloaded flag.
		 * @return Sample downloaded flag
		 */
		public function get isSampleDownloaded():Boolean {
			return _isSampleDownloaded;
		}

		
		
		/**
		 * Get sample open flag.
		 * @return Sample open flag
		 */
		public function get isSampleOpen():Boolean {
			return _isSampleOpen;
		}

		
		
		/**
		 * Get current sample position.
		 * @return Sample position in ms
		 */
		public function get position():uint {
			if(!_isSamplePlaying) return _pausedSamplePos;
			else if(_isSamplePaused) return _pausedSamplePos; 
			else return _sampleChannel.position;
		}

		
		
		/**
		 * Set sample volume.
		 * @param value Volume
		 */
		public function set volume(value:Number):void {
			if(_isMuted) {
				// sound is muted, don't set anything
				// but save new volume value for later
				_unmutedVolume = value;
			}
			else {
				// sound is unmuted
				_currentSoundTransform.volume = value;
				_refreshSoundTransform();
			}
		}

		
		
		/**
		 * Get current volume.
		 * @return Current volume
		 */
		public function get volume():Number {
			if(_isMuted) {
				// sound is muted, return stored volume value
				return _unmutedVolume;
			}
			else {
				// sound is unmuted				
				return _currentSoundTransform.volume;
			}
		}

		
		
		/**
		 * Set sample balance.
		 * @param value Balance
		 */
		public function set balance(value:Number):void {
			_currentSoundTransform.pan = value;
			_refreshSoundTransform();
		}

		
		
		/**
		 * Get current balance.
		 * @return Current balance
		 */
		public function get balance():Number {
			return _currentSoundTransform.pan;
		}

		
		
		/**
		 * Set muted flag.
		 * @param value Muted flag
		 */
		public function set isMuted(value:Boolean):void {
			if(value == _isMuted) return;
			else {
				_isMuted = value;
				if(_isMuted) {
					// mute now
					// store current volume value
					_unmutedVolume = _currentSoundTransform.volume;
					_currentSoundTransform.volume = 0;
				}
				else {
					// unmute now
					// restore old volume value
					_currentSoundTransform.volume = _unmutedVolume;
				}
				_refreshSoundTransform();
			}
		}

		
		
		/**
		 * Refresh sound transformation.
		 */
		private function _refreshSoundTransform():void {
			if(_sampleChannel) _sampleChannel.soundTransform = _currentSoundTransform;
		}

		
		
		/**
		 * Sample download progress event handler.
		 * @param event Event data
		 */
		private function _onSampleProgress(event:ProgressEvent):void {
			if(event.bytesLoaded >= event.bytesTotal) {
				// sample is fully downloaded
				_isSampleDownloaded = true;
				
				// dispatch event
				dispatchEvent(new SamplerEvent(SamplerEvent.SAMPLE_DOWNLOADED, true));
			}
			
			// dispatch progress event
			var p:Number = 1 / (event.bytesTotal / event.bytesLoaded);
			dispatchEvent(new SamplerEvent(SamplerEvent.SAMPLE_PROGRESS, true, false, {progress:p}));
		}

		
		
		/**
		 * Sample open event handler.
		 * @param event Event data
		 */
		private function _onSampleOpen(event:Event):void {
			Logger.info(sprintf('Sample %s open', _sampleID));
			_isSampleOpen = true;
			_sampleSound = App.bulkLoader.getSound(_sampleID);
			dispatchEvent(new SamplerEvent(SamplerEvent.PLAYBACK_OPEN, true));
		}

		
		
		/**
		 * Sound playback complete event handler.
		 * @param event Event data
		 */
		private function _onSoundComplete(event:Event):void {
			Logger.info(sprintf('Sample %s complete', _sampleID));
			_isSamplePlaying = false;
			_sampleChannel.removeEventListener(Event.SOUND_COMPLETE, _onSoundComplete);
			dispatchEvent(new SamplerEvent(SamplerEvent.PLAYBACK_COMPLETE, true));
		}

		
		
		/**
		 * Sample loading error event handler.
		 * @param event Event data
		 */
		private function _onSampleError(event:BulkErrorEvent):void {
			_isSamplePlaying = false;
			_sampleChannel.removeEventListener(Event.SOUND_COMPLETE, _onSoundComplete);
			dispatchEvent(new SamplerEvent(SamplerEvent.SAMPLE_ERROR, true));
		}
	}
}
