package controls
{
	import caurina.transitions.Tweener;
	
	import flash.display.Bitmap;
	
	import org.bytearray.display.ScaleBitmap;
	import org.vancura.graphics.QSprite;
	import org.vancura.util.addChildren;
	import org.vancura.util.removeChildren;

	public class ProgressBar extends QSprite
	{
		private var $uploadBackSBM:ScaleBitmap;
		private var $uploadProgressSBM:ScaleBitmap;

	
		public function ProgressBar(c:Object = null)
		{
			super(c);
			
			if(c.background == undefined) throw new Error("Progress bar background missing");
			if(c.progress == undefined) throw new Error("Progress bar missing");
			if(c.grid == undefined) throw new Error("Progress grid missing");

			$uploadBackSBM = new ScaleBitmap((c.background as Bitmap).bitmapData);
			$uploadProgressSBM = new ScaleBitmap((c.progress as Bitmap).bitmapData);
			
			$uploadBackSBM.width = c.width || 250;
			$uploadBackSBM.scale9Grid = $uploadProgressSBM.scale9Grid = c.grid;
			$uploadProgressSBM.width = 1;
			
			addChildren(this, $uploadBackSBM, $uploadProgressSBM);
		}
		
		public function destroy():void {
			removeChildren(this, $uploadBackSBM, $uploadProgressSBM);
		}
		
		public function set progress(value:uint):void {
			$uploadProgressSBM.width = value;

			//Tweener.removeTweens($uploadProgressSBM);
			Tweener.addTween($uploadProgressSBM, {width:value, rounded:true, time:.25});  
		}
	
		override public function set width(value:Number):void {
			$uploadBackSBM.width = value;
		}	
	}
}