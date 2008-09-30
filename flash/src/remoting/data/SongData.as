package remoting.data {

	
	
	/**
	 * Song data.
	 * 
	 * @author Vaclav Vancura (http://vaclav.vancura.org)
	 * @since Jul 4, 2008
	 */
	public class SongData {

		
		
		public var songGenreID:uint;
		public var songID:uint;
		public var songInstrumentsCount:uint;
		public var songSiblingsCount:uint;
		public var songBPM:uint = 0;
		public var songSampleURL:String;
		public var songWaveformURL:String;
		public var songUserNickname:String;
		public var songAuthor:String;
		public var songTitle:String;
		public var songKey:String;
		public var songDescription:String;
		public var songRating:Number;
		public var songMilliseconds:uint;
		public var songTracks:Array = new Array();

		
		
		/**
		 * Get song data dump.
		 * @return Song data dump
		 */
		public function toString():String {
			return(
				'  *  songGenreID=' + songGenreID + '\n' +
				'  *  songID=' + songID + '\n' +
				'  *  songInstrumentsCount=' + songInstrumentsCount + '\n' +
				'  *  songSiblingsCount=' + songSiblingsCount + '\n' +
				'  *  songBPM=' + songBPM + '\n' +
				'  *  songSampleURL=' + songSampleURL + '\n' +
				'  *  songWaveformURL=' + songWaveformURL + '\n' +
				'  *  songUserNickname=' + songUserNickname + '\n' +
				'  *  songAuthor=' + songAuthor + '\n' +
				'  *  songTitle=' + songTitle + '\n' +
				'  *  songKey=' + songKey + '\n' +
				'  *  songDescription=' + songDescription + '\n' +
				'  *  songRating=' + songRating + '\n' +
				'  *  songMilliseconds=' + songMilliseconds + '\n\n'			
			);
		}
	}
}
