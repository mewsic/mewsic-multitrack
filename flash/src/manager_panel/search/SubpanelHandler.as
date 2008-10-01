package manager_panel.search {
	import application.App;
	
	import config.Embeds;
	import config.Filters;
	import config.Formats;
	import config.Settings;
	
	import controls.Slider;
	import controls.SliderEvent;
	
	import manager_panel.search.SubpanelA;
	
	import remoting.data.SongData;
	import remoting.data.TrackData;
	import remoting.dynamic_services.SongSiblingsService;
	import remoting.dynamic_services.TrackSiblingsService;
	import remoting.events.SongSiblingsEvent;
	import remoting.events.TrackSiblingsEvent;
	
	import de.popforge.utils.sprintf;
	
	import org.osflash.thunderbolt.Logger;
	import org.vancura.graphics.Drawing;
	import org.vancura.graphics.QBitmap;
	import org.vancura.graphics.QSprite;
	import org.vancura.graphics.QTextField;
	import org.vancura.util.addChildren;
	
	import flash.text.TextFieldAutoSize;	

	
	
	/**
	 * Search results sub tab.
	 * 
	 * TODO: Write documentation
	 * 
	 * @author Vaclav Vancura (http://vaclav.vancura.org)
	 * @since Jun 28, 2008
	 */
	public class SubpanelHandler extends QSprite {

		
		
		private var _backBM:QBitmap;
		private var _headlineTF:QTextField;
		private var _contentHeight:Number;
		private var _subpanelA:SubpanelA;
		private var _subpanelB:SubpanelB;
		private var _subpanelC:SubpanelC;
		private var _subpanelD:SubpanelD;
		private var _sliderA:Slider;
		private var _sliderB:Slider;
		private var _sliderC:Slider;
		private var _sliderD:Slider;
		private var _subpanelAMaskSpr:QSprite;
		private var _subpanelBMaskSpr:QSprite;
		private var _subpanelCMaskSpr:QSprite;
		private var _subpanelDMaskSpr:QSprite;
		private var _currentTitle:String;
		private var _songSiblingsService:SongSiblingsService;
		private var _trackSiblingsService:TrackSiblingsService;

		
		
		/**
		 * Constructor.
		 * @param o QSprite config Object
		 */
		public function SubpanelHandler(o:Object = null) {
			super(o);
			// add components
			_backBM = new QBitmap({embed:new Embeds.subpanelSearchResultsBackBD(), y:37});
			_headlineTF = new QTextField({x:19, y:8, width: 270, autoSize:TextFieldAutoSize.LEFT, defaultTextFormat:Formats.tabHeadline, filters:Filters.tabHeadline, text:'BROWSE SEARCH RESULTS'});
			
			// add masks
			_subpanelAMaskSpr = new QSprite({x:7, y:45});
			_subpanelBMaskSpr = new QSprite({x:325, y:45});
			_subpanelCMaskSpr = new QSprite({x:650, y:45});
			_subpanelDMaskSpr = new QSprite({x:650, y:231});
			
			// add subpanels
			_subpanelA = new SubpanelA(366, {x:7, y:45, mask:_subpanelAMaskSpr});
			_subpanelB = new SubpanelB(366, {x:325, y:45, mask:_subpanelBMaskSpr});
			_subpanelC = new SubpanelC(180, {x:650, y:45, mask:_subpanelCMaskSpr});
			_subpanelD = new SubpanelD(180, {x:650, y:231, mask:_subpanelDMaskSpr});
			
			// add scrolling thumbs
			_sliderA = new Slider({x:300, y:70, height:314, slideTime:.5, backSkin:new Embeds.sliderVerticalScrollerBD(), thumbSkin:new Embeds.buttonVerticalScrollerThumbBD(), wheelRatio:.005}, Slider.DIRECTION_VERTICAL);
			_sliderB = new Slider({x:618, y:70, height:314, slideTime:.5, backSkin:new Embeds.sliderVerticalScrollerBD(), thumbSkin:new Embeds.buttonVerticalScrollerThumbBD(), wheelRatio:.005}, Slider.DIRECTION_VERTICAL);
			_sliderC = new Slider({x:943, y:70, height:128, slideTime:.5, backSkin:new Embeds.sliderVerticalScrollerBD(), thumbSkin:new Embeds.buttonVerticalScrollerThumbBD(), wheelRatio:.005}, Slider.DIRECTION_VERTICAL);
			_sliderD = new Slider({x:943, y:256, height:128, slideTime:.5, backSkin:new Embeds.sliderVerticalScrollerBD(), thumbSkin:new Embeds.buttonVerticalScrollerThumbBD(), wheelRatio:.005}, Slider.DIRECTION_VERTICAL);
			
			// drawing
			Drawing.drawRect(_subpanelAMaskSpr, 0, 0, 292, 364, 0xFF0000, .3);
			Drawing.drawRect(_subpanelBMaskSpr, 0, 0, 292, 364, 0xFF0000, .3);
			Drawing.drawRect(_subpanelCMaskSpr, 0, 0, 292, 178, 0xFF0000, .3);
			Drawing.drawRect(_subpanelDMaskSpr, 0, 0, 292, 178, 0xFF0000, .3);
			
			// add to display list
			addChildren(this, _backBM, _headlineTF, _subpanelA, _subpanelB, _subpanelC, _subpanelD, _sliderA, _sliderB, _sliderC, _sliderD, _subpanelAMaskSpr, _subpanelBMaskSpr, _subpanelCMaskSpr, _subpanelDMaskSpr);
			
			// add event listeners
			_subpanelA.addEventListener(SubpanelEvent.ROW_SELECT, _onSubpanelARowSelect, false, 0, true);
			_subpanelB.addEventListener(SubpanelEvent.ROW_SELECT, _onSubpanelBRowSelect, false, 0, true);
			_subpanelD.addEventListener(SubpanelEvent.ROW_SELECT, _onSubpanelDRowSelect, false, 0, true);
			_subpanelA.addEventListener(SubpanelEvent.RESET, _onSubpanelReset, false, 0, true);
			_sliderA.addEventListener(SliderEvent.REFRESH, _onSliderARefresh, false, 0, true);			_sliderB.addEventListener(SliderEvent.REFRESH, _onSliderBRefresh, false, 0, true);			_sliderC.addEventListener(SliderEvent.REFRESH, _onSliderCRefresh, false, 0, true);			_sliderD.addEventListener(SliderEvent.REFRESH, _onSliderDRefresh, false, 0, true);
			
			// refresh sliders
			_refreshSliders();
		}

		
		
		public function postInit():void {
			_songSiblingsService = new SongSiblingsService();
			_songSiblingsService.url = App.connection.serverPath + App.connection.configService.songSiblingsRequestURL;
			_songSiblingsService.addEventListener(SongSiblingsEvent.REQUEST_DONE, _onSongSiblingsRequestDone, false, 0, true);
			
			_trackSiblingsService = new TrackSiblingsService();
			_trackSiblingsService.url = App.connection.serverPath + App.connection.configService.trackSiblingsRequestURL;
			_trackSiblingsService.addEventListener(TrackSiblingsEvent.REQUEST_DONE, _onTrackSiblingsRequestDone, false, 0, true);
		}

		
		
		/**
		 * Get content height.
		 * @return Content height
		 */
		public function get contentHeight():Number {
			return _contentHeight;
		}

		
		
		/**
		 * Clean results.
		 */
		public function cleanResults():void {
			Logger.debug('Cleaning subpanels.');
			
			_subpanelA.clean();
			_subpanelB.clean();
			_subpanelC.clean();
			_subpanelD.clean();
			
			_subpanelA.setStatus(SubpanelCommon.STATUS_INFO, 'LOADING');
			_subpanelB.setStatus(SubpanelCommon.STATUS_INFO, '');
			_subpanelC.setStatus(SubpanelCommon.STATUS_INFO, '');
			_subpanelD.setStatus(SubpanelCommon.STATUS_INFO, '');
			
			_refreshSliders();
		}

		
		
		/**
		 * Parse results.
		 * @param si Song data array
		 * @param ti Track data array
		 */
		public function parseResults(si:Array, ti:Array):void {
			_subpanelA.setData(si, ti);
			_subpanelA.currentType = Settings.TYPE_SONG;
			_subpanelB.setStatus(SubpanelCommon.STATUS_INFO, 'CLICK ON A SONG OR TRACK\nTO BEGIN BROWSING');
			
			_refreshSliders();
		}

		
		
		private function _refreshSliders():void {
			_sliderA.areEventsEnabled = (_subpanelA.height > _sliderA.height);
			_sliderB.areEventsEnabled = (_subpanelB.height > _sliderB.height);
			_sliderC.areEventsEnabled = (_subpanelC.height > _sliderC.height);
			_sliderD.areEventsEnabled = (_subpanelD.height > _sliderD.height);
			
			_sliderA.alpha = (_subpanelA.height > _sliderA.height) ? 1 : .4;
			_sliderB.alpha = (_subpanelB.height > _sliderB.height) ? 1 : .4;
			_sliderC.alpha = (_subpanelC.height > _sliderC.height) ? 1 : .4;
			_sliderD.alpha = (_subpanelD.height > _sliderD.height) ? 1 : .4;
		}

		
		
		/**
		 * Song or track in subpanel A selected.
		 * @param event Event data
		 */
		private function _onSubpanelARowSelect(event:SubpanelEvent):void {
			if(event.data.type == Settings.TYPE_SONG) {
				// song clicked
				var sd:SongData = event.data.data as SongData;
				_currentTitle = sd.songTitle;
				
				Logger.info(sprintf('Subpanel A row select (%s, %s)', event.data.type, _currentTitle));
				
				// process panel B
				_subpanelB.clean();
				_subpanelB.setStatus(SubpanelCommon.STATUS_INFO, 'LOADING');
				
				// process panel C
				_subpanelC.clean();
				_subpanelC.setData(sd.songTracks, sprintf('%s for “%s”', App.getPlural(sd.songTracks.length, '%u track', '%u tracks'), _currentTitle));
				_subpanelC.fill();
				
				// process panbel D
				_subpanelD.clean();
				_subpanelD.setStatus(SubpanelCommon.STATUS_INFO, 'LOADING');
				
				// refresh sliders
				_refreshSliders();
				
				try { _songSiblingsService.request({songID:sd.songID}); }
				catch(err1:Error) { Logger.error(sprintf('Could not get song siblings:\n%s', err1.message)); }
			}
			
			else {
				// track clicked
				var td:TrackData = event.data.data as TrackData;
				_currentTitle = td.trackTitle;
				
				// process panel B
				_subpanelB.clean();
				_subpanelB.setStatus(SubpanelCommon.STATUS_INFO, 'LOADING');
				
				// process panel C
				_subpanelC.clean();
				
				// process panel D
				_subpanelD.clean();
				_subpanelD.setStatus(SubpanelCommon.STATUS_INFO, 'LOADING');
				
				// refresh sliders
				_refreshSliders();
				
				try { _trackSiblingsService.request({trackID:td.trackID}); }
				catch(err2:Error) { Logger.error(sprintf('Could not get track siblings:\n%s', err2.message)); }
			}
		}

		
		
		/**
		 * Song in subpanel A selected.
		 * @param event Event data
		 */
		private function _onSubpanelBRowSelect(event:SubpanelEvent):void {
			if(event.data.type == Settings.TYPE_SONG) {
				// song clicked
				var sd:SongData = event.data.data as SongData;
				_currentTitle = sd.songTitle;
				Logger.info(sprintf('Subpanel B row select (%s, %s)', event.data.type, _currentTitle));
				
				// process panel C
				_subpanelC.clean();
				_subpanelC.setData(sd.songTracks, sprintf('%s for “%s”', App.getPlural(sd.songTracks.length, '%u track', '%u tracks'), _currentTitle));
				_subpanelC.fill();
				
				// refresh sliders
				_refreshSliders();
			}
			else {
				Logger.warn('Invalid selection in subpanel A (has to be song)');
			}
		}

		
		
		/**
		 * Song in subpanel D selected.
		 * @param event Event data
		 */
		private function _onSubpanelDRowSelect(event:SubpanelEvent):void {
			if(event.data.type == Settings.TYPE_SONG) {
				// song clicked
				var sd:SongData = event.data.data as SongData;
				_currentTitle = sd.songTitle;
				Logger.info(sprintf('Subpanel D row select (%s, %s)', event.data.type, _currentTitle));
				
				// process panel C
				_subpanelC.clean();
				_subpanelC.setData(sd.songTracks, sprintf('%s for “%s”', App.getPlural(sd.songTracks.length, '%s track', '%s tracks'), _currentTitle));
				_subpanelC.fill();
				
				// refresh sliders
				_refreshSliders();
			}
			else {
				Logger.warn('Invalid selection in subpanel A (has to be song)');
			}
		}

		
		
		/**
		 * Song siblings request done event handler.
		 * @param event Event data
		 */
		private function _onSongSiblingsRequestDone(event:SongSiblingsEvent):void {
			// process panel B
			_subpanelB.setData(event.directList, sprintf('%s of “%s”', App.getPlural(event.directList.length, '%u version', '%u versions'), _currentTitle));
			_subpanelB.fill();
			
			// process panel D
			_subpanelD.setData(event.indirectList, sprintf('%s of “%s”', App.getPlural(event.indirectList.length, '%u remote version', '%u remote versions'), _currentTitle));
			_subpanelD.fill();
			
			// refresh sliders
			_refreshSliders();
		}

		
		
		/**
		 * Track siblings request done event handler.
		 * @param event Event data
		 */
		private function _onTrackSiblingsRequestDone(event:TrackSiblingsEvent):void {
			// process panel B
			_subpanelB.setData(event.directList, sprintf('%s of “%s”', App.getPlural(event.directList.length, '%u version', '%u versions'), _currentTitle));
			_subpanelB.fill();
			
			// process panel C
			_subpanelC.setStatus(SubpanelCommon.STATUS_INFO, 'SELECT A SONG TO SEE\nIT\'S TRACKS');
			
			// process panel D
			_subpanelD.setData(event.indirectList, sprintf('%s of “%s”', App.getPlural(event.indirectList.length, '%u remote version', '%u remote versions'), _currentTitle));
			_subpanelD.fill();
			
			// refresh sliders
			_refreshSliders();
		}

		
		
		/**
		 * Reset subpanels.
		 * @param event Event data
		 */
		private function _onSubpanelReset(event:SubpanelEvent):void {
			cleanResults();
		}

		
		
		private function _onSliderARefresh(event:SliderEvent):void {
			var p:int = Math.round((_subpanelA.height - 314 - 21) * event.thumbPos);
			_subpanelA.y = 45 + p * -1;
		}

		
		
		private function _onSliderBRefresh(event:SliderEvent):void {
			var p:int = Math.round((_subpanelB.height - 314 - 21) * event.thumbPos);
			_subpanelB.y = 45 + p * -1;
		}

		
		
		private function _onSliderCRefresh(event:SliderEvent):void {
			var p:int = Math.round((_subpanelC.height - 128 - 21) * event.thumbPos);
			_subpanelC.y = 45 + p * -1;
		}

		
		
		private function _onSliderDRefresh(event:SliderEvent):void {
			var p:int = Math.round((_subpanelD.height - 128 - 21) * event.thumbPos);
			_subpanelD.y = 231 + p * -1;
		}
	}
}

