--[[
	Addon: APCounter
	Author: Mladen90
	Created by @Mladen90
]]--


APC = {}
APC_GLOBAL = {}
APC_FORMS = {}
APC_MENU = {}


APC_TimerStarted = function() return (APC.SavedVariables.StartTimeStamp ~= nil) end


APC_CheckIfRestoreIsSkipped = function() return (APC.SavedVariables.SkipRestoreApAfterMins <= APC_GetMinutesFromTimes(GetTimeStamp(), APC.SavedVariables.LastGainTimeStamp)) end


APC_GetSecondsFromTimes = function(greater, lower) return (greater - lower) end


APC_GetMinutesFromTimes = function(greater, lower) return math.floor(APC_GetSecondsFromTimes(greater, lower) / 60) end


APC_PrintLog = function() APC_SystemPrint(APC.SavedVariables.CurrentAP .. APC_GetApText() .. APC_GetMinutesForDisplay()) end


APC_GetMinutesFromTimer = function() return math.floor(APC_GetSecondsFromTimer() / 60) end


APC_GetMinutesForDisplay = function() return " (" .. APC_GetMinutesFromTimer() .. " mins) " end


APC_StartTimer = function()
	if APC_TimerStarted() then APC_SystemPrint("APC running" .. APC_GetMinutesForDisplay())
	else
		APC_TryInitTimer()
		APC_SystemPrint("APC started")
	end
end


-- Initializes the timer if not initialized
APC_TryInitTimer = function()
	if APC_TimerStarted() == false then APC.SavedVariables.StartTimeStamp = GetTimeStamp() end
end


APC_GetSecondsFromTimer = function()
	if APC_TimerStarted() then return (GetTimeStamp() - APC.SavedVariables.StartTimeStamp)
	else return 0 end
end


APC_Update = function(eventCode, alliancePoints, playSound, difference, reason)
	-- Nothing to calculate
	if (reason == CURRENCY_CHANGE_REASON_BANK_WITHDRAWAL or difference < 1) then return end

	-- Starts the timer if not started
	APC_TryInitTimer()
	
	APC.SavedVariables.LastGainTimeStamp = GetTimeStamp()
	APC_GLOBAL.SumLogAP = (APC_GLOBAL.SumLogAP + difference)

	APC_TryLogAlliancePoints(reason, APC.SavedVariables.CurrentAP, difference, APC.SavedVariables.CurrentAP + difference)
	APC_TryAnnounce(reason, difference)
	APC_UpdateApVariables(reason, difference)
	GetAddOnManager():RequestAddOnSavedVariablesPrioritySave(APC.AddOnName)
end


APC_TryLogAlliancePoints = function(reason, oldAP, diffAP, newAP)
	if (APC_GLOBAL.SumLogAP >= APC.SavedVariables.LogAPAmount) then
		APC_GLOBAL.SumLogAP = 0
		if APC.SavedVariables.LogEnabled then
			if ( APC.SavedVariables.LogAPLongFormat) then
				if (APC.SavedVariables.LogAPAmount == 1) then APC_SystemPrint(APC_GetApSourceInfoForDisplay(reason) .. oldAP .. APC_GetApText() .. " + " .. diffAP .. APC_GetApText() .. " = " .. newAP .. APC_GetApText() .. APC_GetMinutesForDisplay())
				else APC_SystemPrint("+" .. (newAP - oldAP) .. APC_GetApText() .. " -> " .. newAP .. APC_GetApText() .. APC_GetMinutesForDisplay()) end
			else
				if (APC.SavedVariables.LogAPAmount == 1) then APC_SystemPrint(APC_GetBaseApSourceInfoForDisplay(reason) .. " +" .. diffAP .. APC_GetApText() .. " -> " .. newAP .. APC_GetApText() .. APC_GetMinutesForDisplay())
				else APC_SystemPrint(newAP .. APC_GetApText() .. APC_GetMinutesForDisplay()) end
			end
		end
	end
	
	if (APC.SavedVariables.LogEveryTickEnabled and (reason == CURRENCY_CHANGE_REASON_DEFENSIVE_KEEP_REWARD or reason == CURRENCY_CHANGE_REASON_OFFENSIVE_KEEP_REWARD)) then
		APC_SystemPrint(APC_GetApSourceInfoForDisplay(reason) .. diffAP .. APC_GetApText())
	end
