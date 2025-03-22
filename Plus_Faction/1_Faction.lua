local id, e = ...
WoWTools_FactionMixin.Save={
	btn=WoWTools_DataMixin.Player.husandro,--启用，TrackButton
	factions={},--指定,显示,声望
	btnstr=true,--文本
	scaleTrackButton=1,--缩放
	--notAutoHideTrack=true,--自动隐藏
	toRightTrackText=true,--向右平移
	--toTopTrack=true,--向上

	factionUpdateTips=true,--更新, 提示
	--indicato=true,--指定
	onlyIcon=WoWTools_DataMixin.Player.husandro,--隐藏名称， 仅显示有图标
	--notPlus=true,
}

local function Save()
	return WoWTools_FactionMixin.Save
end


local panel= CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent("PLAYER_LOGOUT")
panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
		if arg1== 'WoWTools' then

			if WoWToolsSave['Plus_Reputation'] then
				WoWTools_FactionMixin.Save= WoWToolsSave['Plus_Reputation']
				Save().factions= Save().factions or {}
				WoWToolsSave['Plus_Reputation']= nil
			else
				WoWTools_FactionMixin.Save= WoWToolsSave['Plus_Faction'] or Save()
			end
			

			local addName= format('|A:%s:0:0|a%s', WoWTools_DataMixin.Icon[WoWTools_DataMixin.Player.Faction] or 'ParagonReputation_Glow', WoWTools_Mixin.onlyChinese and '声望' or REPUTATION)
			WoWTools_FactionMixin.addName= addName

			--添加控制面板
			WoWTools_PanelMixin:OnlyCheck({
				name= addName,
				GetValue= function() return not Save().disabled end,
				SetValue= function()
					Save().disabled= not Save().disabled and true or nil
					print(WoWTools_DataMixin.Icon.icon2.. addName, WoWTools_TextMixin:GetEnabeleDisable(not Save().disabled), WoWTools_Mixin.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
				end
			})

			if Save().disabled then
				self:UnregisterEvent(event)
			else
				WoWTools_FactionMixin:Init_Button()
				WoWTools_FactionMixin:Init_ScrollBox_Plus()
				WoWTools_FactionMixin:Init_Chat_MSG()
				WoWTools_FactionMixin:Init_TrackButton()
				WoWTools_FactionMixin:Init_Other_Button()
			end

		elseif arg1=='Blizzard_MajorFactions' then
			WoWTools_FactionMixin:Init_MajorFactionRenownFrame()--名望

		elseif arg1=='Blizzard_CovenantRenown' then
			WoWTools_FactionMixin:Init_CovenantRenown(CovenantRenownFrame)--盟约 9.0
		end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            WoWToolsSave['Plus_Faction']=Save()
        end
    end
end)