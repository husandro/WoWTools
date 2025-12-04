local function Save()
    return WoWToolsSave['Plus_ItemInfo']
end
local Category, Layout





local function Init_Panel()
    local tooltip= '|cnWARNING_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)



    WoWTools_PanelMixin:Header(Layout, WoWTools_DataMixin.onlyChinese and '选项' or OPTIONS)



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
            name= name:gsub('Blizzard_', ''),
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







local function Init()
    for name, func in pairs(WoWTools_ItemMixin.Events) do
        if C_AddOns.IsAddOnLoaded(name) then
            if not Save().no[name] then
                func(WoWTools_ItemMixin)
            end
            WoWTools_ItemMixin.Events[name]= nil
        end
    end

    do
        for name, func in pairs(WoWTools_ItemMixin.Frames) do
            if _G[name] then
                if not Save().no[name] then
                    func(WoWTools_ItemMixin)
                end
            elseif WoWTools_DataMixin.Player.husandro then
                print('物品信息，没有发现Frames', name)
            end
        end
    end
    WoWTools_ItemMixin.Frames={}

    Init=function()end
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

            WoWTools_PanelMixin:Check_Button({
                checkName= WoWTools_DataMixin.onlyChinese and '启用' or ENABLE,
                GetValue= function() return not Save().disabled end,
                SetValue= function()
                    Save().disabled= not Save().disabled and true or nil
                    Init_Panel()
                end,
                buttonText= '|A:bags-button-autosort-up:0:0|a'..(WoWTools_DataMixin.onlyChinese and '重置' or RESET),
                buttonFunc= function()
                    StaticPopup_Show('WoWTools_RestData',
                        WoWTools_ItemMixin.addName
                        ..'|n|cnGREEN_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '重新加载UI' or RELOADUI)..'|r',
                        nil,
                    function()
                        WoWToolsSave['Plus_ItemInfo']= nil
                        WoWTools_DataMixin:Reload()
                    end)
                end,
                tooltip= '|cnWARNING_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '需要重新加载' or REQUIRES_RELOAD),
                layout= Layout,
                category= Category,
            })

            WoWTools_ItemMixin.QalityText= {
                [0]= '|c'..select(4, C_Item.GetItemQualityColor(0))..(WoWTools_DataMixin.onlyChinese and '粗糙' or ITEM_QUALITY0_DESC)..'|r',
                [1]= '|c'..select(4, C_Item.GetItemQualityColor(1))..(WoWTools_DataMixin.onlyChinese and '普通' or ITEM_QUALITY1_DESC)..'|r',
                [2]= '|c'..select(4, C_Item.GetItemQualityColor(2))..( WoWTools_DataMixin.onlyChinese and '优秀' or ITEM_QUALITY2_DESC)..'|r',
                [3]= '|c'..select(4, C_Item.GetItemQualityColor(3))..(WoWTools_DataMixin.onlyChinese and '精良' or ITEM_QUALITY3_DESC)..'|r',
                [4]= '|c'..select(4, C_Item.GetItemQualityColor(4))..(WoWTools_DataMixin.onlyChinese and '史诗' or ITEM_QUALITY4_DESC)..'|r',
                [5]= '|c'..select(4, C_Item.GetItemQualityColor(5))..(WoWTools_DataMixin.onlyChinese and '传说' or ITEM_QUALITY5_DESC)..'|r',
                [6]= '|c'..select(4, C_Item.GetItemQualityColor(6))..(WoWTools_DataMixin.onlyChinese and '神器' or ITEM_QUALITY6_DESC)..'|r',
                [7]= '|c'..select(4, C_Item.GetItemQualityColor(7))..(WoWTools_DataMixin.onlyChinese and '传家宝' or ITEM_QUALITY7_DESC)..'|r',
                [8]= '|c'..select(4, WoWTools_ItemMixin:GetColor(8))..(WoWTools_DataMixin.onlyChinese and '时光徽章' or ITEM_QUALITY8_DESC)..'|r',
             }

            if Save().disabled then
                WoWTools_ItemMixin.Events= {}
                WoWTools_ItemMixin.Frames= {}
                self:SetScript('OnEvent', nil)
                self:UnregisterEvent(event)
            else
                do
                    Init_Panel()
                end
                Init()
                --self:RegisterEvent('PLAYER_ENTERING_WORLD')
            end

        elseif WoWToolsSave and WoWTools_ItemMixin.Events[arg1] then
            if not Save().no[arg1] then
                WoWTools_ItemMixin.Events[arg1](WoWTools_ItemMixin)
            end
            WoWTools_ItemMixin.Events[arg1]= nil
        end

    --[[elseif event=='PLAYER_ENTERING_WORLD' then
        Init()
        self:UnregisterEvent(event)]]
    end
end)