end


APC_TryAnnounce = function(reason, difference)
	if (APC.SavedVariables.ScreenMessage and APC.SavedVariables.TickAPAmount <= difference) then
		if (reason == CURRENCY_CHANGE_REASON_DEFENSIVE_KEEP_REWARD) then APC_FORMS.Functions.SetlblTick("DTICK " .. difference .. APC_GetApText(true))
		elseif(reason == CURRENCY_CHANGE_REASON_OFFENSIVE_KEEP_REWARD) then APC_FORMS.Functions.SetlblTick("OTICK " .. difference .. APC_GetApText(true)) end
	end
end


APC_UpdateApVariables = function(reason, diffAP)
	APC.SavedVariables.CurrentAP = (APC.SavedVariables.CurrentAP + diffAP)

	if (reason == CURRENCY_CHANGE_REASON_QUESTREWARD) then APC.SavedVariables.APFromQ = APC.SavedVariables.APFromQ + diffAP
	elseif (reason == CURRENCY_CHANGE_REASON_KILL) then APC.SavedVariables.APFromKH = APC.SavedVariables.APFromKH + diffAP
	elseif (reason == CURRENCY_CHANGE_REASON_DEFENSIVE_KEEP_REWARD) then APC.SavedVariables.APFromDT = APC.SavedVariables.APFromDT + diffAP
	elseif (reason == CURRENCY_CHANGE_REASON_OFFENSIVE_KEEP_REWARD) then APC.SavedVariables.APFromOT = APC.SavedVariables.APFromOT + diffAP
	elseif (reason == CURRENCY_CHANGE_REASON_KEEP_REPAIR) then APC.SavedVariables.APFromWD = APC.SavedVariables.APFromWD + diffAP
	elseif (reason == CURRENCY_CHANGE_REASON_PVP_RESURRECT) then APC.SavedVariables.APFromRA = APC.SavedVariables.APFromRA + diffAP
	elseif (reason == CURRENCY_CHANGE_REASON_REWARD) then APC.SavedVariables.APFromRE = APC.SavedVariables.APFromRE + diffAP
	elseif (reason == CURRENCY_CHANGE_REASON_BATTLEGROUND or reason == CURRENCY_CHANGE_REASON_MEDAL) then APC.SavedVariables.APFromBG = APC.SavedVariables.APFromBG + diffAP
	else APC.SavedVariables.APFromU = APC.SavedVariables.APFromU + diffAP end
end


APC_GetApSourceInfoForDisplay = function(reason) return APC_GetBaseApSourceInfoForDisplay(reason) .. " -> " end


APC_GetBaseApSourceInfoForDisplay = function(reason)
	if (reason == CURRENCY_CHANGE_REASON_QUESTREWARD) then return "Q "
	elseif (reason == CURRENCY_CHANGE_REASON_KILL) then return "KH"
	elseif (reason == CURRENCY_CHANGE_REASON_DEFENSIVE_KEEP_REWARD) then return "DT"
	elseif (reason == CURRENCY_CHANGE_REASON_OFFENSIVE_KEEP_REWARD) then return "OT"
	elseif (reason == CURRENCY_CHANGE_REASON_KEEP_REPAIR) then return "WD"
	elseif (reason == CURRENCY_CHANGE_REASON_PVP_RESURRECT) then return "RA"
	elseif (reason == CURRENCY_CHANGE_REASON_REWARD) then return "RE"
	elseif (reason == CURRENCY_CHANGE_REASON_BATTLEGROUND or reason == CURRENCY_CHANGE_REASON_MEDAL) then return "BG"
	else return "U " end
end


