local id, e = ...
local addName= 'spanelSettings'
local Save={
    onlyChinese= e.Player.husandro,
    useClassColor= e.Player.husandro,--使用,职业, 颜色
    useCustomColor= nil,--使用, 自定义, 颜色
    useCustomColorTab= e.Player.useCustomColorTab,--自定义, 颜色, 表
}
local panel = CreateFrame("Frame")--Panel

panel.name = id--'|cffff00ffWoW|r|cff00ff00Tools|r'
InterfaceOptions_AddCategory(panel)

local reloadButton=CreateFrame('Button', nil, panel, 'UIPanelButtonTemplate')--重新加载UI
reloadButton:SetPoint('TOPLEFT')
reloadButton:SetSize(120, 28)
reloadButton:SetScript('OnMouseUp', e.Reload)

--##############
--Instance Panel
--##############
local instancePane= CreateFrame('Frame')
instancePane.name = '|A:poi-rift1:0:0|a'..INSTANCE
instancePane.parent =id;
InterfaceOptions_AddCategory(instancePane)

--##############
--创建, 添加控制面板
--##############
local gamePlus=e.Cstr(panel)
gamePlus:SetPoint('TOPLEFT', panel,'TOP', 0, -14)
gamePlus:SetText('Game Plus')

local lastWoW, lastGame, lastInstance
lastWoW, lastGame= reloadButton, gamePlus

e.CPanel= function(name, value, GamePlus, Instance)
    local check=CreateFrame("CheckButton", nil, Instance and instancePane or panel, "InterfaceOptionsCheckButtonTemplate")
    check.text:SetText(name)
    check:SetChecked(value)

    if Instance then--副本, 大类
        if not lastInstance then
            check:SetPoint('TOPLEFT')
            lastInstance= check
        else
            check:SetPoint('TOPLEFT', lastInstance, 'BOTTOMLEFT')
        end

    elseif GamePlus then--GamePlus, 大类
        check:SetPoint('TOPLEFT', lastGame, 'BOTTOMLEFT')
        lastGame=check

    else--WoWPlus, 大类
        check:SetPoint('TOPLEFT', lastWoW, 'BOTTOMLEFT')
        lastWoW=check
    end
    return check
end

panel:RegisterEvent('ADDON_LOADED')
panel:RegisterEvent("PLAYER_LOGOUT")

