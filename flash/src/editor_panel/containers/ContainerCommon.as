package editor_panel.containers {
	import caurina.transitions.Tweener;
	
	import config.Settings;
	
	import controls.MorphSprite;
	
	import editor_panel.tracks.StandardTrack;
	import editor_panel.tracks.TrackCommon;
	
	import org.vancura.graphics.QSprite;
	import org.vancura.util.addChildren;

	
	
	/**
	 * Container
	 * 
	 * @author Vaclav Vancura (http://vaclav.vancura.org)
	 * @since Jun 20, 2008
	 */
	public class ContainerCommon extends MorphSprite {


		private var $trackSpr:QSprite;
		private var $contentHeight:Number = 0;

		protected var $trackList:Array = new Array();
		
		/**
		 * Constructor.
		 * @param t Container type (TrackCommon.STANDARD_TRACK or TrackCommon.RECORD_TRACK)
		 * @throws TypeError if container type is not TrackCommon.STANDARD_TRACK or TrackCommon.RECORD_TRACK
		 */
		public function ContainerCommon() {
			super();

			// add graphics
			$trackSpr = new QSprite({y:2});

			// set visual properties
			$morphTime = Settings.STAGE_HEIGHT_CHANGE_TIME;
			$morphTransition = 'easeInOutQuad';

			// morph settings
			$isChangeWidthEnabled = false;
			$isChangeHeightEnabled = false;
			$isMorphWidthEnabled = false;
			$isMorphHeightEnabled = false;

			// intro animation
			Tweener.addTween(this, {delay:.05, onComplete:function():void {
				addChildren(this, $trackSpr);
				_recountHeight();
			}});
		}



		/**
		 * Display a new track.
		 * @param t TrackCommon
		 * @return void nothing
		 */
		protected function displayTrack(t:TrackCommon):void {
			// set visual properties
			t.y = Settings.TRACK_CONTAINER_HEADER_HEIGHT + $trackList.length * Settings.TRACK_HEIGHT;
			
			// add to the lists
			$trackSpr.addChild(t);
			$trackList.push(t);
			_recountHeight();
			
			// animate
			//t.alpha = 0;
			//Tweener.addTween(t, {alpha:1, time:Settings.STAGE_HEIGHT_CHANGE_TIME});
		}



		/**
		 * Kill track by it's ID.
		 * @param id Track ID to be killed
		 */
		public function killTrack(killed:TrackCommon):void {
			// remove track
			$trackList = $trackList.filter(function(t:TrackCommon, idx:uint, ary:Array):Boolean {
				if(t.trackID != killed.trackID)
					return true; // keep in list
					
				killed.destroy();
				return false; // remove from list
			});
			
			// reposition
			var idx:uint = 0;
			for each(var t:TrackCommon in $trackList) {
				var trackY:uint = Settings.TRACK_CONTAINER_HEADER_HEIGHT + idx * Settings.TRACK_HEIGHT;
				Tweener.addTween(t, {y:trackY, time:$morphTime, rounded:true, transition:'easeInOutQuad'});
				idx++;
			}
			
			// recount current height
			_recountHeight();
			
			// dispatch			
			dispatchEvent(new ContainerEvent(ContainerEvent.TRACK_KILL, true));
		}

		
		
		/**
		 * Morph.
		 * @param c Morph config Object
		 */
		override public function morph(c:Object):void {
			cacheAsBitmap = true;
			Tweener.addTween(this, {time:$morphTime, onComplete:function():void {
				cacheAsBitmap = false;
			}});
			super.morph(c);
		}
		
		
		
		public function eachTrack(callback:Function = null):Array {
			for each(var t:TrackCommon in $trackList) {
				if(callback != null) callback(t);
			}
			return $trackList;
		}
		
		
		/**
		 * Get content height.
		 * @return Content height
		 */
		public function get contentHeight():Number {
			return $contentHeight;
		}

		
		
		/**
		 * Get height.
		 * @return Height
		 */
		override public function get height():Number {
			return $contentHeight;
		}

		
		
		/**
		 * Get track count.
		 * @return Track count
		 */
		public function get trackCount():uint {
			return $trackList.length;
		}
		
		
		
		/**
		 * Get current sample position.
		 * @author Shimray Current sample position.
		 */
		public function get position():uint {
			var c:uint = 0;
			for each(var t:TrackCommon in $trackList) c = Math.max(c, t.position);
			return c;
		}


		
		public function get milliseconds():uint {
			var max:uint = 0;
			var t:TrackCommon;

			for each(t in $trackList) {
				if(t.trackData)
					max = Math.max(max, (t as StandardTrack).milliseconds);//trackData.trackMilliseconds); 
			}			
			return max;
		}

		
		
		/**
		 * Recount height.
		 */
		private function _recountHeight():void {
			var h:Number = Settings.TRACK_CONTAINER_HEADER_HEIGHT;

			for each(var t:TrackCommon in $trackList) {
				h += Settings.TRACK_HEIGHT + Settings.TRACK_MARGIN;
			}
			
			$contentHeight = h;

			dispatchEvent(new ContainerEvent(ContainerEvent.CONTENT_HEIGHT_CHANGE, true));
		}
	}
}
