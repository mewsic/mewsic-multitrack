package editor_panel.containers {
	import org.vancura.graphics.QBitmap;
	import org.vancura.graphics.QSprite;
	import org.vancura.util.addChildren;
	
	import application.App;
	
	import config.Embeds;
	
	import controls.Thumbnail;
	
	import editor_panel.tracks.TrackCommon;
	
	import remoting.data.SongData;
	import remoting.data.UserData;	

	
	
	/**
	 * Container header common things.
	 * 
	 * @author Vaclav Vancura (http://vaclav.vancura.org)
	 * @since Jun 23, 2008
	 */
	public class ContainerHeaderCommon extends QSprite {

		
		
		protected var $contentSpr:QSprite;
		private var _avatarThumbnail:Thumbnail;
		private var _backBM:QBitmap;
		private var _type:String;

		

		/**
		 * Constructor.
		 * @param type Container type (TrackCommon.STANDARD_TRACK or TrackCommon.RECORD_TRACK)
		 * @throws TypeError if container type is not TrackCommon.STANDARD_TRACK or TrackCommon.RECORD_TRACK
		 */
		public function ContainerHeaderCommon(type:String) {
			super();

			// check for type validity
			if(type != TrackCommon.RECORD_TRACK && type != TrackCommon.STANDARD_TRACK) {
				throw new TypeError('Container header type has to be TrackCommon.RECORD_TRACK or TrackCommon.STANDARD_TRACK.');
			}
			else _type = type;

			// add components
			_backBM = new QBitmap({embed:(_type == TrackCommon.RECORD_TRACK) ? new Embeds.recordContainerHeaderBD() : new Embeds.standardContainerHeaderBD()});
			_avatarThumbnail = new Thumbnail({x:2, y:2});
			$contentSpr = new QSprite();
			
			// add to display list
			addChildren(this, _backBM, $contentSpr, _avatarThumbnail);
		}

		
		
		/**
		 * Set data.
		 * @param sd Song data
		 */		
		public function setData(sd:SongData):void {
			// load avatar image
			_avatarThumbnail.load(App.connection.serverPath + App.connection.coreUserData.userAvatarURL);
			
			// fix FDT warning
			sd;
		}
	}
}
