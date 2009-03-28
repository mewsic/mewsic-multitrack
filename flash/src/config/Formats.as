package config {
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;	

	
	
	/**
	 * Global formats.
	 * 
	 * @author Vaclav Vancura (http://vaclav.vancura.org)
	 * @since Jun 13, 2008
	 */
	public class Formats {

		
		
		private static const _MYRIAD_WEB_REGULAR:String = 'MyriadWebRegular';
		private static const _MYRIAD_WEB_BOLD:String = 'MyriadWebBold';
		private static const _HELVETICA_NEUE_BOLD:String = 'HelveticaNeueBold';
		
		// NEW formats
		public static var controllerText:TextFormat = new TextFormat();
		
		
		public static var buttonStandard:TextFormat = new TextFormat();
		public static var buttonSmall:TextFormat = new TextFormat();
		public static var panelDescription:TextFormat = new TextFormat();
		public static var standardContainerInstrument:TextFormat = new TextFormat();
		public static var standardContainerTitle:TextFormat = new TextFormat();
		public static var standardContainerDescription:TextFormat = new TextFormat();
		public static var standardContainerSpecsTitle:TextFormat = new TextFormat();
		public static var standardContainerSpecsContent:TextFormat = new TextFormat();
		public static var recordContainerInstrument:TextFormat = new TextFormat();
		public static var recordContainerTitle:TextFormat = new TextFormat();
		public static var recordContainerDescription:TextFormat = new TextFormat();
		public static var recordContainerSpecsTitle:TextFormat = new TextFormat();
		public static var recordContainerSpecsContent:TextFormat = new TextFormat();
		public static var recordTrackStatus:TextFormat = new TextFormat();
		public static var scrollerRuntimeTitle:TextFormat = new TextFormat();
		public static var scrollerRuntimeContent:TextFormat = new TextFormat();
		public static var rulerPlayhead:TextFormat = new TextFormat();
		public static var menuOut:TextFormat = new TextFormat();
		public static var menuOver:TextFormat = new TextFormat();
		public static var inputOut:TextFormat = new TextFormat();
		public static var inputOver:TextFormat = new TextFormat();
		public static var inputPress:TextFormat = new TextFormat();
		public static var inputIntro:TextFormat = new TextFormat();
		public static var modalTitle:TextFormat = new TextFormat();
		public static var modalDescription:TextFormat = new TextFormat();
		public static var modalDescriptionLeft:TextFormat = new TextFormat();
		public static var fps:TextFormat = new TextFormat();
		public static var viewportPreloadInfoLabel:TextFormat = new TextFormat();
		public static var progress:TextFormat = new TextFormat();
		public static var rulerTickLabel:TextFormat = new TextFormat();
		
		
		// NEW formats
		controllerText.font = _MYRIAD_WEB_BOLD;
		controllerText.size = 12;
		controllerText.color = 0x305A78;
		controllerText.align = TextFormatAlign.LEFT;
		
		
		
		buttonStandard.font = _MYRIAD_WEB_BOLD; 
		buttonStandard.size = 12; 
		buttonStandard.color = 0xFFFFFF; 
		buttonStandard.align = TextFormatAlign.CENTER; 
		
		buttonSmall.font = _MYRIAD_WEB_BOLD; 
		buttonSmall.size = 9; 
		buttonSmall.color = 0xFFFFFF; 
		buttonSmall.align = TextFormatAlign.CENTER; 
		
		panelDescription.font = _MYRIAD_WEB_REGULAR; 
		panelDescription.size = 10; 
		panelDescription.color = 0x666666; 
		
		standardContainerInstrument.font = _MYRIAD_WEB_BOLD; 
		standardContainerInstrument.size = 10; 
		standardContainerInstrument.color = 0x3c4e2e; 
		standardContainerInstrument.leading = -1; 
		
		standardContainerTitle.font = _MYRIAD_WEB_BOLD; 
		standardContainerTitle.size = 12; 
		standardContainerTitle.color = 0x3c4e2e; 
		standardContainerTitle.leading = -1; 
		
		standardContainerDescription.font = _MYRIAD_WEB_REGULAR; 
		standardContainerDescription.size = 9; 
		standardContainerDescription.color = 0x808978; 
		
		standardContainerSpecsTitle.font = _MYRIAD_WEB_REGULAR; 
		standardContainerSpecsTitle.size = 9; 
		standardContainerSpecsTitle.color = 0x808978; 
		standardContainerSpecsTitle.leading = 2; 
		standardContainerSpecsTitle.align = 'right'; 
		
		standardContainerSpecsContent.font = _MYRIAD_WEB_BOLD; 
		standardContainerSpecsContent.size = 10; 
		standardContainerSpecsContent.color = 0x3c4e2e; 
		standardContainerSpecsContent.leading = 1; 
		
		recordContainerInstrument.font = _MYRIAD_WEB_BOLD; 
		recordContainerInstrument.size = 10; 
		recordContainerInstrument.color = 0x2f454f; 
		recordContainerInstrument.leading = -1; 
		
		recordContainerTitle.font = _MYRIAD_WEB_BOLD; 
		recordContainerTitle.size = 12; 
		recordContainerTitle.color = 0x2f454f; 
		recordContainerTitle.leading = -1; 
		
		recordContainerDescription.font = _MYRIAD_WEB_REGULAR; 
		recordContainerDescription.size = 9; 
		recordContainerDescription.color = 0x6a808a; 
		
		recordContainerSpecsTitle.font = _MYRIAD_WEB_REGULAR; 
		recordContainerSpecsTitle.size = 9; 
		recordContainerSpecsTitle.color = 0x6a808a; 
		recordContainerSpecsTitle.leading = 2; 
		recordContainerSpecsTitle.align = 'right'; 
		
		recordContainerSpecsContent.font = _MYRIAD_WEB_BOLD; 
		recordContainerSpecsContent.size = 10; 
		recordContainerSpecsContent.color = 0x2f454f; 
		recordContainerSpecsContent.leading = 1;
		
		recordTrackStatus.font = _MYRIAD_WEB_BOLD;
		recordTrackStatus.size = 14;
		recordTrackStatus.leading = -4; 
		
		scrollerRuntimeTitle.font = _MYRIAD_WEB_REGULAR; 
		scrollerRuntimeTitle.size = 10; 
		scrollerRuntimeTitle.color = 0x202020; 
		
		scrollerRuntimeContent.font = _MYRIAD_WEB_BOLD; 
		scrollerRuntimeContent.size = 14; 
		scrollerRuntimeContent.color = 0x303030; 
		
		rulerPlayhead.font = _MYRIAD_WEB_BOLD; 
		rulerPlayhead.size = 11; 
		rulerPlayhead.color = 0xFFFFFF; 
		rulerPlayhead.align = TextFormatAlign.CENTER; 
		
		menuOut.font = _MYRIAD_WEB_BOLD; 
		menuOut.size = 11; 
		menuOut.color = 0x202020; 
		menuOut.align = TextFormatAlign.CENTER; 
		
		menuOver.font = _MYRIAD_WEB_BOLD; 
		menuOver.size = 11; 
		menuOver.color = 0xFFFFFF; 
		menuOver.align = TextFormatAlign.CENTER; 
		
		inputOut.font = _MYRIAD_WEB_BOLD; 
		inputOut.size = 13; 
		inputOut.color = 0x808080; 
		
		inputOver.font = _MYRIAD_WEB_BOLD; 
		inputOver.size = 13; 
		inputOver.color = 0x202020; 
		
		inputPress.font = _MYRIAD_WEB_BOLD; 
		inputPress.size = 13; 
		inputPress.color = 0xD40512; 
		
		inputIntro.font = _MYRIAD_WEB_BOLD; 
		inputIntro.size = 13; 
		inputIntro.color = 0x808080; 
		
		modalTitle.font = _MYRIAD_WEB_BOLD; 
		modalTitle.size = 26; 
		modalTitle.letterSpacing = -.8; 
		modalTitle.color = 0x333333; 
		modalTitle.align = TextFormatAlign.CENTER; 
		modalTitle.leading = -3; 
		modalTitle.kerning = true;
		
		modalDescription.font = _MYRIAD_WEB_BOLD; 
		modalDescription.size = 12; 
		modalDescription.color = 0x333333; 
		modalDescription.align = TextFormatAlign.CENTER; 
		
		modalDescriptionLeft.font = _MYRIAD_WEB_BOLD; 
		modalDescriptionLeft.size = 12; 
		modalDescriptionLeft.color = 0x333333; 
		
		fps.font = _MYRIAD_WEB_BOLD;
		fps.size = 9;
		fps.color = 0xFFFFFF;
		fps.align = TextFormatAlign.CENTER;
		
		viewportPreloadInfoLabel.font = _MYRIAD_WEB_BOLD;
		viewportPreloadInfoLabel.size = 7;
		viewportPreloadInfoLabel.color = 0xFFFFFF;
		viewportPreloadInfoLabel.align = TextFormatAlign.CENTER;
		
		progress.font = _MYRIAD_WEB_BOLD;
		progress.size = 11;
		progress.color = 0xFFFFFF;
		
		rulerTickLabel.font = _MYRIAD_WEB_REGULAR;
		rulerTickLabel.size = 8;
		rulerTickLabel.color = 0x303030;
	}
}
