package editor_panel {
	import config.Embeds;
	
	import de.popforge.utils.sprintf;
	
	import org.osflash.thunderbolt.Logger;
	
	import flash.events.EventDispatcher;
	import flash.media.Sound;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;	

	
	
	/**
	 * Beat clicker. 
	 * 
	 * TODO: Write documentation
	 * 
	 * @author Vaclav Vancura (http://vaclav.vancura.org)
	 * @since Jul 28, 2008
	 */
	public class BeatClicker extends EventDispatcher {

		
		
		private var _beatTimeout:uint;
		private var _bpmSound:Sound;
		private var _isEnabled:Boolean;
		private var _isPlaying:Boolean;
		private var _isPaused:Boolean;
		private var _bpm:uint;
		private var _polarity:Boolean;
		private var _firstBeat:uint;
		private var _interval:uint;
		private var _pauseOffset:int;
		private var _beatCounter:uint;

		
		
		/**
		 * Constructor.
		 */
		public function BeatClicker() {
			_bpmSound = new Embeds.soundMetronomeSnd() as Sound;
		}



		/**
		 * Set enabled flag.
		 * @param value Enabled flag
		 */
		public function set isEnabled(value:Boolean):void {
			if(value) Logger.debug('Enabling beat click.');
			else Logger.debug('Disabling beat click.');
			_isEnabled = value;
		}


		
		public function get isEnabled():Boolean {
			return _isEnabled;
		}



		/**
		 * Set BPM.
		 * @param value BPM
		 */
		public function set bpm(value:uint):void {
			if(!_isPlaying) {
				if(value > 40 && value < 300) {
					_bpm = value;
					_interval = 60000 / _bpm;
				}
			}
		}



		/**
		 * Start clicking.
		 */
		public function play():void {
			if(!_isPlaying) {
				Logger.debug(sprintf('Starting beat click (%u BPM, %u ms).', _bpm, _interval));
				_firstBeat = uint(new Date()) - _interval;
				_beatCounter = 0;
				_onBeat();
				_isPlaying = true;
			}
		}

		
		
		/**
		 * Stop clicking.
		 */
		public function stop():void {
			if(_isPlaying) {
				Logger.debug('Stopping beat click.');
				clearTimeout(_beatTimeout);
				_isPlaying = false;
			}
		}
		
		
		
		public function pause():void {
			if(!_isPaused) {
				_pauseOffset = uint(new Date()) - _firstBeat;
				Logger.debug(sprintf('Pausing beat click (sync offset %d ms).', _pauseOffset));
				clearTimeout(_beatTimeout);
				_isPaused = true;
			}
		}



		public function resume():void {
			if(_isPaused) {
				var v:int = ((_interval * _beatCounter) - _pauseOffset) * -1;
				Logger.debug(sprintf('Resuming beat click (after %d ms).', v));
				_firstBeat = uint(new Date()) - _pauseOffset - _interval;
				_beatTimeout = setTimeout(_onBeat, v);
				_isPaused = false;
				_beatCounter++;
			}
		}
		
		
		
		private function _onBeat():void {
			if(_isEnabled && !_isPaused) _bpmSound.play();
			
			_polarity = !_polarity;
			_beatCounter++;
			
			var sync:int = (_interval * _beatCounter) - (uint(new Date()) - _firstBeat);
			Logger.debug(sprintf('Beat synchronization (%d ms)', sync));
			try { _beatTimeout = setTimeout(_onBeat, _interval + sync); } catch(e:Error) {};
			
			// dispatch
			dispatchEvent(new BeatClickerEvent(BeatClickerEvent.BEAT, true, false, _bpm, _polarity));
		}
	}
}
