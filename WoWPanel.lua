local id, e = ...
local addName= 'panel Settings'
local Save={
    onlyChinese= e.Player.husandro or LOCALE_zhCN,
    useClassColor= e.Player.husandro,--使用,职业, 颜色
    useCustomColor= nil,--使用, 自定义, 颜色
    useCustomColorTab= {r=1, g=0.82, b=0, a=1, hex='|cffffd100'},--自定义, 颜色, 表
}

--#####################
--重新加载UI, 重置, 按钮
--#####################
function e.ReloadPanel(tab)
    local rest= e.Cbtn(tab.panel, {type=false, size={25,25}})
    rest:SetNormalAtlas('bags-button-autosort-up')
    rest:SetPushedAtlas('bags-button-autosort-down')
    rest:SetPoint('TOPRIGHT',0,8)
    rest.addName=tab.addName
    rest.func=tab.clearfunc
    rest.clearTips=tab.clearTips
    rest.clearWoWData= tab.clearWoWData
    rest:SetScript('OnClick', function(self)
        StaticPopupDialogs[id..'restAllSetup']={
            text =id..'  '..self.addName..'|n|n|cnRED_FONT_COLOR:'..(self.clearTips or (e.onlyChinese and '当前保存' or (ITEM_UPGRADE_CURRENT..SAVE)))..'|r '..(e.onlyChinese and '保存' or SAVE)..'|n|n'..(e.onlyChinese and '重新加载UI' or RELOADUI)..' /reload',
            button1= '|cnRED_FONT_COLOR:'..(e.onlyChinese and '重置' or RESET),
            button2= e.onlyChinese and '取消' or CANCEL,
            whileDead=true,timeout=30,hideOnEscape = 1,
            OnAccept=self.func,
        }

        if self.clearWoWData then
            StaticPopupDialogs[id..'restAllSetup'].button3= '|cffff00ff'..(e.onlyChinese and '清除WoW数据' or 'Clear WoW data')..'|r'
            StaticPopupDialogs[id..'restAllSetup'].OnAlt= function()
                WoWDate=nil
                e.Reload()
                print(id, addName, (e.onlyChinese and '缩放' or UI_SCALE)..': 1', '|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD))
            end
        end
        StaticPopup_Show(id..'restAllSetup')
    end)
    rest:SetScript('OnLeave', function() e.tips:Hide() end)
    rest:SetScript('OnEnter', function(self)
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddLine(self.clearTips or (e.onlyChinese and '当前保存' or (ITEM_UPGRADE_CURRENT..SAVE)))
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine(id, self.addName)
        e.tips:Show()
    end)
    local reload= e.Cbtn(tab.panel, {type=false, size={25,25}})
    reload:SetNormalTexture('Interface\\Vehicles\\UI-Vehicles-Button-Exit-Up')
    reload:SetPushedTexture('Interface\\Vehicles\\UI-Vehicles-Button-Exit-Down')
    reload:SetPoint('TOPLEFT',-12, 8)
    reload:SetScript('OnClick', e.Reload)
    reload.addName=tab.addName
    reload:SetScript('OnLeave', function() e.tips:Hide() end)
    reload:SetScript('OnEnter', function(self)
        e.tips:SetOwner(self, "ANCHOR_LEFT")
        e.tips:ClearLines()
        e.tips:AddLine(e.onlyChinese and '重新加载UI' or RELOADUI)
        e.tips:AddLine(' ')
        e.tips:AddDoubleLine(id, self.addName)
        e.tips:Show()
    end)
    if tab.restTips then
        local needReload= e.Cstr(tab.panel)
        needReload:SetText(e.Icon.toRight2..(e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)..e.Icon.toLeft2)
        needReload:SetPoint('BOTTOMRIGHT')
        needReload:SetTextColor(0,1,0)
    end
    if tab.disabledfunc then
        local check=CreateFrame("CheckButton", nil, tab.panel, "InterfaceOptionsCheckButtonTemplate")
        check.text:SetText(e.GetEnabeleDisable(true))
        check:SetChecked(tab.checked)
        check:SetPoint('LEFT', reload, 'RIGHT')
        check:SetScript('OnClick', tab.disabledfunc)
        check:SetScript('OnLeave', function() e.tips:Hide() end)
        check.addName= tab.addName
        check:SetScript('OnEnter', function(self)
            e.tips:SetOwner(self, "ANCHOR_LEFT")
            e.tips:ClearLines()
            e.tips:AddLine(e.onlyChinese and '启用/禁用' or ENABLE..'/'..DISABLE)
            e.tips:AddLine(' ')
            e.tips:AddDoubleLine(id, self.addName)
            e.tips:Show()
        end)
    end
end

local panel = CreateFrame("Frame")--Panel
panel.name = id--'|cffff00ffWoW|r|cff00ff00Tools|r'
InterfaceOptions_AddCategory(panel)

--##############
--Instance Panel
--##############
--[[
local instancePane= CreateFrame('Frame')
instancePane.name = '|A:poi-rift1:0:0|a'..INSTANCE
instancePane.parent =id;
InterfaceOptions_AddCategory(instancePane)
]]

--##############
--创建, 添加控制面板
--##############
local lastWoW, lastGame, lastInstance
e.CPanel= function(name, value, GamePlus)--, Instance)
    --local check=CreateFrame("CheckButton", nil, Instance and instancePane or panel, "InterfaceOptionsCheckButtonTemplate")
    local check=CreateFrame("CheckButton", nil, panel, "InterfaceOptionsCheckButtonTemplate")
    check.text:SetText(name)
    check:SetChecked(value)

