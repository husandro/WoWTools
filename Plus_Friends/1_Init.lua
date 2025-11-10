WoWTools_FriendsMixin={}


local P_Save={
    Friends={},
    disabledBNFriendInfo=not WoWTools_DataMixin.Player.husandro and true or nil,--禁用战网，好友信息，提示
    --allFriendInfo= true,--仅限，WoW，好友
    --showInCombatFriendInfo=true,--仅限，不在战斗中，好友，提示
    --showFriendInfoOnlyFavorite=true,--仅限收藏好友
}


local function Save()
    return WoWToolsSave['Plus_FriendsList']
end


local panel= CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent('LOADING_SCREEN_DISABLED')

panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1== 'WoWTools' then

            WoWToolsSave['Plus_FriendsList']= WoWToolsSave['Plus_FriendsList'] or P_Save
            P_Save=nil

            WoWTools_FriendsMixin.addName= '|A:socialqueuing-icon-group:0:0|a'..(WoWTools_DataMixin.onlyChinese and '好友列表' or FRIENDS_LIST)

            --添加控制面板
            WoWTools_PanelMixin:OnlyCheck({
                name= WoWTools_FriendsMixin.addName,
                GetValue= function() return not Save().disabled end,
                SetValue= function()
                    Save().disabled= not Save().disabled and true or nil
                    print(
                        WoWTools_FriendsMixin.addName..WoWTools_DataMixin.Icon.icon2,
                        WoWTools_TextMixin:GetEnabeleDisable(not Save().disabled),
                        WoWTools_DataMixin.onlyChinese and '需要重新加载' or REQUIRES_RELOAD
                    )
                end
            })

            if Save().disabled then
                self:UnregisterAllEvents()

            else
                WoWTools_FriendsMixin:Blizzard_QuickJoin()
                WoWTools_FriendsMixin:Blizzard_RaidFrame()

                if C_AddOns.IsAddOnLoaded('Blizzard_RaidUI') then
                    WoWTools_FriendsMixin:Blizzard_RaidUI()
                    self:UnregisterEvent(event)
                end
            end

        elseif arg1=='Blizzard_RaidUI' and WoWToolsSave then
            WoWTools_FriendsMixin:Blizzard_RaidUI()
            self:UnregisterEvent(event)
        end

    elseif event=='LOADING_SCREEN_DISABLED' then
        WoWTools_FriendsMixin:Blizzard_FriendsFrame()
        self:UnregisterEvent(event)
    end
end)
