APC_FORMS.MainWindow = nil
APC_FORMS.MainWindowBackGround = nil
APC_FORMS.Fragment = nil
APC_FORMS.Functions = {}


APC_FORMS.Functions.Init = function()
	APC_FORMS.MainWindow = WINDOW_MANAGER:CreateTopLevelWindow()
	APC_FORMS.MainWindow:SetDimensions(500, 100)
	APC_FORMS.MainWindow:SetResizeToFitDescendents(false)
	APC_FORMS.MainWindow:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
	APC_FORMS.MainWindow:SetMovable(false)
	APC_FORMS.MainWindow:SetMouseEnabled(false)
	
	APC_FORMS.MainWindowBackGround = WINDOW_MANAGER:CreateControl(nil, APC_FORMS.MainWindow, CT_BACKDROP)
	APC_FORMS.MainWindowBackGround:SetEdgeColor(0, 0, 0)
	APC_FORMS.MainWindowBackGround:SetCenterColor(0, 0, 0)
	APC_FORMS.MainWindowBackGround:SetAnchor(TOPLEFT, nil, TOPLEFT, 0, 0)
	APC_FORMS.MainWindowBackGround:SetDimensions(500, 100)
	APC_FORMS.MainWindowBackGround:SetAlpha(0)
	APC_FORMS.MainWindowBackGround:SetDrawLayer(0)
end


APC_FORMS.Functions.SetlblTick = function(text)
	if APC_FORMS.Fragment then APC_FORMS.Fragment:Hide(0) end

	local lblTick = WINDOW_MANAGER:CreateControl(nil, APC_FORMS.MainWindow, CT_LABEL)
	lblTick:SetText(text)
	lblTick:SetColor(APC.SavedVariables.TickColor.Red, APC.SavedVariables.TickColor.Green, APC.SavedVariables.TickColor.Blue, 1)
	lblTick:SetFont("ZoFontCallout3")
	lblTick:SetScale(1)
	lblTick:SetDrawLayer(1)
	lblTick:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
	lblTick:SetDimensions(0, 0)
	
	APC_FORMS.Fragment = ZO_HUDFadeSceneFragment:New(lblTick)
	SCENE_MANAGER:AddFragment(APC_FORMS.Fragment)
	APC_FORMS.Fragment:Hide(APC.SavedVariables.TickFadeTime * 1000)
end