APC_MENU.LAM2 = LibStub:GetLibrary("LibAddonMenu-2.0")


APC_MENU.PanelData =
{
	type = "panel",
	name = "Alliance Points Counter",
	displayName = "Alliance Points Counter",
	author = "Mladen90",
	version = APC.StringVersion,
	registerForRefresh = true
}


APC_MENU.OptionData = 
{
	{
		type = "header",
		name = "Settings"
	},
	{
		type = "checkbox",
		name = "Use Alliance Point icon",
		tooltip = "When checked, uses icon instead of text for Alliance Points",
		width = "half",
		getFunc = function() return APC.SavedVariables.UseAPIcon end,
		setFunc = function(newValue) APC.SavedVariables.UseAPIcon = newValue end
	},
	{
		type = "colorpicker",
		name = "Chat text color",
		width = "half",
		getFunc = function()
			return
			APC.SavedVariables.LogColor.Red,
			APC.SavedVariables.LogColor.Green,
			APC.SavedVariables.LogColor.Blue
		end,
		setFunc = function(r, g, b)
			APC.SavedVariables.LogColor.Red = r
			APC.SavedVariables.LogColor.Green = g
			APC.SavedVariables.LogColor.Blue = b
		end
    },
	{
		type = "checkbox",
		name = "Restore alliance points",
		tooltip = "When checked, restores alliance points after relog/reload",
		width = "half",
		getFunc = function() return APC.SavedVariables.RestoreAP end,
		setFunc = function(newValue) APC.SavedVariables.RestoreAP = newValue end
	},
	{
		type = "slider",
		name = "Skip restoring after last gain in mins",
		tooltip = "Skip restoring AP when this amount of minutes elapsed from last AP gain, instead it will reset the data",
		width = "half",
		min = 1,
		max = 120,
		step = 1,
		getFunc = function() return APC.SavedVariables.SkipRestoreApAfterMins end,
		setFunc = function(newValue) APC.SavedVariables.SkipRestoreApAfterMins = newValue end,
		disabled = function() return (not APC.SavedVariables.RestoreAP) end
	},
	{
		type = "checkbox",
		name = "Show available commands on startup",
		tooltip = "When checked, shows startup message which commands are available",
		getFunc = function() return APC.SavedVariables.ShowAvailableCommandsMessageOnStart end,
		setFunc = function(newValue) APC.SavedVariables.ShowAvailableCommandsMessageOnStart = newValue end
	},
	{
		type = "submenu",
		name = "Alliance point log settings",
		controls =
		{
			{
				type = "checkbox",
				name = "Log Alliance Points to chat",
				tooltip = "When checked, logs Alliance Points to chat",
				width = "half",
				getFunc = function() return APC.SavedVariables.LogEnabled end,
				setFunc = function(newValue) APC.SavedVariables.LogEnabled = newValue end
			},
			{
				type = "slider",
				name = "Log after this amount of alliance points",
				tooltip = "Logs each time you get this amount of alliance point over time (If set to 1 will show log with AP type, else will show current AP and time)",
				width = "half",
				min = 1,
				max = 10000,
				step = 1,
				getFunc = function() return APC.SavedVariables.LogAPAmount end,
				setFunc = function(newValue) APC.SavedVariables.LogAPAmount = newValue end,
				disabled = function() return (not APC.SavedVariables.LogEnabled) end
			},
			{
				type = "checkbox",
				name = "Log AP in long format",
				tooltip = "When checked, logs Alliance Points in long format",
				getFunc = function() return APC.SavedVariables.LogAPLongFormat end,
				setFunc = function(newValue) APC.SavedVariables.LogAPLongFormat = newValue end,
				disabled = function() return (not APC.SavedVariables.LogEnabled) end
			},
			{
				type = "checkbox",
				name = "Log every tick to chat (even if logging is disabled)",
				tooltip = "When checked, logs Alliance Points gain for ticks",
				getFunc = function() return APC.SavedVariables.LogEveryTickEnabled end,
				setFunc = function(newValue) APC.SavedVariables.LogEveryTickEnabled = newValue end
			}
		}
	},
	{
		type = "submenu",
		name = "Alliance point screen message settings",
		controls =
		{
			{
				type = "checkbox",
				name = "Show message when Tick happens",
				tooltip = "When checked, shows message on screen",
				width = "half",
				getFunc = function() return APC.SavedVariables.ScreenMessage end,
				setFunc = function(newValue) APC.SavedVariables.ScreenMessage = newValue end
			},
			{
				type = "slider",
				name = "Show ticks with this amount of alliance points",
				tooltip = "Shows tick message when you get this amount from tick",
				width = "half",
				min = 1,
				max = 10000,
				step = 1,
				getFunc = function() return APC.SavedVariables.TickAPAmount end,
				setFunc = function(newValue) APC.SavedVariables.TickAPAmount = newValue end,
				disabled = function() return (not APC.SavedVariables.ScreenMessage) end
			},
			{
				type = "slider",
				name = "Tick fade time",
				tooltip = "Fades the tick screen message after this amount of sec",
				width = "half",
				min = 1,
				max = 10,
				step = 1,
				getFunc = function() return APC.SavedVariables.TickFadeTime end,
				setFunc = function(newValue) APC.SavedVariables.TickFadeTime = newValue end,
				disabled = function() return (not APC.SavedVariables.ScreenMessage) end
			},
			{
				type = "colorpicker",
				name = "Tick color",
				tooltip = "Color for the tick",
				width = "half",
				getFunc = function()
					return
					APC.SavedVariables.TickColor.Red,
					APC.SavedVariables.TickColor.Green,
					APC.SavedVariables.TickColor.Blue
				end,
				setFunc = function(r, g, b)
					APC.SavedVariables.TickColor.Red = r
					APC.SavedVariables.TickColor.Green = g
					APC.SavedVariables.TickColor.Blue = b
				end,
				disabled = function() return (not APC.SavedVariables.ScreenMessage) end
			}
		}
	},
	{
		type = "submenu",
		name = "Test buttons",
		controls =
		{
			{
			    type = "button",
			    name = "Test chat text",
				width = "half",
			    func = function()
					APC_SystemPrint("APC TEST: 12345" .. APC_GetApText())
				end
			},
			{
			    type = "button",
			    name = "Test screen message",
				width = "half",
			    func = function()
					APC_FORMS.Functions.SetlblTick("APC TEST: 12345" .. APC_GetApText(true))
				end,
				disabled = function() return (not APC.SavedVariables.ScreenMessage) end
			}
		}
	}
}


APC_MENU.Init = function()
	APC_MENU.LAM2:RegisterAddonPanel("APC_SETTINGS", APC_MENU.PanelData)
	APC_MENU.LAM2:RegisterOptionControls("APC_SETTINGS", APC_MENU.OptionData)
end