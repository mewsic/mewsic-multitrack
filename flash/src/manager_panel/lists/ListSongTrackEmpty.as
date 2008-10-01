package manager_panel.lists {
	import config.Formats;
	
	import manager_panel.lists.ListSongTrackCommon;
	
	import org.vancura.graphics.QTextField;
	import org.vancura.util.addChildren;
	import org.vancura.util.removeChildren;
	
	import flash.text.TextFieldAutoSize;	

	
	
	/**
	 * Empty song track.
	 *
	 * @author Vaclav Vancura (http://vaclav.vancura.org)
	 * @since Jul 07, 2008
	 */
	public class ListSongTrackEmpty extends ListSongTrackCommon {

		
		
		private var _infoTF:QTextField;

		
		
		/**
		 * Constructor.
		 * @param sd Song data
		 * @param o QSprite config
		 */
		public function ListSongTrackEmpty(o:Object = null) {
			super(o);
			
			// add textfields
			_infoTF = new QTextField({x:2, width:123, defaultTextFormat:Formats.tabSongTrackL, text:'No tracks', multiline:false, autoSize:TextFieldAutoSize.CENTER});
			
			// add to display list
			addChildren($contentSpr, _infoTF);
			addChildren(this, $contentSpr);
		}

		
		
		/**
		 * Destructor.
		 */
		override public function destroy():void {
			removeChildren($contentSpr, _infoTF);
			removeChildren(this, $contentSpr);
			
			super.destroy();
		}
	}
}
