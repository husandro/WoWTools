local id, e = ...

e.Panel = CreateFrame("Frame")--Panel
e.Panel.name = id
InterfaceOptions_AddCategory(e.Panel)

local btn=CreateFrame('Button', nil, e.Panel, 'UIPanelButtonTemplate')
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

local btn2=CreateFrame('Button', nil, e.Panel, 'UIPanelButtonTemplate')
btn2:SetPoint('LEFT', btn, 'RIGHT', 10, 0)
btn2:SetText('|cnRED_FONT_COLOR:'..RESET_ALL_BUTTON_TEXT..'|r')
btn2:SetSize(120, 28)
btn2:SetScript('OnClick', function()
    StaticPopup_Show(id..'restAllSetup')
end)

local lastFrame=btn

--添加控制面板
e.CPanel= function(name, value)
    local sel=CreateFrame("CheckButton", nil, e.Panel, "InterfaceOptionsCheckButtonTemplate")
    sel.Text:SetText(name)
    sel:SetPoint('TOPLEFT', lastFrame, 'BOTTOMLEFT',0,0)
    sel:SetChecked(value)
    lastFrame=sel
    return sel
end

e.Panel:RegisterEvent("PLAYER_LOGOUT")
e.Panel:SetScript("OnEvent", function(self, event, arg1)
    if event == "PLAYER_LOGOUT" and e.ClearAllSave then
        WoWToolsSave={}
    end
end)

--FrameUtil.RegisterFrameForEvents(self, table);