package manager_panel.lists {
	import org.vancura.graphics.Drawing;
	import org.vancura.graphics.QSprite;
	import org.vancura.util.addChildren;
	import org.vancura.util.removeChildren;	

	
	
	/**
	 * Song track common functions (for row and for empty row)
	 *
	 * @author Vaclav Vancura (http://vaclav.vancura.org)
	 * @since Jul 11, 2008
	 */
	public class ListSongTrackCommon extends QSprite {

		
		
		protected static const $CONTENT_HEIGHT:Number = 16;
		protected static const $CONTENT_WIDTH:Number = 966;
		protected var $contentSpr:QSprite;
		private var _maskSpr:QSprite;

		
		
		/**
		 * Constructor.
		 * @param sd Song data
		 * @param o QSprite config
		 */
		public function ListSongTrackCommon(o:Object = null) {
			super(o);
			
			// add main containers
			_maskSpr = new QSprite();
			$contentSpr = new QSprite({mask:_maskSpr});
			
			// drawing			
			Drawing.drawRect(_maskSpr, 0, 0, $CONTENT_WIDTH, $CONTENT_HEIGHT);
			
			// add to display list
			addChildren(this, $contentSpr, _maskSpr);
		}

		
		
		/**
		 * Destructor.
		 */
		public function destroy():void {
			removeChildren(this, $contentSpr, _maskSpr);
		}

		
		
		/**
		 * Get content height.
		 * @return Content height
		 */
		override public function get height():Number {
			return $CONTENT_HEIGHT;
		}
	}
}
