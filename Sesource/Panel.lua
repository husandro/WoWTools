local id, e = ...

local panel = CreateFrame("Frame")--Panel
panel.name = id
InterfaceOptions_AddCategory(panel)

local btn=CreateFrame('Button', nil, panel, 'UIPanelButtonTemplate')
btn:SetPoint('TOPLEFT')
btn:SetText(RELOADUI)
btn:SetSize(120, 28)
btn:SetScript('OnClick', function()
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

local btn2=CreateFrame('Button', nil, panel, 'UIPanelButtonTemplate')
btn2:SetPoint('LEFT', btn, 'RIGHT', 10, 0)
btn2:SetText('|cnRED_FONT_COLOR:'..RESET_ALL_BUTTON_TEXT..'|r')
btn2:SetSize(120, 28)
btn2:SetScript('OnClick', function()
    StaticPopup_Show(id..'restAllSetup')
end)


local gamePlus=e.Cstr(panel)
gamePlus:SetPoint('TOPLEFT', panel,'TOP', 0, -14)
gamePlus:SetText('Game Plus')

local lastWoW=btn
local lastGame=gamePlus
--添加控制面板
e.CPanel= function(name, value, game)
    local check=CreateFrame("CheckButton", nil, panel, "InterfaceOptionsCheckButtonTemplate")
    check.Text:SetText(name)
    check:SetChecked(value)
    if game then
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