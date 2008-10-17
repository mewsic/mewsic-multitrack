package manager_panel.search {
	import application.App;
	import application.AppEvent;
	
	import config.Embeds;
	import config.Filters;
	import config.Formats;
	import config.Settings;
	
	import controls.Button;
	import controls.Dropbox;
	import controls.Input;
	import controls.InputEvent;
	
	import com.gskinner.utils.StringUtils;
	
	import org.vancura.graphics.QBitmap;
	import org.vancura.graphics.QSprite;
	import org.vancura.graphics.QTextField;
	import org.vancura.util.addChildren;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextFieldAutoSize;	

	
	
	/**
	 * Advanced search sub tab.
	 * 
	 * TODO: Write documentation
	 * 
	 * @author Vaclav Vancura (http://vaclav.vancura.org)
	 * @since Jun 28, 2008
	 */
	public class AdvancedSearch extends QSprite {

		
		
		private var _bpmInput:Input;
		private var _countriesDropbox:Dropbox;
		private var _genresDropbox:Dropbox;
		private var _instrumentsDropbox:Dropbox;
		private var _keysDropbox:Dropbox;
		private var _authorInput:Input;
		private var _titleInput:Input;
		private var _backBM:QBitmap;
		private var _goBtn:Button;
		private var _headlineTF:QTextField;
		private var _contentHeight:Number;

		
		
		/**
		 * Constructor.
		 * @param o QSprite config Object
		 */
		public function AdvancedSearch(o:Object = null) {
			super(o);
			
			// add components
			_backBM = new QBitmap({embed:new Embeds.subpanelAdvancedSearchBackBD()});
			_goBtn = new Button({x:901, y:13, width:51, height:50, icon:new Embeds.glyphGoBD()});
			_authorInput = new Input({x:479, y:13, width:396, introText:'Author'});
			_titleInput = new Input({x:479, y:39, width:396, introText:'Title'});
			_genresDropbox = new Dropbox({x:333, y:13, width:120, introText:'Genre'});
			_countriesDropbox = new Dropbox({x:333, y:39, width:120, introText:'Country'});
			_bpmInput = new Input({x:229, y:13, width:78, introText:'BPM'});
			_keysDropbox = new Dropbox({x:229, y:39, width:78, introText:'Key'});
			_instrumentsDropbox = new Dropbox({x:14, y:13, width:189, introText:'Instrument'});
			_headlineTF = new QTextField({x:19, y:-29, width: 270, autoSize:TextFieldAutoSize.LEFT, defaultTextFormat:Formats.tabHeadline, filters:Filters.tabHeadline, text:'ADVANCED SEARCH'});

			// add to display list
			addChildren(this, _backBM, _headlineTF, _goBtn, _authorInput, _titleInput, _genresDropbox, _countriesDropbox, _bpmInput, _keysDropbox, _instrumentsDropbox);
			
			// add event listeners
			_goBtn.addEventListener(MouseEvent.CLICK, _onGoClick, false, 0, true);
			_authorInput.addEventListener(InputEvent.FOCUS_IN, _onInputFocusIn, false, 0, true);			_authorInput.addEventListener(InputEvent.ENTER_PRESSED, _onGoClick, false, 0, true);
			_titleInput.addEventListener(InputEvent.FOCUS_IN, _onInputFocusIn, false, 0, true);
			_titleInput.addEventListener(InputEvent.ENTER_PRESSED, _onGoClick, false, 0, true);
			_bpmInput.addEventListener(InputEvent.FOCUS_IN, _onInputFocusIn, false, 0, true);
			_bpmInput.addEventListener(InputEvent.ENTER_PRESSED, _onGoClick, false, 0, true);
			
			// fill dropboxes
			_keysDropbox.list = Settings.KEY_LIST;
		}

		
		
		public function postInit():void {
			_genresDropbox.list = App.connection.genresSearchService.genresNameList;
			_instrumentsDropbox.list = App.connection.instrumentsSearchService.instrumentsNameList;
			_countriesDropbox.list = App.connection.countriesSearchService.countriesList;
		}

		
		
		public function reset():void {
			_authorInput.reset();
			_titleInput.reset();
			_genresDropbox.reset();
			_countriesDropbox.reset();
			_bpmInput.reset();
			_keysDropbox.reset();
			_instrumentsDropbox.reset();
		}

		
		
		/**
		 * Get content height.
		 * @return Content height
		 */
		public function get contentHeight():Number {
			return _contentHeight;
		}

		
		
		/**
		 * Go click event handler.
		 * @param event Event data
		 */
		private function _onGoClick(event:Event):void {
			// dispatch
			dispatchEvent(new AppEvent(AppEvent.HIDE_DROPBOX, true));
			dispatchEvent(new AdvancedSearchEvent(AdvancedSearchEvent.ADVANCED_SEARCH, false, false, StringUtils.removeExtraWhitespace(_authorInput.text), StringUtils.removeExtraWhitespace(_titleInput.text), StringUtils.removeExtraWhitespace(_genresDropbox.text), StringUtils.removeExtraWhitespace(_countriesDropbox.text), StringUtils.removeExtraWhitespace(_bpmInput.text), StringUtils.removeExtraWhitespace(_keysDropbox.text), StringUtils.removeExtraWhitespace(_instrumentsDropbox.text)));
		}

		
		
		/**
		 * Input focus event listener.
		 * @param event Event data
		 */
		private function _onInputFocusIn(event:InputEvent):void {
			// dispatch
			dispatchEvent(new AppEvent(AppEvent.HIDE_DROPBOX, true));
		}
	}
}
