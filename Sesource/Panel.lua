local id, e = ...
local addName= 'panelSettings'
local Save={onlyChinse=e.Player.husandro}
local panel = CreateFrame("Frame")--Panel

panel.name = id--'|cffff00ffWoW|r|cff00ff00Tools|r'
InterfaceOptions_AddCategory(panel)

local reloadButton=CreateFrame('Button', nil, panel, 'UIPanelButtonTemplate')--重新加载UI
reloadButton:SetPoint('TOPLEFT')

reloadButton:SetSize(120, 28)
reloadButton:SetScript('OnMouseUp', e.Reload)



local restButton=CreateFrame('Button', nil, panel, 'UIPanelButtonTemplate')--全部重
restButton:SetPoint('LEFT', reloadButton, 'RIGHT', 10, 0)

restButton:SetSize(120, 28)
restButton:SetScript('OnMouseUp', function()
    StaticPopupDialogs[id..'restAllSetup']={
        text =id..'|n|n|cnRED_FONT_COLOR:'..(e.onlyChinse and '清除全部' or CLEAR_ALL)..'|r '..(e.onlyChinse and '保存' or SAVE)..'|n|n'..(e.onlyChinse and '重新加载UI' or RELOADUI)..' /reload',
        button1 = '|cnRED_FONT_COLOR:'..(e.onlyChinse and '全部重置' or RESET_ALL_BUTTON_TEXT),
        button2 = e.onlyChinse and '取消' or CANCEL,
        whileDead=true,timeout=30,hideOnEscape = 1,
        OnAccept=function(self)
            e.ClearAllSave=true
            WoWToolsSave={}
            WoWDate={}
            e.Reload()
        end,
    }
    StaticPopup_Show(id..'restAllSetup')
end)


--##############
--Instance Panel
--##############
local instancePane= CreateFrame('Frame')
instancePane.name = INSTANCE
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

            e.onlyChinse= Save.onlyChinse

            reloadButton:SetText(e.onlyChinse and '重新加载UI' or RELOADUI)
            restButton:SetText('|cnRED_FONT_COLOR:'..(e.onlyChinse and '全部重置' or RESET_ALL_BUTTON_TEXT)..'|r')

            local check=CreateFrame("CheckButton", nil, panel, "InterfaceOptionsCheckButtonTemplate")--仅中文
            check:SetChecked(Save.onlyChinse)
            check.text:SetText('Chinse')
            check:SetPoint('TOPLEFT', restButton, 'TOPRIGHT')
            check:SetScript('OnMouseUp',function()
                e.onlyChinse= not e.onlyChinse and true or nil
                Save.onlyChinse = e.onlyChinse
                print(id, addName, e.GetEnabeleDisable(e.onlyChinse), '|cffff00ff', e.onlyChinse and '需要重新加载' or REQUIRES_RELOAD)
            end)
            check:SetScript('OnEnter', function(self2)
                e.tips:SetOwner(self2, "ANCHOR_LEFT")
                e.tips:ClearLines()
                e.tips:AddDoubleLine(LANGUAGE..'('..SHOW..')', LFG_LIST_LANGUAGE_ZHCN)
                e.tips:AddDoubleLine('显示语言', '简体中文')
                e.tips:Show()
            end)
            check:SetScript('OnLeave', function() e.tips:Hide() end)
            panel:UnregisterEvent('ADDON_LOADED')

            local text= e.Cstr(panel, nil, nil, nil, nil, nil, 'RIGHT')
            text:SetPoint('TOPRIGHT')
            text:SetText('|cnGREEN_FONT_COLOR:'..(e.onlyChinse and '启用' or ENABLE)..'|r/|cnRED_FONT_COLOR:'..(e.onlyChinse and '禁用' or DISABLE))
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