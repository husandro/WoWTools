--总装等
local LabelPvE, LabelPvP




local function Set_Label()
    if not LabelPvP then
        return
    end

    local pve, pvp, cur
    if not WoWToolsSave['Plus_PaperDoll'].hide then
        local _
        pve, cur, pvp= GetAverageItemLevel()
        if pvp==0 or pvp==pve then
            pvp=nil
        else
            pvp= format('%i', pvp)
        end
        pve= format('%i', pve)
        if pve==0 or cur-pve<=-5 then
             pve= '|cnWARNING_FONT_COLOR:'..pve..'|r'
        end
    end
    LabelPvE:SetText(pve or '')
    LabelPvP:SetText(pvp or '')
end









local function Init()

--物品等级
    LabelPvE=WoWTools_LabelMixin:Create(PaperDollSidebarTab1, {
        justifyH='CENTER',
        mouse=true,
        name='WoWToolsPDPvELevelLabel'
    })
    LabelPvE:SetPoint('BOTTOM')


--PvP物品等级
    LabelPvP=WoWTools_LabelMixin:Create(PaperDollSidebarTab1, {
        justifyH='CENTER',
        mouse=true,
        name='WoWToolsPDPvPLevelLabel'
    })
    LabelPvP:SetPoint('TOP')





    LabelPvE:SetScript('OnMouseDown', function()
        WoWTools_DataMixin:Call('PaperDollFrame_SetSidebar', PaperDollSidebarTab1, 1)
    end)
    LabelPvE:SetScript('OnLeave', function(self)
        GameTooltip:Hide()
        self:SetAlpha(1)
    end)
    LabelPvE:SetScript('OnEnter', function(self)
        GameTooltip:SetOwner(self:GetParent(), "ANCHOR_TOPRIGHT")
        GameTooltip:SetText(CharacterStatsPane.ItemLevelFrame.tooltip)
        GameTooltip:AddLine(CharacterStatsPane.ItemLevelFrame.tooltip2)
        GameTooltip:Show()
        self:SetAlpha(0.5)
    end)




    LabelPvP:SetScript('OnMouseDown', function()
        WoWTools_DataMixin:Call('PaperDollFrame_SetSidebar', PaperDollSidebarTab1, 1)
    end)
    LabelPvP:SetScript('OnLeave', function(self)
        GameTooltip:Hide()
        self:SetAlpha(1)
    end)
    LabelPvP:SetScript('OnEnter', function(self)
        GameTooltip:SetOwner(self:GetParent(), "ANCHOR_TOPRIGHT")
        GameTooltip:SetText(CharacterStatsPane.ItemLevelFrame.tooltip)
        GameTooltip:AddLine(CharacterStatsPane.ItemLevelFrame.tooltip2)
        GameTooltip:Show()
        self:SetAlpha(0.5)
    end)

    Init=function()end
end








function WoWTools_PaperDollMixin:Init_Tab1()
    Init()
end

function WoWTools_PaperDollMixin:Settings_Tab1()
    Set_Label()
end