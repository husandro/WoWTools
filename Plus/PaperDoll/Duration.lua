--装备,总耐久度
local function Save()
    return WoWToolsSave['Plus_PaperDoll']
end










local function Init()
    if Save().notAllDurability then
        return
    end

    local Frame= CreateFrame('Frame', 'WoWToolsPaperDollAllDurationFrame', PaperDollItemsFrame)
    Frame:SetSize(1, 1)
    Frame:SetPoint('RIGHT', CharacterLevelText, 'LEFT',-2, 0)

    Frame.Text= Frame:CreateFontString(nil, 'BORDER', 'GameFontNormal') -- WoWTools_LabelMixin:Create(Frame, {copyFont=CharacterLevelText, mouse=true, size=18})
    --Frame.Text:SetHeight(22)
    Frame.Text:SetPoint('RIGHT')
    Frame.Text:EnableMouse(true)
    WoWTools_ColorMixin:SetLabelColor(Frame.Text)

    Frame.Text:SetScript('OnLeave', function(self)
        GameTooltip:Hide()
        self:SetAlpha(1)
    end)
    Frame.Text:SetScript('OnEnter', function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:SetText(WoWTools_PaperDollMixin.addName..WoWTools_DataMixin.Icon.icon2)
        GameTooltip:AddLine(' ')
        WoWTools_DurabiliyMixin:OnEnter()
        GameTooltip:Show()
        self:SetAlpha(0.3)
    end)

    function Frame:set_text()
        self.Text:SetText(WoWTools_DurabiliyMixin:Get(true))
    end

    function Frame:settings()
        if self:IsVisible() and not Save().notAllDurability then
            self:RegisterEvent('UPDATE_INVENTORY_DURABILITY')
            self:set_text()
        else
            self:UnregisterEvent('UPDATE_INVENTORY_DURABILITY')
            self.Text:SetText('')
        end
    end

    Frame:SetScript('OnShow', Frame.settings)
    Frame:SetScript('OnHide', Frame.settings)
    Frame:SetScript('OnEvent', Frame.set_text)

    Init=function()
        _G['WoWToolsPaperDollAllDurationFrame']:settings()
    end
end











function WoWTools_PaperDollMixin:Init_Duration()
    Init()
end
