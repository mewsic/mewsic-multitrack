package manager_panel {
	import application.App;
	import application.AppEvent;
	import application.PanelCommon;
	
	import caurina.transitions.Tweener;
	
	import config.Embeds;
	import config.Filters;
	import config.Formats;
	import config.Settings;
	
	import controls.Button;
	import controls.Input;
	import controls.InputEvent;
	
	import manager_panel.tabs.TabCommon;
	import manager_panel.tabs.TabEvent;
	
	import modals.MessageModal;
	
	import de.popforge.utils.sprintf;
	
	import com.gskinner.utils.StringUtils;
	
	import org.osflash.thunderbolt.Logger;
	import org.vancura.graphics.Drawing;
	import org.vancura.graphics.QBitmap;
	import org.vancura.graphics.QSprite;
	import org.vancura.util.addChildren;
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;	

	
	
	/**
	 * Search tab for manager panel.
	 * 
	 * TODO: Write documentation
	 * 
	 * @author Vaclav Vancura (http://vaclav.vancura.org)
	 * @since Jun 24, 2008
	 */
	public class Search extends TabCommon {

		
		
		private static const _TAB_ID:String = 'TabSearch';
		private static const _SUBTAB_Y:Number = 34;
		private static const _HEADER_X:Number = 20;
		private static const _VIEW_NONE:String = 'viewNone';
		private var _headerEditBtn:Button;
		private var _headerEditInput:Input;
		private var _headerFrontBM:QBitmap;
		private var _headerFixBM:QBitmap;
		private var _headerWaitPieMC:MovieClip;

		
		
		/**
		 * Constructor.
		 * @param o Config data
		 */
		public function Search(o:Object = null) {
			super(_TAB_ID, PanelCommon.BACK_TYPE_DARK, o);
			
			// add header
			_headerFrontBM = new QBitmap({embed:new Embeds.tabSearchFrontBD()});
			_headerEditInput = new Input({x:8, y:7, width:240, introText:'Search...'});
			_headerEditBtn = new Button({x:247, y:7, width:31, height:24, skin:new Embeds.buttonBlueMiniBD(), icon:new Embeds.glyphGoBD()});
			_headerFixBM = new QBitmap({embed:new Embeds.tabSearchFixBD(), x:_HEADER_X});
			_headerWaitPieMC = new Embeds.waitPieBlackMC() as MovieClip;
			
			// set visual properties
			$headerSpr.x = _HEADER_X;
			_headerEditInput.alpha = 0;
			_headerEditBtn.alpha = 0;
			_headerWaitPieMC.x = _HEADER_X + _headerFrontBM.width - 4;
			_headerWaitPieMC.y = 19;
			_headerWaitPieMC.visible = false;

			// add to display list
			addChildren($headerSpr, _headerFrontBM, _headerEditInput, _headerEditBtn, _headerWaitPieMC);

			// intro animation
			Tweener.addTween($headerSpr, {time:Settings.STAGE_HEIGHT_CHANGE_TIME, y:-35, rounded:true, transition:'easeInOutQuad'});
			Tweener.addTween(_headerEditInput, {alpha:1, delay:.2, time:Settings.STAGE_HEIGHT_CHANGE_TIME, transition:'easeInSine'});
			Tweener.addTween(_headerEditBtn, {alpha:1, delay:.2, time:Settings.STAGE_HEIGHT_CHANGE_TIME, transition:'easeInSine'});
			
			// add event listeners
			_headerEditBtn.addEventListener(MouseEvent.CLICK, _onHeaderEditBtnClick, false, 0, true);
			_headerEditInput.addEventListener(MouseEvent.CLICK, _onHeaderEditInputClick, false, 0, true);
			_headerEditInput.addEventListener(InputEvent.ENTER_PRESSED, _onHeaderEditBtnClick, false, 0, true);
			_headerEditInput.addEventListener(InputEvent.FOCUS_IN, _onInputFocusIn, false, 0, true);
		}

		
		
		public function postInit():void {
			Logger.debug("Skipped search service initialization");
		}

		
		
		private function _onHeaderEditInputClick(event:MouseEvent):void {
			dispatchEvent(new TabEvent(TabEvent.ACTIVATE));
		}

		
		
		private function _onHeaderEditBtnClick(event:Event):void {
			dispatchEvent(new TabEvent(TabEvent.ACTIVATE));
			App.messageModal.show({title:'Search', description:'This feature has been removed'});
		}

		
		
		/**
		 * Input focus event listener.
		 * @param event Event data
		 */
		private function _onInputFocusIn(event:InputEvent):void {
			dispatchEvent(new AppEvent(AppEvent.HIDE_DROPBOX, true));
		}
	}
}
