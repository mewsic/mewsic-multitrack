package remoting.data {

	
	
	/**
	 * Track data.
	 * 
	 * @author Vaclav Vancura (http://vaclav.vancura.org)
	 * @since Jul 4, 2008
	 */
	public class TrackData {

		
		
		public var trackGenreID:uint;
		public var trackInstrumentID:uint;
		public var trackID:uint;
		public var trackBPM:uint;
		public var trackSongsCount:uint;
		public var trackSampleURL:String;
		public var trackWaveformURL:String;
		public var trackUserNickname:String;
		public var trackAuthor:String;
		public var trackTitle:String;
		public var trackKey:String;
		public var trackDescription:String;
		public var trackRating:Number;
		public var trackVolume:Number;
		public var trackBalance:Number;
		public var trackMilliseconds:uint;

		
		
		/**
		 * Get track data dump.
		 * @return Track data dump
		 */
		public function toString():String {
			return(
				'  *  trackGenreID=' + trackGenreID + '\n' +
				'  *  trackInstrumentID=' + trackInstrumentID + '\n' +
				'  *  trackID=' + trackID + '\n' +
				'  *  trackBPM=' + trackBPM + '\n' +
				'  *  trackSongsCount=' + trackSongsCount + '\n' +
				'  *  trackSampleURL=' + trackSampleURL + '\n' +
				'  *  trackWaveformURL=' + trackWaveformURL + '\n' +
				'  *  trackUserNickname=' + trackUserNickname + '\n' +
				'  *  trackAuthor=' + trackAuthor + '\n' +
				'  *  trackTitle=' + trackTitle + '\n' +
				'  *  trackKey=' + trackKey + '\n' +
				'  *  trackDescription=' + trackDescription + '\n' +
				'  *  trackRating=' + trackRating + '\n' +
				'  *  trackVolume=' + trackVolume + '\n' +
				'  *  trackBalance=' + trackBalance + '\n' +
				'  *  trackMilliseconds=' + trackMilliseconds + '\n\n'
			);
		}
	}
}
