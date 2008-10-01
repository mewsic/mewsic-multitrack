package manager_panel.search {
	import config.Formats;
	
	import de.popforge.utils.sprintf;
	
	import org.vancura.graphics.QSprite;
	import org.vancura.graphics.QTextField;
	import org.vancura.util.addChildren;
	
	import flash.text.TextFieldAutoSize;	

	
	
	/**
	 * Common subpanel functions. 
	 * 
	 * @author Vaclav Vancura (http://vaclav.vancura.org)
	 * @since Jul 12, 2008
	 */
	public class SubpanelCommon extends QSprite {

		
		
		public static const STATUS_RESULTS:String = 'statusResults';
		public static const STATUS_INFO:String = 'statusInfo';
		protected var $headerSpr:QSprite;
		protected var $contentSpr:QSprite;
		protected var $isFilled:Boolean;
		private var _infoTF:QTextField;
		private var _height:uint;

		
		
		/**
		 * Constructor.
		 * @param height Container height
		 * @param c Sprite config Object
		 */
		public function SubpanelCommon(height:uint, c:Object = null) {
			super(c);
			_height = height;
			
			// add graphics
			$headerSpr = new QSprite({visible:false});
			$contentSpr = new QSprite({y:30});
			_infoTF = new QTextField({visible:false, x:0, width:291, defaultTextFormat:Formats.searchResultsPanelBanner, autoSize:TextFieldAutoSize.LEFT, sharpness:50});
			
			// add to display list
			addChildren(this, $headerSpr, $contentSpr, _infoTF);
		}

		
		
		/**
		 * Set status.
		 * @param info Information string (not required)
		 * @param value Status (STATUS_INFO, STATUS_RESULTS)
		 */
		public function setStatus(value:String, info:String = ''):void {
			switch(value) {
				case STATUS_INFO:
					$headerSpr.visible = false;
					_infoTF.text = info;
					_infoTF.visible = true;
					_infoTF.y = Math.round((_height - _infoTF.textHeight) * .5) - 4;
					break;
					
				case STATUS_RESULTS:
					$headerSpr.visible = true;
					_infoTF.text = '';
					_infoTF.visible = false;
					break;
					
				default:
					throw new Error(sprintf('Invalid subpanel status (%s).', value));
					return;
			}
		}

		
		
		/**
		 * Get content height.
		 * @return Content height
		 */
		override public function get height():Number {
			return Math.round($contentSpr.height);
		}
	}
}
