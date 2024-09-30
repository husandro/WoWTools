local id, e = ...
WoWTools_ReputationMixin={
Save={
	btn=e.Player.husandro,--启用，TrackButton
	factions={},--指定,显示,声望
	btnstr=true,--文本
	scaleTrackButton=1,--缩放
	--notAutoHideTrack=true,--自动隐藏
	toRightTrackText=true,--向右平移
	--toTopTrack=true,--向上

	factionUpdateTips=true,--更新, 提示
	--indicato=true,--指定
	onlyIcon=e.Player.husandro,--隐藏名称， 仅显示有图标
	--notPlus=true,
},
addName=nil,
TrackButton=nil,
onlyIcon=nil
}

local function Save()
	return WoWTools_ReputationMixin.Save
end






--######
--初始化
--######
local function Init()
	WoWTools_ReputationMixin:Init_Button()
	WoWTools_ReputationMixin:Init_ScrollBox_Plus()
	WoWTools_ReputationMixin:Init_Chat_MSG()
	WoWTools_ReputationMixin:Init_TrackButton()
end







--###########
--加载保存数据
--###########
local panel= CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent("PLAYER_LOGOUT")
panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
		if arg1==id then
			if WoWToolsSave[REPUTATION] then
				WoWTools_ReputationMixin.Save= WoWToolsSave[REPUTATION]
				WoWToolsSave[REPUTATION]= nil
			else
				WoWTools_ReputationMixin.Save= WoWToolsSave['Plus_Reputation'] or WoWTools_ReputationMixin.Save
			end

			WoWTools_ReputationMixin.addName= format('|A:%s:0:0|a%s', e.Icon[e.Player.faction] or 'ParagonReputation_Glow', e.onlyChinese and '声望' or REPUTATION)

			Save().factions= Save().factions or {}

			

			--添加控制面板
            Initializer= e.AddPanel_Check({
                name= WoWTools_ReputationMixin.addName,
                tooltip= WoWTools_ReputationMixin.addName,
                GetValue= function() return not Save().disabled end,
                SetValue= function()
                    Save().disabled= not Save().disabled and true or nil
                    print(e.addName, WoWTools_ReputationMixin.addName, e.GetEnabeleDisable(not Save().disabled), e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
                end
            })



            if not Save().disabled then

                Init()
            end
            self:UnregisterEvent('ADDON_LOADED')
		end

    elseif event == "PLAYER_LOGOUT" then
        if not e.ClearAllSave then
            WoWToolsSave['Plus_Reputation']= WoWTools_ReputationMixin.Save
        end
    end
end)
