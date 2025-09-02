local P_Save={
    onlyChinese= LOCALE_zhCN or WoWTools_DataMixin.Player.husandro,
    --useClassColor= WoWTools_DataMixin.Player.husandro,--使用,职业, 颜色
    --useCustomColor= nil,--使用, 自定义, 颜色
    useColor=1,
    useCustomColorTab= {r=1, g=0.82, b=0, a=1, hex='|cffffd100'},--自定义, 颜色, 表
}

local function Save()
    return WoWToolsSave['WoWTools_Settings'] or {}
end

--自定义，颜色
local function Set_Color()
    WoWTools_DataMixin.Player.UseColor= Save().useColor==2 and Save().useCustomColorTab
        or {
            r=WoWTools_DataMixin.Player.r,
            g=WoWTools_DataMixin.Player.g,
            b=WoWTools_DataMixin.Player.b,
            a=1,
            hex= WoWTools_DataMixin.Player.col
        }
end











--####
--开始
--####
local function Init_Options()
    WoWTools_PanelMixin:Header(nil, WoWTools_DataMixin.onlyChinese and '数据' or 'Data')

    local header= WoWTools_DataMixin.onlyChinese and '插件选项' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, ADDONS, OPTIONS)
    WoWTools_PanelMixin:OnlyButton({
        title= '|A:talents-button-undo:0:0|a'..header,
        buttonText= '|A:QuestArtifact:0:0|a'..(WoWTools_DataMixin.onlyChinese and '重置' or RESET ),
        addSearchTags= header,
        SetValue= function()
            StaticPopup_Show('WoWTools_RestData',
                (WoWTools_DataMixin.onlyChinese and '全部重置，插件设置' or (RESET_ALL_BUTTON_TEXT..', '..format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, ADDONS, SETTINGS)))
                ..'|n|cnGREEN_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '重新加载UI' or RELOADUI)..'|r',
                nil,
            function()
                WoWTools_DataMixin.ClearAllSave= true
                --EventRegistry:RegisterFrameEventAndCallback("PLAYER_LOGOUT", function()
                WoWToolsSave= {}
                WoWTools_Mixin:Reload()
            end)
        end,
        tooltip=function()
            local text
            for name in pairs(WoWToolsSave) do
                text= (text and text..'\n' or '')..name
            end
            return text
        end
    })


--清除战网数据
    local wowHeader= WoWTools_DataMixin.onlyChinese and '清除战网数据' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, WoWTools_DataMixin.onlyChinese and '清除' or SLASH_STOPWATCH_PARAM_STOP2, format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, ACCOUNT_QUEST_LABEL, 'Data'))
    WoWTools_PanelMixin:OnlyButton({
        title= WoWTools_DataMixin.Icon.wow2..wowHeader,
        buttonText= WoWTools_DataMixin.Icon.wow2..(WoWTools_DataMixin.onlyChinese and '清除' or SLASH_STOPWATCH_PARAM_STOP2),
        addSearchTags= header,
        SetValue= function()
            StaticPopup_Show('WoWTools_RestData',
                WoWTools_DataMixin.Icon.wow2
                ..wowHeader
                ..'|n|n|cnGREEN_FONT_COLOR:'
                ..(WoWTools_DataMixin.onlyChinese and '重新加载UI' or RELOADUI),
                nil,
                function()
                    WoWTools_WoWDate= {}
                    WoWTools_Mixin:Reload()
                end
            )
        end,
        tooltip=function()
            local text
            for guid, tab in pairs(WoWTools_WoWDate) do
                text= (text and text..'\n' or '')
                   ..WoWTools_UnitMixin:GetPlayerInfo(nil, guid, nil,{
                        faction=tab.faction,
                        reName=true,
                        reRealm=true,
                        level=tab.level
                    })
            end
            return text
        end
    })








--清除玩家输入数据
    header= WoWTools_DataMixin.onlyChinese and '清除玩家输入数据' or 'Clear player input data'
    WoWTools_PanelMixin:OnlyButton({
        title= '|A:UI-HUD-UnitFrame-Player-Group-FriendOnlineIcon:0:0|a'..header,
        buttonText= '|A:UI-HUD-UnitFrame-Player-Group-FriendOnlineIcon:0:0|a'..(WoWTools_DataMixin.onlyChinese and '清除' or SLASH_STOPWATCH_PARAM_STOP2),
        addSearchTags= header,
        SetValue= function()
           
        end,
    })










--全部清除
    header= '|A:bags-button-autosort-up:0:0|a'..(WoWTools_DataMixin.onlyChinese and '全部清除' or CLEAR_ALL)
    WoWTools_PanelMixin:OnlyButton({
        title= header,
        buttonText= header,
        addSearchTags= header,
        SetValue= function()
            StaticPopup_Show('WoWTools_RestData',
                '|A:bags-button-autosort-up:0:0|a'..(WoWTools_DataMixin.onlyChinese and '全部清除' or CLEAR_ALL)
                ..'|n|cnGREEN_FONT_COLOR:'..(WoWTools_DataMixin.onlyChinese and '重新加载UI' or RELOADUI)..'|r',
                nil,
            function()
                WoWToolsSave={}
                WoWToolsPlayerDate= {}
                WoWTools_WoWDate= {}
                WoWTools_Mixin:Reload()
            end)
        end,
    })