APC_ResetApcState = function(skipMessage)
	APC.SavedVariables.StartTimeStamp = nil
	APC.SavedVariables.CurrentAP = 0
	APC.SavedVariables.APFromQ = 0
	APC.SavedVariables.APFromKH = 0
	APC.SavedVariables.APFromDT = 0
	APC.SavedVariables.APFromOT = 0
	APC.SavedVariables.APFromWD = 0
	APC.SavedVariables.APFromRA = 0
	APC.SavedVariables.APFromRE = 0
	APC.SavedVariables.APFromBG = 0
	APC.SavedVariables.APFromU = 0
	APC_GLOBAL.SumLogAP = 0
	APC.SavedVariables.LastGainTimeStamp = GetTimeStamp()

	if (skipMessage ~= true) then APC_SystemPrint("APC reseted") end
end


APC_PrintCommands = function()
	APC_SystemPrint("APC slash commands:")
	APC_SystemPrint("/apc_commands /apc_source_info /apc_data")
	APC_SystemPrint("/apc_start /apc_reset /apc_statistic")
end


APC_Load = function(eventCode, addonName)
	-- Prevents running this function if the addonName is not the same as this AddOnName, since load is called for all addons more times
    if addonName ~= APC.AddOnName then return end

    EVENT_MANAGER:UnregisterForEvent(addonName, eventCode)
	
	APC.SavedVariables = ZO_SavedVars:New(APC.SavedVariablesFileName, APC.Version, nil, APC.Default)
	
	if (APC.SavedVariables.ShowAvailableCommandsMessageOnStart) then APC_PrintCommands() end
	
	APC_FORMS.Functions.Init()
	APC_MENU.Init()

	if (APC.SavedVariables.RestoreAP) then
		if(APC.SavedVariables.CurrentAP < 1) then
			APC_SystemPrint("APC has nothing to restore")
			APC_ResetApcState(true)
		elseif (APC_CheckIfRestoreIsSkipped()) then
			APC_SystemPrint("APC reseted state, restore time elapsed")
			APC_ResetApcState(true)
		else
			APC_SystemPrint("APC restored state:")
			APC_PrintLog()
		end
	else APC_ResetApcState(true) end
end


APC_CheckStatistic = function()
	if (APC.SavedVariables.CurrentAP == 0) then APC_SystemPrint("No data for statistics")
	elseif (APC_GetMinutesFromTimer() < 10) then APC_SystemPrint("Statistics available in " .. (10 - APC_GetMinutesFromTimer()) .. " mins")
	else
		APC_SystemPrint(math.floor((APC.SavedVariables.CurrentAP / APC_GetSecondsFromTimer()) * 60) .. APC_GetApText() .. "/min")
		APC_SystemPrint(math.floor((APC.SavedVariables.CurrentAP / APC_GetSecondsFromTimer()) * 3600) .. APC_GetApText() .. "/hour")

		forSort = {}
		APC_AddForSort(forSort, APC.SavedVariables.APFromQ, "Q")
		APC_AddForSort(forSort, APC.SavedVariables.APFromKH, "KH")
		APC_AddForSort(forSort, APC.SavedVariables.APFromDT, "DT")
		APC_AddForSort(forSort, APC.SavedVariables.APFromOT, "OT")
		APC_AddForSort(forSort, APC.SavedVariables.APFromWD, "WD")
		APC_AddForSort(forSort, APC.SavedVariables.APFromRA, "RA")
		APC_AddForSort(forSort, APC.SavedVariables.APFromRE, "RE")
		APC_AddForSort(forSort, APC.SavedVariables.APFromBG, "BG")
		APC_AddForSort(forSort, APC.SavedVariables.APFromU, "U")
		
		APC_MySortDescending(forSort)
		
		for i=1,forSort.Length,1 do
			if forSort[i].Value > 0 then APC_SystemPrint(APC_PercentStatisticInfo(forSort[i].Value, forSort[i].Data)) end
		end
	end
end


-- forSort needs to be created with APC_AddForSort
APC_MySortDescending = function(forSort)
	sorted = {}
	for i=1,forSort.Length,1 do table.insert(sorted, forSort[i]) end
	table.sort(sorted, function(a,b) return a.Value > b.Value end)
	for i=1,forSort.Length,1 do forSort[i] = sorted[i] end
