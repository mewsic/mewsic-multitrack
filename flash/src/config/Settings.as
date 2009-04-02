package config {
	import flash.events.EventDispatcher;		

	
	
	/**
	 * Global settings.
	 * 
	 * @author Vaclav Vancura (http://vaclav.vancura.org)
	 * @since Jun 13, 2008
	 */
	public class Settings extends EventDispatcher {

		
		
		public static const HEADER_HEIGHT:uint = 125;
		public static const STAGE_WIDTH:uint = 690;
		
		public static const WAVEFORM_WIDTH:uint = 432;
		public static const TRACKCONTROLS_WIDTH:uint = 250;
		
		public static const TRACK_HEIGHT:uint = 65;
		public static const BPM:uint = 60;
		
		public static const START_STAGE_HEIGHT:uint = 40;
		public static const STAGE_HEIGHT_CHANGE_TIME:Number = .6;
		public static const TAB_CHANGE_TIME:Number = .25;
		public static const PANEL_EDITOR_LAUNCH_DELAY:Number = .1;
		public static const CONNECTION_LAUNCH_DELAY:Number = 2.8;
		
		public static const FADEIN_TIME:Number = .3;
		public static const FADEOUT_TIME:Number = .3;
		
		public static const DEFAULT_CONNECTION_TIMEOUT:Number = 20;
		public static const PREVENT_CACHING:Boolean = false;
		public static const IGNORE_FMS_CALLS:Boolean = false; // :D
		public static const MAX_TRACKS:uint = 16;
		public static const WORKER_INTERVAL:Number = 3;

		public static var isLogEnabled:Boolean;
		public static var isServiceDumpEnabled:Boolean;



	}
}
