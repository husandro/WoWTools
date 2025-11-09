local P_Save={
    no={},
}



local function Save()
    return WoWToolsSave['Plus_ItemInfo']
end

local function Init_Panel()
    local Category, Layout= WoWTools_PanelMixin:AddSubCategory({
        name=WoWTools_ItemMixin.addName,
        disabled=Save().disabled
    })

    WoWTools_PanelMixin:OnlyCheck({
        name= WoWTools_DataMixin.onlyChinese and '启用' or ENABLE,
        tooltip= WoWTools_DataMixin.onlyChinese and '需要重新加载' or REQUIRES_RELOAD,
        GetValue= function() return not Save().disabled end,
        category= Category,
        func= function()
            Save().disabled= not Save().disabled and true or nil
        end
    })

    WoWTools_PanelMixin:Header(Layout, WoWTools_DataMixin.onlyChinese and '选项' or OPTIONS)

    WoWTools_DataMixin:OnlySlider({
        name= WoWTools_DataMixin.onlyChinese and '字体' or FONT_SIZE,
        GetValue= function() return Save().size or 10 end,
        minValue= 6,
        maxValue= 18,
        setp= 1,
        tooltip= WoWTools_DataMixin.onlyChinese and '需要重新加载' or REQUIRES_RELOAD,
        category= Category,
        SetValue= function(_, _, value2)
            Save().size= value2 or 10
        end
    })

    for _, tab in pairs({
        {name= 'bag', tip= WoWTools_DataMixin.onlyChinese and '背包' or HUD_EDIT_MODE_BAGS_LABEL},
    }) do
        
    end

    Init_Panel=function()end
end








local panel= CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")

panel:SetScript("OnEvent", function(self, event, arg1)
    if event=='ADDON_LOADED' then
        if arg1== 'WoWTools' then

            WoWToolsSave['Plus_ItemInfo']= WoWToolsSave['Plus_ItemInfo'] or CopyTable(P_Save)
            Save().no= Save().no or {}
            P_Save= nil

            WoWTools_ItemMixin.addName= '|A:Barbershop-32x32:0:0|a'..(WoWTools_DataMixin.onlyChinese and '物品信息' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, ITEMS, INFO))

--添加控制面板
            Init_Panel()

            if Save().disabled then
                WoWTools_ItemMixin.Events={}
                WoWTools_ItemMixin.Frames={}
            else
                self:RegisterEvent('PLAYER_ENTERING_WORLD')
            end
            self:UnregisterEvent(event)

        elseif WoWToolsSave then
            if WoWTools_ItemMixin.Events[arg1] then
                do
                    WoWTools_ItemMixin.Events[arg1](WoWTools_ItemMixin)
                end
                WoWTools_ItemMixin.Events[arg1]= nil
            end
        end

    elseif event=='PLAYER_ENTERING_WORLD' then

        for name in pairs(WoWTools_ItemMixin.Events) do
            if C_AddOns.IsAddOnLoaded(name) then
                do
                    WoWTools_ItemMixin.Events[name](WoWTools_ItemMixin)
                end
                WoWTools_ItemMixin.Events[name]= nil
            end
        end

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