panel:SetScript("OnEvent", function(self, event, arg1)
    if event=='ADDON_LOADED' then
        if arg1==id then
            Save= WoWToolsSave and WoWToolsSave[addName] or Save
            Save.useCustomColorTab= Save.useCustomColorTab or e.Player.useCustomColorTab

            e.onlyChinese= Save.onlyChinese
            e.Player.useCustomColorTab= Save.useCustomColorTab

            local useClassColor=CreateFrame("CheckButton", nil, panel, "InterfaceOptionsCheckButtonTemplate")--使用,职业,颜色
            local useCustomColor=CreateFrame("CheckButton", nil, panel, "InterfaceOptionsCheckButtonTemplate")--使用,自定义,颜色
            local function set_Use_Color()
                if Save.useClassColor then
                    useClassColor:SetChecked(true)
                    useCustomColor:SetChecked(false)
                    Save.useCustomColor=nil
                elseif Save.useCustomColor then
                    useClassColor:SetChecked(false)
                    useCustomColor:SetChecked(true)
                    Save.useClassColor=nil
                end
                e.Player.useClassColor= Save.useClassColor
                e.Player.useCustomColor= Save.useCustomColor
            end
            set_Use_Color()
          
            useClassColor.text:SetText(e.Player.col..(e.onlyChinese and '职业颜色' or COLORS))
            useClassColor:SetPoint('BOTTOMLEFT')
            useClassColor:SetScript('OnMouseDown', function()
                Save.useClassColor= not Save.useClassColor and true or false
                Save.useCustomColor= Save.useClassColor and nil or Save.useCustomColor
                set_Use_Color()
            end)
                    
            useCustomColor.text:SetText('|A:colorblind-colorwheel:0:0|a'..(e.onlyChinese and '自定义 ' or CUSTOM))
            useCustomColor:SetPoint('LEFT', useClassColor.text, 'RIGHT',2,0)
            useCustomColor:SetScript('OnMouseDown', function()
                Save.useCustomColor= not Save.useCustomColor and true or false
                Save.useCustomColor= Save.useCustomColor and nil or Save.useCustomColor
                set_Use_Color()
            end)
            useCustomColor.text.r, useCustomColor.text.g, useCustomColor.text.b, useCustomColor.text.a= Save.useCustomColorTab.r, Save.useCustomColorTab.g, Save.useCustomColorTab.b, Save.useCustomColorTab.a
            useCustomColor.text:SetTextColor(Save.useCustomColorTab.r, Save.useCustomColorTab.g, Save.useCustomColorTab.b, Save.useCustomColorTab.a)
            useCustomColor.text:EnableMouse(true)
            useCustomColor.text:SetScript('OnEnter', function(self)
                e.tips:SetOwner(self, "ANCHOR_RIGHT")
                e.tips:ClearLines()
                e.tips:AddDoubleLine(e.onlyChinese and '设置' or SETTINGS, (e.onlyChinese and '颜色' or COLOR)..e.Icon.left)
                e.tips:Show()
            end)
            useCustomColor.text:SetScript('OnLeave', function() e.tips:Hide() end)
            useCustomColor.text:SetScript('OnMouseDown', function(self2)
                local valueR, valueG, valueB, valueA= self2.r, self2.g, self2.b, self2.a
                e.ShowColorPicker(self2.r, self2.g, self2.b,self2.a, function(restore)
                    local setA, setR, setG, setB
                    if not restore then
                        setR, setG, setB, setA= e.Get_ColorFrame_RGBA()
                    else
                        setR, setG, setB, setA= valueR, valueG, valueB, valueA
                    end
                    e.RGB_to_HEX(setR, setG, setB, setA, self2)--RGB转HEX
                    Save.useCustomColorTab= {r=setR, g=setG, b=setB, a=setA, hex=self2.hex}
                    e.Player.useCustomColorTab=Save.useCustomColorTab
                end)
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

            local restButton=CreateFrame('Button', nil, panel, 'UIPanelButtonTemplate')--全部重
            restButton:SetPoint('TOPRIGHT',3,10)
            restButton:SetSize(120, 28)
            restButton:SetScript('OnMouseUp', function()
                StaticPopupDialogs[id..'restAllSetup']={
                    text =id..'|n|n|cnRED_FONT_COLOR:'..(e.onlyChinese and '清除全部' or CLEAR_ALL)..'|r '..(e.onlyChinese and '保存' or SAVE)..'|n|n'..(e.onlyChinese and '重新加载UI' or RELOADUI)..' /reload',
                    button1 = '|cnRED_FONT_COLOR:'..(e.onlyChinese and '全部重置' or RESET_ALL_BUTTON_TEXT),
                    button2 = e.onlyChinese and '取消' or CANCEL,
                    whileDead=true,timeout=30,hideOnEscape = 1,
                    OnAccept=function()
                        e.ClearAllSave=true
                        WoWToolsSave={}
                        WoWDate={}
                        e.Reload()
                    end,
                }
                StaticPopup_Show(id..'restAllSetup')
            end)
            restButton:SetText('|cnRED_FONT_COLOR:'..(e.onlyChinese and '全部重置' or RESET_ALL_BUTTON_TEXT)..'|r')

            local textTips= e.Cstr(panel, nil, nil, nil, nil, nil, 'CENTER')
            textTips:SetPoint('TOP',-70,10)
            textTips:SetText('|cnGREEN_FONT_COLOR:'..(e.onlyChinese and '启用' or ENABLE)..'|r/|cnRED_FONT_COLOR:'..(e.onlyChinese and '禁用' or DISABLE))

            reloadButton:SetText(e.onlyChinese and '重新加载UI' or RELOADUI)

            MainMenuMicroButton:EnableMouseWheel(true)--主菜单, 打开插件选项
            MainMenuMicroButton:SetScript('OnMouseWheel', function()
                InterfaceOptionsFrame_OpenToCategory(id)
            end)

            panel:UnregisterEvent('ADDON_LOADED')
        end

    elseif event == "PLAYER_LOGOUT" then
        if e.ClearAllSave then
            WoWToolsSave={}
        else
            if not WoWToolsSave then WoWToolsSave={} end
            WoWToolsSave[addName]=Save
        end
    end
end)