--[[if Instance then--副本, 大类
        if not lastInstance then
            check:SetPoint('TOPLEFT')
            lastInstance= check
        else
            check:SetPoint('TOPLEFT', lastInstance, 'BOTTOMLEFT')
        end
]]
    if GamePlus then--GamePlus, 大类
        if lastGame then
            check:SetPoint('TOPLEFT', lastGame, 'BOTTOMLEFT')
        else
            check:SetPoint('TOPLEFT', panel, 'TOP', 0, -25)
        end
        lastGame=check

    else--WoWPlus, 大类
        if lastWoW then
            check:SetPoint('TOPLEFT', lastWoW, 'BOTTOMLEFT')
        else
            check:SetPoint('TOPLEFT', 0, -25)
        end
        lastWoW=check
    end
    return check
end

panel:RegisterEvent('ADDON_LOADED')
panel:RegisterEvent("PLAYER_LOGOUT")

panel:SetScript("OnEvent", function(self, event, arg1)
    if event=='ADDON_LOADED' then
        if arg1==id then
            WoWToolsSave= WoWToolsSave or {}
            WoWDate= WoWDate or {}
            --BunniesDB= BunniesDB or {}

            Save= WoWToolsSave[addName] or Save
            Save.useCustomColorTab= Save.useCustomColorTab or {r=1, g=0.82, b=0, a=1, hex='|cffffd100'}

            e.onlyChinese= Save.onlyChinese

            e.ReloadPanel({--重新加载UI, 重置, 按钮
                panel=panel, addName= addName, restTips=true, checked=not Save.disabled,
                clearTips= not e.onlyChinese and '1) '..CLEAR_ALL..'\n2) Clear WoW data' or '1) 清除全部\n2) 清除WoW数据',
                clearWoWData=true,
                disabledfunc=nil,
                clearfunc= function()
                    e.ClearAllSave=true
                    e.Reload()
                end
            })

            if e.onlyChinese or LOCALE_zhCN or LOCALE_zhTW then
                e.Player.LayerText= '位面'
            elseif LOCALE_koKR then
                e.Player.LayerText= '층'
            elseif LOCALE_frFR then
                e.Player.LayerText= 'Couche'
            elseif LOCALE_deDE then
                e.Player.LayerText= 'Schicht'
            elseif LOCALE_esES or LOCALE_esMX then
                e.Player.LayerText= 'Capa'
            elseif LOCALE_ruRU then
                e.Player.LayerText= 'слой'
            elseif LOCALE_ptBR then
                e.Player.LayerText= 'Camada'
            elseif LOCALE_itIT then
                e.Player.LayerText= 'Strato'
            end

            local useClassColor=CreateFrame("CheckButton", nil, panel, "InterfaceOptionsCheckButtonTemplate")--使用,职业,颜色
            local useCustomColor=CreateFrame("CheckButton", nil, panel, "InterfaceOptionsCheckButtonTemplate")--使用,自定义,颜色

            local function set_Use_Color()
                if Save.useClassColor then
                    useClassColor:SetChecked(true)
                    useCustomColor:SetChecked(false)
                    Save.useCustomColor=nil
                    local r,g,b= e.Player.r, e.Player.g, e.Player.b
                    local hex= e.RGB_to_HEX(r,g,b,1)
                    e.Player.useColor= {r=r, g=g, b=b, a=1, hex=hex}

                elseif Save.useCustomColor then
                    useClassColor:SetChecked(false)
                    useCustomColor:SetChecked(true)
                    Save.useClassColor=nil
                    e.Player.useColor= Save.useCustomColorTab
                else
                    e.Player.useColor=nil
                end
            end
            set_Use_Color()

            useClassColor.text:SetText(e.Player.col..(e.onlyChinese and '职业颜色' or COLORS))
            useClassColor:SetPoint('BOTTOMLEFT')
            useClassColor:SetScript('OnClick', function()
                Save.useClassColor= not Save.useClassColor and true or nil
                if Save.useCustomColor then
                    Save.useCustomColor=nil
                end
                set_Use_Color()
                print(id, addName, e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
            end)

            useCustomColor.text:SetText('|A:colorblind-colorwheel:0:0|a'..(e.onlyChinese and '自定义 ' or CUSTOM))
            useCustomColor:SetPoint('LEFT', useClassColor.text, 'RIGHT',2,0)
            useCustomColor:SetScript('OnClick', function()
                Save.useCustomColor= not Save.useCustomColor and true or nil
                if Save.useClassColor then
                    Save.useClassColor=nil
                end
                set_Use_Color()
                print(id, addName, e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
            end)
            useCustomColor.text:SetTextColor(Save.useCustomColorTab.r, Save.useCustomColorTab.g, Save.useCustomColorTab.b, Save.useCustomColorTab.a)
            useCustomColor.text:EnableMouse(true)
            useCustomColor.text:SetScript('OnEnter', function(self2)
                e.tips:SetOwner(self2, "ANCHOR_LEFT")
                e.tips:ClearLines()
                e.tips:AddDoubleLine(e.onlyChinese and '设置' or SETTINGS, (e.onlyChinese and '颜色' or COLOR)..e.Icon.left)
                local hex=self2.hex:gsub('|c','')
                e.tips:AddDoubleLine(format('r%.2f g%.2f b%.2f a%.2f', self2.r, self2.g, self2.b, self2.a), hex)
                e.tips:Show()
            end)
            useCustomColor.text:SetScript('OnLeave', function() e.tips:Hide() end)

            useCustomColor.text.r, useCustomColor.text.g, useCustomColor.text.b, useCustomColor.text.a, useCustomColor.text.hex= Save.useCustomColorTab.r, Save.useCustomColorTab.g, Save.useCustomColorTab.b, Save.useCustomColorTab.a, Save.useCustomColorTab.hex
            useCustomColor.text:SetScript('OnMouseDown', function(self2)
                local valueR, valueG, valueB, valueA, class, custom= self2.r, self2.g, self2.b, self2.a, Save.useClassColor, Save.useCustomColor
                local setA, setR, setG, setB, class2, custom2
                local function func()
                    e.RGB_to_HEX(setR, setG, setB, setA, self2)--RGB转HEX
                    Save.useCustomColorTab= {r=setR, g=setG, b=setB, a=setA, hex=self2.hex}
                    Save.useClassColor, Save.useCustomColor= class2, custom2
                    set_Use_Color()
                end
                e.ShowColorPicker(self2.r, self2.g, self2.b,self2.a, function()
                        setR, setG, setB, setA= e.Get_ColorFrame_RGBA()
                        class2, custom2= nil, true
                        func()
                    end, function()
                        setR, setG, setB, setA= valueR, valueG, valueB, valueA
                        class2, custom2= class, custom
                        func()
                    end
                )
            end)

            local check=CreateFrame("CheckButton", nil, panel, "InterfaceOptionsCheckButtonTemplate")--仅中文
            check:SetChecked(Save.onlyChinese)
            check.text:SetText('Chinese')
            check:SetPoint('LEFT', useCustomColor.text, 'RIGHT', 10,0)
            check:SetScript('OnMouseUp',function()
                e.onlyChinese= not e.onlyChinese and true or nil
                Save.onlyChinese = e.onlyChinese
                print(id, addName, e.GetEnabeleDisable(e.onlyChinese), '|cffff00ff', e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
            end)
            check:SetScript('OnEnter', function(self2)
                e.tips:SetOwner(self2, "ANCHOR_LEFT")
                e.tips:ClearLines()
                e.tips:AddDoubleLine(LANGUAGE..'('..SHOW..')', LFG_LIST_LANGUAGE_ZHCN)
                e.tips:AddDoubleLine('显示语言', '简体中文')
                e.tips:Show()
            end)
            check:SetScript('OnLeave', function() e.tips:Hide() end)

            local textTips= e.Cstr(panel, {justifyH='CENTER'})--nil, nil, nil, nil, nil, 'CENTER')
            textTips:SetPoint('TOP',-70,10)
            textTips:SetText('|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '启用' or ENABLE)..'|r/|cnRED_FONT_COLOR:'..(e.onlyChinese and '禁用' or DISABLE))

            if e.Player.region==1 or e.Player.region==3 then--US EU realm提示
                local realmCheck= CreateFrame("CheckButton", nil, panel, "InterfaceOptionsCheckButtonTemplate")
                realmCheck:SetPoint('LEFT', check.text, 'RIGHT',8,0)
                realmCheck:SetChecked(not Save.disabledRealm)
                realmCheck.Text:SetText(e.onlyChinese and '服务器' or 'Realm')
                realmCheck:SetScript('OnClick', function()
                    Save.disabledRealm= not Save.disabledRealm and true or nil
                    if Save.disabledRealm then
                        e.Get_Region(nil, nil, nil, true)
                        e.Get_Region=function() end
                    else
                        print(id, addName, e.GetEnabeleDisable(true), '|cffff00ff', e.onlyChinese and '需要重新加载' or REQUIRES_RELOAD)
                    end
                end)
                realmCheck:SetScript('OnLeave', function() e.tips:Hide() end)
                realmCheck:SetScript('OnEnter', function(self2)
                    e.tips:SetOwner(self2, "ANCHOR_LEFT")
                    e.tips:ClearLines()
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
                            or e.Player.region==1 and
                                {
                                    ["oce"] = {col="|cFF00FF00OCE|r", text='CE', realm="Oceanic"},
                                    ["usp"] = {col="|cFF00FFFFUSP|r", text='USP', realm="US Pacific"},
                                    ["usm"] = {col="|cFFFF00FFUSM|r", text='USM', realm="US Mountain"},
                                    ["usc"] = {col="|cFFFFFF00USC|r", text='USC', realm="US Central"},
                                    ["use"] = {col="|cFFFFBF00USE|r", text='USE', realm="US East"},
                                    ["mex"] = {col="|cFFCCCCFFMEX|r", text='MEX', realm="Mexico"},
                                    ["bzl"] = {col="|cFF8fce00BZL|r", text='BZL', realm="Brazil"},
                                }
                            or {}
                    for text, tab in pairs(tabs) do
                        e.tips:AddDoubleLine(tab.realm.. ' ('..tab.text..') '.. text, tab.col)
                    end
                    e.tips:Show()
                end)
                if Save.disabledRealm then
                    e.Get_Region(nil, nil, nil, true)
                    e.Get_Region=function() end
                end
            end

            panel:UnregisterEvent('ADDON_LOADED')
        end

    elseif event == "PLAYER_LOGOUT" then
        if e.ClearAllSave then
            WoWToolsSave=nil
            WoWDate=nil
        else
            WoWToolsSave[addName]=Save
        end
    end
end)