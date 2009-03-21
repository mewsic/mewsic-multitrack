package config {
	import flash.filters.DropShadowFilter;	

	
	
	/**
	 * Global filters.
	 * 
	 * @author Vaclav Vancura (http://vaclav.vancura.org)
	 * @since Jun 13, 2008
	 */
	public class Filters {

		
		
		public static var buttonBlueLabel:Array = [new DropShadowFilter(1, 90, 0x126180, 1, 2, 2, 1, 1)];
		public static var buttonGreenLabel:Array = [new DropShadowFilter(1, 90, 0x31610D, 1, 2, 2, 1, 1)];
		public static var buttonRedLabel:Array = [new DropShadowFilter(1, 90, 0x7A000D, 1, 2, 2, 1, 1)];
		public static var buttonBeigeLabel:Array = [new DropShadowFilter(1, 90, 0x585D4D, 1, 2, 2, 1, 1)];
		public static var buttonGrayLabel:Array = [new DropShadowFilter(1, 90, 0x505050, 1, 2, 2, 1, 1)];
		public static var buttonActiveLabel:Array = [new DropShadowFilter(1, 90, 0x7b2f29, 1, 2, 2, 1, 1)];
		public static var standardContainerHeaderTitle:Array = [new DropShadowFilter(1, 45, 0xe6f6d9, 1, 0, 0, 1.5, 1)];
		public static var recordContainerHeaderTitle:Array = [new DropShadowFilter(1, 45, 0xdbf7ff, 1, 0, 0, 1.5, 1)];
		public static var standardContainerContentTitle:Array = [new DropShadowFilter(1, 45, 0xf8fff2, 1, 0, 0, 1.5, 1)];
		public static var recordContainerContentTitle:Array = [new DropShadowFilter(1, 45, 0xf2fbff, 1, 0, 0, 1.5, 1)];
		public static var inputLabel:Array = [new DropShadowFilter(1, 45, 0xFFFFFF, 1, 0, 0, 1.5, 1)];
		public static var modalTitle:Array = [new DropShadowFilter(1, 45, 0xFFFFFF, 2, 2, 2, 1.5, 1)];
		public static var progress:Array = [new DropShadowFilter(1, 90, 0x126180, 1, 2, 2, 1, 1)];
		public static var dummy:Array = [];
	}
}