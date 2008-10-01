package editor_panel.containers {
	import config.Filters;
	import config.Formats;
	
	import editor_panel.containers.ContainerHeaderCommon;
	
	import remoting.data.SongData;
	
	import org.vancura.graphics.QTextField;
	import org.vancura.util.addChildren;	

	
	
	/**
	 * Standard container header.
	 * 
	 * @author Vaclav Vancura (http://vaclav.vancura.org)
	 * @since Jul 16, 2008
	 */
	public class StandardContainerHeader extends ContainerHeaderCommon {

		
		
		private var _authorContentTF:QTextField;
		private var _authorTitleTF:QTextField;
		private var _titleContentTF:QTextField;
		private var _titleTitleTF:QTextField;

		
		
		/**
		 * Constructor.
		 * @param type Container type (TrackCommon.STANDARD_TRACK or TrackCommon.RECORD_TRACK)
		 */
		public function StandardContainerHeader(type:String) {
			super(type);

			// add components
			_authorTitleTF = new QTextField({x:42, y:13, height:20, defaultTextFormat:Formats.standardContainerDescription, sharpness:-100, thickness:0, text:'Author:'});
			_authorContentTF = new QTextField({x:77, y:10, width:100, height:20, defaultTextFormat:Formats.standardContainerTitle, filters:Filters.standardContainerHeaderTitle, sharpness:-25, thickness:-50});
			_titleTitleTF = new QTextField({x:185, y:13, height:20, defaultTextFormat:Formats.standardContainerDescription, sharpness:-100, thickness:0, text:'Title:'});
			_titleContentTF = new QTextField({x:208, y:10, width:305, height:20, defaultTextFormat:Formats.standardContainerTitle, filters:Filters.standardContainerHeaderTitle, sharpness:-25, thickness:-50});
			
			// add to display list
			addChildren($contentSpr, _titleTitleTF, _titleContentTF, _authorTitleTF, _authorContentTF);
		}

		
		
		/**
		 * Set data.
		 * @param sd Song data
		 */		
		override public function setData(sd:SongData):void {
			super.setData(sd);
			
			_authorContentTF.text = sd.songAuthor;
			_titleContentTF.text = sd.songTitle;
		}
	}
}
