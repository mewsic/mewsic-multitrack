package remoting.data {

	
	
	/**
	 * Track data.
	 * 
	 * @author Vaclav Vancura (http://vaclav.vancura.org)
	 * @since Jul 4, 2008
	 */
	public class TrackData {

		
		
		public var trackID:uint;
		public var trackUserNickname:String;
		public var trackTitle:String;
		public var trackAuthor:String;
		public var trackTags:String;
		public var trackInstrumentID:uint;
		public var trackRating:Number;
		public var trackSampleURL:String;
		public var trackWaveformURL:String;
		public var trackMilliseconds:uint;
		public var trackVolume:Number;
		public var trackBalance:Number;

		
		
		/**
		 * Get track data dump.
		 * @return Track data dump
		 */
		public function toString():String {
			return(
				'  *  trackID=' + trackID + '\n' +
				'  *  trackUserNickname=' + trackUserNickname + '\n' +
				'  *  trackTitle=' + trackTitle + '\n' +
				'  *  trackAuthor=' + trackAuthor + '\n' +
				'  *  trackTags=' + trackTags + '\n' +
				'  *  trackInstrumentID=' + trackInstrumentID + '\n' +
				'  *  trackRating=' + trackRating + '\n' +
				'  *  trackSampleURL=' + trackSampleURL + '\n' +
				'  *  trackWaveformURL=' + trackWaveformURL + '\n' +
				'  *  trackMilliseconds=' + trackMilliseconds + '\n' +
				'  *  trackVolume=' + trackVolume + '\n' +
				'  *  trackBalance=' + trackBalance + '\n\n'
			);
		}
	}
}