--显示战网物品
    WoWTools_PanelMixin:OnlyButton({
        title= WoWTools_DataMixin.onlyChinese and '战网物品' or format(CLUB_FINDER_LOOKING_FOR_CLASS_SPEC, ACCOUNT_QUEST_LABEL, ITEMS),
        buttonText= WoWTools_DataMixin.onlyChinese and '显示' or SHOW,
        SetValue= function()
           WoWTools_ItemMixin:OpenWoWItemListFrame()--战团，物品列表
        end,
    })






    WoWTools_PanelMixin:Header(nil, WoWTools_DataMixin.onlyChinese and '设置' or SETTINGS)

    WoWTools_PanelMixin:OnlyMenu({
        SetValue= function(value)
            Save().useColor= value

            if value==2 then
                local valueR, valueG, valueB, valueA= Save().useCustomColorTab.r, Save().useCustomColorTab.g, Save().useCustomColorTab.b, Save().useCustomColorTab.a
                local setA, setR, setG, setB
                local function func()
                    local hex=WoWTools_ColorMixin:RGBtoHEX(setR, setG, setB, setA)--RGB转HEX
                    Save().useCustomColorTab={r=setR, g=setG, b=setB, a=setA, hex= '|c'..hex }
                    Set_Color()--自定义，颜色
                    print(
                        WoWTools_DataMixin.Player.UseColor.hex,
                        WoWTools_DataMixin.addName,
                        WoWTools_DataMixin.onlyChinese and '需要重新加载' or REQUIRES_RELOAD
                    )
                end
                WoWTools_ColorMixin:ShowColorFrame(valueR, valueG, valueB, valueA, function()
                        setR, setG, setB, setA= WoWTools_ColorMixin:Get_ColorFrameRGBA()
                        func()
                    end, function()
                        setR, setG, setB, setA= valueR, valueG, valueB, valueA
                        func()
                    end
                )
            else
                if ColorPickerFrame:IsShown() then
                    ColorPickerFrame.Footer.OkayButton:Click()
                end
                Set_Color()--自定义，颜色
                print(
                    WoWTools_DataMixin.Player.UseColor.hex,
                    WoWTools_DataMixin.addName,
                    WoWTools_DataMixin.onlyChinese and '颜色' or COLOR,
                    '|r',
                    WoWTools_DataMixin.onlyChinese and '需要重新加载' or REQUIRES_RELOAD
                )
            end
        end,
        GetOptions= function()
            local container = Settings.CreateControlTextContainer()
			container:Add(1, WoWTools_DataMixin.onlyChinese and '职业' or CLASS)
			container:Add(2, WoWTools_DataMixin.onlyChinese and '自定义' or CUSTOM)
			--container:Add(3, WoWTools_DataMixin.onlyChinese and '无' or NONE)
			return container:GetData()
        end,
        GetValue= function() return Save().useColor end,
        name= '|A:Forge-ColorSwatch:0:0|a'..WoWTools_DataMixin.Player.UseColor.hex..(WoWTools_DataMixin.onlyChinese and '颜色' or COLOR),
        tooltip= WoWTools_DataMixin.addName,
    })


    if not LOCALE_zhCN then
        WoWTools_PanelMixin:OnlyCheck({
            name= 'Chinese ',
            tooltip= WoWTools_DataMixin.onlyChinese and '语言: 简体中文'
                    or (LANGUAGE..': '..LFG_LIST_LANGUAGE_ZHCN),
            Value= Save().onlyChinese,
            GetValue= function() return Save().onlyChinese end,
            SetValue= function()
                WoWTools_DataMixin.onlyChinese= not WoWTools_DataMixin.onlyChinese and true or nil
                Save().onlyChinese = WoWTools_DataMixin.onlyChinese
                print(WoWTools_DataMixin.addName,  WoWTools_DataMixin.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
            end
        })
    end

    if WoWTools_DataMixin.Player.Region==1 or WoWTools_DataMixin.Player.Region==3 then--US EU realm提示
        local function get_tooltip()
            local tabs= WoWTools_DataMixin.Player.Region==3 and
                {
                    ["deDE"] = {col="|cFF00FF00DE|r", text='DE', realm="Germany"},
                    ["frFR"] = {col="|cFF00FFFFFR|r", text='FR', realm="France"},
                    ["enGB"] = {col="|cFFFF00FFGB|r", text='GB', realm="Great Britain"},
                    ["itIT"] = {col="|cFFFFFF00IT|r", text='IT', realm="Italy"},
                    ["esES"] = {col="|cFFFFBF00ES|r", text='ES', realm="Spain"},
                    ["ruRU"] = {col="|cFFCCCCFFRU|r" ,text='RU', realm="Russia"},
                    ["ptBR"] = {col="|cFF8fce00PT|r", text='PT', realm="Portuguese"},
                }
            or
                {
                    ["oce"] = {col="|cFF00FF00OCE|r", text='CE', realm="Oceanic"},
                    ["usp"] = {col="|cFF00FFFFUSP|r", text='USP', realm="US Pacific"},
                    ["usm"] = {col="|cFFFF00FFUSM|r", text='USM', realm="US Mountain"},
                    ["usc"] = {col="|cFFFFFF00USC|r", text='USC', realm="US Central"},
                    ["use"] = {col="|cFFFFBF00USE|r", text='USE', realm="US East"},
                    ["mex"] = {col="|cFFCCCCFFMEX|r", text='MEX', realm="Mexico"},
                    ["bzl"] = {col="|cFF8fce00BZL|r", text='BZL', realm="Brazil"},
                }
            local text
            for text2, tab in pairs(tabs) do
                text= (text and text..'|n' or '')..tab.col..'  '..tab.realm.. '  ('..tab.text..')  '.. text2
            end
            return text
        end

        WoWTools_PanelMixin:OnlyCheck({
            name= WoWTools_DataMixin.onlyChinese and '服务器' or 'Realm',
            tooltip=get_tooltip(),
            Value= not Save().disabledRealm,
            GetValue= function() return not Save().disabledRealm end,
            SetValue= function()
                Save().disabledRealm= not Save().disabledRealm and true or nil
                print(WoWTools_DataMixin.addName,  WoWTools_DataMixin.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
            end
        })

        if Save().disabledRealm then
            do
                WoWTools_RealmMixin:Get_Region(nil, nil, nil, true)
            end
---@diagnostic disable-next-line: duplicate-set-field
            WoWTools_RealmMixin.Get_Region=function() end
        end
    end

    WoWTools_PanelMixin:Header(nil, 'Plus')
end
















local panel= CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent('PLAYER_LOGIN')

panel:SetScript("OnEvent", function(self, event, arg1)
    if event=='ADDON_LOADED' then
        if arg1== 'WoWTools' then

            WoWToolsSave['WoWTools_Settings']= WoWToolsSave['WoWTools_Settings'] or P_Save

            WoWTools_DataMixin.onlyChinese= LOCALE_zhCN or Save().onlyChinese

            Save().useColor= Save().useColor or 1
            Save().useCustomColorTab= Save().useCustomColorTab or {r=1, g=0.82, b=0, a=1, hex='|cffffd100'}
            Set_Color()--自定义，颜色

            Init_Options()

            WoWTools_DataMixin.Is_Timerunning= PlayerGetTimerunningSeasonID()--PlayerIsTimerunning()


            if WoWTools_DataMixin.onlyChinese then
                WoWTools_DataMixin.Player.Language= {
                    layer='位面',
                    key='关键词',
                }
            end

            WoWTools_DataMixin.StausText={
                [ITEM_MOD_HASTE_RATING_SHORT]= WoWTools_DataMixin.onlyChinese and '急' or WoWTools_TextMixin:sub(STAT_HASTE, 1, 2, true),
                [ITEM_MOD_CRIT_RATING_SHORT]= WoWTools_DataMixin.onlyChinese and '爆' or WoWTools_TextMixin:sub(STAT_CRITICAL_STRIKE, 1, 2, true),
                [ITEM_MOD_MASTERY_RATING_SHORT]= WoWTools_DataMixin.onlyChinese and '精' or WoWTools_TextMixin:sub(STAT_MASTERY, 1, 2, true),
                [ITEM_MOD_VERSATILITY]= WoWTools_DataMixin.onlyChinese and '全' or WoWTools_TextMixin:sub(STAT_VERSATILITY, 1, 2, true),
                [ITEM_MOD_CR_AVOIDANCE_SHORT]= WoWTools_DataMixin.onlyChinese and '闪' or WoWTools_TextMixin:sub(STAT_AVOIDANCE, 1, 2, true),
                [ITEM_MOD_CR_LIFESTEAL_SHORT]= WoWTools_DataMixin.onlyChinese and '吸' or WoWTools_TextMixin:sub(STAT_LIFESTEAL, 1, 2, true),
                [ITEM_MOD_CR_SPEED_SHORT]=WoWTools_DataMixin.onlyChinese and '速' or WoWTools_TextMixin:sub(SPEED, 1,2,true),
                --[ITEM_MOD_EXTRA_ARMOR_SHORT]= WoWTools_DataMixin.onlyChinese and '护' or WoWTools_TextMixin:sub(ARMOR, 1,2,true)
            }

            self:UnregisterEvent(event)
        end

    elseif event=='PLAYER_LOGIN' then
        WoWTools_DataMixin.Is_Timerunning= PlayerGetTimerunningSeasonID()
        self:UnregisterEvent(event)
    end
end)



