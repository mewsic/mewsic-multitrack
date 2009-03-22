package progress_panel {
	import caurina.transitions.Tweener;
	
	import config.Embeds;
	import config.Filters;
	import config.Formats;
	import config.Settings;
	
	import org.vancura.graphics.QSprite;
	import org.vancura.graphics.QTextField;
	import org.vancura.util.addChildren;
	import org.vancura.util.removeChildren;
	
	import flash.display.MovieClip;
	import flash.text.TextFieldAutoSize;	

	
	
	/**
	 * Progress item
	 * 
	 * TODO: Write documentation
	 * 
	 * @author Vaclav Vancura (http://vaclav.vancura.org)
	 * @since Jul 21, 2008
	 */
	public class ProgressItem extends QSprite {

		
		
		private var _id:String;
		private var _description:String;
		private var _descriptionTF:QTextField;
		private var _isEnabled:Boolean;
		private var _pieMC:MovieClip;

		
		
		/**
		 * Constructor.
		 * @param description Description
		 * @param id ID
		 * @param o QSprite config Object
		 */
		public function ProgressItem(id:String, description:String = 'No description given', o:Object = null) {
			_id = id;
			_description = description;
			_isEnabled = true;
			
			super(o);
			
			// add components
			_descriptionTF = new QTextField({text:_description, x:23, y:1, alpha:0, width:910, autoSize:TextFieldAutoSize.LEFT, defaultTextFormat:Formats.progress, filters:Filters.progress, thickness:-150, sharpness:50});
			_pieMC = new Embeds.waitPieWhiteMC() as MovieClip;
			_pieMC.x = 9;
			_pieMC.y = 9;
			
			// add to display list
			addChildren(this, _descriptionTF, _pieMC);
			
			// animation
			Tweener.addTween(_descriptionTF, {alpha:1, time:Settings.FADEIN_TIME, delay:Settings.FADEIN_TIME, transition:'easeOutSine'});
		}

		
		
		/**
		 * Destructor.
		 */
		public function destroy():void {
			// remove from display list
			removeChildren(this, _descriptionTF, _pieMC);
			
			_isEnabled = false;
		}

		
		
		/**
		 * Get enabled flag.
		 * @return Enabled flag
		 */
		public function get isEnabled():Boolean {
			return _isEnabled;
		}
		
		
		
		/**
		 * Get ID.
		 * @return ID
		 */
		public function get id():String {
			return _id;
		}
		
		
		
		/**
		 * Get height.
		 * @return Height
		 */
		override public function get height():Number {
			return 22;
		}
	}
}
