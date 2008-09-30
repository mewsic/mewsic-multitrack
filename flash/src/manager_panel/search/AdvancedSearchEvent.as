package manager_panel.search {
	import flash.events.Event;	

	
	
	/**
	 * Advanced search event.
	 * 
	 * @author Vaclav Vancura (http://vaclav.vancura.org)
	 * @since Jul 20, 2008
	 */
	public class AdvancedSearchEvent extends Event {

		
		
		public static const ADVANCED_SEARCH:String = 'onAdvancedSearch';
		public var author:String;
		public var bpm:String;
		public var country:String;
		public var genre:String;
		public var instrument:String;
		public var key:String;
		public var title:String;

		
		
		/**
		 * Advanced search event.
		 * @param bubbles Bubbling
		 * @param cancelable Cancelable
		 * @param qauthor Author
		 * @param qbpm BPM
		 * @param qcountry Country
		 * @param qgenre Genre
		 * @param qinstrument Instrument
		 * @param qkey Key
		 * @param qtitle Title
		 * @param type Type
		 */
		public function AdvancedSearchEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false, qauthor:String = '', qtitle:String = '', qgenre:String = '', qcountry:String = '', qbpm:String = '' , qkey:String = '', qinstrument:String = '') {
			author = qauthor;
			bpm = qbpm;
			country = qcountry;
			genre = qgenre;
			instrument = qinstrument;
			key = qkey;
			title = qtitle;
			super(type, bubbles, cancelable);
		}
	}
}
