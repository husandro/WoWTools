local id, e = ...
local addName= 'panelSettings'
local Save={onlyChinse=e.Player.husandro}
local panel = CreateFrame("Frame")--Panel

panel.name = id--'|cffff00ffWoW|r|cff00ff00Tools|r'
InterfaceOptions_AddCategory(panel)

local reloadButton=CreateFrame('Button', nil, panel, 'UIPanelButtonTemplate')
reloadButton:SetPoint('TOPLEFT')
reloadButton:SetText(e.onlyChinse and '重新加载UI' or RELOADUI)
reloadButton:SetSize(120, 28)
reloadButton:SetScript('OnMouseDown', function()
    ReloadUI()
end)

StaticPopupDialogs[id..'restAllSetup']={
    text =id..'|n|n|cnRED_FONT_COLOR:'..CLEAR_ALL..'|r '..SAVE..'|n|n'..RELOADUI..' /reload',
    button1 = '|cnRED_FONT_COLOR:'..RESET_ALL_BUTTON_TEXT..'|r',
    button2 = CANCEL,
    whileDead=true,timeout=30,hideOnEscape = 1,
    OnAccept=function(self)
        e.ClearAllSave=true
        WoWToolsSave={}
        WoWDate={}
        ReloadUI()
    end,
}

local restButton=CreateFrame('Button', nil, panel, 'UIPanelButtonTemplate')
restButton:SetPoint('LEFT', reloadButton, 'RIGHT', 10, 0)
restButton:SetText('|cnRED_FONT_COLOR:'..(e.onlyChinse and '全部重置' or RESET_ALL_BUTTON_TEXT)..'|r')
restButton:SetSize(120, 28)
restButton:SetScript('OnMouseDown', function()
    StaticPopup_Show(id..'restAllSetup')
end)





local gamePlus=e.Cstr(panel)
gamePlus:SetPoint('TOPLEFT', panel,'TOP', 0, -14)
gamePlus:SetText('Game Plus')

local lastWoW= reloadButton
local lastGame= gamePlus
--添加控制面板
e.CPanel= function(name, value, GamePlus)
    local check=CreateFrame("CheckButton", nil, panel, "InterfaceOptionsCheckButtonTemplate")
    check.Text:SetText(name)
    check:SetChecked(value)
    if GamePlus then
        check:SetPoint('TOPLEFT', lastGame, 'BOTTOMLEFT')
        lastGame=check
    else
        check:SetPoint('TOPLEFT', lastWoW, 'BOTTOMLEFT')
        lastWoW=check
    end
    return check
end

panel:RegisterEvent('ADDON_LOADED')
panel:RegisterEvent("PLAYER_LOGOUT")

panel:SetScript("OnEvent", function(self, event, arg1)
    if event=='ADDON_LOADED' and arg1==id then

        Save= WoWToolsSave and WoWToolsSave[addName] or Save
        
        
        e.onlyChinse= Save.onlyChinse

        local check=CreateFrame("CheckButton", nil, panel, "InterfaceOptionsCheckButtonTemplate")--仅中文
        check:SetChecked(Save.onlyChinse)
        check.text:SetText('Chinse')
        check:SetPoint('TOPLEFT', restButton, 'TOPRIGHT')
        check:SetScript('OnMouseDown',function()
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

    elseif event == "PLAYER_LOGOUT" then
        if e.ClearAllSave then
            WoWToolsSave={}
        else
            if not WoWToolsSave then WoWToolsSave={} end
            WoWToolsSave[addName]=Save
        end
    end
end)