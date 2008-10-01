package editor_panel.ruler {
	import config.Formats;
	
	import org.vancura.graphics.QSprite;
	import org.vancura.graphics.QTextField;
	import org.vancura.util.addChildren;	

	
	
	/**
	 * Ruler info.
	 * 
	 * @author Vaclav Vancura (http://vaclav.vancura.org)
	 * @since Jun 20, 2008
	 */
	public class Info extends QSprite {

		
		
		private var _runtimeTitleTF:QTextField;
		private var _runtimeContentTF:QTextField;

		
		
		/**
		 * Constructor.
		 * @param c QSprite config Object
		 */
		public function Info(c:Object = null) {
			super(c);
			
			// add components
			_runtimeTitleTF = new QTextField({x:0, y:5, width:200, height:20, defaultTextFormat:Formats.scrollerRuntimeTitle, text:'Runtime:'});
			_runtimeContentTF = new QTextField({x:0, y:2, width:200, height:20, defaultTextFormat:Formats.scrollerRuntimeContent, text:'0:00'});

			// refresh components
			_refresh();

			// add to display list
			addChildren(this, _runtimeTitleTF, _runtimeContentTF);
		}

		
		
		/**
		 * Set label.
		 * @param value Label
		 */
		public function set label(value:String):void {
			_runtimeContentTF.text = value;
			_refresh();
		}

		
		
		/**
		 * Refresh components.
		 */
		private function _refresh():void {
			var x:Number = 495 - _runtimeContentTF.textWidth;
			_runtimeContentTF.x = x;
			_runtimeTitleTF.x = x - _runtimeTitleTF.textWidth - 5;
		}
	}
}
