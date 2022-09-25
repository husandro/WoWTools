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

--FrameUtil.RegisterFrameForEvents(self, table);