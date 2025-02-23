local id, e = ...
local Save={
    onlyChinese= LOCALE_zhCN or e.Player.husandro,
    --useClassColor= e.Player.husandro,--使用,职业, 颜色
    --useCustomColor= nil,--使用, 自定义, 颜色
    useColor=1,
    useCustomColorTab= {r=1, g=0.82, b=0, a=1, hex='|cffffd100'},--自定义, 颜色, 表
}








--自定义，颜色
local function Set_Color()
    if Save.useColor==1 then
        e.Player.useColor= {r=e.Player.r, g=e.Player.g, b=e.Player.b, a=1, hex= e.Player.col}
    elseif Save.useColor==2 then
        e.Player.useColor= Save.useCustomColorTab
    else
        e.Player.useColor=nil
    end
end










--####
--开始
--####
local function Init_Options()
    e.AddPanel_Header(nil, e.onlyChinese and '设置' or SETTINGS)

    e.AddPanel_Button({
        title= '|A:talents-button-undo:0:0|a'..(e.onlyChinese and '全部重置' or RESET_ALL_BUTTON_TEXT),
        buttonText= '|A:QuestArtifact:0:0|a'..(e.onlyChinese and '清除全部' or REMOVE_WORLD_MARKERS ),
        addSearchTags= e.onlyChinese and '全部重置' or RESET_ALL_BUTTON_TEXT,
        SetValue= function()
            StaticPopup_Show('WoWTools_RestData',
                (e.onlyChinese and '全部重置' or RESET_ALL_BUTTON_TEXT)..'|n|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '重新加载UI' or RELOADUI)..'|r',
                nil,
                function()
                    e.ClearAllSave=true
                    WoWTools_Mixin:Reload()
                end
            )
        end
    })

    e.AddPanel_Button({
        title= e.Icon.wow2..(e.onlyChinese and '清除WoW数据' or 'Clear WoW data'),
        buttonText= '|A:QuestArtifact:0:0|a'..(e.onlyChinese and '清除' or SLASH_STOPWATCH_PARAM_STOP2),
        addSearchTags= e.onlyChinese and '清除WoW数据' or 'Clear WoW data',
        SetValue= function()
            StaticPopup_Show('WoWTools_RestData',
                (e.Icon.wow2..(e.onlyChinese and '清除WoW数据' or 'Clear WoW data'))..'|n|n|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '重新加载UI' or RELOADUI)..'|r',
                nil,
                function()
                    e.WoWDate={}
                    WoWTools_Mixin:Reload()
                end
            )
        end
    })








    e.AddPanel_DropDown({
        SetValue= function(value)
            if value==2 then
                local valueR, valueG, valueB, valueA= Save.useCustomColorTab.r, Save.useCustomColorTab.g, Save.useCustomColorTab.b, Save.useCustomColorTab.a
                local setA, setR, setG, setB
                local function func()
                    local hex=WoWTools_ColorMixin:RGBtoHEX(setR, setG, setB, setA)--RGB转HEX
                    Save.useCustomColorTab={r=setR, g=setG, b=setB, a=setA, hex= '|c'..hex }
                    Set_Color()--自定义，颜色
                    print(e.Player.useColor and e.Player.useColor.hex or '', id, WoWTools_Mixin.addName,   e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
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
                print(WoWTools_Mixin.addName, e.Player.useColor and e.Player.useColor.hex or '', (e.onlyChinese and '颜色' or COLOR)..'|r',   e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
            end
            Save.useColor= value

        end,
        GetOptions= function()
            local container = Settings.CreateControlTextContainer()
			container:Add(1, e.onlyChinese and '职业' or CLASS)
			container:Add(2, e.onlyChinese and '自定义' or CUSTOM)
			container:Add(3, e.onlyChinese and '无' or NONE)
			return container:GetData();
        end,
        GetValue= function() return Save.useColor end,
        name= (e.Player.useColor and e.Player.useColor.hex or '')..(e.onlyChinese and '颜色' or COLOR),
        tooltip= WoWTools_Mixin.addName,
    })


    if not LOCALE_zhCN then
        e.AddPanel_Check({
            name= 'Chinese ',
            tooltip= e.onlyChinese and '语言: 简体中文'
                    or (LANGUAGE..': '..LFG_LIST_LANGUAGE_ZHCN),
            Value= Save.onlyChinese,
            GetValue= function() return Save.onlyChinese end,
            SetValue= function()
                e.onlyChinese= not e.onlyChinese and true or nil
                WoWTools_Mixin.isChinese= e.onlyChinese
                Save.onlyChinese = e.onlyChinese
                print(WoWTools_Mixin.addName,  e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
            end
        })
    end

    if e.Player.region==1 or e.Player.region==3 then--US EU realm提示
        local function get_tooltip(tooltip)
            local tabs= e.Player.region==3 and
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

        e.AddPanel_Check({
            name= e.onlyChinese and '服务器' or 'Realm',
            tooltip=get_tooltip(),
            Value= not Save.disabledRealm,
            GetValue= function() return not Save.disabledRealm end,
            SetValue= function()
                Save.disabledRealm= not Save.disabledRealm and true or nil
                print(WoWTools_Mixin.addName,  e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
            end
        })

        if Save.disabledRealm then
            e.Get_Region(nil, nil, nil, true)
            e.Get_Region=function() end
        end
    end

    e.AddPanel_Header(nil, 'Plus')
end
















local panel= CreateFrame("Frame")
panel:RegisterEvent("ADDON_LOADED")
panel:RegisterEvent("PLAYER_LOGOUT")
panel:SetScript("OnEvent", function(self, event, arg1)
    if event=='ADDON_LOADED' then
        if arg1 == id then
            WoWToolsSave= WoWToolsSave or {}

            if WoWToolsSave['Panel Settings'] then
                Save= WoWToolsSave['Panel Settings']
                WoWToolsSave['Panel_Settings']=nil
            else
                Save= WoWToolsSave['WoWTools_Settings'] or Save
            end
            e.onlyChinese= LOCALE_zhCN or Save.onlyChinese
            WoWTools_Mixin.onlyChinese= e.onlyChinese

            Save.useColor= Save.useColor or 1
            Save.useCustomColorTab= Save.useCustomColorTab or {r=1, g=0.82, b=0, a=1, hex='|cffffd100'}
            Set_Color()--自定义，颜色

            Init_Options()

            e.Is_Timerunning= PlayerGetTimerunningSeasonID()


            if e.onlyChinese then
                e.Player.L= {
                    layer='位面',
                    key='关键词',
                }
            end

            e.StausText={
                [ITEM_MOD_HASTE_RATING_SHORT]= e.onlyChinese and '急' or WoWTools_TextMixin:sub(STAT_HASTE, 1, 2, true),
                [ITEM_MOD_CRIT_RATING_SHORT]= e.onlyChinese and '爆' or WoWTools_TextMixin:sub(STAT_CRITICAL_STRIKE, 1, 2, true),
                [ITEM_MOD_MASTERY_RATING_SHORT]= e.onlyChinese and '精' or WoWTools_TextMixin:sub(STAT_MASTERY, 1, 2, true),
                [ITEM_MOD_VERSATILITY]= e.onlyChinese and '全' or WoWTools_TextMixin:sub(STAT_VERSATILITY, 1, 2, true),
                [ITEM_MOD_CR_AVOIDANCE_SHORT]= e.onlyChinese and '闪' or WoWTools_TextMixin:sub(STAT_AVOIDANCE, 1, 2, true),
                [ITEM_MOD_CR_LIFESTEAL_SHORT]= e.onlyChinese and '吸' or WoWTools_TextMixin:sub(STAT_LIFESTEAL, 1, 2, true),
                [ITEM_MOD_CR_SPEED_SHORT]=e.onlyChinese and '速' or WoWTools_TextMixin:sub(SPEED, 1,2,true),
                --[ITEM_MOD_EXTRA_ARMOR_SHORT]= e.onlyChinese and '护' or WoWTools_TextMixin:sub(ARMOR, 1,2,true)
            }


            if not StaticPopupDialogs['GAME_SETTINGS_APPLY_DEFAULTS'].OnShow then
                --你想要将所有用户界面和插件设置重置为默认状态，还是只重置这个界面或插件的设置？
                --所有设置
                StaticPopupDialogs['GAME_SETTINGS_APPLY_DEFAULTS'].OnShow= function(frame)
                    frame.button1:SetEnabled(false)
                    C_Timer.After(3, function()
                        frame.button1:SetEnabled(true)
                    end)
                end
            end

            C_Timer.After(2, function()
                e.Is_Timerunning= PlayerGetTimerunningSeasonID()
            end)
            self:UnregisterEvent('ADDON_LOADED')
        end
    else
        if not e.ClearAllSave then
            WoWToolsSave['Panel_Settings']= Save
        end
    end
end)



