local function Save()
    return WoWToolsSave['Plus_ItemInfo'] or {}
end


local function Set_Event(name)
    if WoWTools_ItemMixin.Events[name] then
        do
            WoWTools_ItemMixin.Events[name](WoWTools_ItemMixin)
        end
        WoWTools_ItemMixin.Events[name]= nil
    end
end




local panel= CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent('PLAYER_ENTERING_WORLD')
panel:SetScript("OnEvent", function(self, event, arg1)
    if event=='ADDON_LOADED' then

        if arg1== 'WoWTools' then
            WoWToolsSave['Plus_ItemInfo']= WoWToolsSave['Plus_ItemInfo'] or {}
            WoWTools_ItemMixin.addName= '|A:Barbershop-32x32:0:0|a'..(WoWTools_DataMixin.onlyChinese and '物品信息' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, ITEMS, INFO))

            --添加控制面板
            WoWTools_PanelMixin:OnlyCheck({
                name= WoWTools_ItemMixin.addName,
                tooltip= WoWTools_DataMixin.onlyChinese and '系统背包|n商人' or (BAGSLOT..'|n'..MERCHANT),--'Inventorian, Baggins', 'Bagnon'
                GetValue= function() return not Save().disabled end,
                SetValue= function()
                    Save().disabled= not Save().disabled and true or nil
                    print(WoWTools_DataMixin.Icon.icon2..WoWTools_ItemMixin.addName, WoWTools_TextMixin:GetEnabeleDisable(not Save().disabled), WoWTools_DataMixin.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
                end
            })

            if Save().disabled then
                self:UnregisterAllEvents()
            else

                for name in pairs(WoWTools_ItemMixin.Events) do
                    if C_AddOns.IsAddOnLoaded(name) then
                        Set_Event(name)
                    end
                end

                WoWTools_ItemMixin:Init_WoW_ItemList()--战团，物品列表
            end

        elseif WoWToolsSave then
            Set_Event(arg1)

        end
    elseif event=='PLAYER_ENTERING_WORLD' then
        for name in pairs(WoWTools_ItemMixin.Frames) do
            if _G[name] then
                do
                    WoWTools_ItemMixin.Frames[name](WoWTools_ItemMixin)
                end
                WoWTools_ItemMixin.Frames[name]= nil
            end
        end
        self:UnregisterEvent(event)
    end
end)