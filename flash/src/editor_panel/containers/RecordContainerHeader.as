package editor_panel.containers {
	import org.vancura.graphics.QTextField;
	import org.vancura.util.addChildren;
	
	import config.Filters;
	import config.Formats;
	
	import editor_panel.containers.ContainerHeaderCommon;	

	
	
	/**
	 * Record container header.
	 * 
	 * @author Vaclav Vancura (http://vaclav.vancura.org)
	 * @since Jul 16, 2008
	 */
	public class RecordContainerHeader extends ContainerHeaderCommon {

		
		
		private var _recordedTF:QTextField;

		
		
		/**
		 * Constructor.
		 * @param type Container type (TrackCommon.STANDARD_TRACK or TrackCommon.RECORD_TRACK)
		 */
		public function RecordContainerHeader(type:String) {
			super(type);

			// add components
			_recordedTF = new QTextField({x:42, y:10, height:20, width:400, defaultTextFormat:Formats.recordContainerTitle, filters:Filters.recordContainerHeaderTitle, sharpness:-25, thickness:-50, text:'Recorded tracks'}); 
			
			// add to display list
			addChildren($contentSpr, _recordedTF);
		}
	}
}
