--装备,总耐久度
local function Save()
    return WoWToolsSave['Plus_PaperDoll']
end
local Frame









local function Init()
    Frame= CreateFrame('Frame', nil, PaperDollItemsFrame)
    Frame:SetSize(1, 1)
    Frame:SetPoint('RIGHT', CharacterLevelText, 'LEFT')

    Frame.Text= WoWTools_LabelMixin:Create(Frame, {copyFont=CharacterLevelText, mouse=true, size=18})
    Frame.Text:SetPoint('RIGHT')
    Frame.Text:SetScript('OnLeave', function(self) GameTooltip:Hide() self:SetAlpha(1) end)
    Frame.Text:SetScript('OnEnter', function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:ClearLines()
        GameTooltip:AddDoubleLine(WoWTools_Mixin.addName, WoWTools_PaperDollMixin.addName)
        GameTooltip:AddLine(' ')
        WoWTools_DurabiliyMixin:OnEnter()
        GameTooltip:Show()
        self:SetAlpha(0.3)
    end)

    function Frame:set_text()
        self.Text:SetText(WoWTools_DurabiliyMixin:Get(true))
    end

    function Frame:settings()
        if self:IsVisible() and not Save().hide then
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
end











function WoWTools_PaperDollMixin:Init_Duration()
    Init()
end

function WoWTools_PaperDollMixin:Set_Duration()
    Frame:settings()
end
