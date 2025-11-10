local function Save()
    return WoWToolsSave['Plus_ItemInfo']
end

local Category, Layout


local function Init_Panel()
    if Save().disabled then
        return
    end

    WoWTools_PanelMixin:Header(Layout, WoWTools_DataMixin.onlyChinese and '选项' or OPTIONS)

    local tooltip= '|cffff00ff'..(WoWTools_DataMixin.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)

--字体
    WoWTools_PanelMixin:OnlySlider({
        name= WoWTools_DataMixin.onlyChinese and '字体大小' or FONT_SIZE,
        GetValue= function() return Save().size or 10 end,
        minValue= 6,
        maxValue= 18,
        setp= 1,
        tooltip=tooltip,
        category= Category,
        SetValue= function(_, _, value2)
            Save().size= value2 or 10
        end
    })

    local function Add_Options(name)
        WoWTools_PanelMixin:OnlyCheck({
            name= name,
            tooltip= tooltip,
            category= Category,
            Value= not Save().no[name],
            GetValue= function() return not Save().no[name] end,
            SetValue= function()
                Save().no[name]= not Save().no[name] and true or nil
            end
        })
    end

    WoWTools_PanelMixin:Header(Layout, 'Event')
    for name in pairs(WoWTools_ItemMixin.Events) do
        Add_Options(name)
    end

    WoWTools_PanelMixin:Header(Layout, 'Frame')
    for name in pairs(WoWTools_ItemMixin.Frames) do
        Add_Options(name)
    end


    Init_Panel=function()end
end







local panel= CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")

panel:SetScript("OnEvent", function(self, event, arg1)
    if event=='ADDON_LOADED' then
        if arg1== 'WoWTools' then

            WoWToolsSave['Plus_ItemInfo']= WoWToolsSave['Plus_ItemInfo'] or {no={}}
            Save().no= Save().no or {}

            WoWTools_ItemMixin.addName= '|A:Barbershop-32x32:0:0|a'..(WoWTools_DataMixin.onlyChinese and '物品信息' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, ITEMS, INFO))

            Category, Layout= WoWTools_PanelMixin:AddSubCategory({
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
                    print(WoWTools_ItemMixin.addName..WoWTools_DataMixin.Icon.icon2, WoWTools_DataMixin.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
                end
            })

            if Save().disabled then
                WoWTools_ItemMixin.Events= {}
                WoWTools_ItemMixin.Frames= {}
                self:UnregisterEvent(event)

            else
                if C_AddOns.IsAddOnLoaded('Blizzard_Settings') then
                    Init_Panel()
                end

                self:RegisterEvent('PLAYER_ENTERING_WORLD')
            end

        elseif WoWToolsSave then

            if arg1=='Blizzard_Settings' then
                Init_Panel()
            end

            if WoWTools_ItemMixin.Events[arg1] then
                do
                    if not not Save().no[arg1] then
                        WoWTools_ItemMixin.Events[arg1](WoWTools_ItemMixin)
                    end
                end
                WoWTools_ItemMixin.Events[arg1]= {}
            end
        end

    elseif event=='PLAYER_ENTERING_WORLD' then

        for name in pairs(WoWTools_ItemMixin.Events) do
            if C_AddOns.IsAddOnLoaded(name) then
                do
                    if not Save().no[name] then
                        WoWTools_ItemMixin.Events[name](WoWTools_ItemMixin)
                    end
                end
                WoWTools_ItemMixin.Events[name]= {}
            end
        end

        for name in pairs(WoWTools_ItemMixin.Frames) do
            if _G[name] then
                do
                    if not Save().no[name] then
                        WoWTools_ItemMixin.Frames[name](WoWTools_ItemMixin)
                    end
                end
                WoWTools_ItemMixin.Frames[name]= {}
            end
        end

        self:UnregisterEvent(event)
    end
end)