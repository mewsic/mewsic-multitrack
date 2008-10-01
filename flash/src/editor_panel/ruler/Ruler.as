package editor_panel.ruler {
	import editor_panel.ruler.Info;
	
	import org.vancura.graphics.QSprite;
	import org.vancura.util.addChildren;	

	
	
	/**
	 * Ruler manager.
	 * 
	 * @author Vaclav Vancura (http://vaclav.vancura.org)
	 * @since Jun 23, 2008
	 */
	public class Ruler extends QSprite {

		
		
		private var _scroller:Scroller;
		private var _info:Info;

		
		
		/**
		 * Constructor.
		 * @param c QSprite config Object
		 */
		public function Ruler(c:Object = null) {
			super(c);
			
			// add components
			_scroller = new Scroller();
			_info = new Info();

			// add to display list
			addChildren(this, _scroller, _info);
		}

		
		
		/**
		 * Get scroller.
		 * @return Scroller
		 */
		public function get scroller():Scroller {
			return _scroller;
		}

		
		
		/**
		 * Get info.
		 * @return Info
		 */
		public function get info():Info {
			return _info;
		}
	}
}