end


APC_AddForSort = function(forSort, value, data)
	if (forSort.Length == nil) then forSort.Length = 0 end
	
	forSort.Length = forSort.Length + 1
	forSort[forSort.Length] = {}
	forSort[forSort.Length].Value = value
	forSort[forSort.Length].Data = data
end


APC_PercentStatisticInfo = function(sourceAP, sourceInfo) return sourceAP .. APC_GetApText() .. " (" .. APC_Floor((sourceAP / APC.SavedVariables.CurrentAP) * 100, 2) .. "%) from " .. APC_GetSourceInfo(sourceInfo) end


APC_DisplaySourceInfo = function()
	APC_SystemPrint("Q  -> " .. APC_GetSourceInfo("Q") .. " ")
	APC_SystemPrint("KH -> " .. APC_GetSourceInfo("KH") .. " ")
	APC_SystemPrint("DT -> " .. APC_GetSourceInfo("DT") .. " ")
	APC_SystemPrint("OT -> " .. APC_GetSourceInfo("OT") .. " ")
	APC_SystemPrint("WD -> " .. APC_GetSourceInfo("WD") .. " ")
	APC_SystemPrint("RA -> " .. APC_GetSourceInfo("RA") .. " ")
	APC_SystemPrint("RE -> " .. APC_GetSourceInfo("RE") .. " ")
	APC_SystemPrint("BG -> " .. APC_GetSourceInfo("BG") .. " ")
	APC_SystemPrint("U  -> " .. APC_GetSourceInfo("U") .. " ")
end


APC_GetSourceInfo = function(sourceInfo)
	if (sourceInfo == "Q") then return "Quest"
	elseif (sourceInfo == "KH") then return "Kill or Heal"
	elseif (sourceInfo == "DT") then return "Tick for defending"
	elseif (sourceInfo == "OT") then return "Tick for capping"
	elseif (sourceInfo == "WD") then return "Repairing wall or door"
	elseif (sourceInfo == "RA") then return "Resurrect ally"
	elseif (sourceInfo == "RE") then return "Reward (daily login)"
	elseif (sourceInfo == "BG") then return "Battleground"
	elseif (sourceInfo == "U") then return "Unknown"
	else return sourceInfo end
end


APC_Floor = function(num, numDecimalPlaces) return tonumber(string.format("%." .. (numDecimalPlaces or 0) .. "f", num)) end


APC_SystemPrint = function(text) d(APC_GetChatTextColor() .. text .. "|r") end


APC_GetChatTextColor = function()
	local color = ZO_ColorDef:New(APC.SavedVariables.LogColor.Red, APC.SavedVariables.LogColor.Green, APC.SavedVariables.LogColor.Blue, 1)
	return "|c" .. color:ToHex()
end


APC_GetApText = function(isTick)
	local apText = " AP"

	if APC.SavedVariables.UseAPIcon then
		if isTick then apText = APC_ALLIANCE_POINT_TEXT_ICON_LARGE
		else apText = APC_ALLIANCE_POINT_TEXT_ICON_SMALL .. APC_GetChatTextColor() end
	end

	return apText
end


SLASH_COMMANDS["/apc_commands"]		= 	APC_PrintCommands
SLASH_COMMANDS["/apc_start"]		=	APC_StartTimer
SLASH_COMMANDS["/apc_reset"]		= 	APC_ResetApcState
SLASH_COMMANDS["/apc_data"]      	= 	APC_PrintLog
SLASH_COMMANDS["/apc_statistic"]	=	APC_CheckStatistic
SLASH_COMMANDS["/apc_source_info"]	=	APC_DisplaySourceInfo


EVENT_MANAGER:RegisterForEvent("APC_Load", EVENT_ADD_ON_LOADED, APC_Load)
EVENT_MANAGER:RegisterForEvent("APC_Update", EVENT_ALLIANCE_POINT_UPDATE, APC_Update)