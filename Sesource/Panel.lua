local id, e = ...

local panel = CreateFrame("Frame")--Panel
panel.name = id--'|cffff00ffWoW|r|cff00ff00Tools|r'
InterfaceOptions_AddCategory(panel)

local reloadButton=CreateFrame('Button', nil, panel, 'UIPanelButtonTemplate')
reloadButton:SetPoint('TOPLEFT')
reloadButton:SetText(RELOADUI)
reloadButton:SetSize(120, 28)
reloadButton:SetScript('OnClick', function()
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
        ReloadUI()
    end,
}

local restButton=CreateFrame('Button', nil, panel, 'UIPanelButtonTemplate')
restButton:SetPoint('LEFT', reloadButton, 'RIGHT', 10, 0)
restButton:SetText('|cnRED_FONT_COLOR:'..RESET_ALL_BUTTON_TEXT..'|r')
restButton:SetSize(120, 28)
restButton:SetScript('OnClick', function()
    StaticPopup_Show(id..'restAllSetup')
end)


local gamePlus=e.Cstr(panel)
gamePlus:SetPoint('TOPLEFT', panel,'TOP', 0, -14)
gamePlus:SetText('Game Plus')

local lastWoW=reloadButton
local lastGame=gamePlus
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

panel:RegisterEvent("PLAYER_LOGOUT")
panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "PLAYER_LOGOUT" and e.ClearAllSave then
        WoWToolsSave={}
    end
end)

--FrameUtil.RegisterFrameForEvents(self, table);