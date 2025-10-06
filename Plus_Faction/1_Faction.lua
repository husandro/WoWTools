
local P_Save={
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

	hideRenownFrame={},
	--hide_MajorFactionRenownFrame_Button=true,--隐藏，派系声望，列表，图标
	--MajorFactionRenownFrame_Button_Scale
	onlyUnlockRenownFrame=WoWTools_DataMixin.Player.husandro--仅限已解锁
}

local function Save()
	return WoWToolsSave['Plus_Faction']
end


local panel= CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")


panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
		if arg1== 'WoWTools' then

			WoWToolsSave['Plus_Faction']= WoWToolsSave['Plus_Faction'] or CopyTable(P_Save)
			Save().hideRenownFrame= Save().hideRenownFrame or {}
			P_Save=nil


			WoWTools_FactionMixin.addName= format('|A:%s:0:0|a%s', WoWTools_DataMixin.Icon[WoWTools_DataMixin.Player.Faction] or 'ParagonReputation_Glow', WoWTools_DataMixin.onlyChinese and '声望' or REPUTATION)

			--添加控制面板
			WoWTools_PanelMixin:OnlyCheck({
				name= WoWTools_FactionMixin.addName,
				GetValue= function() return not Save().disabled end,
				SetValue= function()
					Save().disabled= not Save().disabled and true or nil
					print(
						WoWTools_DataMixin.Icon.icon2..WoWTools_FactionMixin.addName,
						WoWTools_TextMixin:GetEnabeleDisable(not Save().disabled),
						WoWTools_DataMixin.onlyChinese and '需要重新加载' or REQUIRES_RELOAD
					)
				end
			})

			if not Save().disabled then
				self:RegisterEvent('PLAYER_ENTERING_WORLD')

				if C_AddOns.IsAddOnLoaded('Blizzard_MajorFactions') then
					WoWTools_FactionMixin:Init_MajorFactionRenownFrame()--名望
				end
				if C_AddOns.IsAddOnLoaded('Blizzard_CovenantRenown') then
					WoWTools_FactionMixin:Init_CovenantRenown(CovenantRenownFrame)--盟约 9.0
				end
			end

		elseif arg1=='Blizzard_MajorFactions' and WoWToolsSave then
			WoWTools_FactionMixin:Init_MajorFactionRenownFrame()--名望
			if C_AddOns.IsAddOnLoaded('Blizzard_CovenantRenown') then
				self:UnregisterEvent(event)
			end

		elseif arg1=='Blizzard_CovenantRenown' and WoWToolsSave then
			WoWTools_FactionMixin:Init_CovenantRenown(CovenantRenownFrame)--盟约 9.0
			if C_AddOns.IsAddOnLoaded('Blizzard_MajorFactions') then
				self:UnregisterEvent(event)
			end
		end

    elseif event == 'PLAYER_ENTERING_WORLD' then
		WoWTools_FactionMixin:Init_Button()
		WoWTools_FactionMixin:Init_ScrollBox_Plus()
		WoWTools_FactionMixin:Init_Chat_MSG()
		WoWTools_FactionMixin:Init_TrackButton()
		WoWTools_FactionMixin:Init_Other_Button()
		self:UnregisterEvent(event)
    end
end)